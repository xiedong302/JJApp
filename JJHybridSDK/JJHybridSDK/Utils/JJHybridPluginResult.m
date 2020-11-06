//
//  JJHybridPluginResult.m
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/6.
//

#import "JJHybridPluginResult.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

static const NSInteger ERROR = -1;
static const NSInteger SUCCESS = 0;

@implementation JJHybridPluginResult

- (instancetype)initWithCallbackId:(NSString *)callbackId
                            result:(int)result
                              data:(NSDictionary *)data
                      errorMessage:(NSString *)errorMessage {
    self = [super init];
    if (self) {
        _callbackId = [callbackId copy];
        _result = result;
        _data = data;
        _errorMessage = [errorMessage copy];
    }
    return self;
}

+ (instancetype)success:(NSString *)callbackId data:(NSDictionary *)data {
    return [[JJHybridPluginResult alloc] initWithCallbackId:callbackId result:SUCCESS data:data errorMessage:nil];
}

+ (instancetype)error:(NSString *)callbackId message:(NSString *)message {
    return [[JJHybridPluginResult alloc] initWithCallbackId:callbackId result:ERROR data:nil errorMessage:message];
}

- (NSString *)encode {
    NSString *js = @"javascript:window.nativeCakkback(";
    
    
    retutn js;
}
@end


#pragma clang diagnostic pop
