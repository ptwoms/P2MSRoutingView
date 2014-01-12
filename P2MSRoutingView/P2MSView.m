//
//  P2MSView.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 7/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSView.h"

@implementation P2MSView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

//skip insertsubview methods overriding
//- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index{
//}

- (void)didAddSubview:(UIView *)subview{
    [super didAddSubview:subview];
    if ([_delegate respondsToSelector:@selector(didAddSubView:subView:)]) {
        [_delegate didAddSubView:self subView:subview];
    }
}

- (void)bringSubviewToFront:(UIView *)view{
    [super bringSubviewToFront:view];
    if ([_delegate respondsToSelector:@selector(didBringSubViewToFront:subView:)]) {
        [_delegate didBringSubViewToFront:self subView:view];
    }
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if ([_delegate respondsToSelector:@selector(didTouchView:atPoint:)]) {
        [_delegate didTouchView:self atPoint:CGPointZero];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
