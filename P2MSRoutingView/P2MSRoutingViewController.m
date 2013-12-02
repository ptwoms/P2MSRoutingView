//
//  P2MSRoutingViewController.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 29/10/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSRoutingViewController.h"
#import "P2MSGoogleMapHelper.h"
#import "P2MSGlobalFunctions.h"
#import "LocationManager.h"
#import "JSONKit.h"
#import "P2MSDirectionView.h"
#import "P2MSActivityIndicator.h"

@interface P2MSRoutingViewController (){
    NSUInteger prevSegmentIndex;
    
    UITableView *suggestionView;
    P2MSNetworkRequest *curRequest;
    NSArray *locSuggestions;
    NSArray *allRoutes;
    TABLE_CELL_DISPLAY_TYPE cell_type_to_display;
    
    UITextField *startTextField, *endTextField;
    NSString *nextTextToSearch;
    
    NSString *curTravelMode;
    NSMutableData *receivedData;
}

@end

@implementation P2MSRoutingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _travel_mode_index = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    cell_type_to_display = TBL_CELL_NONE;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    CGFloat topPadding = ([P2MSGlobalFunctions sharedInstance].isIOS_7_OR_LATER*20);
    CGRect curRect = CGRectMake(0, 0, self.view.bounds.size.width, 44 + topPadding);
    UIImageView *toolbar = [[UIImageView alloc]initWithFrame:curRect];
    toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:toolbar];
    UIImage *backgroundImage = [P2MSGlobalFunctions getFlatImage:STD_GRADIENT_BAR_BACKGROUND_START_COLOR end:STD_GRADIENT_BAR_BACKGROUND_END_COLOR forSize:CGSizeMake(10, 45)];
    [toolbar setImage:[backgroundImage stretchableImageWithLeftCapWidth:5 topCapHeight:0]];
    toolbar.userInteractionEnabled = YES;
    
    CGFloat segmentHeight = 38.0f;
    UISegmentedControl *segment = [[UISegmentedControl alloc]initWithFrame:CGRectMake(0, 2+topPadding, 160, segmentHeight)];
    [segment insertSegmentWithImage:[UIImage imageNamed:@"car"] atIndex:0 animated:NO];
    [segment insertSegmentWithImage:[UIImage imageNamed:@"walk"] atIndex:1 animated:NO];
    [segment insertSegmentWithImage:[UIImage imageNamed:@"bus"] atIndex:2 animated:NO];
    [segment setBackgroundImage:[P2MSGlobalFunctions imageWithColor:[UIColor whiteColor]forRect:CGRectMake(0, 0, 1, segmentHeight)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [segment setBackgroundImage:[P2MSGlobalFunctions imageWithColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0]forRect:CGRectMake(0, 0, 1, segmentHeight)] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [segment setDividerImage:[P2MSGlobalFunctions imageWithColor:[UIColor whiteColor]forRect:CGRectMake(0, 0, 2, 1)] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [segment setDividerImage:[P2MSGlobalFunctions imageWithColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] forRect:CGRectMake(0, 0, 2, 1)] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    segment.layer.cornerRadius = 5.0f;
    NSInteger lastIndex = 0;
    if (_travel_mode_index >= 0) {
        lastIndex = _travel_mode_index;
    }else{
        NSUserDefaults *stdUser = [NSUserDefaults standardUserDefaults];
        NSNumber *direcionType = [stdUser objectForKey:LAST_USED_DIRECTION_TYPE];
        if (direcionType) {
            lastIndex = [direcionType integerValue];
        }else{
            [stdUser setObject:[NSNumber numberWithInteger:lastIndex] forKey:LAST_USED_DIRECTION_TYPE];
            [stdUser synchronize];
        }
    }
    [segment setSelectedSegmentIndex:lastIndex];
    [self updateSegmentAppearance:segment];
    curTravelMode = [self getCurrentTravelMode:prevSegmentIndex];
    
    segment.clipsToBounds = YES;
    segment.layer.borderColor = [UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0].CGColor;
    segment.layer.borderWidth = 1.5;
    [segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    segment.segmentedControlStyle = UISegmentedControlStylePlain;
    segment.center = CGPointMake(toolbar.frame.size.width/2, segment.center.y);
    segment.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [toolbar addSubview:segment];
    
    CGFloat widthToFill = self.view.bounds.size.width;
    curRect.origin.y += curRect.size.height;
    curRect.size.width = widthToFill;
    curRect.size.height = 105;
    UIView *paneView = [[UIView alloc]initWithFrame:curRect];
    paneView.backgroundColor = [UIColor whiteColor];
    paneView.layer.shadowColor = [UIColor lightGrayColor].CGColor;
    paneView.layer.shadowOffset = CGSizeMake(0, 1.0f);
    paneView.layer.shadowOpacity = 0.8;
    paneView.layer.shadowRadius = 0.8;
    paneView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:paneView];
    UIButton *switchDestination = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 31, 33)];
    [switchDestination setImage:[UIImage imageNamed:@"switch_dest"] forState:UIControlStateNormal];
    switchDestination.center = CGPointMake(26, paneView.frame.size.height/2);
    [switchDestination addTarget:self action:@selector(switchDestinations:) forControlEvents:UIControlEventTouchUpInside];
    [paneView addSubview:switchDestination];
    
    startTextField = [self getTextFieldWithTextForRect:CGRectMake(53, 15, widthToFill-65, 37) andLeftText:@"Start:"];
    startTextField.returnKeyType = UIReturnKeyNext;
    [paneView addSubview:startTextField];
    if (!self.startAddress) {
        startTextField.text = @"Current Location";
        _startAddress = @"Current Location";
        startTextField.textColor = [UIColor blueColor];
    }else{
        startTextField.text = self.startAddress;
    }
    startTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    endTextField = [self getTextFieldWithTextForRect:CGRectMake(53, 57, widthToFill-65, 37) andLeftText:@"End:"];
    endTextField.returnKeyType = UIReturnKeyRoute;
    endTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [paneView addSubview:endTextField];
    
    if (_endAddress) {
        endTextField.text = _endAddress;
    }
    
    CGFloat tableViewY = paneView.frame.origin.y+paneView.frame.size.height+2;
    suggestionView = [[UITableView alloc]initWithFrame:CGRectMake(0, tableViewY, widthToFill, self.view.bounds.size.height-tableViewY)];
    suggestionView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    suggestionView.delegate = self;
    suggestionView.dataSource = self;
    suggestionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:suggestionView];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(7, 5+topPadding, 60, 30);
    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:18];
    [button setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [button addTarget:self action:@selector(closeRoutingView:) forControlEvents:UIControlEventTouchUpInside];
    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [toolbar addSubview:button];
    
    UIButton *routeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    routeBtn.frame = CGRectMake(toolbar.frame.size.width-57, 5+topPadding, 50, 30);
    [routeBtn setTitle:@"Route" forState:UIControlStateNormal];
    routeBtn.titleLabel.font = [UIFont systemFontOfSize:18];
    [routeBtn setTitleColor:[UIColor colorWithRed:0.0 green:0.5 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [routeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    routeBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [routeBtn addTarget:self action:@selector(doRouting:) forControlEvents:UIControlEventTouchUpInside];
    [toolbar addSubview:routeBtn];

    [P2MSGlobalFunctions hidePoweredByGoogleLogo:NO inView:self.view forRect:CGRectMake(self.view.bounds.size.width - 109, self.view.bounds.size.height - 20, 104, 16)];
}

- (IBAction)closeRoutingView:(id)sender{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (_endAddress) {
        [self doRouting:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (UITextField *)getTextFieldWithTextForRect:(CGRect)rect andLeftText:(NSString *)leftText{
    UITextField *startLoc = [[UITextField alloc]initWithFrame:rect];
    startLoc.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    startLoc.delegate = self;
    startLoc.borderStyle = UITextBorderStyleNone;
    startLoc.layer.borderColor = [UIColor lightGrayColor].CGColor;
    startLoc.layer.borderWidth = 1;
    startLoc.layer.cornerRadius = 3;
    startLoc.enablesReturnKeyAutomatically = YES;
    
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 55, 37)];
    UILabel *startLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 50, 37)];
    startLabel.textColor = [UIColor lightGrayColor];
    startLabel.backgroundColor = [UIColor clearColor];
    startLabel.text = leftText;
    startLabel.textAlignment = UITextAlignmentRight;
    [leftView addSubview:startLabel];
    
    startLoc.leftView = leftView;
    startLoc.leftViewMode = UITextFieldViewModeAlways;
    startLoc.clearButtonMode = UITextFieldViewModeWhileEditing;
    [startLoc addTarget:self action:@selector(textFieldTextChanged:) forControlEvents:UIControlEventEditingChanged];
    startLoc.clipsToBounds = YES;
    return startLoc;
}

- (IBAction)switchDestinations:(id)sender{
    NSString *tempText  = [startTextField.text copy];
    startTextField.text = [endTextField.text copy];
    endTextField.text = tempText;
    NSString *tempDesc = [_startLocDescription copy];
    _startLocDescription = (_endLocDescription)?[_endLocDescription copy]:nil;
    _endLocDescription = tempDesc;
    [self checkForCurrentLocationColor];
    [self doRouting:sender];
}

- (NSString *)getCurrentTravelMode:(NSInteger)index{
    switch (index) {
        case 0:return @"driving";break;
        case 1:return @"walking";break;
        default:return @"transit";break;
    }
}

- (IBAction)segmentAction:(UISegmentedControl *)sender{
    [self updateSegmentAppearance:sender];
    curTravelMode = [self getCurrentTravelMode:sender.selectedSegmentIndex];
    [self doRouting:sender];
}

- (void)updateSegmentAppearance:(UISegmentedControl *)sender{
    switch (prevSegmentIndex) {
        case 0:[sender setImage:[UIImage imageNamed:@"car"] forSegmentAtIndex:0];break;
        case 1:[sender setImage:[UIImage imageNamed:@"walk"] forSegmentAtIndex:1];break;
        case 2:[sender setImage:[UIImage imageNamed:@"bus"] forSegmentAtIndex:2];break;
    }
    prevSegmentIndex = sender.selectedSegmentIndex;
    NSUserDefaults *stdUser = [NSUserDefaults standardUserDefaults];
    [stdUser setObject:[NSNumber numberWithInteger:prevSegmentIndex] forKey:LAST_USED_DIRECTION_TYPE];
    [stdUser synchronize];
    
    switch (sender.selectedSegmentIndex) {
        case 0:{
            [sender setImage:[UIImage imageNamed:@"car-highlight"] forSegmentAtIndex:0];
        }break;
        case 1:{
            [sender setImage:[UIImage imageNamed:@"walk-highlight"] forSegmentAtIndex:1];
        }break;
        case 2:{
            [sender setImage:[UIImage imageNamed:@"bus-highlight"] forSegmentAtIndex:2];
        }break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark textField Delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if ([textField isEqual:endTextField]) {
        textField.returnKeyType = (!_startAddress.length)?UIReturnKeyNext:UIReturnKeyRoute;
    }
    return YES;
}
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    if (curRequest) {
        [curRequest cancel];
        curRequest = nil;
    }
    locSuggestions = nil;
    [suggestionView reloadData];
    if (textField.text.length) {
        [self textFieldTextChanged:textField];
    }
}

- (IBAction)textFieldTextChanged:(UITextField *)sender{
    if ([sender isEqual:startTextField]) {
        _startAddress =  sender.text;
    }else
        _endAddress = sender.text;
    BOOL isCurrentLocation = [sender.text caseInsensitiveCompare:@"Current Location"] == NSOrderedSame;
    if (isCurrentLocation) {
        sender.textColor = [UIColor blueColor];
    }else{
        sender.textColor = [UIColor blackColor];
        [self queryAutoComplete:sender.text];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self checkForCurrentLocationColor];
}

- (void)checkForCurrentLocationColor{
    startTextField.textColor = (([startTextField.text caseInsensitiveCompare:@"current location"] == NSOrderedSame))?[UIColor blueColor]:[UIColor blackColor];
    endTextField.textColor = (([endTextField.text caseInsensitiveCompare:@"current location"] == NSOrderedSame))?[UIColor blueColor]:[UIColor blackColor];
}

- (void)queryAutoComplete:(NSString *)textToSearch{
    if (textToSearch.length >= 2 && !curRequest) {
        curRequest = [P2MSGoogleMapHelper getLocationSuggestionsForQuery:textToSearch withCurLocation:[LocationManager sharedInstance].curLoc withDelegate:self];
        if (curRequest) {
            receivedData = [NSMutableData data];
        }
        nextTextToSearch = nil;
    }else if (curRequest){
        nextTextToSearch = textToSearch;
    }else
        nextTextToSearch = nil;
}

- (void)nextSearch{
    [self queryAutoComplete:nextTextToSearch];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:startTextField]) {
        [endTextField becomeFirstResponder];
    }else{
        if (textField.returnKeyType == UIReturnKeyRoute) {
            [textField resignFirstResponder];
            [self doRouting:nil];
        }else{
            [startTextField becomeFirstResponder];
        }
    }
    return YES;
}

