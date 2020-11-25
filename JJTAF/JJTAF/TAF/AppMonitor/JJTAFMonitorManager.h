//
//  JJTAFMonitorManager.h
//  JJTAF
//
//  Created by xiedong on 2020/11/25.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJTAFMonitorConfig : NSObject

+ (instancetype)defaultConfig;

@property (nonatomic, assign) int maxDepth; // 最大的深度 default 3

@property (nonatomic, assign) uint64_t minTimeCost; // 最小的时间间隔 default 200ms

@end

@interface JJTAFMonitorManager : NSObject

+ (void)start:(JJTAFMonitorConfig *)config; //开始记录

+ (void)stopSaveAndClean;

@end

NS_ASSUME_NONNULL_END
