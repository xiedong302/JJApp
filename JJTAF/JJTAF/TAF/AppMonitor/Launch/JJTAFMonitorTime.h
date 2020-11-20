//
//  JJTAFMonitorTime.h
//  JJTAF
//
//  Created by xiedong on 2020/11/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJTAFMonitorTime : NSObject

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
