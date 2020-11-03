//
//  JJDeviceInfoManager.h
//  JJBase
//
//  Created by xiedong on 2020/9/27.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJDeviceInfoManager : NSObject

/**
 build号
 */
+ (NSString *)jj_appBuildVersion;

/**
 版本号
 */
+ (NSString *)jj_appShortVersion;

/**
 app名字
 */
+ (NSString *)jj_appName;

/**
 最后一次打开app的时间
 */
+ (NSString *)jj_appLastLaunchTime;

/**
 更新app打开的时间
 */
+ (void)jj_appUpdateLaunchTime;

/**
 系统版本号
 */
+ (NSString *)jj_deviceSystemVersion;

/**
 设备名称
 */
+ (NSString *)jj_deviceName;

/**
 判断设备时候是刘海屏
 */
+ (BOOL)jj_deviceIsIphoneXStyle;

@end

NS_ASSUME_NONNULL_END
