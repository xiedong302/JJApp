//
//  JJWebView.m
//  JJBaseUI
//
//  Created by xiedong on 2020/11/13.
//

#import "JJWebView.h"

@interface JJWebView ()<JJHybridViewDelegate>

@property (nonatomic, copy) NSURL *loadingURL;

@end

@implementation JJWebView {
    NSString *_callbackFun;
    NSString *_funcId;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    /**
     * 用于页面做兼容，添加新的插件时修改
     * 1.0 初始化
     */
    
    self = [super initWithFrame:frame uaVersion:@"1.0" uaChannel:@"JJApp"];
    
    if (self) {
        self.delegate = self;
        self.allowOverrideRequestHeader = YES;
        
        [self setUser:[self buildHybridUser]];
        
//        self addPlugin:<#(nonnull JJHybridPlugin *)#>
        
        self.progressType = JJHybridViewProgressTypeDefault;
        [self setThemeType:[JJThemeManager isDarkTheme] ? JJHybridViewThemeTypeDark : JJHybridViewThemeTypeLight];
        [self setHeaderColor:UIColor.whiteColor];
        [self setBackgroundColor:UIColor.whiteColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeDidChangeNotify) name:kJJThemeDidChangeNotification object:nil];
    }
    return self;
}

- (UIView *)getErrorView {
    return nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)themeDidChangeNotify {
    [self setThemeType:[JJThemeManager isDarkTheme] ? JJHybridViewThemeTypeDark : JJHybridViewThemeTypeLight];
    [self reload];
}

- (void)viewdidAppear {
    [super viewdidAppear];
}

//MARK: - JJHybridViewDelegate
- (BOOL)jjHybridViewShouldOverrideUrl:(NSURL *)url {
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(jjwebViewShouldOverrideUrl:)]) {
        if ([self.webViewDelegate jjwebViewShouldOverrideUrl:url]) {
            return YES;
        }
    }
    
    if ([JJRouter canNavigate:url.absoluteString]) {
        JJRouterNavigate(url.absoluteString);
        
        return YES;
    }
    
    JJLog(@"loading webURL : %@", url);
    
    self.loadingURL = url;
    
    return NO;
}

- (void)jjHybridViewOnPageLoadStarted {
    JJLog(@"[JJWebView] Loading : %@",self.loadingURL);
}

- (void)jjHybridViewOnPageLoadFinished {
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(jjwebViewOnPageLoadFinished)]) {
        [self.webViewDelegate jjwebViewOnPageLoadFinished];
    }
}

- (void)jjHybridViewOnPageLoadError {
    
}

- (void)jjHybridViewOnCloseView {
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(jjwebViewOnCloseView)]) {
        [self.webViewDelegate jjwebViewOnCloseView];
    }
}

- (void)jjHybridViewOnOpenUrl:(NSURL *)url {
    JJRouterNavigate(url.absoluteString);
}

- (void)jjHybridViewOnCanGoBackChanged:(BOOL)canGoBack {
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(jjwebViewOnCanGoBackChanged:)]) {
        [self.webViewDelegate jjwebViewOnCanGoBackChanged:canGoBack];
    }
}

- (void)jjHybridViewOnPresentViewController:(UIViewController *)controller {
    
}

//MARK: - Private
- (JJHybridUser *)buildHybridUser {
    JJHybridUser *user = [[JJHybridUser alloc] init];
    
    user.nickName = @"test";
    
    return user;
}

@end
