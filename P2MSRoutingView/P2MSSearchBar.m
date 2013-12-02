//
//  P2MSSearchBar.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 6/11/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSSearchBar.h"
#import "P2MSGlobalFunctions.h"
#import "UIView+P2MSShadowCategory.h"

@implementation P2MSSearchBar{
    NSMutableArray *buttonArray;
    CGFloat occupiedWidth;
    CGFloat buttonGap;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self setShadowForOffset:CGSizeMake(0, 2) withRadius:2];
        self.layer.cornerRadius = 6;
        
        occupiedWidth = 0;
        buttonGap = 10;
        
        _txtField = [[UITextField alloc]initWithFrame:CGRectMake(10, 0, frame.size.width-20 - occupiedWidth, frame.size.height)];
        _txtField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _txtField.borderStyle = UITextBorderStyleNone;
        _txtField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _txtField.font = [UIFont systemFontOfSize:14];
        UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"search"]];
        imgView.frame = CGRectMake(0, 0, 22, 26);
        _txtField.leftView = imgView;
        _txtField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _txtField.leftViewMode = UITextFieldViewModeAlways;
        _txtField.clearButtonMode = UITextFieldViewModeWhileEditing;
        [_txtField setBackgroundColor:[UIColor clearColor]];
        [_txtField setBackground:[P2MSGlobalFunctions imageWithColor:[UIColor whiteColor] forRect:CGRectMake(0, 0, 10, 10)]];
        _txtField.delegate = self;
        [self addSubview:_txtField];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (IBAction)orientationChanged:(NSNotification *)sender{
//    occupiedWidth = 0;
//    for (UIView *view in buttonArray) {
//        occupiedWidth += view.bounds.size.width + buttonGap;
//    }
}

- (void)additionalViewsHidden:(BOOL)hidden{
    for (UIView *view in buttonArray) {
        view.hidden = hidden;
    }
    CGRect curRect = _txtField.bounds;
    curRect.origin.x = 10;
    curRect.size.width = self.bounds.size.width - 20 - (occupiedWidth * !hidden);
    _txtField.frame = curRect;
}

- (CGFloat)textFieldWidthForParentWidth:(CGFloat)searchBarWidth andOtherViewsHidden:(BOOL)hidden{
    return searchBarWidth - 20 - (occupiedWidth * !hidden);
}

- (CGFloat)textFieldFinalWidth:(BOOL)hidden{
    return self.bounds.size.width - 20 - (occupiedWidth * !hidden);
}

- (void)clearAdditionalViews{
    occupiedWidth = 0;
    for (UIView *btn in buttonArray) {
        [btn removeFromSuperview];
    }
    [buttonArray removeAllObjects];
}

- (void)pushAdditionalViewAtRight:(UIView *)button{
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    occupiedWidth += button.bounds.size.width + buttonGap;
    CGFloat startX = self.bounds.size.width - 10 - occupiedWidth + buttonGap;
    
    for (UIView *curView in buttonArray) {
        curView.frame = CGRectMake(startX, curView.frame.origin.y, curView.bounds.size.width, curView.bounds.size.height);
        startX += curView.frame.size.width + buttonGap;
    }
    if (!buttonArray) {
        buttonArray = [NSMutableArray array];
    }
    [buttonArray addObject:button];
    CGRect curRect = button.frame;
    curRect.origin.x = startX;
    curRect.origin.y = (self.bounds.size.height-button.bounds.size.height)/2;
    button.frame = curRect;
    [self addSubview:button];
    
    curRect = _txtField.bounds;
    curRect.origin.x = 10;
    curRect.size.width = self.bounds.size.width - 20 - occupiedWidth;
    _txtField.frame = curRect;
}

- (IBAction)textChanged:(id)sender{
    NSString *string = _txtField.text;
    if ([_delegate respondsToSelector:@selector(p2msSearchBar:textDidChange:)]) {
        [_delegate p2msSearchBar:self textDidChange:string];
    }
}

- (void)searchBarSetText:(NSString *)text{
    _txtField.text = text;
    _txtField.frame = CGRectMake(10, 0, self.bounds.size.width-60, self.bounds.size.height);
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake(0, 0, 40, 40);
    [self addSubview:cancelBtn];
}

@end
