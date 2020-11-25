//
//  JJTAFCallStackCore.h
//  JJTAF
//
//  Created by xiedong on 2020/11/25.
//  函数调用堆栈 区分不同的线程

#import <Foundation/Foundation.h>
#import "JJTAFCallLib.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, JJTAFCallStackType) {
    JJTAFCallStackTypeAll,      // 全部线程
    JJTAFCallStackTypeMain,     // 主线程
    JJTAFCallStackTypeCurrent,  // 当前线程
};

@interface JJTAFCallStackCore : NSObject

+ (NSString *)callStackWithType:(JJTAFCallStackType)type;

extern NSString *JJTAFStackOfThread(thread_t thread);

@end

NS_ASSUME_NONNULL_END
