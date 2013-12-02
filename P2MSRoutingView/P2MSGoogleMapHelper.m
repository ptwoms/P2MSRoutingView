//
//  P2MSGoogleMapHelper.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 29/10/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSGoogleMapHelper.h"

@implementation LocationSuggestion
@end

@implementation TravelStep
@end

@implementation OneRoute
@end

@implementation TransitTravelStep
@end

@implementation GeocodeResult
@end

@implementation DriveTravelStep
@end


@implementation P2MSGoogleMapHelper


+ (P2MSNetworkRequest *)getLocationSuggestionsForQuery:(NSString *)queryString withCurLocation:(CLLocationCoordinate2D)curLoc withDelegate:(id<NSURLConnectionDelegate>)delegate{
    NSString *urlToGo = @"https://maps.googleapis.com/maps/api/place/queryautocomplete/json";
    NSString *constructedQuery = nil;
    if (CLLocationCoordinate2DIsValid(curLoc)) {
        constructedQuery = [NSString stringWithFormat:@"%@?key=%@&sensor=false&input=%@&location=%f,%f&radius=15000", urlToGo, GOOGLEMAP_API_KEY, queryString, curLoc.latitude, curLoc.longitude];
    }else
        constructedQuery = [NSString stringWithFormat:@"%@?key=%@&sensor=false&input=%@", urlToGo, GOOGLEMAP_API_KEY, queryString];
    
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[constructedQuery stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    P2MSNetworkRequest *connection = [[P2MSNetworkRequest alloc]initWithRequest:request delegate:delegate];
    connection.userInfo = [NSDictionary dictionaryWithObject:@"location_suggestion" forKey:@"req_type"];
    return connection;
}


+ (P2MSNetworkRequest *)getPlaceSuggestionsForQuery:(NSString *)queryString withCurLocation:(CLLocationCoordinate2D)curLoc withDelegate:(id<NSURLConnectionDelegate>)delegate{
    NSString *urlToGo = @"https://maps.googleapis.com/maps/api/place/autocomplete/json";
    NSString *constructedQuery = nil;
    if (CLLocationCoordinate2DIsValid(curLoc)) {
        constructedQuery = [NSString stringWithFormat:@"%@?key=%@&sensor=false&input=%@&location=%f,%f&radius=15000", urlToGo, GOOGLEMAP_API_KEY, queryString, curLoc.latitude, curLoc.longitude];
    }else
        constructedQuery = [NSString stringWithFormat:@"%@?key=%@&sensor=false&input=%@", urlToGo, GOOGLEMAP_API_KEY, queryString];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[constructedQuery stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    P2MSNetworkRequest *connection = [[P2MSNetworkRequest alloc]initWithRequest:request delegate:delegate];
    connection.userInfo = [NSDictionary dictionaryWithObject:@"place_suggestion" forKey:@"req_type"];
    return connection;
}

+ (P2MSNetworkRequest *) getDirectionFromLocation:(NSString *) startLoc to:(NSString *) endLoc forTravelMode:(NSString *)mode alternatives:(BOOL)alternative withNetworkDelegate:(id<NSURLConnectionDelegate>) delegate{
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=false&mode=%@&departure_time=%.0f", startLoc, endLoc, mode, [[NSDate date] timeIntervalSince1970]];
    if (alternative) {
        [urlString appendString:@"&alternatives=true"];
    }
    NSLog(@"Direction Request %@", urlString);
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    P2MSNetworkRequest *connection = [[P2MSNetworkRequest alloc]initWithRequest:request delegate:delegate];
    connection.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"direction", mode, nil] forKeys:[NSArray arrayWithObjects:@"req_type", @"travel_mode", nil]];

    return connection;
}

+ (P2MSNetworkRequest *) geoDecodeAddress:(NSString *)addressToDecode withNetworkDelegate:(id<NSURLConnectionDelegate>) delegate{
    NSMutableString *urlString = [NSMutableString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=false", addressToDecode];
    NSLog(@"Geodecode Request %@", urlString);
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    P2MSNetworkRequest *connection = [[P2MSNetworkRequest alloc]initWithRequest:request delegate:delegate];
    connection.userInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"geocode", nil] forKeys:[NSArray arrayWithObjects:@"req_type", nil]];
    return connection;
}

+ (NSArray *)parseSuggestions:(NSArray *)jsonData{
    NSMutableArray *suggestions = [NSMutableArray array];
    for (NSDictionary *prediction in jsonData) {
        NSArray *terms = [prediction objectForKey:@"terms"];
        if (terms.count == 0)continue;
        int termCount = terms.count-1;
        LocationSuggestion *curSuggestion = [[LocationSuggestion alloc]init];
        NSMutableString *curStr = [NSMutableString string];
        for (int i = 0; i < termCount; i++) {
            NSDictionary *curTerm = [terms objectAtIndex:i];
            if (curStr.length > 0) {
                [curStr appendString:@" "];
            }
            [curStr appendString:[curTerm objectForKey:@"value"]];
        }
        if (curStr.length > 0) {
            curSuggestion.name = curStr;
            NSDictionary *curTerm = [terms objectAtIndex:termCount];
            curSuggestion.country = [curTerm objectForKey:@"value"];
        }else{
            NSDictionary *curTerm = [terms objectAtIndex:termCount];
            curSuggestion.name = [curTerm objectForKey:@"value"];
        }
        [suggestions addObject:curSuggestion];
    }
    return suggestions;
}


