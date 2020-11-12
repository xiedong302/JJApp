//
//  JJHybridEngine.m
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/9.
//

#import "JJHybridEngine.h"
#import "JJHybridWebView.h"
#import "JJHybridPluginManager.h"

#pragma clang diagnostic push

#pragma clang diagnostic ignored "-Wdeprecated-declarations"

static NSString * const JJ_HYBRID_SCHEME = @"jj://";

@interface JJHybridEngine ()<JJHybridWebViewDelegate>

@property (nonatomic, weak) JJHybridWebView *webView;
@property (nonatomic, strong) JJHybridPluginManager *pluginManager;
@property (nonatomic, strong) NSMutableDictionary *httpHeaders;

@end

@implementation JJHybridEngine

- (instancetype)initWithWebView:(JJHybridWebView *)webView {
    self = [super init];
    if (self) {
        __weak JJHybridWebView *weakWebView = webView;
        _webView = weakWebView;
        _webView.delegate = self;
        
        _pluginManager = [[JJHybridPluginManager alloc] initWithEngine:self];
        _httpHeaders = [NSMutableDictionary dictionaryWithCapacity:4];
    }
    return self;
}

//MARK: - Public
- (void)addPlugin:(JJHybridPlugin *)plugin {
    [self.pluginManager addPlugin:plugin];
}

- (void)loadUrl:(NSURL *)url {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:30];
    
    [self loadRequest:request];
}

- (void)loadRequest:(NSURLRequest *)request {
    NSURLRequest *realRequest = request;
    
    NSDictionary *headers = self.httpHeaders;
    
    if (headers && headers.count > 0) {
        NSMutableURLRequest *newRequst = [request mutableCopy];
        
        for (NSString *header in headers) {
            [newRequst setValue:headers[header] forHTTPHeaderField:header];
        }
        
        realRequest = newRequst;
    }
    
    [self.webView loadRequest:realRequest];
}

- (void)loadHTMLString:(NSString *)string {
    [self.webView loadHTMLString:string];
}

- (void)stopLoading {
    [self.webView stopLoading];
}

- (void)reload {
    [self.webView reload];
}

- (BOOL)canGoBack {
    return [self.webView canGoBack];
}

- (BOOL)goBack {
    return [self.webView goBack];
}

- (BOOL)canGoForward {
    return [self.webView canGoForward];
}

- (BOOL)goForward {
    return [self.webView goForward];
}

- (NSURL *)getURL {
    return [self.webView getURL];
}

- (NSString *)getTitle {
    return [self.webView getTitle];
}

- (void)addHttpHeader:(NSString *)name value:(NSString *)value {
    if (name.length) {
        if (value.length) {
            name = [self encodeURLString:name];
            value = [self encodeURLString:value];
            [self.httpHeaders setValue:value forKey:name];
        } else { //移除空值
            [self removeHttpHeader:name];
        }
    }
}

- (void)removeHttpHeader:(NSString *)name {
    if (name.length) {
        name = [self encodeURLString:name];
        [self.httpHeaders removeObjectForKey:name];
    }
}

- (NSDictionary *)allHeaders {
    return [NSDictionary dictionaryWithDictionary:self.httpHeaders];;
}

- (void)handleViewAppear {
    [self.pluginManager handleViewAppear];
}

- (void)handleViewDisAppear {
    [self.pluginManager handleViewDisappear];
}

- (void)executeJavascript:(NSString *)js completionHandler:(void (^)(NSString * _Nonnull, NSError * _Nonnull))completionHandler {
    [self.webView executeJavascript:js completionHandler:completionHandler];
}

- (void)addJavascriptHandler:(NSString *)name handler:(void (^)(id _Nonnull))handler {
    [self.webView addJavasciptHandler:name handler:handler];
}

- (void)presentViewController:(UIViewController *)contoller {
    if (self.host) {
        [self.host jjHybridPresentViewController:contoller];
    }
}

//MARK: - Private

- (BOOL)ignoreError:(NSError *)error {
    if (error) {
        if ([error.domain isEqualToString:NSURLErrorDomain]) {
            switch (error.code) {
                case NSURLErrorCancelled:
                    return YES;
            }
        } else if ([error.domain isEqualToString:@"WebKitErrorDomain"]) {
            switch (error.code) {
                case 102: // 帧框加载已中断
                    return YES;
                case 204: // 插件处理的载入
                    return YES;
            }
        }
    }
    
    return NO;
}

