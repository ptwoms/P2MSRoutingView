//
//  P2MSMapViewController.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 29/10/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSMapViewController.h"
#import "LocationManager.h"
#import "P2MSGlobalFunctions.h"
#import "P2MSDirectionView.h"
#import "P2MSShadowView.h"
#import "UIView+P2MSShadowCategory.h"
#import "P2MSSearchBar.h"
#import "JSONKit.h"
#import "Annotation.h"
#import "P2MSUserTrackingButton.h"

@interface P2MSMapViewController (){
    UIView *mapView;
    id currentRoute;
    MKPolylineView *applePolyLineView;
    
    NSArray *allRoutes;
    id endMarker;
    id positionIndicator, positionIndicatorEnd;
    int lastPageIndex;
    
    UIView *pannedInfoView;
    UIScrollView *mainScrollView;
    CGPoint panGestureOrigin, translatedOrigin;
    BOOL isPannedViewOverlapped;
    
    BOOL isGestureRecognizerOverlapped;
    BOOL tableViewScrollEnable;
    BOOL isPanned;
    CGFloat topPadding;
    
    NSMutableIndexSet *selectedIndexes;
    CGFloat panViewVisibleHeight;
    
    P2MSSearchDisplayViewController *searchController;
    NSArray *allSuggestions;
    P2MSNetworkRequest *curRequest;
    NSString *nextTextToSearch;
    NSMutableData *receivedData;
    GeocodeResult *geocodeResult;
    BOOL statusBarHidden;
    
    PAN_VIEW_TYPE panViewType;
    
    UIView *routeView;
    NSString *startAddress, *endAddress, *startLocDescription, *endLocDescription;
    NSInteger travel_mode_index;
}

//@property (nonatomic, retain) NSString *locationNameToGo;
//@property (nonatomic) CLLocationCoordinate2D locToGo;

@end

@implementation P2MSMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        travel_mode_index = -1;
        isGestureRecognizerOverlapped = NO;
        tableViewScrollEnable = YES;
        panViewType = PAN_VIEW_NONE;
        _mapType = MAP_TYPE_GOOGLE;
    }
    return self;
}

- (void)setDefaultLocation:(NSString *)locNameToGo withCoordinate:(CLLocationCoordinate2D)locToGo{
    if (!geocodeResult) {
        geocodeResult = [[GeocodeResult alloc]init];
    }
    geocodeResult.address = (locNameToGo)?locNameToGo:[NSString stringWithFormat:@"%f,%f", locToGo.latitude, locToGo.longitude];
    geocodeResult.latLng = locToGo;
    CGFloat deltaValue = 0.4*METERS_PER_MILE;
    geocodeResult.southwest = CLLocationCoordinate2DMake(locToGo.latitude  + deltaValue, locToGo.longitude  + deltaValue);
    geocodeResult.northeast = CLLocationCoordinate2DMake(locToGo.latitude  - deltaValue, locToGo.longitude  - deltaValue);
}

- (void)showRouteInfoViewForTravelMode:(NSString *)travel_mode{
    CGSize curSize = self.view.bounds.size;
    if (!routeView) {
        routeView = [[UIView alloc]initWithFrame:CGRectMake(10, 5+topPadding, curSize.width-20, 52)];
        routeView.layer.cornerRadius = 6;
        [routeView setShadowForOffset:CGSizeMake(0, 1) withRadius:2];
        routeView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        routeView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:routeView];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
        cancelBtn.frame = CGRectMake(curSize.width-47, 16, 20, 20);
        cancelBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        cancelBtn.backgroundColor = [UIColor clearColor];
        [cancelBtn addTarget:self action:@selector(removeCurrentRouteResult:) forControlEvents:UIControlEventTouchUpInside];
        [routeView addSubview:cancelBtn];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(8, 16, 25, 20)];
        imageView.tag = 1;
        [routeView addSubview:imageView];
        
        UILabel *fromLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 10, 35, 15)];
        fromLabel.backgroundColor = [UIColor clearColor];
        fromLabel.textColor = [UIColor grayColor];
        fromLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        fromLabel.font = [UIFont systemFontOfSize:13];
        fromLabel.text = @"From";
        [routeView addSubview:fromLabel];
        
        UILabel *fromText = [[UILabel alloc]initWithFrame:CGRectMake(78, 10, curSize.width-128, 15)];
        fromText.backgroundColor = [UIColor clearColor];
        fromText.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        fromText.tag = 2;
        fromText.font = [UIFont systemFontOfSize:13];
        [routeView addSubview:fromText];
        
        UILabel *toLabel = [[UILabel alloc]initWithFrame:CGRectMake(40, 27, 20, 15)];
        toLabel.backgroundColor = [UIColor clearColor];
        toLabel.textColor = [UIColor grayColor];
        toLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        toLabel.font = [UIFont systemFontOfSize:13];
        toLabel.text = @"To";
        [routeView addSubview:toLabel];
        
        UILabel *toText = [[UILabel alloc]initWithFrame:CGRectMake(60, 27, curSize.width-110, 15)];
        toText.backgroundColor = [UIColor clearColor];
        toText.tag = 3;
        toText.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        toText.font = [UIFont systemFontOfSize:13];
        [routeView addSubview:toText];
        
        UIButton *invisibleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        invisibleButton.frame = CGRectMake(0, 0, curSize.width-42, routeView.frame.size.height);
        [invisibleButton addTarget:self action:@selector(showRoutingView:) forControlEvents:UIControlEventTouchUpInside];
        [routeView addSubview:invisibleButton];
    }
    UIImageView *imgView = (UIImageView *)[routeView viewWithTag:1];
    if ([travel_mode isEqualToString:@"transit"]) {
        [imgView setImage:[UIImage imageNamed:@"bus"]];
    }else if([travel_mode isEqualToString:@"driving"]){
        [imgView setImage:[UIImage imageNamed:@"car"]];
    }else{//walking
        [imgView setImage:[UIImage imageNamed:@"walk"]];
    }
    UILabel *fromLabel = (UILabel *)[routeView viewWithTag:2];
    fromLabel.text = startAddress;
    UILabel *toLabel = (UILabel *)[routeView viewWithTag:3];
    toLabel.text = endAddress;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    allRoutes = nil;
    lastPageIndex = -1;
    
    if (_mapType == MAP_TYPE_GOOGLE && ![P2MSGlobalFunctions sharedInstance].isIOS_5_OR_LATER) {
        _mapType = MAP_TYPE_APPLE;
    }
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    topPadding = [P2MSGlobalFunctions sharedInstance].isIOS_7_OR_LATER*20;

    [[LocationManager sharedInstance]startStandardUpdates];
    selectedIndexes = [NSMutableIndexSet indexSet];
    
    CGSize curSize = self.view.bounds.size;
    [self initMapView];
    
    P2MSSearchBar *searchBar = [[P2MSSearchBar alloc]initWithFrame:CGRectMake(10, 5 + topPadding, curSize.width-20, 38)];
    searchBar.delegate = self;
    [searchBar setShadowForOffset:CGSizeMake(0, 1) withRadius:2];
    [self.view addSubview:searchBar];
    
    searchController = [[P2MSSearchDisplayViewController alloc]initWithSearchBar:searchBar contentsController:self];
    searchController.delegate = self;
    searchController.searchResultsDataSource = self;
    searchController.searchResultsDelegate = self;

    [self addRouteButtonToSearchBar];
}


