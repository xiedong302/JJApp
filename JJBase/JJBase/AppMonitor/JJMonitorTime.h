//
//  JJMonitorTime.h
//  JJBase
//
//  Created by xiedong on 2020/11/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJMonitorTime : NSObject

/**
 开始监控
 */
+ (void)startMonitoringTimer;

/**
 停止监控
 */
+ (void)stopMonitoringTimer;

@end

NS_ASSUME_NONNULL_END
