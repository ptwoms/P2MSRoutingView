//
//  UIView+P2MSShadowCategory.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 5/11/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "UIView+P2MSShadowCategory.h"

@implementation UIView (P2MSShadowCategory)

- (void)setShadowForOffset:(CGSize)offset withRadius:(CGFloat)radius{
    self.clipsToBounds = NO;
    self.layer.shadowOffset = offset;
    self.layer.shadowRadius = radius;
    self.layer.shadowOpacity = 0.3;
    self.layer.shadowColor = [UIColor grayColor].CGColor;
}

@end
