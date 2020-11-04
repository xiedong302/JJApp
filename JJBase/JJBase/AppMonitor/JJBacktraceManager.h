//
//  JJBacktraceManager.h
//  JJBase
//
//  Created by xiedong on 2020/11/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJBacktraceManager : NSObject

+ (NSString *)jj_backtraceOfAllThread;
+ (NSString *)jj_backtraceOfCurrentThread;
+ (NSString *)jj_backtraceOfMainThread;
+ (NSString *)jj_backtraceOfNSThread:(NSThread *)thread;

+ (NSDictionary *)jj_backtraceMapOfMainThread;

@end

NS_ASSUME_NONNULL_END
