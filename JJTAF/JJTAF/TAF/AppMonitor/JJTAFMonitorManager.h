//
//  JJTAFMonitorManager.h
//  JJTAF
//
//  Created by xiedong on 2020/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJTAFMonitorConfig : NSObject

// 可以通过主工程 JJTAFMonitorConfig.plist配置
+ (instancetype)defaultConfig;

@property (nonatomic, assign) int maxDepth; // 最大的深度 default 3

@property (nonatomic, assign) uint64_t minTimeCost; // 最小的时间间隔 default 200ms

@property (nonatomic, assign) int maxCPUUsage; // default 80

@end

@interface JJTAFMonitorManager : NSObject

+ (void)startMonitor:(JJTAFMonitorConfig *)config;

+ (void)stopMonitor;

@end

NS_ASSUME_NONNULL_END
