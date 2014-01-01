//
//  P2MSEsriMap.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 1/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSEsriMap.h"

@implementation P2MSEsriMap

@synthesize mapView;


- (id)createMapViewForRect:(CGRect)rect withDefaultLocation:(CLLocationCoordinate2D)defaultLocation andZoomLevel:(CGFloat)zoomLevel inView:(UIView *)parentView{
    return nil;
}

- (void)removeMap{
    [mapView removeFromSuperview];
    mapView = nil;
}

- (void)centerMapToLatLng:(CLLocationCoordinate2D)loc{
}

- (id)drawMarkerAtLocation:(CLLocationCoordinate2D)loc withImage:(NSString *)image andAnchorPoint:(CGPoint)anchor{
    return nil;
}


- (void)moveMarker:(id)marker toLoc:(CLLocationCoordinate2D)loc{
}

- (void)removeMarker:(id)marker{
}

- (void)setMapViewNorthEast:(CLLocationCoordinate2D)northEast andSouthWest:(CLLocationCoordinate2D)southWest withEdgeInset:(UIEdgeInsets)padding{
}


- (id)drawPolyLineWithCoordinates:(NSArray *)points{
    return nil;
}

- (void)removePolyLine:(id)polyLine{
}


@end
