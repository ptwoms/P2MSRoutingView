//
//  P2MSActivityIndicator.m
//
//  Created by PYAE PHYO MYINT SOE on 29/10/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSActivityIndicator.h"
#import <QuartzCore/QuartzCore.h>


@implementation P2MSActivityIndicator{
     
}

//static UIImageView *activityIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (void) showIndicatorInView:(UIView *)view{
    [P2MSActivityIndicator hideIndicatorForView:view];
    UIImageView *activityIndicator = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 50.0, 50.0)];
    [activityIndicator setImage:[UIImage imageNamed:@"loading_1"]];
    activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    activityIndicator.tag = 623;
    [view addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(view.frame.size.width/2, view.frame.size.height/2);
    
    CAKeyframeAnimation *theAnimation = [CAKeyframeAnimation animation];
    double PI_VAL = M_PI;
    double PI_VAL_2 = M_PI_2;
	theAnimation.values = [NSArray arrayWithObjects:
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0,0,1)],
                           [NSValue valueWithCATransform3D:CATransform3DMakeRotation(PI_VAL_2, 0,0,1)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(PI_VAL, 0,0,1)],
                           [NSValue valueWithCATransform3D:CATransform3DMakeRotation(PI_VAL_2*3, 0,0,1)],
						   [NSValue valueWithCATransform3D:CATransform3DMakeRotation(PI_VAL*2, 0,0,1)],//6.26
						   nil];
	theAnimation.cumulative = YES;
    theAnimation.duration = 5.0f;
	theAnimation.repeatCount = HUGE_VALF;
    theAnimation.speed = 3.0f;
    theAnimation.rotationMode = kCAAnimationPaced;
	theAnimation.removedOnCompletion = NO;
    theAnimation.fillMode = kCAFillModeForwards;
    theAnimation.timingFunctions = [NSArray arrayWithObjects:
                                    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                    [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                    nil];
	[activityIndicator.layer addAnimation:theAnimation forKey:@"transform"];    
}

+ (void) hideIndicatorForView:(UIView *)view{
    UIView *myView = [view viewWithTag:623];
    if (myView) {
        [myView.layer removeAllAnimations];
        [myView removeFromSuperview];
    }
}

@end
