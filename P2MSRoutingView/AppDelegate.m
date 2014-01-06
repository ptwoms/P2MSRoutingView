//
//  AppDelegate.m
//  P2MSRoutingView
//
//  Created by PYAE PHYO MYINT SOE on 25/9/13.
//  Copyright (c) 2013 PYAE PHYO MYINT SOE. All rights reserved.
//

#import "AppDelegate.h"
#import "P2MSMapViewController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "P2MSGlobalFunctions.h"
#import "P2MSMapHelper.h"


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    P2MSMapViewController *mapViewC = [[P2MSMapViewController alloc]initWithNibName:nil bundle:nil];
    [mapViewC setDefaultLocation:@"Shop Name, #xx-xx, Clementi Shopping Mall,\n Singapore" withCoordinate:CLLocationCoordinate2DMake(1.315047,103.764752)];
    mapViewC.mapType = MAP_TYPE_GOOGLE;
    mapViewC.mapAPISource = MAP_API_SOURCE_GOOGLE;
    self.window.rootViewController = mapViewC;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
