//
//  P2MSAppleMap.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 1/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSAppleMap.h"
#import "P2MSUserTrackingButton.h"
#import "Annotation.h"

@implementation P2MSAppleMap

@synthesize mapView;

- (id)createMapViewForRect:(CGRect)rect withDefaultLocation:(CLLocationCoordinate2D)defaultLocation andZoomLevel:(CGFloat)zoomLevel inView:(UIView *)parentView{
    MKMapView *appleMapView  = [[MKMapView alloc]initWithFrame:rect];
    appleMapView.showsUserLocation = YES;
    appleMapView.delegate = self;
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(defaultLocation, zoomLevel*METERS_PER_MILE, zoomLevel*METERS_PER_MILE);
    [appleMapView setRegion:viewRegion animated:YES];
    [parentView addSubview:appleMapView];
    
    P2MSUserTrackingButton *trackBtn = [[P2MSUserTrackingButton alloc]initWithMapView:appleMapView andFrame:CGRectMake(rect.size.width-40, rect.size.height-50, 30, 30)];
    [appleMapView addSubview:trackBtn];
    mapView = appleMapView;
    return appleMapView;
}

- (void)removeMap{
    [mapView removeFromSuperview];
    mapView = nil;
}

- (void)centerMapToLatLng:(CLLocationCoordinate2D)loc{
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(loc, 0.8*METERS_PER_MILE, 0.8*METERS_PER_MILE);
    [(MKMapView *)mapView setRegion:viewRegion animated:YES];
}

- (id)drawMarkerAtLocation:(CLLocationCoordinate2D)loc withImage:(NSString *)image andAnchorPoint:(CGPoint)anchor{
    Annotation *tempMarker = [[Annotation alloc]initWithCoordinate:loc];
    if (image) {
        tempMarker.imageName = image;
        CGSize imgSize = [UIImage imageNamed:image].size;
        tempMarker.anchorPoint = CGPointMake((0.5f - anchor.x)*imgSize.width, (0.5f-anchor.y)*imgSize.height);
    }
    [(MKMapView *)mapView addAnnotation:tempMarker];
    return tempMarker;
}

- (void)moveMarker:(id)marker toLoc:(CLLocationCoordinate2D)loc{
    ((Annotation *)marker).coordinate = loc;
}

- (void)removeMarker:(id)marker{
    [(MKMapView *)mapView removeAnnotation:marker];
}

- (void)setMapViewNorthEast:(CLLocationCoordinate2D)northEast andSouthWest:(CLLocationCoordinate2D)southWest withEdgeInset:(UIEdgeInsets)padding{
    BOOL isCoordinateSame = (fabs(northEast.latitude - southWest.latitude) <= MAP_DISTANCE_EPSILON &&  fabs(northEast.longitude - southWest.longitude) <= MAP_DISTANCE_EPSILON);
    if (isCoordinateSame) {
        MKCoordinateRegion region;
        region.span.latitudeDelta = 0.006;
        region.span.longitudeDelta = 0.0;
        region.center.latitude = southWest.latitude;
        region.center.longitude = southWest.longitude;
        [(MKMapView *)mapView setRegion:region animated:YES];
    }else{
        MKMapPoint leftTopMapPoint = MKMapPointForCoordinate(northEast);
        MKMapPoint bottomRightMapPoint = MKMapPointForCoordinate(southWest);
        CLLocationDegrees x = fmin(leftTopMapPoint.x, bottomRightMapPoint.x);
        CLLocationDegrees y = fmin(leftTopMapPoint.y, bottomRightMapPoint.y);
        CLLocationDegrees width = fabs(bottomRightMapPoint.x - leftTopMapPoint.x);
        CLLocationDegrees height = fabs(bottomRightMapPoint.y - leftTopMapPoint.y);
        [(MKMapView *)mapView setVisibleMapRect:MKMapRectMake( x, y, width, height) edgePadding:padding animated:YES];
    }
}

- (id)drawPolyLineWithCoordinates:(NSArray *)points{
    int count = [points count];
    CLLocationCoordinate2D *loc_ptr = malloc(sizeof(CLLocationCoordinate2D)*count);
    int i = 0;
    for (CLLocation *loc in points) {
        loc_ptr[i++] = loc.coordinate;
    }
    MKPolyline *route = [MKPolyline polylineWithCoordinates:loc_ptr count:count];
    [(MKMapView *)mapView addOverlay:route];
    free(loc_ptr);
    return route;
}

- (void)removePolyLine:(id)polyLine{
    [(MKMapView *)mapView removeOverlay:polyLine];
}

#pragma mark MapKit
- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation {
    if (![annotation isKindOfClass:[Annotation class]]) {
        return nil;
    }
    MKAnnotationView *pinView = nil;
    
    static NSString *pinID = @"AnnotationViewIdentifier";
    pinView = (MKAnnotationView *)[(MKMapView *)mapView dequeueReusableAnnotationViewWithIdentifier:pinID];
    if (pinView == nil){
        pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pinID];
    }
    Annotation *ann = annotation;
    pinView.centerOffset = ann.anchorPoint;
    pinView.image = [UIImage imageNamed:ann.imageName];
    pinView.canShowCallout = NO;
    return pinView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    MKOverlayView *overlayView = nil;
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolylineView *applePolyLineView = [[MKPolylineView alloc] initWithPolyline:overlay];
        applePolyLineView.strokeColor = [[UIColor blueColor]colorWithAlphaComponent:0.7];
        applePolyLineView.lineJoin = kCGLineJoinRound;
        applePolyLineView.lineCap = kCGLineCapRound;
        overlayView = applePolyLineView;
    }
    else if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        circleView.strokeColor = [UIColor blueColor];
        circleView.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.4];
        circleView.lineWidth = 1.0;
        overlayView = circleView;
    }
    return overlayView;
}


@end
