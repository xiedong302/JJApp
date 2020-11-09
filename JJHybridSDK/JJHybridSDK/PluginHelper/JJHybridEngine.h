//
//  JJHybridEngine.h
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/9.
//

#import <Foundation/Foundation.h>

@class JJHybridWebView;
@class JJHybridPlugin;
NS_ASSUME_NONNULL_BEGIN

@protocol JJHybridHost <NSObject>

@optional
- (BOOL)jjHybridShouldOverrideUrl:(NSURL *)url;

- (void)jjHybridOnRequestLoadStart;

- (void)jjHybridOnRequestLoadFinished;

- (void)jjHybridOnRequestLoadError;

- (void)jjHybridOnPageLoadStart;

- (void)jjHybridOnPageLoadFinished;

- (void)jjHybridOnPageLoadError;

- (void)jjHybridOnTitleChanged:(NSString *)title;

- (void)jjHybridOnCanGoBackChanged:(BOOL)canGoBack;

- (void)jjHybridPresentViewController:(UIViewController *)controller;
@end

@interface JJHybridEngine : NSObject

@property (nonatomic, weak) id<JJHybridHost> host;
@property (nonatomic, assign) BOOL allowOverrideRequstHeader;

- (instancetype)initWithWebView:(JJHybridWebView *)webView;

- (void)addPlugin:(JJHybridPlugin *)plugin;

- (void)loadRequest:(NSURLRequest *)request;

- (void)loadHTMLString:(NSString *)string;

- (void)stopLoading;

- (void)reload;

- (BOOL)canGoBack;

- (BOOL)goBack;

- (BOOL)canGoForward;

- (BOOL)goForward;

- (NSURL *)getURL;

- (NSString *)getTitle;

- (void)addHttpHeader:(NSString *)name value:(NSString *)value;

- (void)removeHttpHeader:(NSString *)name;

- (NSDictionary *)allHeaders;

- (void)handleViewAppear;

- (void)handleViewDisAppear;

- (void)executeJavascript:(NSString *)js completionHander:(void (^)(NSString *resulr, NSError *error))completionHandler;

- (void)addJavascriptHandler:(NSString *)name handler:(void (^)(id data))handler;

- (void)presentViewController:(UIViewController *)contoller;

@end

NS_ASSUME_NONNULL_END
