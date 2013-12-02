//
//  P2MSSearchDisplayViewController.h
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 10/11/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "P2MSSearchBar.h"

@class P2MSSearchDisplayViewController;

@protocol P2MSSearchDisplayViewControllerDelegate <NSObject>

@optional

- (void)p2msSearchDisplayControllerWillBeginSearch:(P2MSSearchDisplayViewController *)controller;
- (void)p2msSearchDisplayControllerDidBeginSearch:(P2MSSearchDisplayViewController *)controller;
- (void)p2msSearchDisplayControllerWillEndSearch:(P2MSSearchDisplayViewController *)controller;
- (void)p2msSearchDisplayControllerDidEndSearch:(P2MSSearchDisplayViewController *)controller;
- (BOOL)p2msSearchDisplayController:(P2MSSearchDisplayViewController *)controller shouldReloadTableForSearchString:(NSString *)searchString;

- (void)p2msSearchDisplayController:(P2MSSearchDisplayViewController *)controller keyboardWillShow:(BOOL)show WithHeight:(CGFloat)height;

@end

@interface P2MSSearchDisplayViewController : NSObject<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<P2MSSearchDisplayViewControllerDelegate> delegate;
@property (nonatomic, retain) UITableView *searchResultsTableView;
@property (nonatomic, weak) id searchResultsDataSource, searchResultsDelegate;
@property (nonatomic, weak) P2MSSearchBar *searchBar;

- (id)initWithSearchBar:(P2MSSearchBar *)searchBar contentsController:(id)delegate;

@property(nonatomic, getter = isActive) BOOL active;

@end
