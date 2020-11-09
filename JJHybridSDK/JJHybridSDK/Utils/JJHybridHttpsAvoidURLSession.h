//
//  JJHybridHttpsAvoidURLSession.h
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJHybridHttpsAvoidURLSession : NSObject

+ (instancetype)sharedSession;

- (NSURLSessionDataTask *)dataTaskWithURL:(NSURL *)url completionHandler:(void (^)(NSData * data, NSURLResponse * response, NSError * error))completionHandler;

@end

NS_ASSUME_NONNULL_END
