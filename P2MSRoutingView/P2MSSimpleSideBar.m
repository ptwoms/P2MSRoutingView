//
//  P2MSSideBar.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 6/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSSimpleSideBar.h"


@interface P2MSSimpleSideBar(){
    P2MSView *overlayView;
    
}
@property (nonatomic, assign) CGPoint panGestureOrigin;

@end

@implementation P2MSSimpleSideBar

- (void)initSideBar:(UIViewController *)sideVC withVC:(UIViewController *)rootViewController andSideWidth:(CGFloat)sideWidth{
    _state = SIDEBAR_CLOSE;
    _sideMenuController = sideVC;
    _rootViewController = rootViewController;
    CGRect sideFrame = _sideMenuController.view.bounds;
    sideFrame.size.width = sideWidth;
    sideFrame.origin.x = -sideFrame.size.width;
    sideFrame.origin.y = 0;
    _sideMenuController.view.frame = sideFrame;
    _sideMenuController.view.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    [_rootViewController addChildViewController:_sideMenuController];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [_sideMenuController.view addGestureRecognizer:panGesture];
    
}

- (void)setHandleView:(UIView *)touchView{
    UIPanGestureRecognizer *panGesture1 = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePan:)];
    [touchView addGestureRecognizer:panGesture1];
}

- (IBAction)longPress:(UILongPressGestureRecognizer *)recognizer{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGRect curFrame = _sideMenuController.view.frame;
        curFrame.origin.x += 10;
        _sideMenuController.view.frame = curFrame;
    }
}


- (void)closePaneView:(id)sender{
    
}

- (P2MSView *)overlayView{
    if (!overlayView) {
        overlayView = [[P2MSView alloc]initWithFrame:_rootViewController.view.bounds];
        overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [_rootViewController.view insertSubview:overlayView belowSubview:_sideMenuController.view];
        overlayView.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1];
        overlayView.delegate  = self;
    }
    return overlayView;
}

- (IBAction)handlePan:(UIPanGestureRecognizer *)recognizer {
    UIView *view = [_sideMenuController view];
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        _panGestureOrigin = view.frame.origin;
        [self overlayView];
    }
    
    CGPoint translatedPoint = [recognizer translationInView:view];
    CGPoint adjustedOrigin = _panGestureOrigin;
    CGPoint finalPoint = CGPointMake(adjustedOrigin.x + translatedPoint.x,
                                     adjustedOrigin.y + translatedPoint.y);
    
    finalPoint.x = MIN(MAX(-view.bounds.size.width+10, finalPoint.x), 0);
    CGRect frame = _sideMenuController.view.frame;
    frame.origin.x = finalPoint.x;
    [UIView animateWithDuration:0.06 animations:^{
        _sideMenuController.view.frame = frame;
    }];
    overlayView.alpha = ((_sideMenuController.view.bounds.size.width+finalPoint.x)/_sideMenuController.view.bounds.size.width)*0.7;
    
    if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGPoint velocity = [recognizer velocityInView:self.rootViewController.view];
        CGFloat finalX = translatedPoint.x + (.35*velocity.x);
        NSLog(@"FInal X %f, %f, %f", finalX, translatedPoint.x, velocity.x);
        CGFloat viewWidth = self.sideMenuController.view.bounds.size.width;
        [self setSideMenuHidden:finalX<(-viewWidth * 0.25) animated:YES];
    }
}

- (void)setState:(SIDEBAR_STATE)state{
    [self setSideMenuHidden:(state == SIDEBAR_CLOSE) animated:YES];
}

- (void)setSideMenuHidden:(BOOL)hidden animated:(BOOL)animated{
    CGRect finalRect = _sideMenuController.view.bounds;
    CGFloat overlayAlpha;
    if (hidden) {
        overlayAlpha = 0;
        _state = SIDEBAR_CLOSE;
        finalRect.origin.x = -_sideMenuController.view.bounds.size.width;
    }else{
        [self overlayView];
        _state = SIDEBAR_OPEN;
        finalRect.origin.x = 0;
        overlayAlpha = 0.7;
    }
    [UIView animateWithDuration:0.25*animated animations:^{
        _sideMenuController.view.frame = finalRect;
        overlayView.alpha = overlayAlpha;
    }completion:^(BOOL finished) {
        if (hidden) {
            [overlayView removeFromSuperview];
            overlayView = nil;
        }
    }];
}

- (void)didTouchView:(UIView *)view atPoint:(CGPoint)point{
    self.state = SIDEBAR_CLOSE;
}
@end
