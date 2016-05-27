//
//  LocationService.h
//  divide-ios
//
//  Created by Arthur Kopatsy on 5/22/16.
//  Copyright © 2016 Arthur Kopatsy. All rights reserved.
//

@import CoreLocation;

@protocol LocationDelegate
- (void)handleLocation:(CLLocation*)location;
@end

@interface LocationService : NSObject <CLLocationManagerDelegate>
@property (nonatomic, retain) id<LocationDelegate> delegate;
@property (weak) CLLocation *currentLocation;
- (void)startLocationServices:(id<LocationDelegate>)delegate;
@end

