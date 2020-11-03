//
//  JJMainTabBarController.h
//  JJAppMain
//
//  Created by xiedong on 2020/10/23.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJMainTabBarController : UITabBarController

- (void)pushViewController:(UIViewController *)controller;

- (UIViewController *)visibleViewController;

- (void)openURL:(NSString *)URLString;

@end

NS_ASSUME_NONNULL_END
