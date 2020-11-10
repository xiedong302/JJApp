//
//  JJHybridWebView.m
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/6.
//

#import "JJHybridWebView.h"
#import <WebKit/WebKit.h>

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

//MARK: - JJHybridWKProcessPool
@interface JJHybridWKProcessPool : WKProcessPool

+ (instancetype)sharedInstance;

@end

@implementation JJHybridWKProcessPool

+ (instancetype)sharedInstance {
    static JJHybridWKProcessPool *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JJHybridWKProcessPool alloc] init];
    });
    return instance;
}
@end

//MARK: - JJHybridJavascriptHandler
@interface JJHybridJavascriptHandler : NSObject<WKScriptMessageHandler>

@property (nonatomic, copy) void (^handler)(id);

@end

@implementation JJHybridJavascriptHandler

- (instancetype)initWithBlock:(void (^)(id data))handler {
    self = [super init];
    if (self) {
        _handler = [handler copy];
    }
    return self;
}

- (void)dealloc {
    self.handler = nil;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    void (^handlerBlock)(id) = self.handler;
    
    if (handlerBlock) {
        handlerBlock(message.body);
    }
}

@end

//MARK: - JJHybridWebView
@interface JJHybridWebView()<WKNavigationDelegate, WKUIDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) WKWebView *wkWebView;

@property (nonatomic, strong) NSMutableArray *javascriptHandlerArray;

@property (nonatomic, copy) NSURLRequest *lastLoadingRequest;
@end

@implementation JJHybridWebView

- (instancetype)initWithUA:(NSString *)ua {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self initWebView:ua];
    }
    return self;
}

- (void)initWebView:(NSString *)ua {
    _javascriptHandlerArray = [NSMutableArray array];
    
    [self initWKWebView:ua];
    [self addSubview:_wkWebView];
    
    [self setupConstraints];
}

- (void)initWKWebView:(NSString *)ua {
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.allowsInlineMediaPlayback = YES;
    config.processPool = [JJHybridWKProcessPool sharedInstance];
    
    if (@available(iOS 10.0, *)) {
        if ([config respondsToSelector:@selector(dataDetectorTypes)]) {
            config.dataDetectorTypes = WKDataDetectorTypeNone;
        }
    }
    
    config.preferences = [[WKPreferences alloc] init];
    config.preferences.javaScriptCanOpenWindowsAutomatically = YES;
    config.userContentController = [[WKUserContentController alloc] init];
    
    //设置UA
    if ([config respondsToSelector:@selector(applicationNameForUserAgent)]) {
        config.applicationNameForUserAgent = ua;
    } else {
        // 必须在WKWebView初始化之前设置
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            NSDictionary * webKitVersionDict = @{
                @"7.0" : @"537.51.1", // iOS 7.0
                @"7.1" : @"537.51.2", // iOS 7.1

                @"8.0" : @"600.1.3", // iOS 8.0
                @"8.1" : @"600.1.4", // iOS 8.1
                @"8.2" : @"600.1.4", // iOS 8.2
                @"8.3" : @"600.1.4", // iOS 8.3
                @"8.4" : @"600.1.4", // iOS 8.4
            };
            NSString *systemVersion = UIDevice.currentDevice.systemVersion;
            NSString *webKitVersion = nil;
            if (systemVersion.length >= 3) {
                webKitVersion = webKitVersionDict[[systemVersion substringToIndex:3]];
            }
            webKitVersion = webKitVersion ?: @"600.1.3";
            
            NSString *version = [systemVersion stringByReplacingOccurrencesOfString:@"." withString:@"_"];
            NSString *currentUA = [NSString stringWithFormat:
                                   @"Mozilla/5.0 (%@; CPU %@ OS %@ like Mac OS X) AppleWebKit/%@ (KHTML, like Gecko)",
                                   UIDevice.currentDevice.model,
                                   UIDevice.currentDevice.model,
                                   version,
                                   webKitVersion];
            NSString *newUA = [NSString stringWithFormat:@"%@ %@",currentUA, ua];
            
            [[NSUserDefaults standardUserDefaults] registerDefaults:@{@"UserAgent" : newUA}];
            
        });
    }
    
    _wkWebView = [[WKWebView alloc] initWithFrame:self.bounds configuration:config];
    _wkWebView.allowsBackForwardNavigationGestures = YES;
    
    if ([_wkWebView respondsToSelector:@selector(allowsLinkPreview)]) {
        _wkWebView.allowsLinkPreview = YES;
    }
    
    _wkWebView.navigationDelegate = self;
    _wkWebView.UIDelegate = self;
    _wkWebView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    
    [_wkWebView addObserver:self forKeyPath:@"canGoBack" options:(NSKeyValueObservingOptionNew) context:nil];
    [_wkWebView addObserver:self forKeyPath:@"title" options:(NSKeyValueObservingOptionNew) context:nil];
    // 处理WKWebView白屏
    [_wkWebView addObserver:self forKeyPath:@"URL" options:(NSKeyValueObservingOptionNew) context:nil];
    
    // 处理WKWebView白屏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onAppWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)setupConstraints {
    [self.wkWebView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)dealloc {
    self.wkWebView.scrollView.delegate = nil;
    
    [self.wkWebView removeObserver:self forKeyPath:@"canGoBack"];
    [self.wkWebView removeObserver:self forKeyPath:@"title"];
    [self.wkWebView removeObserver:self forKeyPath:@"URL"];
    
    for (NSString *name in self.javascriptHandlerArray) {
        [self.wkWebView.configuration.userContentController removeScriptMessageHandlerForName:name];
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.javascriptHandlerArray removeAllObjects];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"canGoBack"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onCanGoBackChange:)]) {
            BOOL canGoBack = [self.wkWebView canGoBack];
            
            [self.delegate onCanGoBackChange:canGoBack];
        }
    } else if ([keyPath isEqualToString:@"title"]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(onTitleChange:)]) {
            
            [self.delegate onTitleChange:self.wkWebView.title];
        }
    } else if ([keyPath isEqualToString:@"URL"]) {
        // URL为空时强制reload
        if ([object valueForKeyPath:keyPath] == nil) {
            [self.wkWebView reload];
        }
    }
}
//MARK: - Public
- (void)loadRequest:(NSURLRequest *)request {
    [self.wkWebView loadRequest:request];
}

