//
//  LocationService.h
//  divide-ios
//
//  Created by Arthur Kopatsy on 5/22/16.
//  Copyright © 2016 Arthur Kopatsy. All rights reserved.
//

@import CoreLocation;

@interface LocationService : NSObject <CLLocationManagerDelegate> {
    CLLocation *currentLocation;
}

//@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) CLLocation *currentLocation;

- (void)startLocationServices;

@end
