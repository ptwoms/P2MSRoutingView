//
//  P2MSView.h
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 7/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSWebViewController.h"
#import "P2MSActivityIndicator.h"
#import "P2MSGlobalFunctions.h"

@interface P2MSWebViewController (){
    UIWebView *description;
//    UISegmentedControl *segment;
}

@end

@implementation P2MSWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // webViewDidFinishLoad is not getting called when the pages are cached and backward, forward and refresh buttons are removed here
    
//    segment = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:[UIImage imageNamed:@"backward"], [UIImage imageNamed:@"refresh"], [UIImage imageNamed:@"forward"], nil]];
//    segment.frame = CGRectMake(10, 10, 100, 36);
//    segment.momentary = YES;
//    segment.segmentedControlStyle = UISegmentedControlStylePlain;
//    UIBarButtonItem *barBtn = [[UIBarButtonItem alloc]initWithCustomView:segment];
//    self.navigationItem.rightBarButtonItem = barBtn;
//    [segment addTarget:self action:@selector(segmentSwitch:) forControlEvents:UIControlEventValueChanged];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(webViewHistoryDidChange:)
//                                                 name:@"WebHistoryItemChangedNotification"
//                                               object:nil];
}

//- (IBAction)webViewHistoryDidChange:(NSNotification *)sender{
//}

//- (void)dealloc{
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"WebHistoryItemChangedNotification" object:nil];
//}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    if (!description) {
        description = [[UIWebView alloc]initWithFrame:self.view.bounds];
        description.backgroundColor = [UIColor clearColor];
        description.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        description.scalesPageToFit = YES;
        [description loadRequest:[NSURLRequest requestWithURL:_urlToLoad]];
        [description setDelegate:self];
        [self.view addSubview:description];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [super viewWillDisappear:animated];
}


//- (IBAction)segmentSwitch:(id)sender{
//    NSInteger curIndex = ((UISegmentedControl *)sender).selectedSegmentIndex;
//    switch (curIndex) {
//        case 0:{
//            if ([description canGoBack]) {
//                [description stopLoading];
////                [description reload];//this is added since canGoBack and canGoForward are not correctly detected in webViewDidFinishLoad
//                [description goBack];
//            }
//        }break;
//        case 1:{
//            if ([description isLoading]) {
//                [description stopLoading];
//            }
//            [description reload];
//        }break;
//        case 2:{
//            if ([description canGoForward]) {
//                [description stopLoading];
////                [description reload];
//                [description goForward];
//            }
//        }break;
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UIWebView delegates
- (void)webViewDidStartLoad:(UIWebView *)webView{
//    [segment setEnabled:[webView canGoBack] forSegmentAtIndex:0];
//    [segment setEnabled:NO forSegmentAtIndex:1];
//    [segment setEnabled:[webView canGoForward] forSegmentAtIndex:2];
    [P2MSActivityIndicator showIndicatorInView:self.view];
}

- (NSString *) URLDecodedString:(NSString *)str {
    NSString *result = (__bridge_transfer NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(kCFAllocatorDefault, (__bridge CFStringRef)str, CFSTR(""), kCFStringEncodingUTF8);
    return result;
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    if (navigationType == UIWebViewNavigationTypeLinkClicked || navigationType == UIWebViewNavigationTypeOther) {
        NSURL *requestURL = [request URL];
        if ([[requestURL scheme] isEqualToString:@"mailto"]) {
            NSString *mailtoParameterString = [[requestURL absoluteString] substringFromIndex:[@"mailto:" length]];            
            [self sendEmail:[self URLDecodedString:mailtoParameterString]];
            return NO;
        }else if ([[requestURL scheme] isEqualToString:@"tel"]){
            NSString *telNo = [self URLDecodedString:[[requestURL absoluteString] substringFromIndex:[@"tel:" length]]];
            if ([P2MSGlobalFunctions sharedInstance].isIOS_5_OR_LATER) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", telNo]]];
            }else{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", telNo]]];
            }
            return NO;
        }
    }
    return YES;
}


- (void)sendEmail:(NSString *)emailAddress{
    if ([MFMailComposeViewController canSendMail]){
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setToRecipients:[NSArray arrayWithObject:emailAddress]];
        [self presentModalViewController:mc animated:YES];
    }else{
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Email Not Available" message:@"Your device doesn't support to use built-in email. Please setup Mail account in  device Settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Mail" message:@"Mail saved: you saved the email message in the drafts folder." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }break;
        case MFMailComposeResultSent:{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Mail" message:@"Mail sent: your email message have been sent." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }break;
        case MFMailComposeResultFailed:
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Mail" message:@"Mail sent Failed: there is an error in email message sending." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }break;
        default:{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Mail" message:@"Mail not sent!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }break;
    }
    [self dismissModalViewControllerAnimated:YES];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [P2MSActivityIndicator hideIndicatorForView:self.view];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Loading Error!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView{
    [P2MSActivityIndicator hideIndicatorForView:self.view];
    ((UILabel *)self.navigationItem.titleView).text = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//        [segment setEnabled:[description canGoBack] forSegmentAtIndex:0];
//        [segment setEnabled:YES forSegmentAtIndex:1];
//        [segment setEnabled:[webView canGoForward] forSegmentAtIndex:2];
}


@end
