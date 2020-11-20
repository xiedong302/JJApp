//
//  JJTAFTimer.h
//  JJTAF
//
//  Created by xiedong on 2020/11/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJTAFTimer : NSObject

/**
 * schedule GCD Timer  默认为main queue
 * @param identifier 唯一标识
 * @param timeInterval timer执行时间间隔
 * @param repeat 是否重复调用
 * @param block timer执行block
 */
+ (void)scheduleTimerWithIndentifier:(NSString *)identifier timeInterval:(NSTimeInterval)timeInterval repeat:(BOOL)repeat block:(dispatch_block_t)block;

/**
 * schedule GCD Timer
 * @param identifier 唯一标识
 * @param timeInterval timer执行时间间隔
 * @param queue timer执行队列， 默认为main queue
 * @param repeat 是否重复调用
 * @param block timer执行block
 */
+ (void)scheduleTimerWithIndentifier:(NSString *)identifier timeInterval:(NSTimeInterval)timeInterval queue:(dispatch_queue_t)queue repeat:(BOOL)repeat block:(dispatch_block_t)block;

/**
 * 取消Timer
 * @param identifier 唯一标识
 */
+ (void)cancelTiemrWithIndentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