- (void)initMapView{
    CLLocationCoordinate2D locToDisplay;
    
    //use the category provided in http://troybrant.net/blog/2010/01/set-the-zoom-level-of-an-mkmapview/, if you want to set the same zoom level for MapKit as Google
    CGFloat mapKitZoom = 0.8, googlMapZoom = 15;
    if (CLLocationCoordinate2DIsValid(geocodeResult.latLng)) {
        locToDisplay = geocodeResult.latLng;
    }else{
        locToDisplay = DEFAULT_LOCATION;
        mapKitZoom = 9000;
        googlMapZoom = 2;
    }
    if (_mapType == MAP_TYPE_GOOGLE) {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:locToDisplay.latitude longitude:locToDisplay.longitude zoom:googlMapZoom];
        mapView = [GMSMapView mapWithFrame:self.view.bounds camera:camera];
        GMSMapView *googleMapView = (GMSMapView *)mapView;
        googleMapView.myLocationEnabled = YES;
        googleMapView.delegate = self;
        googleMapView.settings.myLocationButton = YES;
        [self.view addSubview:googleMapView];
    }else{
        mapView = [[MKMapView alloc]initWithFrame:self.view.bounds];
        MKMapView *appleMapView = (MKMapView *)mapView;
        ((MKMapView *)mapView).showsUserLocation = YES;
        ((MKMapView *)mapView).delegate = self;
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(locToDisplay, mapKitZoom*METERS_PER_MILE, mapKitZoom*METERS_PER_MILE);
        [appleMapView setRegion:viewRegion animated:YES];
        [self.view addSubview:mapView];
        
        P2MSUserTrackingButton *trackBtn = [[P2MSUserTrackingButton alloc]initWithMapView:(MKMapView *)mapView andFrame:CGRectMake(self.view.bounds.size.width-40, self.view.bounds.size.height-50, 30, 30)];
        [mapView addSubview:trackBtn];
        
    }
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self createEndMarkerForCoordinate:geocodeResult.latLng];
}

- (void)centerMapToLatLng:(CLLocationCoordinate2D)loc showPin:(BOOL)show{
    if (_mapType == MAP_TYPE_GOOGLE) {
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:loc.latitude longitude:loc.longitude zoom:15];
        ((GMSMapView *)mapView).camera = camera;
        if (show) {
            if (!positionIndicator) {
                positionIndicator = [GMSMarker markerWithPosition:loc];
                [((GMSMarker *)positionIndicator) setIcon:[UIImage imageNamed:@"pin_green"]];
                ((GMSMarker *)positionIndicator).groundAnchor = CGPointMake(0.5, 1);
                [positionIndicator setMap:(GMSMapView *)mapView];
            }else{
                ((GMSMarker *)positionIndicator).position = loc;
            }
        }else if(positionIndicator){
            ((GMSMarker *)positionIndicator).map = nil;
            positionIndicator = nil;
        }
        if (positionIndicatorEnd) {
            ((GMSMarker *)positionIndicatorEnd).map = nil;
            positionIndicatorEnd = nil;
        }
    }else{
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(loc, 0.8*METERS_PER_MILE, 0.8*METERS_PER_MILE);
        [(MKMapView *)mapView setRegion:viewRegion animated:YES];
        if (show) {
            if (positionIndicator) {
                ((Annotation *)positionIndicator).coordinate = loc;
            }else{
                positionIndicator =[[Annotation alloc] initWithCoordinate:loc];
                ((Annotation *)positionIndicator).type = 'g';
                [(MKMapView *)mapView addAnnotation:positionIndicator];
            }
        }else if(positionIndicator){
            [(MKMapView *)mapView removeAnnotation:positionIndicator];positionIndicator = nil;
        }
        [(MKMapView *)mapView removeAnnotation:positionIndicatorEnd];positionIndicatorEnd = nil;
    }
}

- (void)centerMapToCurLoc{
    if (CLLocationCoordinate2DIsValid([LocationManager sharedInstance].curLoc)) {
        [self centerMapToLatLng:[LocationManager sharedInstance].curLoc showPin:NO];
    }
}

- (void)createEndMarkerForCoordinate:(CLLocationCoordinate2D)endMarkerCoordinate{
    if (CLLocationCoordinate2DIsValid(endMarkerCoordinate)) {
        if (_mapType == MAP_TYPE_GOOGLE) {
            if (!endMarker) {
                endMarker = [[GMSMarker alloc] init];
                [endMarker setMap:(GMSMapView *)mapView];
            }
            ((GMSMarker *)endMarker).position = endMarkerCoordinate;
        }else{
            if (!endMarker) {
                endMarker = [[Annotation alloc]init];
                [(MKMapView *)mapView addAnnotation:endMarker];
            }
            ((Annotation *)endMarker).coordinate = endMarkerCoordinate;
        }
    }
}

- (void)removeEndMarker{
    if (!endMarker) {
        return;
    }
    if (_mapType == MAP_TYPE_GOOGLE) {
        ((GMSMarker *)endMarker).map = nil;
    }else{
        [(MKMapView *)mapView removeAnnotation:endMarker];
    }
    endMarker = nil;
}

- (void)setMapViewNorthEast:(CLLocationCoordinate2D)northEast andSouthWest:(CLLocationCoordinate2D)southWest withEdgeInset:(UIEdgeInsets)padding willhighLightNE:(BOOL)highlight{
    BOOL isCoordinateSame = (fabs(northEast.latitude - southWest.latitude) <= MAP_DISTANCE_EPSILON &&  fabs(northEast.longitude - southWest.longitude) <= MAP_DISTANCE_EPSILON);
    if (_mapType == MAP_TYPE_GOOGLE) {
        if (highlight) {
            if (!positionIndicator) {
                positionIndicator = [GMSMarker markerWithPosition:northEast];
                [((GMSMarker *)positionIndicator) setIcon:[UIImage imageNamed:@"pin_green"]];
                ((GMSMarker *)positionIndicator).groundAnchor = CGPointMake(0.5, 1);
                [positionIndicator setMap:(GMSMapView *)mapView];
            }else{
                ((GMSMarker *)positionIndicator).position = northEast;
            }
            if (!positionIndicatorEnd) {
                positionIndicatorEnd = [GMSMarker markerWithPosition:southWest];
                [((GMSMarker *)positionIndicatorEnd) setIcon:[UIImage imageNamed:@"pin_blue"]];
                ((GMSMarker *)positionIndicatorEnd).groundAnchor = CGPointMake(0.5, 1);
                [positionIndicatorEnd setMap:(GMSMapView *)mapView];

            }else{
                ((GMSMarker *)positionIndicatorEnd).position = southWest;
            }
        }else{
            if(positionIndicator){
                ((GMSMarker *)positionIndicator).map = nil;
                positionIndicator = nil;
            }
            if (positionIndicatorEnd) {
                ((GMSMarker *)positionIndicatorEnd).map = nil;
                positionIndicatorEnd = nil;
            }
        }
        if (isCoordinateSame) {
            ((GMSMapView *)mapView).camera = [GMSCameraPosition cameraWithTarget:southWest zoom:16.5];
        }else{
            GMSCameraUpdate *camera = [GMSCameraUpdate fitBounds:[[GMSCoordinateBounds alloc]initWithCoordinate:northEast coordinate:southWest] withEdgeInsets:padding];
            [(GMSMapView *)mapView animateWithCameraUpdate:camera];
        }
    }else{
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
        if (highlight) {
            if (positionIndicator) {
                ((Annotation *)positionIndicator).coordinate = northEast;
            }else{
                positionIndicator =[[Annotation alloc] initWithCoordinate:northEast];
                ((Annotation *)positionIndicator).type = 'g';
                [(MKMapView *)mapView addAnnotation:positionIndicator];
            }
            if (positionIndicatorEnd) {
                ((Annotation *)positionIndicatorEnd).coordinate = southWest;

            }else{
                positionIndicatorEnd =[[Annotation alloc] initWithCoordinate:southWest];
                ((Annotation *)positionIndicatorEnd).type = 'b';
                [(MKMapView *)mapView addAnnotation:positionIndicatorEnd];
            }
        }else{
            if(positionIndicator){
                [(MKMapView *)mapView removeAnnotation:positionIndicator];positionIndicator = nil;
            }
            if (positionIndicatorEnd) {
                [(MKMapView *)mapView removeAnnotation:positionIndicatorEnd];positionIndicatorEnd = nil;
            }
        }
    }
}

