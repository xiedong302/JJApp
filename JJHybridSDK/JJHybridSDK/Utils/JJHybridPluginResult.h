//
//  JJHybridPluginResult.h
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJHybridPluginResult : NSObject

@property (nonatomic, copy, readonly) NSString *callbackId;
@property (nonatomic, assign, readonly) int result;
@property (nonatomic, strong, readonly) NSDictionary *data;
@property (nonatomic, copy, readonly) NSString *errorMessage;

+ (instancetype)success:(NSString *)callbackId data:(NSDictionary *)data;

+ (instancetype)error:(NSString *)callbackId message:(NSString *)message;

- (NSString *)encode;

@end

NS_ASSUME_NONNULL_END
