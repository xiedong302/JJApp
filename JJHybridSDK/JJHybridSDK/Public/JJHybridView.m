//
//  JJHybridView.m
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/6.
//

#import "JJHybridView.h"
#import "JJHybridWebImageView.h"
#import "JJHybridWebImageButton.h"
#import "JJHybridWebView.h"
#import "JJHybridEngine.h"
#import "JJHybridUserPlugin.h"
#import "JJHybridUser.h"
#import "JJHybridPlugin.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

static NSString *const JJHYBRID_ENABLE_DEBUG = @"JJHYBRID_ENABLE_DEBUG";

//MARK: - JJHybridViewMenuItem
@implementation JJHybridViewMenuItem

@end

//MARK: - JJHybridWebViewPlugin
@interface JJHybridWebViewPlugin : JJHybridPlugin

@property (nonatomic, weak) JJHybridView *hybridView;

- (void)sendMenuEvent:(NSString *)itemId;

- (void)sendVisibleEvent;

- (void)sendInvisibleEvent;

- (void)sendOnLoadEvent;

@end

@implementation JJHybridWebViewPlugin

- (instancetype)init {
    return [super initWithName:@"JJWebView"];
}

- (BOOL)execute:(NSString *)callbackId action:(NSString *)action args:(NSDictionary *)args {
    if ([action compare:@"setTitle"] == NSOrderedSame) {
        NSString *title = [args objectForKey:@"title"];
        NSString *subtitle = [args objectForKey:@"subTitle"];
        NSString *iconURL = [args objectForKey:@"icon"];
        BOOL alignmentLeft = [args[@"left"] boolValue];
        
//        [self.hybridView setTitle:title subtitle:subtitle icon:iconURL alignmentLeft:alignmentLeft];
        
        [self sendSuccessResult:callbackId data:nil];
    } else if ([action compare:@"setMenu"] == NSOrderedSame) {
        NSArray * array = [args objectForKey:@"items"];

        if(array) {
            NSMutableArray * items = [NSMutableArray arrayWithCapacity:4];
            
            for(NSDictionary * dict in array) {
                NSString * itemId = [dict objectForKey:@"id"];
                NSString * title = [dict objectForKey:@"title"];
                NSString * icon = [dict objectForKey:@"icon"];

                if(itemId && itemId.length > 0 && title && title.length > 0) {
                    JJHybridViewMenuItem * item = [[JJHybridViewMenuItem alloc] init];
                    item.itemId = itemId;
                    item.title = title;
                    item.icon = icon;

                    [items addObject:item];
                }
            }

            if(items) {
                [self.hybridView setMenu:items];

                [self sendSuccessResult:callbackId data:nil];

                return YES;
            }
        }

        [self sendErrorResult:callbackId message:@"set menu failed"];
    } else if ([action compare:@"open"] == NSOrderedSame) {
        NSString *url = [args objectForKey:@"url"];
        NSNumber *external = [args objectForKey:@"external"];
        
        if (url && url.length > 0) {
            if ([external boolValue]) {
                if (@available(iOS 10.0, *)) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url] options:@{} completionHandler:nil];
                } else {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
                }
            } else if (self.hybridView.delegate && [self.hybridView.delegate respondsToSelector:@selector(jjHybridViewOnOpenUrl:)]) {
                [self.hybridView.delegate jjHybridViewOnOpenUrl:[NSURL URLWithString:url]];
            }
            
            [self sendSuccessResult:callbackId data:nil];
        } else {
            [self sendErrorResult:callbackId message:@"url is empty"];
        }
    } else if ([action compare:@"close"] == NSOrderedSame) {
        if (self.hybridView.delegate && [self.hybridView.delegate respondsToSelector:@selector(jjHybridViewOnCloseView)]) {
            [self.hybridView.delegate jjHybridViewOnCloseView];
        }
        
        [self sendSuccessResult:callbackId data:nil];
    } else if ([action compare:@"getThemeType"] == NSOrderedSame) {
        NSDictionary *retDic = @{@"ret":@(self.hybridView.themeType)};
        [self sendSuccessResult:callbackId data:retDic];
    } else {
        return NO;
    }
    return YES;
}

- (void)sendMenuEvent:(NSString *)itemId {
    if (itemId && itemId.length > 0) {
        [self sendEvent:@"menu" data:@{@"id" : itemId}];
    }
}

- (void)sendVisibleEvent {
    [self sendEvent:@"visible" data:nil];
}

