//
//  P2MSOneMapAPI.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 1/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSOneMapAPI.h"

@implementation P2MSOneMapAPI

- (P2MSNetworkRequest *) geoDecodeAddress:(NSString *)addressToDecode withNetworkDelegate:(id<NSURLConnectionDelegate>) delegate{
//    connection.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"geocode", nil] forKeys:[NSArray arrayWithObjects:@"req_type", nil]];
    return nil;
}

- (P2MSLocationInfo *)mapGeocode:(id)responseJSON{
    return nil;
}


- (P2MSNetworkRequest *) getDirectionFromLocation:(NSString *) startLoc to:(NSString *) endLoc forTravelMode:(NSString *)mode alternatives:(BOOL)alternative withNetworkDelegate:(id<NSURLConnectionDelegate>) delegate{
//        connection.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"direction", mode, nil] forKeys:[NSArray arrayWithObjects:@"req_type", @"travel_mode", nil]];
    return nil;
}

- (NSArray *)parseDirections:(id)responseJSON forTravelMode:(NSString *)travel_mode{
    return nil;
}

- (P2MSNetworkRequest *)getLocationSuggestionsForQuery:(NSString *)queryString withCurLocation:(CLLocationCoordinate2D)curLoc withDelegate:(id<NSURLConnectionDelegate>)delegate{
//    connection.userInfo = [NSDictionary dictionaryWithObject:@"location_suggestion" forKey:@"req_type"];
    return nil;
}

- (NSArray *)parseLocationSuggestions:(id)responseJSON{
    return nil;
}


- (P2MSNetworkRequest *)getPlaceSuggestionsForQuery:(NSString *)queryString withCurLocation:(CLLocationCoordinate2D)curLoc withDelegate:(id<NSURLConnectionDelegate>)delegate{
//    connection.userInfo = [NSDictionary dictionaryWithObject:@"place_suggestion" forKey:@"req_type"];
    return nil;
}

- (NSArray *)parsePlacesSuggestions:(id)jsonData{
    return nil;
}

- (NSArray *)decodePolyLine:(id)encodedLine{
    return nil;
}

- (BOOL)isResponseOK:(id)responseJSON{
    return NO;
}

- (NSString *)getResponseStatus:(id)responseJSON{
    return @"Not implemented";
}

- (void)displayMessageForResponse:(id)responseJSON{
}

- (void)showPoweredByLogo:(BOOL)show InView:(UIView *)view atPoint:(CGPoint)bottom_right_corner{
    
}

- (void)movePoweredByLogoInView:(UIView *)viewToDisplay toPoint:(CGPoint)bottom_right_corner{
    
}

@end
