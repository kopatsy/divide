//
//  LocationService.m
//  divide-ios
//
//  Created by Arthur Kopatsy on 5/22/16.
//  Copyright © 2016 Arthur Kopatsy. All rights reserved.
//

#import "LocationService.h"
#import "GRMustache.h"
#import "JSONModel.h"

#define METERS_TO_MILES 0.000621371192

@protocol RoutePointColor
@end

@interface RoutePointColor : JSONModel
@property (nonatomic, assign) int red;
@property (nonatomic, assign) int green;
@property (nonatomic, assign) int blue;
@end

@implementation RoutePointColor
@end

@protocol RoutePoint
@end

@interface RoutePoint : JSONModel
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (nonatomic, assign) float grade;
@property (nonatomic, assign) float distance;
@property (nonatomic, strong) RoutePointColor *color;
@property (nonatomic, assign) int elevation;
@property (nonatomic, assign) int total_elevation;
@end

@implementation RoutePoint
@end

@protocol RoutePlace
@end

@interface RoutePlace : JSONModel
@property (strong, nonatomic) NSString *name;
@property (nonatomic, strong) NSString<Optional> *note;
@property (nonatomic, strong) NSString<Optional> *address;
@property (nonatomic, strong) NSString<Optional> *hours;
@property (nonatomic, strong) NSString<Optional> *phone;
@end

@implementation RoutePlace
@end

@protocol RoutePOI
@end

@interface RoutePOI : JSONModel
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) int distance;
@property (assign, nonatomic) int acc_elevation;
@property (nonatomic, strong) NSString<Optional> *note;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) float offroute_distance;
@property (strong, nonatomic) NSArray<RoutePlace>* places;
@end

@implementation RoutePOI
@end

@interface RouteInfo : JSONModel
@property (strong, nonatomic) NSArray<RoutePoint>* points;
@property (strong, nonatomic) NSArray<RoutePOI>* pois;
@end

@implementation RouteInfo
@end

@implementation LocationService
@synthesize currentLocation;

CLLocationManager *_locationManager;
GRMustacheTemplate *_template;
RouteInfo *_route;

- (void)startLocationServices:(id)aDelegate {
    _delegate = aDelegate;
    
    // Parse JSON data.
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"course" ofType:@"json" inDirectory:@"www"];
    NSError *error = nil;
    NSData *JSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    
    NSError* err = nil;
    _route = [[RouteInfo alloc] initWithData:JSONData error:&err];
    
    // Setup location manager.
    NSLog(@"%d", [CLLocationManager authorizationStatus]);
    
    _locationManager = [[CLLocationManager alloc] init];
    _locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    _locationManager.distanceFilter = 250; // meters.
    _locationManager.delegate = self;
    
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"Location services is enabled");
        [_locationManager startUpdatingLocation];
    } else {
        NSLog(@"Location services is not enabled");
    }
    
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager startUpdatingLocation];
    
    // Parse template once.
    _template = [GRMustacheTemplate templateFromResource:@"Profile" bundle:nil error:nil];
    
    // Generate a directory with JS files.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *dirPath = NSTemporaryDirectory();
    for (id fullFileName in @[ @"highcharts.js", @"jquery.min.js", @"multicolor_series.js", @"bootstrap.min.css", @"bootstrap-theme.min.css", @"bootstrap.min.js", @"bootstrap.min.css.map", @"bootstrap-theme.min.css.map"]) {
        NSString* fileName = [[fullFileName lastPathComponent] stringByDeletingPathExtension];
        NSString* extension = [fullFileName pathExtension];
        NSString *srcPath = [[NSBundle mainBundle] pathForResource:fileName ofType:extension inDirectory:@"www"];
        NSString *dstPath = [NSString stringWithFormat:@"%@%@", dirPath, [srcPath lastPathComponent]];
        [fileManager copyItemAtPath:srcPath toPath:dstPath error:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self->currentLocation = [locations lastObject];
    
    int displayed_distance = 200;
    
    // Find the closest point.
    int closest = -1;
    double distance_to_route = -1;
    int idx = 0;
    int current_distance = 0;
    int current_total_elevation = 0;
    for (RoutePoint* item in _route.points) {
        CLLocation* location = [[CLLocation alloc] initWithLatitude:item.latitude longitude:item.longitude];
        double distance =[location distanceFromLocation:self.currentLocation];
        if (distance_to_route == -1 || distance < distance_to_route) {
            closest = idx;
            distance_to_route = distance;
            current_distance = item.distance;
            current_total_elevation = item.total_elevation;
        }
        idx += 1;
    }
    
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:1000];
    idx = closest;
    while (idx < [_route.points count]) {
        if (((RoutePoint*)[_route.points objectAtIndex:idx]).distance - ((RoutePoint*)[_route.points objectAtIndex:closest]).distance > displayed_distance) {
            break;
        }
        [data addObject:[_route.points objectAtIndex:idx]];
        idx += 1;
    }
    
    
    NSMutableArray *pois = [[NSMutableArray alloc] initWithCapacity:10];
    for (RoutePOI* poi in _route.pois) {
        if (poi.distance >= current_distance && poi.distance < current_distance + displayed_distance) {
            NSString *offroute = @"";
            if (poi.offroute_distance) {
                offroute = [NSString stringWithFormat:@"%.1f", poi.offroute_distance];
            }
            
            [pois addObject:@{
                              @"name": poi.name,
                              @"distance": [NSNumber numberWithInt:poi.distance],
                              @"distance_togo": [NSNumber numberWithInt:(poi.distance - current_distance)],
                              @"elevation_togo": [NSNumber numberWithInt:(poi.acc_elevation - current_total_elevation)],
                              @"details": poi,
                              @"offroute": offroute,
                              @"index": [NSNumber numberWithLong:[pois count]] // To be able to name sections by index in mustache (don't know how to enumerate).
                            }];
        }
    }

    // Generate the html.
    NSString *rendering = [_template renderObject:@{@"data": data, @"pois": pois, @"offroute": [NSNumber numberWithInt:distance_to_route * METERS_TO_MILES], @"distance": [NSNumber numberWithInt:current_distance]} error:NULL];
    NSString *path = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"gen.html"];
    NSLog(@"%@", path);
    [rendering writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];

    [self->_delegate handleLocation:self.currentLocation];
}

@end
