//
//  JJHybridPlugin.h
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJHybridPlugin : NSObject

@property (nonatomic, copy, readonly) NSString *pluginName;

- (instancetype)initWithName:(NSString *)name;

- (BOOL)execute:(NSString *)callbackId action:(NSString *)action args:(NSDictionary *)args;

- (void)sendSuccessResult:(NSString *)callbackId data:(NSDictionary *)data;

- (void)sendErrorResult:(NSString *)callbackId message:(NSString *)message;

- (void)sendEvent:(NSString *)action data:(NSDictionary *)data;

- (void)presentViewController:(UIViewController *)controller;

- (void)onInit;

- (void)viewDidAppear;

- (void)viewDisappear;

@end

NS_ASSUME_NONNULL_END
