//
//  JJTAFMonitorManager.h
//  JJTAF
//
//  Created by xiedong on 2020/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 * maxDepth default 3
 * minTimeCost detault 200ms
 * maxCPUUsage default 80
 * JJTAFMonitorConfig.plist配置
 */

@interface JJTAFMonitorManager : NSObject

/**
 * 进行 CPU 和 卡顿监测
 */
+ (void)startLagMonitor;

+ (void)stopLagMonitor;

/**
 * 进行调用追溯的监测
 */
+ (void)startCallTraceMonitor;

+ (void)stopCallTraceMonitor;

@end

NS_ASSUME_NONNULL_END
