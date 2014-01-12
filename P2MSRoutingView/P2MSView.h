//
//  P2MSView.h
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 7/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol P2MSViewDelegate <NSObject>

@optional
- (void)didAddSubView:(UIView *)veiw subView:(UIView *)subView;
- (void)didBringSubViewToFront:(UIView *)veiw subView:(UIView *)subView;
- (void)didTouchView:(UIView *)view atPoint:(CGPoint)point;
@end

@interface P2MSView : UIView

@property (nonatomic, unsafe_unretained) id<P2MSViewDelegate> delegate;

@end
