//
//  JJHybridWebView.h
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JJHybridWebViewDelegate <NSObject>

- (BOOL)shouldOverrideRequest:(NSURLRequest *)request linkOrReload:(BOOL)linkOrReload;

- (void)onRequestLoadStarted:(NSURLRequest *)request;

- (void)onRequestLoadFinished:(NSURLRequest *)request;

- (void)onRequestLoadError:(NSURLRequest *)request error:(NSError *)error;

- (void)onPageLoadStarted:(NSURL *)url;

- (void)onPageLoadFinished:(NSURL *)url;

- (void)onPageLoadError:(NSURL *)url error:(NSError *)error;

- (BOOL)onJavasciptPromt:(NSURL *)url promt:(NSString *)promt defaultText:(NSString *)defaultText;

- (void)onCanGoBackChange:(BOOL)canGoBack;

- (void)onTitleChange:(NSString *)titl;

@end

@interface JJHybridWebView : UIView

@property (nonatomic, weak) id<JJHybridWebViewDelegate> delegate;

- (instancetype)initWithUA:(NSString *)ua;

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

- (void)executeJavascript:(NSString *)js completionHandler:(void (^)(NSString * result, NSError * error))completionHandler;

- (void)addJavasciptHandler:(NSString *)name handler:(void (^)(id data))handler;
@end

NS_ASSUME_NONNULL_END