+ (NSArray *)parseGoogleDirections:(NSArray *)routesJsonData forTravelMode:(NSString *)travel_mode{
    NSMutableArray *finalArray = [NSMutableArray array];
    for (NSDictionary *one_direction in routesJsonData) {
        OneRoute *oneRoute = [[OneRoute alloc]init];
        oneRoute.overview_polyline = [[one_direction objectForKey:@"overview_polyline"] objectForKey:@"points"];
        
        NSDictionary *bounds = [one_direction objectForKey:@"bounds"];
        NSDictionary *tempDict = [bounds objectForKey:@"northeast"];
        oneRoute.northEast = CLLocationCoordinate2DMake([[tempDict objectForKey:@"lat"]floatValue], [[tempDict valueForKey:@"lng"]floatValue]);
        tempDict = [bounds objectForKey:@"southwest"];
        oneRoute.southWest = CLLocationCoordinate2DMake([[tempDict valueForKey:@"lat"]floatValue], [[tempDict valueForKey:@"lng"]floatValue]);

        oneRoute.travel_mode = travel_mode;
        NSDictionary *legs = [[one_direction objectForKey:@"legs"]objectAtIndex:0];
        oneRoute.distance = [[legs objectForKey:@"distance"]objectForKey:@"text"];
        oneRoute.duration = [[legs objectForKey:@"duration"]objectForKey:@"text"];
        oneRoute.start_address = [legs objectForKey:@"start_address"];
        oneRoute.end_address = [legs objectForKey:@"end_address"];

        tempDict = [legs objectForKey:@"start_location"];
        oneRoute.startLoc = CLLocationCoordinate2DMake([[tempDict valueForKey:@"lat"]floatValue], [[tempDict valueForKey:@"lng"]floatValue]);
        tempDict = [legs objectForKey:@"end_location"];
        oneRoute.endLoc = CLLocationCoordinate2DMake([[tempDict valueForKey:@"lat"]floatValue], [[tempDict valueForKey:@"lng"]floatValue]);

        NSMutableArray *toArray = [NSMutableArray array];
        [P2MSGoogleMapHelper convertSteps:&toArray fromSteps:[legs objectForKey:@"steps"] withLevel:0 withMainRoute:&oneRoute];
        if ([travel_mode isEqualToString:@"transit"]) {
            NSString *departureTime = [[legs objectForKey:@"departure_time"]objectForKey:@"text"];
            NSString *arrivalTime = [[legs objectForKey:@"arrival_time"]objectForKey:@"text"];
            if (departureTime && arrivalTime) {
                oneRoute.routeOverviewTitle = [NSString stringWithFormat:@"%@ - %@ (%@)", departureTime, arrivalTime, oneRoute.duration];
            }else
                oneRoute.routeOverviewTitle = oneRoute.duration;
                
        }else{
            oneRoute.routeOverview = [NSString stringWithFormat:@"via %@", [one_direction objectForKey:@"summary"]];
            oneRoute.routeOverviewTitle = [NSString stringWithFormat:@"%@ (%@)", oneRoute.duration, oneRoute.distance];
        }
        oneRoute.travel_steps = toArray;
        [finalArray addObject:oneRoute];
    }
    return finalArray;
}


