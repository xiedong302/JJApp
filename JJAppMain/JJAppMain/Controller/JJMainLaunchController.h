//
//  JJMainLaunchController.h
//  JJAppMain
//
//  Created by xiedong on 2020/10/23.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JJMainLaunchController;
@protocol JJMainLaunchControllerDelegate <NSObject>

- (void)launchController:(JJMainLaunchController *)controller openURL:(NSString *)URLString;

@end

//启动界面，显示闪屏或者广告
@interface JJMainLaunchController : UIViewController

@property (nonatomic, weak) id<JJMainLaunchControllerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
