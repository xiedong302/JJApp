//
//  JJTAFCallStackMonitor.h
//  JJTAF
//
//  Created by xiedong on 2020/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJTAFCallStackMonitorConfig : NSObject

+ (instancetype)defaultConfig;

@property (nonatomic, assign) int maxCPUUsage; // CPU最大使用率 defalult 80


@end

@interface JJTAFCallStackMonitor : NSObject

+ (void)start:(JJTAFCallStackMonitorConfig *)config; // 开始卡顿监控

+ (void)stop;  // 停止卡顿监控

@end

NS_ASSUME_NONNULL_END
