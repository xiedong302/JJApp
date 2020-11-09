//
//  JJHybridPluginManager.h
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/6.
//

#import <Foundation/Foundation.h>

@class JJHybridPlugin;
@class JJHybridPluginEvent;
@class JJHybridPluginResult;
@class JJHybridEngine;

NS_ASSUME_NONNULL_BEGIN
@interface JJHybridPluginManager : NSObject

- (instancetype)initWithEngine:(JJHybridEngine *)engine;

- (void)addPlugin:(JJHybridPlugin *)plugin;

- (void)sendPluginResult:(JJHybridPluginResult *)result;

- (void)sendPluginEvent:(JJHybridPluginEvent *)event;

- (void)presentViewController:(UIViewController *)controller;

- (void)onJsRequest:(NSString *)request;

- (void)reset;

- (void)handleViewAppear;

- (void)handleViewDisappear;

@end

NS_ASSUME_NONNULL_END
