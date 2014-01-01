//
//  P2MSMapHelper.h
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 29/10/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "P2MSNetworkRequest.h"


#warning Provide your own API Access Keys
//can be same key
#define GOOGLEMAP_IOS_KEY @"" //Key for iOS apps
#define GOOGLEMAP_API_KEY @"" //Key for API Access authenticaition

#define MAP_DISTANCE_EPSILON 0.00005f

#pragma mark set your own default location here
//Default center location set to Pathein, Myanmar
//This is used when locToGo is not provided.
#define DEFAULT_LOCATION CLLocationCoordinate2DMake(16.815058, 94.700432)

@interface LocationSuggestion : NSObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *country;

@end

typedef enum {
    TRAVEL_MODE_WALKING = 10,
    TRAVEL_MODE_TRANSIT,
    TRAVEL_MODE_DRIVING,
    TRAVEL_MODE_CYCLING
}TRAVEL_MODE;

@interface OneRoute : NSObject

@property (nonatomic, retain) NSString *start_address, *end_address;
@property (nonatomic) CLLocationCoordinate2D startLoc, endLoc;
@property (nonatomic) CLLocationCoordinate2D northEast, southWest;
@property (nonatomic, retain) NSString *distance, *duration;
@property (nonatomic, retain) NSArray *travel_steps;
@property (nonatomic, retain) NSString *overview_polyline;
@property (nonatomic, retain) NSString *routeOverview;
@property (nonatomic, retain) NSString *routeOverviewTitle;
@property (nonatomic, retain) NSString *travel_mode;
@property (nonatomic, retain) NSString *viaString;

@end


@interface TravelStep : NSObject

@property (nonatomic) NSInteger level;
@property (nonatomic) CLLocationCoordinate2D startLoc, endLoc;
@property (nonatomic, retain) NSString *mode_of_travel;
@property (nonatomic, retain) NSString *distanceText, *durationText, *instruction;
@property (nonatomic, retain) NSArray *travel_steps;
@property (nonatomic) NSString *polyLine;
@end

@interface TransitTravelStep : TravelStep
@property (nonatomic, retain) NSString *transit_name;
@property (nonatomic, retain) NSString *arrivalName, *departureName, *headSign;
@property (nonatomic) int numOfStops;
@property (nonatomic, retain) NSString *vehicle_type;

@end

@interface P2MSLocationInfo : NSObject

@property (nonatomic, retain) NSString *address;
@property (nonatomic) CLLocationCoordinate2D latLng;
@property (nonatomic) CLLocationCoordinate2D northeast, southwest;

@end

@interface DriveTravelStep : TravelStep
@property (nonatomic, retain) NSString *maneuver;

@end


@interface P2MSMapHelper : NSObject

+ (P2MSNetworkRequest *)getLocationSuggestionsForQuery:(NSString *)queryString withCurLocation:(CLLocationCoordinate2D)curLoc withDelegate:(id<NSURLConnectionDelegate>)delegate;
+ (NSArray *)parseSuggestions:(NSArray *)jsonData;


+ (P2MSNetworkRequest *) getDirectionFromLocation:(NSString *) startLoc to:(NSString *) endLoc forTravelMode:(NSString *)mode alternatives:(BOOL)alternative withNetworkDelegate:(id<NSURLConnectionDelegate>)delegate;
+ (NSArray *)parseGoogleDirections:(NSArray *)routesJsonData forTravelMode:(NSString *)travel_mode;

+ (NSMutableArray *)getLocationsFromPolyLineString:(NSString *)encodedStr;

+ (P2MSNetworkRequest *)getPlaceSuggestionsForQuery:(NSString *)queryString withCurLocation:(CLLocationCoordinate2D)curLoc withDelegate:(id<NSURLConnectionDelegate>)delegate;

+ (P2MSNetworkRequest *) geoDecodeAddress:(NSString *)addressToDecode withNetworkDelegate:(id<NSURLConnectionDelegate>) delegate;

+ (P2MSLocationInfo *)googleMapGeocode:(NSArray *)results;


@end
