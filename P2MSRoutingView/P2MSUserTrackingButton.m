//
//  P2MSUserTrackingButton.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 28/11/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSUserTrackingButton.h"

@interface P2MSUserTrackingButton(){
    __weak MKMapView *_mapView;
}

@property (nonatomic) MKUserTrackingMode trackingMode;

@end

@implementation P2MSUserTrackingButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)initWithMapView:(MKMapView *)mapView andFrame:(CGRect)rect{
    self = [super initWithFrame:rect];
    if (self) {
        _mapView = mapView;
        [mapView addObserver:self forKeyPath:@"userTrackingMode" options:NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew context:NULL];
        _trackingMode = MKUserTrackingModeNone;
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [self addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self setImage:[UIImage imageNamed:@"location_not_active"] forState:UIControlStateNormal];
    }
    return self;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    _trackingMode = [change[@"new"] intValue];
    [self reflectViewForTrackingMode:_trackingMode];
}

- (void)reflectViewForTrackingMode:(MKUserTrackingMode)trackingMode{
    switch (_trackingMode) {
        case MKUserTrackingModeNone:{
            [self setImage:[UIImage imageNamed:@"location_not_active"] forState:UIControlStateNormal];
        }break;
        case MKUserTrackingModeFollow:{
            [self setImage:[UIImage imageNamed:@"current_located"] forState:UIControlStateNormal];
            
        }break;
        case MKUserTrackingModeFollowWithHeading:{
            [self setImage:[UIImage imageNamed:@"location-tracked"] forState:UIControlStateNormal];
        }
    }
}


- (IBAction)buttonClicked:(id)sender{
    switch (_trackingMode) {
        case MKUserTrackingModeNone:{
            _trackingMode = MKUserTrackingModeFollow;
        }break;
        case MKUserTrackingModeFollow:{
            _trackingMode = MKUserTrackingModeFollowWithHeading;
        }break;
        case MKUserTrackingModeFollowWithHeading:{
            _trackingMode = MKUserTrackingModeNone;
        }
    }
    [self reflectViewForTrackingMode:_trackingMode];
    [_mapView setUserTrackingMode:_trackingMode animated:YES];
}

- (void)dealloc{
    [_mapView removeObserver:self forKeyPath:@"userTrackingMode"];
}

@end
