//
//  P2MSDirectionView.h
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 29/10/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface P2MSDirectionView : UIView

@property (nonatomic, retain) NSString *routeOverview;
- (void)redrawOverview;

@end


@interface DirectionIndex : NSObject

@property (nonatomic) NSInteger index;
@property (nonatomic) CGFloat width;

@end