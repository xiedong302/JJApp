//
//  JJHybridUserPlugin.h
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/9.
//

#import "JJHybridPlugin.h"

@class JJHybridUser;
NS_ASSUME_NONNULL_BEGIN

@interface JJHybridUserPlugin : JJHybridPlugin

@property (nonatomic, strong) JJHybridUser *user;

- (void)sendUserChangeEvent;

@end

NS_ASSUME_NONNULL_END