- (IBAction)doRouting:(id)sender{
    if (_startAddress.length && _endAddress.length) {
        CLLocationCoordinate2D curLoc = [LocationManager sharedInstance].curLoc;
        BOOL isCurStart;
        if ((isCurStart = ([_startLocDescription caseInsensitiveCompare:@"Current Location"] == NSOrderedSame)) || [_endLocDescription caseInsensitiveCompare:@"Current Location"] == NSOrderedSame) {
            if (CLLocationCoordinate2DIsValid(curLoc)) {
                if (isCurStart) {
                    _startLocDescription = [NSString stringWithFormat:@"%f,%f", curLoc.latitude, curLoc.longitude];
                }else
                    _endLocDescription = [NSString stringWithFormat:@"%f,%f", curLoc.latitude, curLoc.longitude];
                [self routeRequest];
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Current Location Failed!" message:@"Cannot detect current Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }else{
            [self routeRequest];
        }
    }
}

- (void)routeRequest{
    curRequest = [P2MSGoogleMapHelper getDirectionFromLocation:_startLocDescription to:_endLocDescription  forTravelMode:curTravelMode alternatives:YES withNetworkDelegate:self];
    if (curRequest) {
        cell_type_to_display = TBL_LOADING_CELL;
        [suggestionView reloadData];
        receivedData = [NSMutableData data];
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    locSuggestions = nil;
    if ([textField isEqual:startTextField]) {
        _startAddress = nil;
        _startLocDescription = nil;
    }else{
        _endAddress = nil;
        _endLocDescription = nil;
    }
    [suggestionView reloadData];
    return YES;
}

#pragma mark Query Return
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    curRequest = nil;
    P2MSNetworkRequest *con = (P2MSNetworkRequest *)connection;
    NSDictionary *responseJSON = [receivedData objectFromJSONData];
    if ([[con.userInfo objectForKey:@"req_type"] isEqualToString:@"direction"]) {
        NSString *statusString = [responseJSON objectForKey:@"status"];
        cell_type_to_display = TBL_DIRECTION_CELL;

        if ([statusString isEqualToString:@"OK"]){
            NSArray *arr = [P2MSGoogleMapHelper parseGoogleDirections:[responseJSON objectForKey:@"routes"] forTravelMode:[con.userInfo objectForKey:@"travel_mode"]];
            locSuggestions = nil;
            allRoutes = arr;
            if ([startTextField isFirstResponder]) {
                [startTextField resignFirstResponder];
            }else if ([endTextField isFirstResponder]){
                [endTextField resignFirstResponder];
            }
        }else{
            allRoutes = nil;
            if ([statusString isEqualToString:@"NOT_FOUND"] || [statusString isEqualToString:@"ZERO_RESULTS"]) {
            }else{
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Google Map" message:statusString delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }
        [suggestionView reloadData];
    }else{
        if ([[responseJSON objectForKey:@"status"] isEqualToString:@"OK"]){
            locSuggestions = [P2MSGoogleMapHelper parseSuggestions:[responseJSON objectForKey:@"predictions"]];
            if ([startTextField.text caseInsensitiveCompare:@"Current Location"] != NSOrderedSame && [endTextField.text caseInsensitiveCompare:@"Current Location"] != NSOrderedSame) {
                LocationSuggestion *curLoc = [[LocationSuggestion alloc]init];
                curLoc.name = @"Current Location";
                curLoc.country = nil;
                [((NSMutableArray *)locSuggestions) insertObject:curLoc atIndex:0];
            }
            cell_type_to_display = TBL_SUGGESTION_CELL;
            [suggestionView reloadData];
        }else{
        }
        if (nextTextToSearch) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextSearch) object:nil];
            [self performSelector:@selector(nextSearch) withObject:nil afterDelay:0.1];
        }
    }
    curRequest = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    curRequest = nil;
    receivedData = nil;
}

