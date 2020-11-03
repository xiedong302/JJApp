//
//  AppDelegate.m
//  JJAppMain
//
//  Created by xiedong on 2020/9/24.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "AppDelegate.h"
#import "TestViewController.h"
#import "JJMainRootController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [self.window setRootViewController:[JJMainRootController new]];
//    [self.window setRootViewController:[TestViewController new]];
    [self.window makeKeyAndVisible];
    return YES;
}


@end
