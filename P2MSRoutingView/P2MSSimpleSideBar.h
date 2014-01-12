//
//  P2MSSideBar.h
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 6/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2MSView.h"


typedef enum {
    SIDEBAR_CLOSE,
    SIDEBAR_OPEN
}SIDEBAR_STATE;

@interface P2MSSimpleSideBar : NSObject<P2MSViewDelegate>

@property (nonatomic, retain, readonly) UIViewController *sideMenuController;
@property (nonatomic, assign) UIViewController *rootViewController;
@property (nonatomic) SIDEBAR_STATE state;


- (void)initSideBar:(UIViewController *)sideVC withVC:(UIViewController *)rootViewController andSideWidth:(CGFloat)sideWidth;
- (void)setHandleView:(UIView *)touchView;
- (void)setSideMenuHidden:(BOOL)hidden animated:(BOOL)animated;

@end
