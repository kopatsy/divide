//
//  LocationService.m
//  divide-ios
//
//  Created by Arthur Kopatsy on 5/22/16.
//  Copyright © 2016 Arthur Kopatsy. All rights reserved.
//

#import "LocationService.h"

@implementation LocationService
@synthesize currentLocation;

CLLocationManager *_locationManager;

- (void)startLocationServices:(id)aDelegate {
    _delegate = aDelegate;
    
    // Parse JSON data.
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"course" ofType:@"json" inDirectory:@"www"];
    NSError *error = nil;
    NSData *JSONData = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    
    NSDictionary *JSONObject = (NSDictionary*)[NSJSONSerialization
                                               JSONObjectWithData:JSONData
                                               options:NSJSONReadingAllowFragments
                                               error:&error];
    
    
    NSLog(@"%@", JSONObject[@"pois"]);
    
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
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    self->currentLocation = [locations lastObject];
    
    // Generate the html.
    
    [self->_delegate handleLocation:self.currentLocation];
}



@end
