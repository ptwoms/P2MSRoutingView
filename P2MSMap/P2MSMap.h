//
//  P2MSMap.h
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 31/12/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2MSMapHelper.h"

const static CGFloat METERS_PER_MILE = 1609.344;

typedef enum {
    MAP_DISPLAY_TYPE_STANDARD,
    MAP_DISPLAY_TYPE_SATELLITE,
    MAP_DISPLAY_TYPE_HYBRID
}MAP_DISPLAY_TYPE;


@class P2MSMap;

@protocol P2MSMapDelegate <NSObject>

//longPress
- (void)handleLongPressForMap:(P2MSMap *)mapObject atCoordinate:(CLLocationCoordinate2D) coordinate;

@end

@protocol P2MSMap <NSObject>

@property (nonatomic, retain) UIView *mapView;
@property (nonatomic) MAP_DISPLAY_TYPE mapDisplayType;

@required

@property (nonatomic, weak) id<P2MSMapDelegate> delegate;

- (id)createMapViewForRect:(CGRect)rect withDefaultLocation:(CLLocationCoordinate2D)defaultLocation andZoomLevel:(CGFloat)zoomLevel inView:(UIView *)parentView;
- (void)centerMapToLatLng:(CLLocationCoordinate2D)loc;

//AnchortPoint -> (0,0) is the top-left corner of the image, and (1,1) is the bottom-right corner
- (id)drawMarkerAtLocation:(CLLocationCoordinate2D)loc withImage:(NSString *)image andAnchorPoint:(CGPoint)anchor;

- (void)moveMarker:(id)marker toLoc:(CLLocationCoordinate2D)loc;

- (void)removeMarker:(id)marker;
- (void)setMapViewNorthEast:(CLLocationCoordinate2D)northEast andSouthWest:(CLLocationCoordinate2D)southWest withEdgeInset:(UIEdgeInsets)padding;

- (void)removeMap;

- (id)drawPolyLineWithCoordinates:(NSArray *)points;
- (void)removePolyLine:(id)polyLine;


@end