- (void)sendInvisibleEvent {
    [self sendEvent:@"invisible" data:nil];
}

- (void)sendOnLoadEvent {
    [self sendEvent:@"onload" data:nil];
}


@end

//MARK: - JJHybridView
@interface JJHybridView (JJHybridWebViewPlugin)

- (void)setTitle:(NSString *)title subtitle:(NSString *)subtitle icon:(NSString *)icon alignmentLeft:(BOOL)alignmentLeft;

@end

@interface JJHybridView ()

@property (nonatomic, copy) NSString *hybridUA; //自定义UA

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) JJHybridWebImageButton *backButton;
@property (nonatomic, strong) JJHybridWebImageButton *closeButton;

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) JJHybridWebImageView *titleIcon;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, assign) BOOL titleAlignmentLeft;

@property (nonatomic, strong) JJHybridWebImageButton *firstMenuButton;
@property (nonatomic, strong) JJHybridWebImageButton *secondMenuButton;
@property (nonatomic, strong) UIImage *moreMenuImage;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property (nonatomic, strong) UIView *errorView;

@property (nonatomic, strong) JJHybridWebView *webView;

@property (nonatomic, strong) UIButton *debugButton;

@property (nonatomic, strong) JJHybridEngine *engine;
@property (nonatomic, strong) JJHybridWebViewPlugin *webViewPlugin;
@property (nonatomic, strong) JJHybridUserPlugin *userPlugin;

@property (nonatomic, strong) NSSet *externalSchemeSet;

@property (nonatomic, copy) NSString *userSetTitle;
@property (nonatomic, copy) NSString *userSetUconURL;
@property (nonatomic, copy) NSString *userSetSubtitle;

@property (nonatomic, strong) NSArray <JJHybridViewMenuItem *> *menuItems;

@property (nonatomic, strong) NSTimer *progressTimer;

@property (nonatomic, copy) NSURL *lastLoadingURL;

@property (nonatomic, assign) BOOL isViewWillAppear;
@property (nonatomic, assign) BOOL isViewWillDisappear;
@property (nonatomic, assign) BOOL isViewAppear;

@property (nonatomic, weak) UIScrollView *superScrollView;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, copy) NSString *staticsticUrl;

@end

@implementation JJHybridView

