//
//  P2MSSearchDisplayViewController.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 10/11/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSSearchDisplayViewController.h"
#import "UIView+P2MSShadowCategory.h"
#import "P2MSGlobalFunctions.h"

@interface P2MSSearchDisplayViewController (){
    UIView *backgroundView;
    CGPoint originalStartPoint;
    CGFloat sizeDiff, originalHeight;
    CGFloat originalCorner;
    
    __weak UIViewController *contentController;
}

@end

@implementation P2MSSearchDisplayViewController

- (id)initWithSearchBar:(P2MSSearchBar *)searchBar contentsController:(UIViewController *)viewC{
    self = [super init];
    if (self) {
        _searchBar = searchBar;
        _searchBar.txtField.delegate = self;
        [_searchBar.txtField removeTarget:_searchBar action:NULL forControlEvents:UIControlEventEditingChanged];
        [_searchBar.txtField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        
        backgroundView = [[UIView alloc]initWithFrame:viewC.view.bounds];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        backgroundView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.7];
        backgroundView.hidden = YES;
        contentController = viewC;
        [viewC.view addSubview:backgroundView];
        [viewC.view bringSubviewToFront:_searchBar];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapViewTapped:)];
        tapGesture.delegate = self;
        [backgroundView addGestureRecognizer:tapGesture];
        _active = NO;
        self.searchResultsTableView.hidden = YES;
        
        NSNotificationCenter *notif = [NSNotificationCenter defaultCenter];
        [notif addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [notif addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (void)dealloc{
    NSNotificationCenter *notif = [NSNotificationCenter defaultCenter];
    [notif removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [notif removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (IBAction)keyboardWillShow:(NSNotification *)sender{
    CGRect keyboardRect = [[[sender userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect actualFrame = [contentController.view convertRect:keyboardRect fromView:contentController.view.window];
    self.searchResultsTableView.contentInset = UIEdgeInsetsMake(0, 0, actualFrame.size.height, 0);
    if (_delegate && [_delegate respondsToSelector:@selector(p2msSearchDisplayController:keyboardWillShow:WithHeight:)]) {
        [_delegate  p2msSearchDisplayController:self keyboardWillShow:YES WithHeight:actualFrame.size.height];
    }
}

- (IBAction)keyboardWillHide:(NSNotification *)sender{
    self.searchResultsTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    if (_delegate && [_delegate respondsToSelector:@selector(p2msSearchDisplayController:keyboardWillShow:WithHeight:)]) {
        [_delegate  p2msSearchDisplayController:self keyboardWillShow:NO WithHeight:0];
    }
}

- (IBAction)textFieldChanged:(id)sender{
    if (!_active) {
        return;
    }
    NSString *string = _searchBar.txtField.text;
    if (_searchBar.delegate && [_searchBar.delegate respondsToSelector:@selector(p2msSearchBar:textDidChange:)]) {
        [_searchBar.delegate p2msSearchBar:_searchBar textDidChange:string];
    }
    if (string.length) {
        self.searchResultsTableView.hidden = NO;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(p2msSearchDisplayController:shouldReloadTableForSearchString:)]) {
        [_delegate p2msSearchDisplayController:self shouldReloadTableForSearchString:string];
    }
}

- (UITableView *)searchResultsTableView{
    if (!_searchResultsTableView) {
        CGFloat topPadding = [P2MSGlobalFunctions sharedInstance].isIOS_7_OR_LATER * 20;
        CGFloat startY = 50 + topPadding;
        _searchResultsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, startY, backgroundView.frame.size.width, backgroundView.frame.size.height - startY) style:UITableViewStylePlain];
        _searchResultsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [backgroundView addSubview:_searchResultsTableView];
    }
    return _searchResultsTableView;
}

- (void)setSearchResultsDataSource:(id)searchResultsDataSource{
    self.searchResultsTableView.dataSource = searchResultsDataSource;
}

- (void)setSearchResultsDelegate:(id)searchResultsDelegate{
    self.searchResultsTableView.delegate = searchResultsDelegate;
}

- (void)setActive:(BOOL)active{
    _active = active;
    if (active) {
        backgroundView.hidden = NO;
        CGFloat headerViewHeight = 50;
        CGFloat topPadding = [P2MSGlobalFunctions sharedInstance].isIOS_7_OR_LATER * 20;
        originalStartPoint = _searchBar.frame.origin;
        sizeDiff = backgroundView.bounds.size.width-_searchBar.bounds.size.width;
        originalHeight = _searchBar.frame.size.height;
        CGRect curRect = CGRectMake(0, 0, backgroundView.bounds.size.width, headerViewHeight + topPadding);
        CGRect txtFrame = CGRectMake(10, ((50 - _searchBar.txtField.frame.size.height)/2) + topPadding, curRect.size.width - 80, _searchBar.txtField.frame.size.height);
        originalCorner = _searchBar.layer.cornerRadius;
        _searchBar.layer.cornerRadius = 0;
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:17];
        [cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        cancelBtn.frame = CGRectMake(backgroundView.bounds.size.width-70, 10+topPadding, 60, 30);
        cancelBtn.backgroundColor = [UIColor clearColor];
        cancelBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [cancelBtn addTarget:self action:@selector(tapViewTapped:) forControlEvents:UIControlEventTouchUpInside];
        cancelBtn.tag = 12345;
        
        [UIView animateWithDuration:0.2 animations:^{
            _searchBar.frame = curRect;
            _searchBar.txtField.frame = txtFrame;
        }completion:^(BOOL finished) {
            [_searchBar addSubview:cancelBtn];
        }];
    }else{
        backgroundView.hidden = YES;
        _searchBar.layer.cornerRadius = originalCorner;
        [[_searchBar viewWithTag:12345] removeFromSuperview];
        [_searchBar.txtField resignFirstResponder];
        
        CGFloat searchBarWidth = backgroundView.bounds.size.width-sizeDiff;
        CGRect txtFieldRect = CGRectMake(10, 0, [_searchBar textFieldWidthForParentWidth:searchBarWidth andOtherViewsHidden:NO], originalHeight);

        [UIView animateWithDuration:0.25 animations:^{
            _searchBar.frame = CGRectMake(originalStartPoint.x, originalStartPoint.y, searchBarWidth, originalHeight);
            _searchBar.txtField.frame = txtFieldRect;
        }];
    }
}

- (IBAction)tapViewTapped:(id)sender{
    self.active = NO;
    _searchBar.txtField.text = @"";
    if (_delegate && [_delegate respondsToSelector:@selector(p2msSearchDisplayControllerDidEndSearch:)]) {
        [_delegate p2msSearchDisplayControllerDidEndSearch:self];
    }
    
    if (_searchBar.delegate && [_searchBar.delegate respondsToSelector:@selector(p2msSearchBarTextDidEndEditing:)]) {
        [_searchBar.delegate p2msSearchBarTextDidEndEditing:_searchBar];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    UITableView *tableView = self.searchResultsTableView;
    CGPoint touchPoint = [touch locationInView:tableView];
    return ![tableView hitTest:touchPoint withEvent:nil];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    BOOL searchBegin = YES;
    if (_searchBar.delegate && [_searchBar.delegate respondsToSelector:@selector(p2msSearchBarShouldBeginEditing:)]) {
        searchBegin = [_searchBar.delegate p2msSearchBarShouldBeginEditing:_searchBar];
    }
    if (searchBegin) {
        if (_delegate && [_delegate respondsToSelector:@selector(p2msSearchDisplayControllerWillBeginSearch:)]) {
            [_delegate p2msSearchDisplayControllerWillBeginSearch:self];
        }
        [_searchBar additionalViewsHidden:YES];
    }
    return searchBegin;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    BOOL searchEnd = YES;
    if (_searchBar.delegate && [_searchBar.delegate respondsToSelector:@selector(p2msSearchBarShouldEndEditing:)]) {
        searchEnd = [_searchBar.delegate p2msSearchBarShouldEndEditing:_searchBar];
    }
    if (searchEnd) {
        if (_delegate && [_delegate respondsToSelector:@selector(p2msSearchDisplayControllerWillEndSearch:)]) {
            [_delegate p2msSearchDisplayControllerWillEndSearch:self];
        }
        [_searchBar additionalViewsHidden:NO];
    }
    return searchEnd;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (_active) {
        return;
    }
    self.active  = YES;
    if (_delegate && [_delegate respondsToSelector:@selector(p2msSearchDisplayControllerDidBeginSearch:)]) {
        [_delegate p2msSearchDisplayControllerDidBeginSearch:self];
    }
    
    if (_searchBar.delegate && [_searchBar.delegate respondsToSelector:@selector(p2msSearchBarTextDidBeginEditing:)]) {
        [_searchBar.delegate p2msSearchBarTextDidBeginEditing:_searchBar];
    }
    
    if (textField.text.length) {
        [_searchResultsTableView reloadData];
    }else
        self.searchResultsTableView.hidden = YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    if (_delegate && [_delegate respondsToSelector:@selector(p2msSearchDisplayControllerDidEndSearch:)]) {
        [_delegate p2msSearchDisplayControllerDidEndSearch:self];
    }
    
    if (_searchBar.delegate && [_searchBar.delegate respondsToSelector:@selector(p2msSearchBarTextDidEndEditing:)]) {
        [_searchBar.delegate p2msSearchBarTextDidEndEditing:_searchBar];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    if (_searchBar.delegate && [_searchBar.delegate respondsToSelector:@selector(p2msSearchBar:textDidChange:)]) {
//        [_searchBar.delegate p2msSearchBar:_searchBar textDidChange:string];
//    }
//    if (string.length) {
//        self.searchResultTableView.hidden = NO;
//    }
//    if (_delegate && [_delegate respondsToSelector:@selector(p2msSearchDisplayController:shouldReloadTableForSearchString:)]) {
//        [_delegate p2msSearchDisplayController:self shouldReloadTableForSearchString:string];
//    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    if (_searchBar.delegate && [_searchBar.delegate respondsToSelector:@selector(p2msSearchBar:textDidChange:)]) {
        [_searchBar.delegate p2msSearchBar:_searchBar textDidChange:nil];
    }
    self.searchResultsTableView.hidden = YES;
    return YES;
}

@end
