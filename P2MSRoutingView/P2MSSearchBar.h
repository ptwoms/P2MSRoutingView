//
//  P2MSSearchBar.h
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 6/11/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <UIKit/UIKit.h>

@class P2MSSearchBar;

@protocol P2MSSearchBarDelegate <NSObject>

@optional
- (void)p2msSearchBar:(P2MSSearchBar *)searchBar textDidChange:(NSString *)searchText;

- (BOOL)p2msSearchBarShouldBeginEditing:(P2MSSearchBar *)searchBar;
- (BOOL)p2msSearchBarShouldEndEditing:(P2MSSearchBar *)searchBar;

- (void)p2msSearchBarTextDidBeginEditing:(P2MSSearchBar *)searchBar;
- (void)p2msSearchBarTextDidEndEditing:(P2MSSearchBar *)searchBar;

@end

@interface P2MSSearchBar : UIView<UITextFieldDelegate>

@property (nonatomic, weak) id<P2MSSearchBarDelegate> delegate;
@property (nonatomic, retain) UITextField *txtField;

- (void)pushAdditionalViewAtRight:(UIView *)button;
- (void)additionalViewsHidden:(BOOL)hidden;
- (CGFloat)textFieldFinalWidth:(BOOL)hidden;
- (CGFloat)textFieldWidthForParentWidth:(CGFloat)searchBarWidth andOtherViewsHidden:(BOOL)hidden;
- (void)clearAdditionalViews;

@end
