//
//  JJHybridUserPlugin.m
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/9.
//

#import "JJHybridUserPlugin.h"
#import "JJHybridUser.h"

@implementation JJHybridUserPlugin

- (instancetype)init {
    return [super initWithName:@"JJUser"];
}

- (BOOL)execute:(NSString *)callbackId action:(NSString *)action args:(NSDictionary *)args {
    if ([action compare:@"getUserInfo"] == NSOrderedSame) {
        [self sendSuccessResult:callbackId data:[self getUserInfo]];
    } else {
        return NO;
    }
    return YES;
}

- (void)sendUserChangeEvent {
    [self sendEvent:@"userChange" data:[self getUserInfo]];
}

- (NSDictionary *)getUserInfo {
    if (self.user) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        if (self.user.nickName && self.user.nickName.length > 0) {
            [userInfo setValue:self.user.nickName forKey:@"nickName"];
        }
        
        return userInfo.copy;
    }
    
    return nil;
}
@end