- (void)dealloc{
    [[LocationManager sharedInstance]stopStandardUpdates];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self animateCurrentRoute];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if (!allRoutes && CLLocationCoordinate2DIsValid(geocodeResult.latLng)) {
        if (geocodeResult.address) {
            panViewVisibleHeight = 70;
            panViewType = PAN_VIEW_SEARCH;
            [self populatePannedViewAnimated:NO];
            [self searchBarSetAddress:geocodeResult.address];
        }
    }else{
        [self performSelector:@selector(centerMapToCurLoc) withObject:nil afterDelay:0.5];
    }
    
    if (pannedInfoView) {
        pannedInfoView.hidden = NO;
        [self adjustInfoView:mainScrollView withAnimation:0.0 toOrientation:self.interfaceOrientation];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (pannedInfoView) {
        lastPageIndex = mainScrollView.contentOffset.x / mainScrollView.bounds.size.width;
        pannedInfoView.hidden = YES;
    }
}

- (IBAction)showRoutingView:(id)sender{
    P2MSRoutingViewController *routingVC = [[P2MSRoutingViewController alloc]initWithNibName:nil bundle:nil];
    
    if (startAddress.length) {
        routingVC.startAddress = startAddress;
        routingVC.startLocDescription = startLocDescription;
    }
    if (endAddress.length) {
        routingVC.endAddress = endAddress;
        routingVC.endLocDescription = endLocDescription;
    }else if (geocodeResult) {
        routingVC.endLocDescription = [NSString stringWithFormat:@"%f,%f", geocodeResult.latLng.latitude, geocodeResult.latLng.longitude];
        routingVC.endAddress = geocodeResult.address;
    }
    routingVC.travel_mode_index = travel_mode_index;
    routingVC.delegate = self;
    [self presentModalViewController:routingVC animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)animateCurrentRoute{
    if (lastPageIndex == -1 || lastPageIndex >= allRoutes.count) {
        return;
    }
    OneRoute *curRouteObject = [allRoutes objectAtIndex:lastPageIndex];
    NSArray *polyLines = [P2MSGoogleMapHelper getLocationsFromPolyLineString:curRouteObject.overview_polyline];
    
    if (_mapType == MAP_TYPE_GOOGLE) {
        if (currentRoute) {
            ((GMSPolyline *)currentRoute).map = nil;
            currentRoute = nil;
        }
        GMSMutablePath *path = [GMSMutablePath path];
        for (CLLocation *curLoc in polyLines) {
            [path addCoordinate:[curLoc coordinate]];
        }
        currentRoute = [GMSPolyline polylineWithPath:path];
        [currentRoute setStrokeWidth:5.0f];
        ((GMSPolyline *)currentRoute).map = (GMSMapView *)mapView;
    }else{
        if (currentRoute) {
            applePolyLineView.hidden = YES;
            [(MKMapView *)mapView removeOverlay:currentRoute];
            applePolyLineView = nil;
            currentRoute = nil;
        }
        int count = [polyLines count];
        CLLocationCoordinate2D *loc_ptr = malloc(sizeof(CLLocationCoordinate2D)*count);
        for(int i = 0; i < count; i++) {
            CLLocation *loc = [polyLines objectAtIndex:i];
            loc_ptr[i] = loc.coordinate;
        }
        currentRoute = [MKPolyline polylineWithCoordinates:loc_ptr count:count];
        [(MKMapView *)mapView addOverlay:currentRoute];
        free(loc_ptr);
    }
    
    [self createEndMarkerForCoordinate:curRouteObject.endLoc];
    [self setMapViewNorthEast:curRouteObject.startLoc andSouthWest:curRouteObject.endLoc withEdgeInset:UIEdgeInsetsMake(50, 15, 0, 15) willhighLightNE:NO];
}

#pragma mark routing view delegate
- (void)routingViewWillClose:(P2MSRoutingViewController *)routingView withRoutes:(NSArray *)routes andSelectedIndex:(NSInteger)index{
    if (currentRoute) {
        if (_mapType == MAP_TYPE_GOOGLE) {
            ((GMSPolyline *)currentRoute).map = nil;
            currentRoute = nil;
        }else{
            
        }
    }
    allRoutes = routes;
    lastPageIndex = index;
    [selectedIndexes removeAllIndexes];
    
    startAddress = routingView.startAddress;
    endAddress = routingView.endAddress;
    startLocDescription = routingView.startLocDescription;
    endLocDescription = routingView.endLocDescription;
    travel_mode_index = routingView.travel_mode_index;
    
    OneRoute *curRouteObject = [allRoutes objectAtIndex:lastPageIndex];
    panViewVisibleHeight = ([curRouteObject.travel_mode isEqualToString:@"transit"])?80:60;
    panViewType = PAN_VIEW_ROUTE;
    [self showRouteInfoViewForTravelMode:curRouteObject.travel_mode];
    [self populatePannedViewAnimated:YES];
}

- (void)populatePannedViewAnimated:(BOOL)animate{
    CGSize curSize = self.view.bounds.size;
    CGRect curRect = CGRectMake(0, curSize.height, curSize.width, curSize.height);//20// - panViewHeight
    if (panViewType == PAN_VIEW_SEARCH) {
        curRect.size.height = panViewVisibleHeight;
    }
    if (!pannedInfoView) {
        pannedInfoView = [[UIView alloc]initWithFrame:CGRectZero];
        pannedInfoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:pannedInfoView];
        [pannedInfoView setShadowForOffset:CGSizeMake(0, -2.5) withRadius:2.5];
        pannedInfoView.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(paneViewPanned:)];
        panGesture.delegate = self;
        [pannedInfoView addGestureRecognizer:panGesture];
        isPannedViewOverlapped = NO;
        
        mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        mainScrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        mainScrollView.backgroundColor = [UIColor clearColor];
        mainScrollView.pagingEnabled = YES;
        mainScrollView.clipsToBounds = NO;
        mainScrollView.tag = 15;
        mainScrollView.showsHorizontalScrollIndicator = NO;
        mainScrollView.showsVerticalScrollIndicator = NO;
        mainScrollView.delegate = self;
        [pannedInfoView addSubview:mainScrollView];
    }else{
        for (UIView *viewToRemove in mainScrollView.subviews) {
            [viewToRemove removeFromSuperview];
        }
    }
    [self.view bringSubviewToFront:pannedInfoView];
    pannedInfoView.frame = curRect;
    mainScrollView.frame = CGRectMake(0, 0, curRect.size.width, curRect.size.height);
    
    NSInteger curIndex = 0;
    
    if (panViewType == PAN_VIEW_ROUTE) {
        for (OneRoute *routeToRender in allRoutes) {
            [self populateOneDirection:routeToRender atIndex:curIndex++ andWidth:curSize.width];
        }
        mainScrollView.contentSize = CGSizeMake(curRect.size.width*curIndex, curRect.size.height);
    }else{
        NSString *addressToGo = geocodeResult.address;
        NSString *firstPart = nil, *secondPart = nil;
        NSRange firstComma = [addressToGo rangeOfString:@","];
        if (firstComma.location != NSNotFound) {
            firstPart = [addressToGo substringWithRange:NSMakeRange(0, firstComma.location)];
            secondPart = [addressToGo substringFromIndex:firstComma.location+1];
        }else{
            firstPart = addressToGo;
        }
        if (firstPart) {
            UILabel *address = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, curRect.size.width-60, 18)];
            address.font = [UIFont systemFontOfSize:17];
            address.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            address.textColor = [UIColor blackColor];
            address.backgroundColor = [UIColor clearColor];
            address.text = firstPart;
            [mainScrollView addSubview:address];
            
            if (secondPart) {
                UILabel *detailAds = [[UILabel alloc]initWithFrame:CGRectMake(10, 28, curRect.size.width-60, 32)];
                detailAds.font = [UIFont systemFontOfSize:13];
                detailAds.backgroundColor = [UIColor clearColor];
                detailAds.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                detailAds.textColor = [UIColor grayColor];
                detailAds.numberOfLines = 2;
                detailAds.text = secondPart;
                [mainScrollView addSubview:detailAds];
            }
        }
        UIButton *directionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [directionBtn setBackgroundImage:[UIImage imageNamed:@"direction"] forState:UIControlStateNormal];
        directionBtn.frame = CGRectMake(curRect.size.width-45, 20, 30, 30);
        directionBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [directionBtn addTarget:self action:@selector(showRoutingView:) forControlEvents:UIControlEventTouchUpInside];
        [mainScrollView addSubview:directionBtn];
        mainScrollView.contentSize = CGSizeMake(curRect.size.width, curRect.size.height);
    }
    
    CGFloat animateDuration = animate * 0.25;
    
    CGRect mapRect = self.view.bounds;
    mapRect.size.height -= panViewVisibleHeight;
    
    [UIView animateWithDuration:animateDuration animations:^{
        pannedInfoView.frame = CGRectMake(0, curSize.height  - panViewVisibleHeight, curSize.width, curSize.height);//20
        mapView.frame = mapRect;
    }];
}