- (void)dealloc{
    if (curRequest) {
        [curRequest cancel];
        curRequest = nil;
    }
}


#pragma mark TableViewDelegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (cell_type_to_display) {
        case TBL_DIRECTION_CELL:return (allRoutes.count)?allRoutes.count:1;
        case TBL_SUGGESTION_CELL:return (locSuggestions)?locSuggestions.count:0;
        case TBL_LOADING_CELL:return 1;
        default:return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (cell_type_to_display == TBL_DIRECTION_CELL) {
        if (allRoutes && allRoutes.count) {
            OneRoute *curRoute = [allRoutes objectAtIndex:indexPath.row];
            if ([curRoute.travel_mode isEqualToString:@"transit"]) {
                static NSString *RouteCellIdentifier = @"CellRouteTransit";
                cell = [tableView dequeueReusableCellWithIdentifier:RouteCellIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:RouteCellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, self.view.bounds.size.width-20, 20)];
                    title.font = [UIFont systemFontOfSize:16];
                    title.tag = 15;
                    title.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                    [cell addSubview:title];
                    
                    P2MSDirectionView *directView = [[P2MSDirectionView alloc]initWithFrame:CGRectMake(5, 30, self.view.bounds.size.width-10, 35)];
                    directView.tag = 16;
                    directView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                    [cell addSubview:directView];
                    
                    UILabel *viaLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 65, self.view.bounds.size.width-20, 15)];
                    viaLabel.backgroundColor = [UIColor clearColor];
                    viaLabel.font = [UIFont systemFontOfSize:13];
                    viaLabel.textColor = [UIColor grayColor];
                    viaLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
                    viaLabel.tag = 321;
                    [cell addSubview:viaLabel];
                }
                UILabel *titleLabel = (UILabel *)[cell viewWithTag:15];
                titleLabel.text = curRoute.routeOverviewTitle;
                
                UILabel *viaLabel = (UILabel *)[cell viewWithTag:321];
                viaLabel.text = curRoute.viaString;
                
                P2MSDirectionView *directView = (P2MSDirectionView *)[cell viewWithTag:16];
                directView.routeOverview = curRoute.routeOverview;
                
                return cell;
                
            }else{
                static NSString *RouteCellIdentifier = @"CellRoute";
                cell = [tableView dequeueReusableCellWithIdentifier:RouteCellIdentifier];
                if (!cell) {
                    cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:RouteCellIdentifier];
                    cell.selectionStyle = UITableViewCellSelectionStyleGray;
                    cell.textLabel.font = [UIFont systemFontOfSize:16];
                }
                cell.textLabel.text = curRoute.routeOverviewTitle;
                cell.detailTextLabel.text = curRoute.routeOverview;
                return cell;
                
            }
        }else{//NO ROUTE FOUND
            static NSString *NFCellIdentifier = @"CellNotFound";
            cell = [tableView dequeueReusableCellWithIdentifier:NFCellIdentifier];
            if (!cell) {
                cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NFCellIdentifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                UIImageView *imageV = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"no_route"]];
                imageV.frame = CGRectMake(0, 0, 40, 35);
                imageV.center =CGPointMake(cell.bounds.size.width/2, 35);
                imageV.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                [cell.contentView addSubview:imageV];
                
                UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 25)];
                label.text = @"No Route Found";
                label.textColor = [UIColor darkGrayColor];
                label.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                label.textAlignment = UITextAlignmentCenter;
                label.center = CGPointMake(cell.center.x, 65);
                [cell.contentView addSubview:label];
            }
            return cell;
        }
        
    }else  if(cell_type_to_display == TBL_SUGGESTION_CELL){
        static NSString *CellIdentifier = @"Cell";
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
            cell.textLabel.font = [UIFont systemFontOfSize:16];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
        LocationSuggestion *curSuggestion = [locSuggestions objectAtIndex:indexPath.row];
        cell.textLabel.text = curSuggestion.name;
        cell.detailTextLabel.text = curSuggestion.country;
        return cell;
    }else{//loading cell
        static NSString *LCellIdentifier = @"LoadingCell";
        cell = [tableView dequeueReusableCellWithIdentifier:LCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:LCellIdentifier];
        }
        [P2MSActivityIndicator showIndicatorInView:cell];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (cell_type_to_display == TBL_DIRECTION_CELL) {
        if (allRoutes.count) {
            OneRoute *curRoute = [allRoutes objectAtIndex:indexPath.row];
            return (([curRoute.travel_mode isEqualToString:@"transit"])?90.0f:60.0f);
        }else{
            return 100;
        }
    }
    return 55;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (cell_type_to_display == TBL_DIRECTION_CELL) {
        self.endAddress = endTextField.text;
        self.startAddress = startTextField.text;
        _travel_mode_index = prevSegmentIndex;
        if (allRoutes.count && _delegate) {
            [_delegate routingViewWillClose:self withRoutes:allRoutes andSelectedIndex:indexPath.row];
            [self dismissModalViewControllerAnimated:YES];
        }
    }else if(cell_type_to_display == TBL_SUGGESTION_CELL){
        LocationSuggestion *suggestion = [locSuggestions objectAtIndex:indexPath.row];
        NSString *finalStr = (suggestion.country)?[NSString stringWithFormat:@"%@ %@", suggestion.name, suggestion.country]:suggestion.name;
        if ([startTextField isFirstResponder]) {
            startTextField.text = suggestion.name;
            _startLocDescription = finalStr;
            [endTextField becomeFirstResponder];
        }else{
            endTextField.text = suggestion.name;
            _endLocDescription = finalStr;
            if (!_startAddress.length) {
                [startTextField becomeFirstResponder];
            }else{
                [endTextField resignFirstResponder];
                [self doRouting:nil];
            }
        }
    }
}