- (void)loadHTMLString:(NSString *)string {
    
    if (@available(iOS 9.0, *)) {
        [self.wkWebView loadData:[string dataUsingEncoding:NSUTF8StringEncoding]
                        MIMEType:@"text/html"
           characterEncodingName:@"UTF-8"
                         baseURL:[NSURL URLWithString:@"http://localhost"]];
    } else {
        [self.wkWebView loadHTMLString:string
                               baseURL:[NSURL URLWithString:@"http://localhost"]];
    }
}

- (void)stopLoading {
    [self.wkWebView stopLoading];
}

- (void)reload {
    [self.wkWebView reload];
}

- (BOOL)canGoBack {
    return [self.wkWebView canGoBack];
}

- (BOOL)goBack {
    if ([self.wkWebView canGoBack]) {
        [self.wkWebView goBack];
        
        return YES;
    }
    
    return NO;
}

- (BOOL)canGoForward {
    return [self.wkWebView canGoForward];
}

- (BOOL)goForward {
    if ([self.wkWebView canGoForward]) {
        
        [self.wkWebView goForward];
        
        return YES;
    }
    
    return NO;
}

- (NSURL *)getURL {
    return self.wkWebView.URL;
}

- (NSString *)getTitle {
    return self.wkWebView.title;
}

- (void)executeJavascript:(NSString *)js completionHandler:(void (^)(NSString * result, NSError * error))completionHandler {
    // BugFix， js的执行是异步的，在iOS8.3以上，如果dealloc之前执行了js，会导致在dealloc时崩溃
    // 这里只能强引用等待js执行完毕之后再释放
    // 参考： https://bugs.webkit.org/show_bug.cgi?id=140203
    __block id strongSelf = self;
    
    [self.wkWebView evaluateJavaScript:js completionHandler:^(NSString * _Nullable result, NSError * _Nullable error) {
        if (completionHandler) {
            completionHandler(result, error);
        }
        
        // 置空释放
        strongSelf = nil;
    }];
}

- (void)addJavasciptHandler:(NSString *)name handler:(void (^)(id data))handler {
    if (!name.length || !handler) {
        return;
    }
    
    [self.javascriptHandlerArray addObject:name];
    
    JJHybridJavascriptHandler *h = [[JJHybridJavascriptHandler alloc] initWithBlock:handler];
    [self.wkWebView.configuration.userContentController addScriptMessageHandler:h name:name];
}

