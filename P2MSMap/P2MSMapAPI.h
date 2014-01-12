//
//  P2MSMapAPI.h
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 31/12/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2MSNetworkRequest.h"
#import "P2MSMapHelper.h"


@protocol P2MSMapAPI <NSObject>

@required

//Geocode
- (P2MSNetworkRequest *) geocodeAddress:(NSString *)addressToDecode withNetworkDelegate:(id<NSURLConnectionDelegate>) delegate;
- (P2MSNetworkRequest *) reverseGeocodeLatLng:(CLLocationCoordinate2D)latlng withNetworkDelegate:(id<NSURLConnectionDelegate>) delegate;
- (P2MSLocationInfo *)mapGeocode:(id)responseJSON;
- (P2MSLocationInfo *)mapReverseGeocode:(id)responseJSON forLocation:(CLLocationCoordinate2D)location;

//Direction
- (P2MSNetworkRequest *) getDirectionFromLocation:(NSString *) startLoc to:(NSString *) endLoc forTravelMode:(NSString *)mode alternatives:(BOOL)alternative withNetworkDelegate:(id<NSURLConnectionDelegate>) delegate;
- (NSArray *)parseDirections:(id)responseJSON forTravelMode:(NSString *)travel_mode;

//Polyline
- (NSArray *)decodePolyLine:(id)encodedLine;

//Suggestion
- (P2MSNetworkRequest *)getLocationSuggestionsForQuery:(NSString *)queryString withCurLocation:(CLLocationCoordinate2D)curLoc withDelegate:(id<NSURLConnectionDelegate>)delegate;
- (NSArray *)parseLocationSuggestions:(id)responseJSON;
- (P2MSNetworkRequest *)getPlaceSuggestionsForQuery:(NSString *)queryString withCurLocation:(CLLocationCoordinate2D)curLoc withDelegate:(id<NSURLConnectionDelegate>)delegate;
- (NSArray *)parsePlacesSuggestions:(id)responseJSON;

//Response
- (BOOL)isResponseOK:(id)responseJSON;
- (NSString *)getResponseStatus:(id)responseJSON;
- (void)displayMessageForResponse:(id)responseJSON;

//powered by logo
- (void)showPoweredByLogo:(BOOL)show InView:(UIView *)view atPoint:(CGPoint)bottom_right_corner;
- (void)movePoweredByLogoInView:(UIView *)viewToDisplay toPoint:(CGPoint)bottom_right_corner;

@end
