//
//  P2MSGoogleMap.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 31/12/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSGoogleMap.h"

@implementation P2MSGoogleMap
@synthesize mapView;

- (id)createMapViewForRect:(CGRect)rect withDefaultLocation:(CLLocationCoordinate2D)defaultLocation andZoomLevel:(CGFloat)zoomLevel inView:(UIView *)parentView{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:defaultLocation.latitude longitude:defaultLocation.longitude zoom:zoomLevel];
    GMSMapView *googleMapView = [GMSMapView mapWithFrame:rect camera:camera];
    googleMapView.myLocationEnabled = YES;
    googleMapView.delegate = self;
    googleMapView.settings.myLocationButton = YES;
    [parentView addSubview:googleMapView];
    mapView = googleMapView;
    return googleMapView;
}

- (void)removeMap{
    [mapView removeFromSuperview];
    mapView = nil;
}

- (void)centerMapToLatLng:(CLLocationCoordinate2D)loc{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:loc.latitude longitude:loc.longitude zoom:15];
    ((GMSMapView *)mapView).camera = camera;
}

- (id)drawMarkerAtLocation:(CLLocationCoordinate2D)loc withImage:(NSString *)image andAnchorPoint:(CGPoint)anchor{
    GMSMarker *tempMarker = [GMSMarker markerWithPosition:loc];
    if (image) {
        [tempMarker setIcon:[UIImage imageNamed:image]];
        tempMarker.groundAnchor = anchor;
    }
    [tempMarker setMap:(GMSMapView *)mapView];
    return tempMarker;
}


- (void)moveMarker:(id)marker toLoc:(CLLocationCoordinate2D)loc{
    ((GMSMarker *)marker).position = loc;
}

- (void)removeMarker:(id)marker{
    ((GMSMarker *)marker).map = nil;
}

- (void)setMapViewNorthEast:(CLLocationCoordinate2D)northEast andSouthWest:(CLLocationCoordinate2D)southWest withEdgeInset:(UIEdgeInsets)padding{
    BOOL isCoordinateSame = (fabs(northEast.latitude - southWest.latitude) <= MAP_DISTANCE_EPSILON &&  fabs(northEast.longitude - southWest.longitude) <= MAP_DISTANCE_EPSILON);
    if (isCoordinateSame) {
        ((GMSMapView *)mapView).camera = [GMSCameraPosition cameraWithTarget:southWest zoom:16.5];
    }else{
        GMSCameraUpdate *camera = [GMSCameraUpdate fitBounds:[[GMSCoordinateBounds alloc]initWithCoordinate:northEast coordinate:southWest] withEdgeInsets:padding];
        [(GMSMapView *)mapView animateWithCameraUpdate:camera];
    }
}

- (void)dealloc{
    NSLog(@"Googlemap Dealloc is called");
}

- (id)drawPolyLineWithCoordinates:(NSArray *)points{
    GMSMutablePath *path = [GMSMutablePath path];
    for (CLLocation *curLoc in points) {
        [path addCoordinate:[curLoc coordinate]];
    }
    GMSPolyline *route = [GMSPolyline polylineWithPath:path];
    [route setStrokeWidth:5.0f];
    ((GMSPolyline *)route).map = (GMSMapView *)mapView;
    return route;
    return nil;
}

- (void)removePolyLine:(id)polyLine{
    ((GMSPolyline *)polyLine).map = nil;
}

@end
