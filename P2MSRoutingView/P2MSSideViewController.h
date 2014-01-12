//
//  P2MSSideViewController.h
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 6/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "P2MSSimpleSideBar.h"

@class P2MSSideViewController;

@protocol P2MSSideViewControllerDelegate <NSObject>

- (void)doActionForSideViewController:(P2MSSideViewController *)viewC withCommand:(NSString *)command;

@end

@interface P2MSSideViewController : UIViewController//<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, assign) P2MSSimpleSideBar *sideBar;
@property (nonatomic, unsafe_unretained) id<P2MSSideViewControllerDelegate> delegate;

@end
