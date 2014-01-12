//
//  P2MSMapViewController.h
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 29/10/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "P2MSRoutingViewController.h"
#import "P2MSMapHelper.h"
#import "P2MSSearchDisplayViewController.h"
#import "P2MSView.h"
#import "P2MSMap.h"
#import "P2MSSideViewController.h"

#define MAX_ROUTING_STEPS 1000
#define MAX_TABLE_VIEW 100

typedef enum {
    PAN_VIEW_NONE,
    PAN_VIEW_SEARCH,
    PAN_VIEW_ROUTE
}PAN_VIEW_TYPE;

typedef enum {
    MAP_TYPE_NONE,
    MAP_TYPE_APPLE,
    MAP_TYPE_GOOGLE,
    MAP_TYPE_ESRI
}MAP_TYPE;

typedef enum {
    MAP_API_SOURCE_NONE,
    MAP_API_SOURCE_GOOGLE
}MAP_API_SOURCE;

@interface P2MSMapViewController : UIViewController<P2MSRoutingViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, NSURLConnectionDelegate, P2MSSearchDisplayViewControllerDelegate, P2MSSearchBarDelegate, P2MSViewDelegate, P2MSMapDelegate, P2MSSideViewControllerDelegate>

@property (nonatomic) MAP_TYPE mapType;
@property (nonatomic) MAP_API_SOURCE mapAPISource;
@property (nonatomic) BOOL allowDroppedPin;

- (void)setDefaultLocation:(NSString *)locNameToGo withCoordinate:(CLLocationCoordinate2D)locToGo;

@end
