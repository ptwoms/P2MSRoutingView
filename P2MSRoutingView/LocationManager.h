//
//  LocationManager.h
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 29/10/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "P2MSNetworkRequest.h"


@interface LocationManager : NSObject<CLLocationManagerDelegate>{
    CLLocationManager *locationManager;
    CLLocationCoordinate2D curLoc;
    BOOL started, first_location;
}

+ (LocationManager *)sharedInstance;
- (void) initWithDefault;

@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic)CLLocationCoordinate2D curLoc;
@property (nonatomic) BOOL started;

- (void)startStandardUpdates;
- (void) stopStandardUpdates;

@end
