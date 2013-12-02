//
//  P2MSGlobalFunctions.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 29/10/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "P2MSGlobalFunctions.h"

@implementation P2MSGlobalFunctions

SINGLETON_GCD(P2MSGlobalFunctions);

- (id) init{
    if ((self = [super init])) {
        UIDevice *curDevice = [UIDevice currentDevice];
        _isIPad = [curDevice userInterfaceIdiom] == UIUserInterfaceIdiomPad;
        _isIOS_5_OR_LATER = [curDevice.systemVersion floatValue] >= 5.0;
        _isIOS_6_OR_LATER = [curDevice.systemVersion floatValue] >= 6.0;
        _isIOS_7_OR_LATER = [curDevice.systemVersion floatValue] >= 7.0;
        _isIPhone_5 = ([curDevice userInterfaceIdiom]== UIUserInterfaceIdiomPhone) && ([[UIScreen mainScreen ] bounds].size.height == 568.0f);        
    }
    return self;
}

+ (UIImage *)getFlatImage:(UIColor *)startColor end:(UIColor *)endColor forSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    
    CGGradientRef glossGradient;
    CGColorSpaceRef rgbColorspace;
    CGRect currentBounds = CGRectMake(0, 0, size.width, size.height);
    CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
    CGPoint midCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMidY(currentBounds));
    
    //create linear gradient
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    NSArray *colors = @[(__bridge id) startColor.CGColor, (__bridge id) endColor.CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    CGPoint startPoint = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMinY(currentBounds));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
    CGContextSaveGState(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    CGFloat components[8] = {1.0, 1.0, 1.0, 0.65, 1.0, 1.0, 1.0, 0.15};
    rgbColorspace = CGColorSpaceCreateDeviceRGB();
    glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, 2);
    CGContextDrawLinearGradient(context, glossGradient, topCenter, midCenter, 0);
    
    UIGraphicsPopContext();
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    CGGradientRelease(glossGradient);
    CGColorSpaceRelease(rgbColorspace);
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    // Create a 1 by 1 pixel context
    return [P2MSGlobalFunctions imageWithColor:color forRect:rect];
}

+ (UIImage *)imageWithColor:(UIColor *)color forRect:(CGRect)rect{
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [color setFill];
    UIRectFill(rect);   // Fill it with the color provided
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color forRect:(CGRect)rect withCornerRadius:(CGFloat)cornerRadius{
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGPathRef clippath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius].CGPath;
    CGContextAddPath(context, clippath);
    CGContextClip(context);
    UIRectFill(rect);   // Fill it with the color provided
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;

}

+ (void)hidePoweredByGoogleLogo:(BOOL)hidden inView:(UIView *)viewToDisplay forRect:(CGRect)rect{
    if (hidden) {
        [[viewToDisplay viewWithTag:121211]removeFromSuperview];
    }else{
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:rect];
        imgView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [imgView setImage:[UIImage imageNamed:@"powered-by-google-on-white"]];
        imgView.tag = 121211;
        [viewToDisplay addSubview:imgView];
    }
}


+ (void)movePoweredByGoogleLoginInView:(UIView *)viewToDisplay toPoint:(CGPoint)point{
    UIView *logoView = [viewToDisplay viewWithTag:121211];
    CGRect rect = logoView.frame;
    rect.origin = point;
    logoView.frame = rect;
}


@end