- (instancetype)initWithFrame:(CGRect)frame uaVersion:(NSString *)version uaChannel:(NSString *)channel {
    self = [super initWithFrame:frame];
    
    if (self) {
        if (!version || version.length == 0) {
            version = @"1.0";
        }
        
        if (!channel || channel.length == 0) {
            channel = @"";
        }
        
        _hybridUA = [NSString stringWithFormat:@"JJHybridSDK/%@ (%@; %@)",version, channel,
                     [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
        
        [self initHybridView];
        
        [self initEngine];
        
        [self setLoadState:JJHybridViewLoadStateInit];
        
        [self setThemeType:JJHybridViewThemeTypeDark];
        
        [self setAllowOverrideRequestHeader:NO];
    }
    
    return self;
}

- (void)didMoveToWindow {
    [super didMoveToWindow];
    
    if (self.window) {
        [self addObserver];
        
        if (!self.isViewWillAppear && !self.isViewWillDisappear) {
            [self viewdidAppear];
        }
    } else {
        [self removeObserver];
        
        if (!self.isViewWillAppear && !self.isViewWillDisappear) {
            [self viewDidDisappear];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //布局开始
    CGFloat headerLeftMargin = 0;
    CGFloat headerRightMargin = 0;

    CGFloat headerHeight = 44;

    if (@available(iOS 11.0, *)) {
        headerHeight += self.safeAreaInsets.top;
        headerLeftMargin = self.safeAreaInsets.left;
        headerRightMargin = self.safeAreaInsets.right;
    } else {
        headerHeight += 20;
    }
    
    // 头
    headerHeight = self.headerView.hidden ? 0 : headerHeight;
    
    
}

- (void)dealloc {
    if (self.progressTimer) {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)initHybridView {
    // Header
    _headerView = [[UIView alloc] init];
    _headerView.backgroundColor = UIColor.whiteColor;
    
    [self addSubview:_headerView];
    
    // 返回按钮
    _backButton = [[JJHybridWebImageButton alloc] init];
    _backButton.adjustsImageWhenHighlighted = NO;
    _backButton.imageView.contentMode = UIViewContentModeCenter;
    _backButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [_backButton setContentHorizontalAlignment:(UIControlContentHorizontalAlignmentCenter)];
    [_backButton setImageEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
    [_backButton addTarget:self action:@selector(backButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [_headerView addSubview:_backButton];
    
    // 关闭按钮
    _closeButton = [[JJHybridWebImageButton alloc] init];
    _closeButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    _closeButton.hidden = YES;
    [_closeButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    [_closeButton setImageEdgeInsets:UIEdgeInsetsMake(7, 7, 7, 7)];
    [_closeButton addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];

    [_headerView addSubview:_closeButton];
    
    // TitleView
    _titleView = [[UIView alloc] init];

    [_headerView addSubview:_titleView];
    
    // 图标
    _titleIcon = [[JJHybridWebImageView alloc] init];
    _titleIcon.contentMode = UIViewContentModeScaleAspectFit;
    _titleIcon.layer.cornerRadius = 15;

    [_titleView addSubview:_titleIcon];
    
    // 主标题
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.font = [UIFont boldSystemFontOfSize:18];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.userInteractionEnabled = YES;

    UITapGestureRecognizer * debugTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                action:@selector(showDebugView)];
    debugTap.numberOfTapsRequired = 8;
    [_titleLabel addGestureRecognizer:debugTap];

    [_titleView addSubview:_titleLabel];
    
    // 副标题
    _subtitleLabel = [[UILabel alloc] init];
    _subtitleLabel.font = [UIFont systemFontOfSize:12];
    _subtitleLabel.textAlignment = NSTextAlignmentCenter;
    _subtitleLabel.hidden = YES;

    [_titleView addSubview:_subtitleLabel];
    
    // 第一个菜单按钮
    _firstMenuButton = [[JJHybridWebImageButton alloc] init];
    _firstMenuButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_firstMenuButton addTarget:self action:@selector(menuItemClick:) forControlEvents:UIControlEventTouchUpInside];
    _firstMenuButton.hidden = YES;
    _firstMenuButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _firstMenuButton.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    _firstMenuButton.delegate = self;
    [_firstMenuButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];

    [_headerView addSubview:_firstMenuButton];
    
    // 第二个菜单按钮
    _secondMenuButton = [[JJHybridWebImageButton alloc] init];
    _secondMenuButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [_secondMenuButton addTarget:self action:@selector(menuItemClick:) forControlEvents:UIControlEventTouchUpInside];
    _secondMenuButton.hidden = YES;
    _secondMenuButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    _secondMenuButton.imageEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 7);
    _secondMenuButton.delegate = self;
    [_secondMenuButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];

    [_headerView addSubview:_secondMenuButton];
    
    // webView
    _webView = [[JJHybridWebView alloc] initWithUA:self.hybridUA];

    [self addSubview:_webView];
    
    // 进度条
    _progressView = [[UIProgressView alloc] init];
    _progressView.trackTintColor = [UIColor colorWithWhite:1.0 alpha:0];
    _progressView.progressTintColor = [UIColor colorWithRed:0.32 green:0.59 blue:0.95 alpha:1.00];
    _progressView.hidden = YES;

    [self addSubview:_progressView];
    
    // 进度加载器
    _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _indicatorView.hidden = YES;

    [self addSubview:_indicatorView];
    
    if([JJHybridView isDebug]) {
        _debugButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [_debugButton addTarget:self action:@selector(showDebugView) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_debugButton];
    }

    self.backgroundColor = UIColor.whiteColor;
}

- (void)initEngine {
    _engine = [[JJHybridEngine alloc] initWithWebView:_webView];
    _engine.host = self;
    
    _webViewPlugin = [[JJHybridWebViewPlugin alloc] init];
    _webViewPlugin.hybridView = self;
    
    _userPlugin = [[JJHybridUserPlugin alloc] init];
    
    [_engine addPlugin:_webViewPlugin];
    [_engine addPlugin:_userPlugin];
    
    [_engine addHttpHeader:@"X-GUID" value:@"X-GUID"];
    [_engine addHttpHeader:@"X-XUA" value:@"X-XUA"];
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    
    if (self.progressTimer) {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
}

//MARK: - Action
- (void)backButtonClick:(UIButton *)sender {
    if (![self.engine goBack]) {
        [self closeButtonClick:sender];
    }
}

- (void)closeButtonClick:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(jjHybridViewOnCloseView)]) {
        [self.delegate jjHybridViewOnCloseView];
    }
}

- (void)menuItemClick:(UIButton *)sender {
    switch (sender.tag) {
        case 1:
        {
            if (self.menuItems.count > 0) {
                [self.webViewPlugin sendMenuEvent:self.menuItems[0].itemId];
            }
        }
            break;
        case 2 :
        {
            if (self.menuItems.count > 1) {
                [self.webViewPlugin sendMenuEvent:self.menuItems[1].itemId];
            }
        }
            break;
        case 3 :
        {
            //显示menuView
        }
            break;
        default:
            break;
    }
}

// MARK: - Getter
- (UIScrollView *)scrollView {
    return self.webView.scrollView;
}

- (NSSet *)externalSchemeSet {
    if (!_externalSchemeSet) {
        _externalSchemeSet = [NSSet setWithArray:@[
            @"tel", // 打电话
            @"sms", // 短信
            @"mms", // 彩信
            @"mailto", // 邮件
            @"geo", // 定位
            @"itms-apps", // itunes
            @"itms-appss", // itunes
        ]];
    }
    
    return _externalSchemeSet;
}

//MARK: - Setter
- (void)setThemeType:(JJHybridViewThemeType)themeType {
    _themeType = themeType;
    [self.engine addHttpHeader:@"X-JJ-THEME" value:[NSString stringWithFormat:@"%zd",themeType]];
    [self setThemeTypeInternal:themeType];
}

- (void)setAllowOverrideRequestHeader:(BOOL)allowOverrideRequestHeader {
    _allowOverrideRequestHeader = allowOverrideRequestHeader;
    self.engine.allowOverrideRequstHeader = allowOverrideRequestHeader;
}

//MARK: - Public
+ (void)enableDebug:(BOOL)debug {
    if (@available(iOS 8.0, *)) {
        [[NSUserDefaults standardUserDefaults] setBool:debug forKey:JJHYBRID_ENABLE_DEBUG];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (BOOL)isDebug {
    return [[NSUserDefaults standardUserDefaults] boolForKey:JJHYBRID_ENABLE_DEBUG];
}

- (void)addPlugin:(JJHybirdPlugin *)plugin {
    [self.engine addPlugin:plugin];
}

- (void)loadUrlString:(NSString *)url {
    [self loadUrl:[NSURL URLWithString:url]];
}

- (void)loadUrl:(NSURL *)url {
    [self.engine loadUrl:url];
}

- (NSString *)getURL {
    if (self.loadState != JJHybridViewLoadStateFinished) {
        return self.lastLoadingURL.absoluteString;
    } else {
        return [self.engine getURL].absoluteString;
    }
}



- (void)reload {
    if (self.loadState != JJHybridViewLoadStateFinished) {
        if (self.lastLoadingURL) {
            [self loadUrl:self.lastLoadingURL];
        }
    } else {
        [self.engine reload];
    }
}

- (void)stopLoading {
    [self.engine stopLoading];
}

- (BOOL)canGoBack {
    return [self.engine canGoBack];
}

- (BOOL)goBack {
    return [self.engine goBack];
}

- (BOOL)canGoForward {
    return [self.engine canGoForward];
}
- (BOOL)goForward {
    return [self.engine goForward];
}

- (NSString *)getTitle {
    return [self.engine getTitle];
}

- (void)setMenu:(NSArray<JJHybridViewMenuItem *> *)items {
    
}

- (void)addHttpHeader:(NSString *)name value:(NSString *)value {
    [self.engine addHttpHeader:name value:value];
}

- (void)setUser:(JJHybirdUser *)user {
    self.userPlugin.user = user;
    
    if (user) {
        [self.engine addHttpHeader:@"X-JJ-NICKNAME" value:(user.nickName ?: @"")];
        
        // 登录标识位
        [self.engine addHttpHeader:@"X-JJ-LOGIN" value:@"1"];
    } else {
        [self.engine removeHttpHeader:@"X-JJ-NICKNAME"];
        
        // 登录标识位
        [self.engine removeHttpHeader:@"X-JJ-LOGIN"];
    }
    
    [self.userPlugin sendUserChangeEvent];
}


//MARK: - Private
- (void)addObserver {
    
}

- (void)removeObserver {
    
}

//MARK: - Action

- (void)setLoadState:(JJHybridViewLoadState)loadState {
    
}

- (void)setTitle:(NSString *)title subtitle:(NSString *)subtitle icon:(NSString *)icon alignmentLeft:(BOOL)alignmentLeft {
    
}

- (void)setThemeTypeInternal:(JJHybridViewThemeType)themeType {
    
}

@end
#pragma clang diagnostic pop
