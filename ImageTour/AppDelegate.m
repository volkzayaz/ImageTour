//
//  AppDelegate.m
//  ImageTour
//
//  Created by Vlad Soroka on 10/19/15.
//  Copyright © 2015 com.286. All rights reserved.
//

#import "AppDelegate.h"
#import "VSRootViewController.h"

@interface AppDelegate ()

@property (weak, nonatomic) VSRootViewController* rootViewController;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    self.rootViewController = (VSRootViewController*)self.window.rootViewController;
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(nonnull NSURL *)url
            options:(nonnull NSDictionary<NSString *,id> *)options
{
    [self.rootViewController handleURL:url];
    return YES;
}

@end
