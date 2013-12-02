//
//  LocationManager.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 29/10/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "LocationManager.h"
#import "P2MSNetworkRequest.h"
#import "P2MSGlobalFunctions.h"

@implementation LocationManager
@synthesize curLoc, locationManager, started;

+ (LocationManager *)sharedInstance {
    static dispatch_once_t pred;
    __strong static LocationManager * shared_locationManager = nil;
    dispatch_once( &pred, ^{
        shared_locationManager = [[self alloc] init];
        if (shared_locationManager) {
            [shared_locationManager initWithDefault];
        }
    });
    return shared_locationManager;
}

- (void) initWithDefault{
    self.started = NO;
    first_location = YES;
    curLoc = kCLLocationCoordinate2DInvalid;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSDate* eventDate = newLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0)
    {
        curLoc = newLocation.coordinate;
        if (first_location) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"first_location" object:self];
            first_location = NO;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"change_location" object:self];
    }
}

- (void)startStandardUpdates
{
    if (started)return;
    if (nil == locationManager)
        locationManager = [[CLLocationManager alloc] init];
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = 2;
    
    if ([CLLocationManager locationServicesEnabled]){
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
            [locationManager startUpdatingLocation];
            self.started = YES;
        }
    }
}

- (void) stopStandardUpdates{
    [locationManager stopUpdatingLocation];
    self.started = NO;
}


@end