//MARK: - notification
- (void)onAppWillEnterForeground:(NSNotification *)notification {
    // 白屏的话需要重新reload
    NSURL *URL = self.wkWebView.URL;
    NSString *title = self.wkWebView.title;
    
    BOOL urlIsBlank = [[URL absoluteString] isEqualToString:@"about:blank"];
    BOOL titleIsNil = (title == nil);
    
    if (urlIsBlank || titleIsNil) {
        [self.wkWebView reload];
    }
}

// MARK: Private

-(void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    // app在后台不显示alert
    if([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        if(@available(iOS 8.0, *)) {
            UIViewController * root = [UIApplication sharedApplication].delegate.window.rootViewController;
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:title
                                                                            message:message
                                                                     preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定"
                                                                style:UIAlertActionStyleDefault
                                                              handler:nil];
            [alert addAction:okAction];

            [root presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title
                                                                 message:message
                                                                delegate:nil
                                                       cancelButtonTitle:@"确定"
                                                       otherButtonTitles:nil, nil];

            [alertView show];
        }
    }
}

-(void)showConfirmWithTitle:(NSString *)title message:(NSString *)message sureHandler:(void (^) (void))sureHandler cancelHandler:(void (^) (void))cancelHandler {
    // app在后台不显示alert
    if([UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
        if(@available(iOS 8.0, *)) {
            UIViewController * root = [UIApplication sharedApplication].delegate.window.rootViewController;
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:title
                                                                            message:message
                                                                     preferredStyle:UIAlertControllerStyleAlert];

            UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                                    style:UIAlertActionStyleCancel
                                                                  handler:^(UIAlertAction * _Nonnull action){
                                                                      if (cancelHandler) {
                                                                          cancelHandler();
                                                                      }
                                                                  }];

            UIAlertAction * okAction = [UIAlertAction actionWithTitle:@"确定"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action){
                                                                  if (sureHandler) {
                                                                      sureHandler();
                                                                  }
                                                              }];

            [alert addAction:cancelAction];
            [alert addAction:okAction];

            [root presentViewController:alert animated:YES completion:nil];
        } else {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:title
                                                                 message:message
                                                                delegate:self
                                                       cancelButtonTitle:@"取消"
                                                       otherButtonTitles:@"确定", nil];
            
            [alertView show];
        }
    }
}

//MARK: Setter
- (void)setOpaque:(BOOL)opaque {
    [super setOpaque:opaque];
    
    [self.wkWebView setOpaque:opaque];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    
    [self.wkWebView setBackgroundColor:backgroundColor];
}

//MARK: - Getter
- (UIScrollView *)scrollView {
    return self.wkWebView.scrollView;
}

//MARK: - UIAlertViewDelegate

//MARK: - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    BOOL linkOrReload = NO;
    
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated ||
        navigationAction.navigationType == WKNavigationTypeReload) {
        linkOrReload = YES;
    }
    
    if (self.delegate && [self.delegate shouldOverrideRequest:navigationAction.request linkOrReload:linkOrReload]) {
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        self.lastLoadingRequest = navigationAction.request;
        
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    if (self.delegate) {
        [self.delegate onRequestLoadStarted:self.lastLoadingRequest];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if (self.delegate) {
        [self.delegate onRequestLoadFinished:self.lastLoadingRequest];
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (self.delegate) {
        [self.delegate onRequestLoadError:self.lastLoadingRequest error:error];
    }
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    if (self.delegate) {
        [self.delegate onPageLoadStarted:self.lastLoadingRequest.URL];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    if (self.delegate) {
        [self.delegate onPageLoadFinished:self.lastLoadingRequest.URL];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (self.delegate) {
        [self.delegate onPageLoadError:self.lastLoadingRequest.URL error:error];
    }
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    if (completionHandler) {
        NSURLCredential *credential = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        
        completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
    }
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    // 解决WKWebView内存占用过大导致白屏的问题
    [webView reload];
}
//MARK: - WKUIDelegate
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    
    [webView loadRequest:navigationAction.request];
    
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    if (self.delegate && [self.delegate onJavasciptPromt:webView.URL promt:prompt defaultText:defaultText]) {
        // Nothing to do
    }
    completionHandler(nil);
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
    [self showConfirmWithTitle:@"提示" message:message sureHandler:^{
        completionHandler(YES);
    } cancelHandler:^{
        completionHandler(NO);
    }];
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    
    [self showAlertWithTitle:@"提示" message:message];
    
    completionHandler();
}
@end

#pragma clang diagnostic pop