+ (void) convertSteps:(NSMutableArray **) toArrayA fromSteps:(NSArray *)steps withLevel:(NSInteger) curLvl withMainRoute:(OneRoute **)toRoute{
    OneRoute *mainRoute = *toRoute;
    NSMutableString *overviewSteps = nil;
    int my_count = [steps count];
    NSMutableArray *toArray = *toArrayA;
    for (int i = 0; i < my_count ; i++) {
        NSDictionary *cur_step = [steps objectAtIndex:i];
        NSString *travelMode = [cur_step objectForKey:@"travel_mode"];
        
        TravelStep *one_step;
        BOOL isTransit = [travelMode isEqualToString:@"TRANSIT"];
        
        if (isTransit) {
            one_step = [[TransitTravelStep alloc]init];
            TransitTravelStep *transitStep = (TransitTravelStep *)one_step;
            NSDictionary *transitDetail = [cur_step objectForKey:@"transit_details"];
            NSDictionary *line_detail = [transitDetail objectForKey:@"line"];
            NSString *transitName = [line_detail objectForKey:@"short_name"];
            if (!transitName) {
                transitName = [line_detail objectForKey:@"name"];
            }
            transitStep.transit_name = transitName;
            transitStep.headSign = [transitDetail objectForKey:@"headsign"];
            transitStep.arrivalName = [[transitDetail objectForKey:@"arrival_stop"]objectForKey:@"name"];
            transitStep.departureName = [[transitDetail objectForKey:@"departure_stop"]objectForKey:@"name"];
            transitStep.numOfStops = [[transitDetail objectForKey:@"num_stops"]intValue];
            transitStep.vehicle_type = [[line_detail objectForKey:@"vehicle"]objectForKey:@"type"];
            one_step.instruction = [NSString stringWithFormat:@"%@ towards %@", transitStep.transit_name, transitStep.headSign];
        }else{
            one_step = [[TravelStep alloc]init];
            if ([mainRoute.travel_mode isEqualToString:@"transit"] && curLvl == 0) {
                if ([travelMode isEqualToString:@"WALKING"]) {
                    one_step.instruction = @"Walk";
                }else
                    one_step.instruction = travelMode;
            }else{
                NSString *tempStr = [cur_step objectForKey:@"html_instructions"];
                NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"<div.*?</div>|<.*?>"                                                                                    options:0 error:NULL];
                one_step.instruction = [re stringByReplacingMatchesInString:tempStr options:0 range:NSMakeRange(0, [tempStr length]) withTemplate:@""];
            }
        }
        one_step.mode_of_travel = travelMode;
        CLLocationCoordinate2D tempLoc;
        NSDictionary *end_pos = [cur_step objectForKey:@"end_location"];
        tempLoc.latitude = [[end_pos objectForKey:@"lat"] floatValue];
        tempLoc.longitude = [[end_pos objectForKey:@"lng"] floatValue];
        one_step.endLoc = tempLoc;
        NSDictionary *st_pos = [cur_step objectForKey:@"start_location"];
        tempLoc.latitude = [[st_pos valueForKey:@"lat"]floatValue];
        tempLoc.longitude = [[st_pos objectForKey:@"lng"] floatValue];
        one_step.startLoc = tempLoc;
        one_step.level = curLvl;
        one_step.mode_of_travel = travelMode;
        
        
        if (curLvl == 0) {
            if (overviewSteps) {
                [overviewSteps appendString:@"##"];
            }else{
                overviewSteps = [NSMutableString string];
            }
            if (isTransit) {
                TransitTravelStep *transitStep = (TransitTravelStep *)one_step;
                [overviewSteps appendFormat:@"%@#%@#%@", @"TRANSIT", transitStep.vehicle_type, transitStep.transit_name];
                if (!(*toRoute).viaString) {
                    (*toRoute).viaString = [NSString stringWithFormat:@" via: %@", transitStep.departureName];
                }
            }else
                [overviewSteps appendFormat:@"%@", one_step.mode_of_travel];
        }
        one_step.durationText = [[cur_step objectForKey:@"duration"] objectForKey:@"text"];
        one_step.distanceText = [[cur_step objectForKey:@"distance"] objectForKey:@"text"];
        [toArray addObject:one_step];
        
        NSArray *inside_steps = [cur_step objectForKey:@"steps"];
        if (inside_steps && [inside_steps count] > 1) {
            NSMutableArray *insideArr = [NSMutableArray arrayWithCapacity:inside_steps.count];
            [self convertSteps:&insideArr fromSteps:inside_steps withLevel:curLvl+1 withMainRoute:toRoute];
            one_step.travel_steps = insideArr;
        }
    }
    if (overviewSteps) {
        (*toRoute).routeOverview = overviewSteps;
    }
}

+ (NSMutableArray *)getLocationsFromPolyLineString:(NSString *)encodedStr{
    NSString *encoded = encodedStr;
    NSInteger len = [encoded length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 32);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encoded characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 32);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        CGFloat latValue = lat * 1e-5;
        CGFloat lngValue = lng * 1e-5;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:latValue];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lngValue];
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

+ (GeocodeResult *)googleMapGeocode:(NSArray *)results{
    if (!results.count) {
        return nil;
    }
    NSDictionary *firstResult = [results objectAtIndex:0];
    GeocodeResult *geoResult = [GeocodeResult new];
    geoResult.address = [firstResult objectForKey:@"formatted_address"];
    NSDictionary *geoDict = [firstResult objectForKey:@"geometry"];
    NSDictionary *locDict = [geoDict objectForKey:@"location"];
    geoResult.latLng = CLLocationCoordinate2DMake([[locDict objectForKey:@"lat"]floatValue], [[locDict objectForKey:@"lng"]floatValue]);
    NSDictionary *boundsDict = [geoDict objectForKey:@"viewport"];
    NSDictionary *tempBdDict = [boundsDict objectForKey:@"northeast"];
    geoResult.northeast = CLLocationCoordinate2DMake([[tempBdDict objectForKey:@"lat"]floatValue], [[tempBdDict objectForKey:@"lng"]floatValue]);
    tempBdDict = [boundsDict objectForKey:@"southwest"];
    geoResult.southwest = CLLocationCoordinate2DMake([[tempBdDict objectForKey:@"lat"]floatValue], [[tempBdDict objectForKey:@"lng"]floatValue]);
    return geoResult;
}



@end
