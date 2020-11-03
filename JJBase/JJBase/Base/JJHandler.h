//
//  JJHandler.h
//  JJBase
//
//  Created by xiedong on 2020/10/22.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^post_block_t)(void);

@protocol JJHandlerDelegate <NSObject>

@optional
- (void)handleMessage:(int)what object:(id)anObject;

@end

@interface JJHandler : NSObject

@property (nonatomic, assign) BOOL debugMode;

/**
 * @abstract
 * 创建在main queue 上的handler
 *
 * @param delegate
 * 消息处理delegate
 */
+ (instancetype)mainHandlerWithDelegate:(id<JJHandlerDelegate>)delegate;

/**
 * @abstract
 * 创建一个handler，使用内部创建的serial queue
 *
 * @param name
 * queue的名字， 默认为“JJHandler”
 *
 * @param delegate
 * 消息处理delegate
 */
- (instancetype)initWithName:(NSString *)name delegate:(id<JJHandlerDelegate>)delegate;

/**
 * @abstract
 * 创建一个handler，使用自定义的serial queue
 *
 * @param queue
 * 自定义的serial queue
 *
 * @param delegate
 * 消息处理delegate
 */
- (instancetype)initWithSerialQueue:(dispatch_queue_t)queue delegate:(id<JJHandlerDelegate>)delegate;

/**
 * @abstract
 * 发送消息
 *
 * @param what
 * 自定义消息的标识
 */
- (void)sendMessage:(int)what;

/**
 * @abstract
 * 发送消息
 *
 * @param what
 * 自定义消息的标识
 *
 * @param anObject
 * 附带的参数
 */
- (void)sendMessage:(int)what object:(id)anObject;

/**
 * @abstract
 * 发送延时执行的消息
 *
 * @param what
 * 自定义消息的标识
 *
 * @param delayTime
 * 延时毫秒数
 */
- (void)sendMessageDelayed:(int)what delayMills:(uint64_t)delayTime;

/**
 * @abstract
 * 发送延时执行的消息
 *
 * @param what
 * 自定义消息的标识
 *
 * @param anObject
 * 附带的参数
 *
 * @param delayTime
 * 延时毫秒数
 */
- (void)sendMessageDelayed:(int)what object:(id)anObject delayMills:(uint64_t)delayTime;

/**
 * @abstract
 * 发送block消息
 *
 * @param block
 * 执行的block
 *
 * @param key
 * block标识字符串, 用于移除时使用
 */
- (void)postBlock:(post_block_t)block forKey:(NSString *)key;

/**
 * @abstract
 * 发送block延时消息
 *
 * @param block
 * 执行的block
 *
 * @param key
 * block标识字符串, 用于移除时使用
 *
 * @param delayTime
 * 延时毫秒数
 */
- (void)postBlockDelayed:(post_block_t)block forKey:(NSString *)key delayMills:(uint64_t)delayTime;

/**
 * @abstract
 * 发送selector消息
 *
 * @param target
 * target
 *
 * @param selector
 * selector
 */
- (void)postSelector:(id)target selector:(SEL)selector;

/**
 * @abstract
 * 发送selector消息
 *
 * @param target
 * target
 *
 * @param selector
 * selector
 *
 * @param anObject
 * 附带的参数
 */
- (void)postSelector:(id)target selector:(SEL)selector object:(id)anObject;

/**
 * @abstract
 * 发送selector消息
 *
 * @param target
 * target
 *
 * @param selector
 * selector
 *
 * @param delayTime
 * 延时毫秒数
 */
- (void)postSelectorDelayed:(id)target selector:(SEL)selector delayMills:(uint64_t)delayTime;

/**
 * @abstract
 * 发送selector消息
 *
 * @param target
 * target
 *
 * @param selector
 * selector
 *
 * @param anObject
 * 附带的参数
 *
 * @param delayTime
 * 延时毫秒数
 */
- (void)postSelectorDelayed:(id)target selector:(SEL)selector object:(id)anObject delayMills:(uint64_t)delayTime;

/**
 * @abstract
 * 移除对应标识的所有待执行消息
 *
 * @param what
 * 消息标识
 */
- (void)removeMessage:(int)what;

/**
 * @abstract
 * 移除对应标识的所有待执行block
 *
 * @param key
 * block标识
 */
- (void)removeBlockWithKey:(NSString *)key;

/**
 * @abstract
 * 移除待执行selector
 *
 * @param target
 * target
 *
 * @param selector
 * selector
 */
- (void)removeSelector:(id)target selector:(SEL)selector;

/**
 * @abstract
 * 移除所有待执行的消息和block
 */
- (void)removeAll;

@end

NS_ASSUME_NONNULL_END
