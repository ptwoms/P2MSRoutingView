//
//  P2MSGlobalFunctions.h
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 29/10/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef SINGLETON_GCD
#define SINGLETON_GCD(classname)                        \
\
+ (classname *)sharedInstance {                      \
\
static dispatch_once_t pred;                        \
__strong static classname * shared##classname = nil;\
dispatch_once( &pred, ^{                            \
shared##classname = [[self alloc] init]; });    \
return shared##classname;                           \
}
#endif

#define STD_GRADIENT_BAR_BACKGROUND_START_COLOR [UIColor colorWithRed:0.95686 green:0.949 blue:0.95294 alpha:1.0]
#define STD_GRADIENT_BAR_BACKGROUND_END_COLOR [UIColor colorWithRed:0.83137 green:0.83137 blue:0.83137 alpha:1.0]

#define LAST_USED_DIRECTION_TYPE @"p2ms_routing_direction_type"

@interface P2MSGlobalFunctions : NSObject<UITextFieldDelegate>

@property (nonatomic, readonly) BOOL isIPad;
@property (nonatomic, readonly) BOOL isIPhone_5;
@property (nonatomic, readonly) BOOL isIOS_5_OR_LATER;
@property (nonatomic, readonly) BOOL isIOS_6_OR_LATER;
@property (nonatomic, readonly) BOOL isIOS_7_OR_LATER;


+ (P2MSGlobalFunctions *)sharedInstance;

+ (UIImage *)getFlatImage:(UIColor *)startColor end:(UIColor *)endColor forSize:(CGSize)size;

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColor:(UIColor *)color forRect:(CGRect)rect;
+ (UIImage *)imageWithColor:(UIColor *)color forRect:(CGRect)rect withCornerRadius:(CGFloat)cornerRadius;

+ (void)hidePoweredByGoogleLogo:(BOOL)hidden inView:(UIView *)viewToDisplay forRect:(CGRect)rect;
+ (void)movePoweredByGoogleLoginInView:(UIView *)viewToDisplay toPoint:(CGPoint)point;

@end