#pragma mark UIKeyboard notification listeners
-(void) keyboardDidShow:(NSNotification *)aNotification{
    NSDictionary *info = [aNotification userInfo];
    CGFloat kbHeight = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size.height;
    
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbHeight, 0.0);
    suggestionView.contentInset = contentInsets;
    suggestionView.scrollIndicatorInsets = contentInsets;
    [P2MSGlobalFunctions movePoweredByGoogleLoginInView:self.view toPoint:CGPointMake(self.view.bounds.size.width - 109, self.view.bounds.size.height - kbHeight - 20)];
}

-(void) keyboardWillHide:(NSNotification *)aNotification{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    suggestionView.contentInset = contentInsets;
    suggestionView.scrollIndicatorInsets = contentInsets;
    [P2MSGlobalFunctions movePoweredByGoogleLoginInView:self.view toPoint:CGPointMake(self.view.bounds.size.width - 109, self.view.bounds.size.height - 20)];
}


- (void)adjustLayout{
    UISegmentedControl *segment = (UISegmentedControl *)self.navigationItem.titleView;
    CGRect curFrame = segment.frame;
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication]statusBarOrientation]) && [[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        curFrame.size.height = 30;
    }else
        curFrame.size.height = 38;
    segment.frame = curFrame;
    
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self adjustLayout];
    [suggestionView reloadData];
}

@end