- (void)removePannedInfoViewAnimate:(BOOL)animate{
    panViewType = PAN_VIEW_NONE;
    CGRect mapFinalRect = self.view.bounds;
    CGRect paneViewFinalRect = pannedInfoView.bounds;
    paneViewFinalRect.origin.y = mapFinalRect.origin.y + mapFinalRect.size.height;
    
    CGFloat animationDuration = animate * 0.25;
    
    if (animationDuration) {
        [UIView animateWithDuration:animationDuration animations:^{
            mapView.frame = mapFinalRect;
            pannedInfoView.frame = paneViewFinalRect;
        } completion:^(BOOL finished) {
            [pannedInfoView removeFromSuperview];
            pannedInfoView = nil;
        }];
    }else{
        [pannedInfoView removeFromSuperview];
        pannedInfoView = nil;
        mapView.frame = mapFinalRect;
    }
}

- (void)populateOneDirection:(OneRoute *)routeToRender atIndex:(NSInteger)index andWidth:(CGFloat)width{
    UIScrollView *scrollView = (UIScrollView *)mainScrollView;
    UIButton *tapView = [[P2MSShadowView alloc]initWithFrame:CGRectMake(index*width, 0, width, panViewVisibleHeight)];
    tapView.backgroundColor = [UIColor colorWithWhite:0.98 alpha:1.0];
    tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    tapView.tag = index + TABLEVIEW_TAG_BASE + MAX_TABLE_VIEW;
    [tapView addTarget:self action:@selector(togglePaneView:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([routeToRender.travel_mode isEqualToString:@"transit"]) {
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(10, 7, self.view.bounds.size.width-20, 20)];
        title.font = [UIFont systemFontOfSize:16];
        title.tag = 15;
        title.backgroundColor = [UIColor clearColor];
        title.text = routeToRender.routeOverviewTitle;
        [tapView addSubview:title];
        
        P2MSDirectionView *directView = [[P2MSDirectionView alloc]initWithFrame:CGRectMake(5, 25, self.view.bounds.size.width-10, 33)];
        directView.tag = 16;
        directView.routeOverview = routeToRender.routeOverview;
        directView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [tapView addSubview:directView];
        
        UILabel *viaLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 58, self.view.bounds.size.width-20, 16)];
        viaLabel.text = routeToRender.viaString;
        viaLabel.textColor = [UIColor grayColor];
        viaLabel.font = [UIFont systemFontOfSize:13];
        viaLabel.backgroundColor = [UIColor clearColor];
        viaLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [tapView addSubview:viaLabel];
    }else{
        UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(10, 12, self.view.bounds.size.width-20, 20)];
        title.font = [UIFont systemFontOfSize:17];
        title.tag = 15;
        title.backgroundColor = [UIColor clearColor];
        title.text = routeToRender.routeOverviewTitle;
        [tapView addSubview:title];
        
        UILabel *overviewlbl = [[UILabel alloc]initWithFrame:CGRectMake(10, 32, self.view.bounds.size.width-20, 16)];
        overviewlbl.text = routeToRender.routeOverview;
        overviewlbl.textColor = [UIColor grayColor];
        overviewlbl.font = [UIFont systemFontOfSize:14];
        overviewlbl.backgroundColor = [UIColor clearColor];
        overviewlbl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [tapView addSubview:overviewlbl];
    }
    UITableView *tableView = [[UITableView alloc]initWithFrame:CGRectMake(10+(index*width), panViewVisibleHeight, width-20, scrollView.frame.size.height-panViewVisibleHeight)];
    tableView.delegate = self;
    tableView.tag = index+TABLEVIEW_TAG_BASE;
    tableView.dataSource = self;
    [tableView.panGestureRecognizer requireGestureRecognizerToFail:[mainScrollView.gestureRecognizers objectAtIndex:0]];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [scrollView addSubview:tableView];
    
    [scrollView addSubview:tapView];
    
}

- (IBAction)togglePaneView:(id)sender{
    [self paneView:pannedInfoView hidden:isPannedViewOverlapped];
}

