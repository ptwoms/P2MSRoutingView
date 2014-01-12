//
//  P2MSSideViewController.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 6/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSSideViewController.h"
#import "P2MSGlobalFunctions.h"
#import "P2MSWebViewController.h"

@interface P2MSSideViewController (){
    NSInteger selectedIndex;
}

@end

@implementation P2MSSideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        selectedIndex = 0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:55.0f/255.0f green:59.0f/255.0f blue:62.0f/255.0f alpha:1.0f];
	// Do any additional setup after loading the view.
    
//    UITableView *tblView = [[UITableView alloc]initWithFrame:CGRectMake(0, 20, self.view.bounds.size.width, 200) style:UITableViewStylePlain];
//    tblView.backgroundView = [[UIView alloc]initWithFrame:tblView.frame];
//    [self.view addSubview:tblView];
    
    UIButton *satellite = [self getButtonWithFrame:CGRectMake(20, 50, 210, 40) andTitle:@"Satellite"];
    satellite.tag = 10;
    [satellite addTarget:self action:@selector(doAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:satellite];

    UIButton *hybrid = [self getButtonWithFrame:CGRectMake(20, 95, 210, 40) andTitle:@"Hybrid"];
    hybrid.tag = 11;
    [hybrid addTarget:self action:@selector(doAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:hybrid];

    UIButton *aboutMe = [self getButtonWithFrame:CGRectMake(20, 195, 210, 40) andTitle:@"GitHub Repositories"];
    aboutMe.tag = 12;
    [aboutMe addTarget:self action:@selector(aboutMe:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:aboutMe];

}

- (UIButton *)getButtonWithFrame:(CGRect)frame andTitle:(NSString *)title{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
//    button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:0.8 alpha:1.0] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithWhite:1.0 alpha:1.0] forState:UIControlStateHighlighted];
    [button setBackgroundImage:[P2MSGlobalFunctions imageWithColor:[UIColor blackColor]] forState:UIControlStateHighlighted];
    return button;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)doAction:(UIButton *)sender{
    NSString *command = sender.titleLabel.text;
    if (sender.tag == selectedIndex) {
        [sender setBackgroundImage:[P2MSGlobalFunctions imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        selectedIndex = 0;
        command = @"standard";
    }else{
        //restore previous btn
        if (selectedIndex != 0) {
            UIButton *prevSelected = (UIButton *)[self.view viewWithTag:selectedIndex];
            [prevSelected setBackgroundImage:[P2MSGlobalFunctions imageWithColor:[UIColor clearColor]] forState:UIControlStateNormal];
        }
        //new selected btn
        selectedIndex = sender.tag;
        command = sender.titleLabel.text;
        [sender setBackgroundImage:[P2MSGlobalFunctions imageWithColor:[UIColor blackColor]] forState:UIControlStateNormal];
    }
    if ([_delegate respondsToSelector:@selector(doActionForSideViewController:withCommand:)]) {
        [_delegate doActionForSideViewController:self withCommand:[command lowercaseString]];
    }
}

- (IBAction)aboutMe:(id)sender{
    self.sideBar.state = SIDEBAR_CLOSE;
    P2MSWebViewController *webView = [[P2MSWebViewController alloc]initWithNibName:nil bundle:nil];
    webView.urlToLoad = [NSURL URLWithString:@"https://github.com/ptwoms?tab=repositories"];
    [self.sideBar.rootViewController.navigationController pushViewController:webView animated:YES];
}

@end