- (NSString *)encodeURLString:(NSString *)urlString {
    
    NSString *result = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                                         (__bridge CFStringRef)urlString,
                                                                                         NULL,
                                                                                         (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                                         CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    
    return result;
    
}

//MARK: - JJHybridWebViewDelegate
- (BOOL)shouldOverrideRequest:(NSURLRequest *)request linkOrReload:(BOOL)linkOrReload {
    BOOL shouldOverride = NO;
    
    if (self.host) {
        shouldOverride = [self.host jjHybridShouldOverrideUrl:request.URL];
    }
    
    // 这段代码主要是为了解决网页跳转请求HTTP头中没有自定义的Header的问题，但是存在兼容问题
    // 原理 其实就是把当前不带头的请求cancel掉，然后重新发起一次请求
    // 但是部分网页 会使用Link的方式来实现切换网页内tab的效果，如果重新发起一次请求，会导致网页状态丢失， Tab无法跳转
    if (self.allowOverrideRequstHeader && !shouldOverride) {
        // 添加自定的Header
        // 只处理点击链接和网页reload，修改Location、前进后退等不处理
        if (linkOrReload) {
            if (![NSURLProtocol propertyForKey:@"JJHybridEngineHeader" inRequest:request]) {
                NSDictionary *headers = self.httpHeaders;
                
                if (headers && headers.count > 0) {
                    NSMutableURLRequest *newRequest = [request mutableCopy];
                    
                    for (NSString *name in headers) {
                        [newRequest setValue:headers[name] forKey:name];
                    }
                    
                    [NSURLProtocol setProperty:@(YES) forKey:@"JJHybridEngineHeader" inRequest:newRequest];
                    
                    [self.webView loadRequest:newRequest];
                    
                    shouldOverride = YES;
                }
            }
        }
    }
    
    return shouldOverride;
}

- (void)onRequestLoadStarted:(NSURLRequest *)request {
    if (self.host) {
        [self.host jjHybridOnRequestLoadStart];
    }
}

- (void)onRequestLoadFinished:(NSURLRequest *)request {
    if (self.host) {
        [self.host jjHybridOnRequestLoadFinished];
    }
}

- (void)onRequestLoadError:(NSURLRequest *)request error:(NSError *)error {
    if (self.host) {
        if ([self ignoreError:error]) {
            [self.host jjHybridOnRequestLoadFinished];
        } else {
            [self.host jjHybridOnRequestLoadError];
        }
    }
}

- (void)onPageLoadStarted:(NSURL *)url {
    [self.pluginManager reset];
    if (self.host) {
        [self.host jjHybridOnPageLoadStart];
    }
}

- (void)onPageLoadFinished:(NSURL *)url {
    if (self.host) {
        [self.host jjHybridOnPageLoadFinished];
    }
}

- (void)onPageLoadError:(NSURL *)url error:(NSError *)error {
    if (self.host) {
        if ([self ignoreError:error]) {
            [self.host jjHybridOnPageLoadFinished];
        } else {
            [self.host jjHybridOnPageLoadError];
        }
    }
}

- (BOOL)onJavasciptPromt:(NSURL *)url promt:(NSString *)promt defaultText:(NSString *)defaultText {
    if (defaultText && [defaultText hasPrefix:JJ_HYBRID_SCHEME]) {
        NSString *dataStr = [defaultText substringFromIndex:JJ_HYBRID_SCHEME.length];
        
        if (dataStr && dataStr.length > 0) {
            [self.pluginManager onJsRequest:dataStr];
            
            return YES;
        }
    }
    
    return NO;
}

- (void)onCanGoBackChange:(BOOL)canGoBack {
    if (self.host) {
        [self.host jjHybridOnCanGoBackChanged:canGoBack];
    }
}

- (void)onTitleChange:(NSString *)title {
    if (self.host) {
        [self.host jjHybridOnTitleChanged:title];
    }
}
@end

#pragma clang diagnostic pop