- (IBAction)paneViewPanned:(UIPanGestureRecognizer *)sender{
    if (panViewType != PAN_VIEW_ROUTE) {
        return;
    }
    if (sender.state == UIGestureRecognizerStateBegan) {
        panGestureOrigin = sender.view.frame.origin;
        translatedOrigin = CGPointZero;
        isPanned = YES;
        //        if (sender.view.frame.size.height != self.view.bounds.size.height) {
        //            CGRect paneViewRect = sender.view.frame;
        //            paneViewRect.size.height = self.view.bounds.size.height;
        //            sender.view.frame = paneViewRect;
        //        }
    }
    if (isGestureRecognizerOverlapped) {
        UITableView *tblView = (UITableView *)[mainScrollView viewWithTag:TABLEVIEW_TAG_BASE+lastPageIndex];
        if (tblView.contentOffset.y <= 0) {
            isGestureRecognizerOverlapped = NO;
            panGestureOrigin = sender.view.frame.origin;
            translatedOrigin = [sender translationInView:sender.view];
        }
    }else
    {
        CGPoint translatedPoint = [sender translationInView:sender.view];
        CGPoint adjustedOrigin = panGestureOrigin;//[P2MSGlobalFunctions pointAdjustedForInterfaceOrientation:panGestureOrigin forInterfaceOrientation:self.interfaceOrientation];
        translatedPoint = CGPointMake(adjustedOrigin.x + translatedPoint.x - translatedOrigin.x, adjustedOrigin.y + translatedPoint.y - translatedOrigin.y);
        translatedPoint.y = MAX(MIN(translatedPoint.y, self.view.bounds.size.height-panViewVisibleHeight), 0);//20
        UIView *paneView = sender.view;
        CGRect curRect = paneView.frame;
        curRect.origin.y = translatedPoint.y;
        paneView.frame = curRect;
        
        if (sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
            CGPoint velocity = [sender velocityInView:self.navigationController.view];
            CGFloat finalY = translatedPoint.y + (.35*velocity.y);
            CGFloat viewHeight = self.view.frame.size.height;
            BOOL willShowPannedInfoView;
            if (isPannedViewOverlapped) {
                willShowPannedInfoView = finalY < adjustedOrigin.y;
            }else{
                willShowPannedInfoView = (finalY < viewHeight*0.67);
            }
            [self paneView:paneView hidden:!willShowPannedInfoView];
        }
    }
    if (sender.state == UIGestureRecognizerStateChanged) {
        tableViewScrollEnable = (pannedInfoView.frame.origin.y == 0);
    }else if(sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled) {
        tableViewScrollEnable = YES;
        isPanned = NO;
    }
}

- (void)paneView:(UIView *)paneView hidden:(BOOL)hidden{
    if (hidden) {
        statusBarHidden = NO;
        [[UIApplication sharedApplication]setStatusBarHidden:NO];
        [UIView animateWithDuration:0.35 animations:^{
            CGRect curRect = paneView.frame;
            curRect.origin.y = self.view.bounds.size.height - panViewVisibleHeight;
            paneView.frame = curRect;
        }completion:^(BOOL finished) {
            isPannedViewOverlapped = NO;
        }];
    }else{
        statusBarHidden = YES;
        if ([P2MSGlobalFunctions sharedInstance].isIOS_7_OR_LATER) {
            [[UIApplication sharedApplication]setStatusBarHidden:YES];
        }
        [UIView animateWithDuration:0.35 animations:^{
            CGRect curRect = paneView.frame;
            curRect.origin.y = 0;//20
            paneView.frame = curRect;
        }completion:^(BOOL finished) {
            isPannedViewOverlapped = YES;
        }];
    }
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
    {
        [self prefersStatusBarHidden];
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    }
}

- (BOOL)prefersStatusBarHidden {
    return statusBarHidden;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    if (pannedInfoView) {
        lastPageIndex = mainScrollView.contentOffset.x / mainScrollView.bounds.size.width;
        [self adjustInfoView:mainScrollView withAnimation:duration toOrientation:toInterfaceOrientation];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

- (void)adjustInfoView:(UIScrollView *)scrollView withAnimation:(CGFloat)duration toOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    CGSize curDeviceDimension = [[UIScreen mainScreen]bounds].size;
    
    CGFloat finalWidth;
    CGRect curRect = pannedInfoView.frame;
    if (isPannedViewOverlapped) {
        finalWidth = (UIInterfaceOrientationIsLandscape(toInterfaceOrientation))?curDeviceDimension.height:curDeviceDimension.width;
        scrollView.contentSize = CGSizeMake(finalWidth*allRoutes.count, scrollView.bounds.size.height);
        curRect.origin.y = 0;
        [UIView animateWithDuration:duration animations:^{
            pannedInfoView.frame = curRect;
            scrollView.contentOffset = CGPointMake(finalWidth*lastPageIndex, 0);
        }];
    }else{
        CGFloat heightDiff;
        BOOL isLandscape, isNaviBarShowing = (self.navigationController.navigationBar && !self.navigationController.navigationBar.hidden);
        BOOL isIPad = [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        if ((isLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation))) {
            heightDiff = curDeviceDimension.width - self.view.bounds.size.height ;
        }else{
            heightDiff = curDeviceDimension.height - self.view.bounds.size.height;
        }
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            curRect.origin.y = curDeviceDimension.width - heightDiff - panViewVisibleHeight + (!isIPad) * ((!isLandscape && isNaviBarShowing) * 12);
            finalWidth = curDeviceDimension.height;
        }else{
            curRect.origin.y = curDeviceDimension.height - heightDiff - panViewVisibleHeight - (!isIPad) * ((isLandscape && isNaviBarShowing) * 12);
            finalWidth = curDeviceDimension.width;
        }
        if (panViewType == PAN_VIEW_ROUTE) {
            scrollView.contentSize = CGSizeMake(finalWidth*allRoutes.count, scrollView.bounds.size.height);
            [UIView animateWithDuration:duration animations:^{
                pannedInfoView.frame = curRect;
                scrollView.contentOffset = CGPointMake(finalWidth*lastPageIndex, 0);
            }];
        }else{
            scrollView.contentSize = CGSizeMake(finalWidth, scrollView.bounds.size.height);
            [UIView animateWithDuration:duration animations:^{
                pannedInfoView.frame = curRect;
                scrollView.contentOffset = CGPointMake(0, 0);
            }];
        }
    }
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    UIScrollView *scrollView = (UIScrollView *)mainScrollView;
    if (scrollView) {
        CGSize curSize = scrollView.bounds.size;
        scrollView.contentSize = CGSizeMake(curSize.width*allRoutes.count, curSize.height);
        scrollView.contentOffset = CGPointMake(lastPageIndex*scrollView.bounds.size.width, 0);
        for (UIView *curView in mainScrollView.subviews) {
            if ([curView isKindOfClass:[UITableView class]]) {
                [((UITableView *)curView) reloadData];
            }
            else if ([curView isKindOfClass:[P2MSShadowView class]]){
                P2MSDirectionView *directView = (P2MSDirectionView *)[curView viewWithTag:16];
                [directView redrawOverview];
            }
        }
    }
}


