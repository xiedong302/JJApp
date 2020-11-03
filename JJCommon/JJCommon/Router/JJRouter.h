//
//  JJRouter.h
//  JJBase
//
//  Created by xiedong on 2020/10/21.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const KJJRouterParamURL;
FOUNDATION_EXPORT NSString * const KJJRouterParamClass;
FOUNDATION_EXPORT NSString * const KJJRouterParamHandler;

FOUNDATION_EXPORT void JJRouterNavigate(NSString *url);

typedef void(^JJRouterHandler)(void);

@protocol JJRouterDelegate <NSObject>

- (UIViewController *)viewControllerForParams:(NSDictionary *)params;

- (void)showViewController:(UIViewController *)controller present:(BOOL)present;

- (UIViewController *)visibleViewController;

- (UIViewController *)rootViewController;

@end

@interface JJRouter : NSObject

+ (void)registerDelegate:(id<JJRouterDelegate>)delegate;

+ (void)showViewController:(UIViewController *)controller;

+ (void)showViewController:(UIViewController *)controller present:(BOOL)present;

+ (UIViewController *)visibleViewController;

+ (UIViewController *)rootViewController;

+ (void)navigate:(NSString *)URLString;

+ (void)navigate:(NSString *)URLString withHandler:(JJRouterHandler)handler;

+ (BOOL)canNavigate:(NSString *)URLString;

@end

//MARK: JJRouter Category
@interface NSObject (JJRouter)

- (void)handleRouter:(NSDictionary *)params;

- (Class)handleRouterDispatch:(NSDictionary *)params;

- (void)handleRouterCustom:(NSDictionary *)params;

@end
NS_ASSUME_NONNULL_END
