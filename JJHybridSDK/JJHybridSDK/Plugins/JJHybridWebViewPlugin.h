//
//  JJHybridWebViewPlugin.h
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/9.
//

#import "JJHybridPlugin.h"

@class JJHybirdView;
NS_ASSUME_NONNULL_BEGIN

@interface JJHybridWebViewPlugin : JJHybridPlugin

- (instancetype)initWithHybridView:(JJHybirdView *)hybridView;

- (void)sendMenuEvent:(NSString *)itemId;

- (void)sendVisibleEvent;

- (void)sendInvisibleEvent;

- (void)sendOnLoadEvent;

@end

NS_ASSUME_NONNULL_END
