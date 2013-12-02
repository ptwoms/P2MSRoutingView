//
//  P2MSShadowView.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 5/11/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSShadowView.h"

@implementation P2MSShadowView

//+(Class) layerClass {
//    return [CALayer class];
//}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = NO;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 0.3;
        _hasShadow = NO;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self drawShadowPath];
}

- (void)setHasShadow:(BOOL)hasShadow{
    _hasShadow = hasShadow;
    [self drawShadowPath];
}

- (void)drawShadowPath{
    CGRect curRect = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPath];
    if (_hasShadow) {
        [path moveToPoint:CGPointMake(curRect.origin.x+5, curRect.origin.y+2)];
        [path addLineToPoint:CGPointMake(curRect.size.width-5, curRect.origin.y+2)];
        [path addLineToPoint:CGPointMake(curRect.size.width-5, curRect.size.height + 2)];
        [path addLineToPoint:CGPointMake(curRect.origin.x+5, curRect.size.height + 2)];
        self.layer.shadowRadius = 2.5;
        self.layer.shadowPath = path.CGPath;
    }else{
        self.layer.shadowRadius = 0;
        self.layer.shadowPath = nil;
    }
}


@end
