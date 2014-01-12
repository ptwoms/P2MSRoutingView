//
//  P2MSView.h
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 7/1/14.
//  Copyright (c) 2014 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface P2MSWebViewController : UIViewController<UIWebViewDelegate, MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) NSURL *urlToLoad;

@end
