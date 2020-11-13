//
//  JJWebView.h
//  JJBaseUI
//
//  Created by xiedong on 2020/11/13.
//

#import <JJHybridSDK/JJHybridSDK.h>

@class JJWebView;

NS_ASSUME_NONNULL_BEGIN

@protocol JJWebViewDelegate <NSObject>

@optional
- (void)jjwebViewOnCloseView;

- (void)jjwebViewOnPageLoadFinished;

- (void)jjwebViewOnCanGoBackChanged:(BOOL)canGoBack;

- (BOOL)jjwebViewShouldOverrideUrl:(NSURL *)url;

- (void)jjwebViewSetStatusBarStyle:(UIStatusBarStyle)statusBarStyle;

@end

@interface JJWebView : JJHybridView

@property (nonatomic, weak) id<JJWebViewDelegate> webViewDelegate;

@end

NS_ASSUME_NONNULL_END
