//
//  JJHybridView.h
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JJHybridViewDelegate <NSObject>

- (BOOL)jjHybridViewShouldOverrideUrl:(NSURL *)url;

- (void)jjHybridViewOnPageLoadStarted;

- (void)jjHybridViewOnPageLoadFinished;

- (void)jjHybridViewOnPageLoadError;

- (void)jjHybridViewOnPresentViewController:(UIViewController *)controller;

- (void)jjHybridViewOnOpenUrl:(NSURL *)url;

- (void)jjHybridViewOnCloseView;

- (void)jjHybridViewOnCanGoBackChanged:(BOOL)canGoBack;

@end

//MARK: - JJHybridViewMenuItem
@interface JJHybridViewMenuItem : NSObject

@property (nonatomic, copy) NSString *itemId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *icon;

@end

typedef NS_ENUM(NSUInteger, JJHybridViewProgessType) {
    JJHybridViewProgessTypeDefault,
    JJHybridViewProgessTypeCircle,
};

typedef NS_ENUM(NSUInteger, JJHybridViewThemeType) {
    JJHybridViewThemeTypeDark = 1,
    JJHybridViewThemeTypeLight,
};

typedef NS_ENUM(NSUInteger, JJHybridViewLoadState) {
    JJHybridViewLoadStateInit,
    JJHybridViewLoadStateLoading,
    JJHybridViewLoadStateFinished,
    JJHybridViewLoadStateError,
};

// 提供给外部使用
@interface JJHybridView : UIView

@property (nonatomic, weak) id<JJHybridViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIScrollView *scrollView;

@property (nonatomic, assign) JJHybridViewProgessType progressType;

@property (nonatomic, assign) JJHybridViewThemeType themeType;

@property (nonatomic, assign, readonly) JJHybridViewLoadState loadState;

@property (nonatomic, assign) BOOL showCloseAlways;

// 是否添加请求头，存在兼容问题，默认为NO
// 内部的WebView默认只支持第一个请求带自定义头，页面中点击第二次跳转是没有的
@property (nonatomic, assign) BOOL allowOverrideRequestHeader;

+ (void)enableDebug:(BOOL)debug;

+ (BOOL)isDebug;

- (instancetype)initWithFrame:(CGRect)frame uaVersion:(NSString *)version uaChannel:(NSString *)channel;

- (void)loadUrlString:(NSString *)url;

- (void)loadUrl:(NSURL *)url;

- (NSString *)getURL;

- (void)reload;

- (void)stopLoading;

- (BOOL)canGoBack;

- (BOOL)goBack;

- (BOOL)cabGoForward;

- (BOOL)goForward;

- (NSString *)getTitle;

- (void)addHttpHeader:(NSString *)name value:(NSString *)value;

- (void)setHeaderColor:(UIColor *)color;

- (void)setTitleTextColot:(UIColor *)color;

- (void)setBackIcon:(UIImage *)image;

- (void)setCloseIcon:(UIImage *)image;

- (void)setMoreMenuIcon:(UIImage *)image;

- (void)setProgressColor:(UIColor *)color;

- (void)hideHeader:(BOOL)hide;

- (UIView *)getErrorView;

- (void)viewWillAppear;

- (void)viewdidAppear;

- (void)viewWillDisappear;

- (void)viewDidDisappear;

- (void)executeJavascript:(NSString *)js completionHandler:(void (^)(NSString * result, NSError * error))completionHandler;

- (void)executeJavascript:(NSString *)js;

// 在Block中注意使用weak self， 否则会循环引用
- (void)addJavascriptHandler:(NSString *)name handler:(void (^)(id data))handler;

@end

NS_ASSUME_NONNULL_END
