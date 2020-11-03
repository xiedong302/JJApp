//
//  JJMainRootController.h
//  JJAppMain
//
//  Created by xiedong on 2020/10/23.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJMainTabBarController.h"

NS_ASSUME_NONNULL_BEGIN

// Root界面，用于切换启动屏和主界面
@interface JJMainRootController : UIViewController

@property (nonatomic, strong) JJMainTabBarController *tabBarController;

@end

NS_ASSUME_NONNULL_END
