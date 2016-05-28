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

@protocol RoutePOI
@end

@interface RoutePOI : JSONModel
@property (strong, nonatomic) NSString *name;
@property (assign, nonatomic) int distance;
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
    for (id name in @[ @"highcharts", @"jquery.min", @"multicolor_series" ]) {
        NSString *srcPath = [[NSBundle mainBundle] pathForResource:name ofType:@"js" inDirectory:@"www"];
        NSString *dstPath = [NSString stringWithFormat:@"%@%@", dirPath, [srcPath lastPathComponent]];
        [fileManager copyItemAtPath:srcPath toPath:dstPath error:nil];
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self->currentLocation = [locations lastObject];
    
    // Find the closest point.
    int closest = -1;
    double closest_distance = -1;
    int idx = 0;
    for (RoutePoint* item in _route.points) {
        CLLocation* location = [[CLLocation alloc] initWithLatitude:item.latitude longitude:item.longitude];
        double distance =[location distanceFromLocation:self.currentLocation];
        if (closest_distance == -1 || distance < closest_distance) {
            closest = idx;
            closest_distance = distance;
        }
        idx += 1;
    }
    
    NSMutableArray *data = [[NSMutableArray alloc] initWithCapacity:1000];
    idx = closest;
    while (idx < [_route.points count]) {
        if (((RoutePoint*)[_route.points objectAtIndex:idx]).distance - ((RoutePoint*)[_route.points objectAtIndex:closest]).distance > 200) {
            break;
        }
        [data addObject:[_route.points objectAtIndex:idx]];
        idx += 1;
    }

    
    // Generate the html.
    NSString *rendering = [_template renderObject:@{@"data": data} error:NULL];
    NSString *path = [NSString stringWithFormat:@"%@%@", NSTemporaryDirectory(), @"gen.html"];
    NSLog(@"%@", rendering);
    [rendering writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];

    [self->_delegate handleLocation:self.currentLocation];
}

@end