#pragma mark TableViewDelegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (tableView == searchController.searchResultsTableView) {
        return 1;
    }else
    {
        NSInteger curIndex = tableView.tag-TABLEVIEW_TAG_BASE;
        OneRoute *curRoute = [allRoutes objectAtIndex:curIndex];
        if ([curRoute.travel_mode isEqualToString:@"transit"]) {
            return curRoute.travel_steps.count+1;
        }else
            return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger curIndex = tableView.tag-TABLEVIEW_TAG_BASE;
    if (tableView == searchController.searchResultsTableView) {
        return allSuggestions.count;
    }else
    {
        OneRoute *curRoute = [allRoutes objectAtIndex:curIndex];
        if ([curRoute.travel_mode isEqualToString:@"transit"]) {
            if (section == curRoute.travel_steps.count) {
                return 1;
            }else{
                TravelStep *curStep = [curRoute.travel_steps objectAtIndex:section];
                return (curStep.travel_steps.count * ([selectedIndexes containsIndex:(curIndex*MAX_ROUTING_STEPS)+section]))+2;
            }
        }else{
            return curRoute.travel_steps.count+2;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    
    if (tableView == searchController.searchResultsTableView) {
        static NSString *RouteCellSuggestionIdentifier = @"CellRoutePlaceSuggestion";
        cell = [tableView dequeueReusableCellWithIdentifier:RouteCellSuggestionIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:RouteCellSuggestionIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:14];
            cell.textLabel.numberOfLines = 0;
            cell.detailTextLabel.textColor = [UIColor grayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        LocationSuggestion *curSuggestion = [allSuggestions objectAtIndex:indexPath.row];
        cell.textLabel.text = curSuggestion.name;
        cell.detailTextLabel.text = curSuggestion.country;
    }else
    {
        NSInteger curIndex = tableView.tag-TABLEVIEW_TAG_BASE;
        OneRoute *curRoute = [allRoutes objectAtIndex:curIndex];
        TravelStep *curStep;
        if ([curRoute.travel_mode isEqualToString:@"transit"]) {
            if (indexPath.row == 0) {
                static NSString *RouteCellIdentifier = @"CellRouteHeader";
                cell = [tableView dequeueReusableCellWithIdentifier:RouteCellIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RouteCellIdentifier];
                    cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
                    cell.contentView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.textLabel.backgroundColor = [UIColor clearColor];
                    cell.textLabel.font = [UIFont systemFontOfSize:16];
                    cell.textLabel.numberOfLines = 0;
                }
                if (indexPath.section == 0) {
                    cell.textLabel.text = (startAddress.length)?startAddress:@"Starting Point";
                }else if (indexPath.section == curRoute.travel_steps.count){
                    cell.textLabel.text = (endAddress.length)?endAddress:@"End Point";
                }
                else{
                    curStep = [curRoute.travel_steps objectAtIndex:indexPath.section];
                    if ([curStep.mode_of_travel isEqualToString:@"TRANSIT"]){
                        cell.textLabel.text = ((TransitTravelStep *)curStep).departureName;
                    }else if([curStep.mode_of_travel isEqualToString:@"WALKING"]){
                        TravelStep *prevStep = [curRoute.travel_steps objectAtIndex:indexPath.section-1];
                        if ([prevStep.mode_of_travel isEqualToString:@"TRANSIT"]){
                            cell.textLabel.text = ((TransitTravelStep *)prevStep).arrivalName;
                        }else
                            cell.textLabel.text = @"";
                    }
                }
            }else if(indexPath.row == 1){
                static NSString *RouteSectionCellIdentifier = @"CellRouteSection";
                cell = [tableView dequeueReusableCellWithIdentifier:RouteSectionCellIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:RouteSectionCellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.textLabel.font = [UIFont systemFontOfSize:15];
                    cell.textLabel.numberOfLines = 0;
                    cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
                }
                curStep = [curRoute.travel_steps objectAtIndex:indexPath.section];
                cell.textLabel.text = curStep.instruction;
                if (curStep.travel_steps.count) {
                    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
                    [imgView setImage:([selectedIndexes containsIndex:(curIndex*MAX_ROUTING_STEPS)+indexPath.section])?[UIImage imageNamed:@"icon_arrow_compact_up"]:[UIImage imageNamed:@"icon_arrow_compact_down"]];
                    cell.accessoryView = imgView;
                }else
                    cell.accessoryView = nil;
                if ([curStep.mode_of_travel isEqualToString:@"TRANSIT"]) {
                    int numOfStops = ((TransitTravelStep*)curStep).numOfStops;
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d stop%@ (%@)", numOfStops, (numOfStops>1)?@"s":@"", curStep.durationText];
                }else{
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)", curStep.distanceText, curStep.durationText];
                }
            }else{
                static NSString *RouteCellNormalIdentifier = @"CellRouteNormal";
                cell = [tableView dequeueReusableCellWithIdentifier:RouteCellNormalIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RouteCellNormalIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.textLabel.numberOfLines = 0;
                    cell.textLabel.font = [UIFont systemFontOfSize:14];
                }
                curStep = [curRoute.travel_steps objectAtIndex:indexPath.section];
                curStep = [curStep.travel_steps objectAtIndex:indexPath.row-2];
                cell.textLabel.text = curStep.instruction;
            }
        }else{
            static NSString *RouteCellNormalIdentifier = @"CellRouteNormal";
            cell = [tableView dequeueReusableCellWithIdentifier:RouteCellNormalIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RouteCellNormalIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.font = [UIFont systemFontOfSize:14];
            }
            if (indexPath.row == 0) {
                cell.textLabel.text = @"Starting Point";
            }else if (indexPath.row-1 == curRoute.travel_steps.count){
                cell.textLabel.text = @"End Point";
            }else{
                curStep = [curRoute.travel_steps objectAtIndex:indexPath.row-1];
                cell.textLabel.text = curStep.instruction;
            }
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat widthToConsider = -(10*[P2MSGlobalFunctions sharedInstance].isIOS_7_OR_LATER);
    widthToConsider = tableView.bounds.size.width- 20 + widthToConsider;
    if (tableView == searchController.searchResultsTableView) {
        LocationSuggestion *curSuggestion = [allSuggestions objectAtIndex:indexPath.row];
        return [curSuggestion.name sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(widthToConsider, CGFLOAT_MAX)].height + 25;
    }else
    {
        NSInteger curIndex = tableView.tag-TABLEVIEW_TAG_BASE;
        OneRoute *curRoute = [allRoutes objectAtIndex:curIndex];
        if ([curRoute.travel_mode isEqualToString:@"transit"]) {
            if (indexPath.row == 0) {
                NSString *textToShow;
                if (indexPath.section == 0) {
                    textToShow = (startAddress.length)?startAddress:@"Starting Point";
                }else if (indexPath.section == curRoute.travel_steps.count){
                    textToShow = (endAddress.length)?endAddress:@"End Point";
                }else{
                    TravelStep *curStep = [curRoute.travel_steps objectAtIndex:indexPath.section];
                    if ([curStep.mode_of_travel isEqualToString:@"TRANSIT"]){
                        textToShow = ((TransitTravelStep *)curStep).departureName;
                    }else if([curStep.mode_of_travel isEqualToString:@"WALKING"]){
                        TravelStep *prevStep = [curRoute.travel_steps objectAtIndex:indexPath.section-1];
                        if ([prevStep.mode_of_travel isEqualToString:@"TRANSIT"]){
                            textToShow = ((TransitTravelStep *)prevStep).arrivalName;
                        }else
                            textToShow = @"";
                    }
                }
                return [textToShow sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(widthToConsider, CGFLOAT_MAX)].height + 20;
            }else if(indexPath.row == 1){
                TravelStep *curStep = [curRoute.travel_steps objectAtIndex:indexPath.section];
                return [curStep.instruction sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize:CGSizeMake(widthToConsider, CGFLOAT_MAX)].height + 30;
            }else{
                TravelStep *curStep = [curRoute.travel_steps objectAtIndex:indexPath.section];
                curStep = [curStep.travel_steps objectAtIndex:indexPath.row-2];
                return [curStep.instruction sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(widthToConsider, CGFLOAT_MAX)].height + 14;
            }
        }else{
            NSString *textToShow;
            if (indexPath.row == 0) {
                textToShow = (startAddress.length)?startAddress:@"Starting Point";
            }else if (indexPath.row-1 == curRoute.travel_steps.count){
                textToShow = (endAddress.length)?endAddress:@"End Point";
            }else{
                textToShow = ((TravelStep *)[curRoute.travel_steps objectAtIndex:indexPath.row-1]).instruction;
            }
            return [textToShow sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(widthToConsider, CGFLOAT_MAX)].height + 20;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (tableView == searchController.searchResultsTableView) {
        LocationSuggestion *suggestion = [allSuggestions objectAtIndex:indexPath.row];
        NSString *strToGeocode = (suggestion.country)?[NSString stringWithFormat:@"%@ %@", suggestion.name, suggestion.country]:suggestion.name;
        if (curRequest) {
            [curRequest cancel];
            curRequest = nil;
        }
        curRequest = [P2MSGoogleMapHelper geoDecodeAddress:strToGeocode withNetworkDelegate:self];
        if (curRequest) {
            receivedData = [NSMutableData data];
        }
        allSuggestions = nil;
        [searchController setActive:NO];
        panViewVisibleHeight = 70;
    }else
    {
        NSInteger curIndex = tableView.tag-TABLEVIEW_TAG_BASE;
        OneRoute *curRoute = [allRoutes objectAtIndex:curIndex];
        if ([curRoute.travel_mode isEqualToString:@"transit"]) {
            if (indexPath.row == 1) {
                int indexToTest = (lastPageIndex * MAX_ROUTING_STEPS) + indexPath.section;
                if ([selectedIndexes containsIndex:indexToTest]) {
                    [selectedIndexes removeIndex:indexToTest];
                }else
                    [selectedIndexes addIndex:indexToTest];
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
            }else{
                 [self paneView:pannedInfoView hidden:YES];
                TravelStep *curStep;
                {
                    if (indexPath.section == 0 && indexPath.row == 0) {
                        [self centerMapToLatLng:curRoute.startLoc showPin:YES];
                    }else if(indexPath.section == curRoute.travel_steps.count){
                        [self centerMapToLatLng:curRoute.endLoc showPin:YES];
                    }else{
                        curStep = [curRoute.travel_steps objectAtIndex:indexPath.section];
                        if (indexPath.row > 1) {//row > 1
                            curStep = [curStep.travel_steps objectAtIndex:indexPath.row-2];
                        }
                        [self setMapViewNorthEast:curStep.startLoc andSouthWest:curStep.endLoc withEdgeInset:UIEdgeInsetsMake(100, 15, 15, 15) willhighLightNE:YES];
                    }
                }
            }
        }else {

            if (indexPath.row == 0) {
                [self centerMapToLatLng:curRoute.startLoc showPin:YES];
            }else if(indexPath.section == curRoute.travel_steps.count){
                [self centerMapToLatLng:curRoute.endLoc showPin:YES];
            }else{
                TravelStep *curTravelStep = [curRoute.travel_steps objectAtIndex:indexPath.row-1];
                [self centerMapToLatLng:curTravelStep.startLoc showPin:YES];
            }
        }

    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //    NSLog(@"scrollView will Begin dragging");
    //    store_y = scrollView.contentOffset.y;
    //    showWillWork = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if ([scrollView isEqual:mainScrollView]) {   
    }else{
        P2MSShadowView *shadowView = (P2MSShadowView *)[mainScrollView viewWithTag:scrollView.tag+MAX_TABLE_VIEW];
        if ((isPanned && scrollView.contentOffset.y < 0) || !tableViewScrollEnable) {
            scrollView.contentOffset = CGPointMake(0, 0);
            scrollView.showsVerticalScrollIndicator = NO;
            shadowView.hasShadow = NO;
        }else{
            scrollView.showsVerticalScrollIndicator = YES;
            shadowView.hasShadow = YES;
        }
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([scrollView isEqual:mainScrollView]) {
        if (!decelerate) {
            lastPageIndex = scrollView.contentOffset.x / scrollView.bounds.size.width;
            [self animateCurrentRoute];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isEqual:mainScrollView]) {
        lastPageIndex = scrollView.contentOffset.x / scrollView.bounds.size.width;
        [self animateCurrentRoute];
    }
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer{
    isGestureRecognizerOverlapped = NO;
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    UITableView *tblView = (UITableView *)[mainScrollView viewWithTag:TABLEVIEW_TAG_BASE+lastPageIndex];
    if (([gestureRecognizer isEqual:[pannedInfoView.gestureRecognizers objectAtIndex:0]] && [otherGestureRecognizer isEqual:tblView.panGestureRecognizer])) {
        isGestureRecognizerOverlapped = YES;
        return YES;
    }
    return NO;
}

#pragma mark searchbar delegate
- (void)p2msSearchDisplayControllerDidBeginSearch:(P2MSSearchDisplayViewController *)controller{
    CGFloat origY = self.view.bounds.size.height - controller.searchResultsTableView.contentInset.bottom - 20;
    [P2MSGlobalFunctions hidePoweredByGoogleLogo:NO inView:self.view forRect:CGRectMake(self.view.bounds.size.width - 109, origY, 104, 16)];
}

- (void)p2msSearchDisplayControllerDidEndSearch:(P2MSSearchDisplayViewController *)controller{
    [P2MSGlobalFunctions hidePoweredByGoogleLogo:YES inView:self.view forRect:CGRectZero];
    if (geocodeResult.address){
        [self searchBarSetAddress:geocodeResult.address];
    }
}

- (void)p2msSearchBarTextDidBeginEditing:(P2MSSearchBar *)searchBar{
    if (searchBar.txtField.text.length) {
        [self queryPlaceAutoComplete:searchBar.txtField.text];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    if (!controller.isActive) {
        controller.searchResultsTableView.hidden = YES;
        return NO;
    }
    return YES;
}

- (void)p2msSearchBar:(P2MSSearchBar *)searchBar textDidChange:(NSString *)searchText{
    [self queryPlaceAutoComplete:searchText];
}

- (void)p2msSearchDisplayController:(P2MSSearchDisplayViewController *)controller keyboardWillShow:(BOOL)show WithHeight:(CGFloat)height{
    if (show) {
        CGFloat origY = self.view.bounds.size.height - height- 20;
        [P2MSGlobalFunctions movePoweredByGoogleLoginInView:self.view toPoint:CGPointMake(self.view.bounds.size.width-109, origY)];
    }else{
        [P2MSGlobalFunctions movePoweredByGoogleLoginInView:self.view toPoint:CGPointMake(self.view.bounds.size.width-109, self.view.bounds.size.height - 20)];
    }
}

- (void)queryPlaceAutoComplete:(NSString *)textToSearch{
    if ([searchController.searchBar.txtField.text isEqualToString:[self firstPartOfAddress:geocodeResult.address]])return;
    if (textToSearch.length && !curRequest) {
        curRequest = [P2MSGoogleMapHelper getPlaceSuggestionsForQuery:textToSearch withCurLocation:[LocationManager sharedInstance].curLoc withDelegate:self];
        if (curRequest) {
            receivedData = [NSMutableData data];
        }
        nextTextToSearch = nil;
    }else if (curRequest){
        nextTextToSearch = textToSearch;
    }else{
        nextTextToSearch = nil;
    }
}

- (NSString *)firstPartOfAddress:(NSString *)addressText{
    if (addressText){
        NSRange curRange = [addressText rangeOfString:@","];
        NSString *firstPart = addressText;
        if (curRange.location != NSNotFound) {
            firstPart = [addressText substringWithRange:NSMakeRange(0, curRange.location)];
        }
        return firstPart;
    }
    return nil;
}

- (void)searchBarSetAddress:(NSString *)addressText{
    searchController.searchBar.txtField.text = [self firstPartOfAddress:addressText];
    [searchController.searchBar clearAdditionalViews];
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(0, 0, 20, 20);
    cancelBtn.backgroundColor = [UIColor clearColor];
    [cancelBtn addTarget:self action:@selector(removeCurrentSearchResult:) forControlEvents:UIControlEventTouchUpInside];
    [searchController.searchBar pushAdditionalViewAtRight:cancelBtn];
}

#pragma mark Google Place API
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    NSDictionary *responseJSON = [receivedData objectFromJSONData];
    NSString *statusString = [responseJSON objectForKey:@"status"];
    if ([statusString isEqualToString:@"OK"]){
        if ([[curRequest.userInfo objectForKey:@"req_type"] isEqualToString:@"geocode"]) {
            [self removePannedInfoViewAnimate:NO];
            geocodeResult = nil;
            panViewType = PAN_VIEW_SEARCH;
            geocodeResult = [P2MSGoogleMapHelper googleMapGeocode:[responseJSON objectForKey:@"results"]];
            [self createEndMarkerForCoordinate:geocodeResult.latLng];
            [self setMapViewNorthEast:geocodeResult.northeast andSouthWest:geocodeResult.southwest withEdgeInset:UIEdgeInsetsMake(50, 15, 0, 15) willhighLightNE:NO];
            [self populatePannedViewAnimated:YES];

            [self searchBarSetAddress:geocodeResult.address];
        }else{
            allSuggestions = nil;
            allSuggestions = [P2MSGoogleMapHelper parseSuggestions:[responseJSON objectForKey:@"predictions"]];
            
            if (nextTextToSearch) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextSearch) object:nil];
                [self performSelector:@selector(nextSearch) withObject:nil afterDelay:0.1];
            }
        }
    }else{
        allRoutes = nil;
        if ([statusString isEqualToString:@"NOT_FOUND"] || [statusString isEqualToString:@"ZERO_RESULTS"]) {
        }else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Google Map" message:statusString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }
    curRequest = nil;
    [searchController.searchResultsTableView reloadData];
}

- (void)nextSearch{
    [self queryPlaceAutoComplete:nextTextToSearch];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    curRequest = nil;
    receivedData = nil;
}

- (void)addRouteButtonToSearchBar{
    UIButton *btnRoute = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnRoute setBackgroundImage:[UIImage imageNamed:@"routing"] forState:UIControlStateNormal];
    btnRoute.frame = CGRectMake(0, 0, 20, 20);
    btnRoute.backgroundColor = [UIColor clearColor];
    [btnRoute addTarget:self action:@selector(showRoutingView:) forControlEvents:UIControlEventTouchUpInside];
    [searchController.searchBar pushAdditionalViewAtRight:btnRoute];
}

- (IBAction)removeCurrentSearchResult:(id)sender{
    searchController.searchBar.txtField.text = @"";
    [searchController.searchBar clearAdditionalViews];
    geocodeResult = nil;
    [self removePannedInfoViewAnimate:YES];
    [self addRouteButtonToSearchBar];
    if (_mapType == MAP_TYPE_GOOGLE) {
        ((GMSMarker *)endMarker).map = nil;
    }else{
        [(MKMapView *)mapView removeAnnotation:endMarker];
    }
    endMarker = nil;
    [self removeEndMarker];
}

- (IBAction)removeCurrentRouteResult:(id)sender{
    [UIView animateWithDuration:0.2 animations:^{
        routeView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [routeView removeFromSuperview];
        routeView = nil;
    }];
    if (_mapType == MAP_TYPE_GOOGLE) {
        ((GMSPolyline *)currentRoute).map = nil;
        
    }else{
        applePolyLineView.hidden = YES;
        [(MKMapView *)mapView removeOverlay:currentRoute];
        applePolyLineView = nil;
        if (positionIndicator) {
            [(MKMapView *)mapView removeAnnotation:positionIndicator];
            positionIndicator = nil;
        }
    }
    currentRoute = nil;
    
    startAddress = nil; endAddress = nil;
    startLocDescription = nil; endLocDescription = nil;
    travel_mode_index = -1;
    
    allRoutes = nil;

    [self removePannedInfoViewAnimate:NO];
    if (geocodeResult) {
        panViewType = PAN_VIEW_SEARCH;
        [self populatePannedViewAnimated:NO];
    }else{
        [self removeEndMarker];
    }
    [mapView setNeedsDisplay];
}


#pragma mark MapKit
- (MKAnnotationView *)mapView:(MKMapView *)mV viewForAnnotation:(id <MKAnnotation>)annotation {
    if (![annotation isKindOfClass:[Annotation class]]) {
        return nil;
    }
    MKAnnotationView *pinView = nil;
    UIImage *pinImage;
    switch (((Annotation *)annotation).type) {
        case 'g':pinImage = [UIImage imageNamed:@"pin_green"];
        case 'b':{
            if (!pinImage) {
                pinImage = [UIImage imageNamed:@"pin_blue"];
            }
            static NSString *circlePinID = @"CircleViewIdentifier";
            pinView = (MKAnnotationView *)[(MKMapView *)mapView dequeueReusableAnnotationViewWithIdentifier:circlePinID];
            if (pinView == nil){
                pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:circlePinID];
            }
            pinView.centerOffset = CGPointMake(0, -11);
            pinView.image = pinImage;
            pinView.canShowCallout = NO;
        }break;
        default:{
            static NSString *defaultPinID = @"StandardIdentifier";
            pinView = (MKAnnotationView *)[(MKMapView *)mapView dequeueReusableAnnotationViewWithIdentifier:defaultPinID];
            if (pinView == nil){
                pinView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:defaultPinID];
            }
            pinView.image = [UIImage imageNamed:@"GoogleMaps.bundle/default_marker.png"];
            pinView.centerOffset = CGPointMake(0, -15);
            pinView.canShowCallout = NO;
        }break;
    }
    return pinView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay{
    MKOverlayView *overlayView = nil;
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        if (currentRoute) {
            if (applePolyLineView == nil) {
                applePolyLineView = [[MKPolylineView alloc] initWithPolyline:currentRoute];
                applePolyLineView.strokeColor = [[UIColor blueColor]colorWithAlphaComponent:0.7];
                applePolyLineView.lineJoin = kCGLineJoinRound;
                applePolyLineView.lineCap = kCGLineCapRound;
            }
            overlayView = applePolyLineView;
        }
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
