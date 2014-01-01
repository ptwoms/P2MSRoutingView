//
//  P2MSRoutingViewController.h
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 29/10/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "P2MSMapHelper.h"
#import "P2MSMapAPI.h"

typedef enum {
    TBL_CELL_NONE,
    TBL_SUGGESTION_CELL,
    TBL_DIRECTION_CELL,
    TBL_LOADING_CELL
}TABLE_CELL_DISPLAY_TYPE;

@class P2MSRoutingViewController;

@protocol P2MSRoutingViewControllerDelegate <NSObject>

- (void)routingViewWillClose:(P2MSRoutingViewController *)routingView withRoutes:(NSArray *)routes andSelectedIndex:(NSInteger)index;

@end


@interface P2MSRoutingViewController : UIViewController<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, NSURLConnectionDelegate>

@property (nonatomic, weak) id<P2MSRoutingViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString *endAddress, *startAddress;
@property (nonatomic, strong) NSString *endLocDescription, *startLocDescription;
@property (nonatomic) NSInteger travel_mode_index;
@property (nonatomic, retain) id<P2MSMapAPI> mapAPIObject;

@end
