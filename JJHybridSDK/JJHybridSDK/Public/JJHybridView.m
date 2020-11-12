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
#import "JJHybridUser.h"
#import "JJHybridPlugin.h"
#import "JJHybridResource.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

static NSString *const JJHYBRID_ENABLE_DEBUG = @"JJHYBRID_ENABLE_DEBUG";

//MARK: - JJHybridViewMenuItem
@implementation JJHybridViewMenuItem

@end

// MARK: - JJHybridUserPlugin
@interface JJHybridUserPlugin : JJHybridPlugin

@property (nonatomic, strong) JJHybridUser *user;

- (void)sendUserChangeEvent;

@end

@implementation JJHybridUserPlugin

- (instancetype)init {
    return [super initWithName:@"JJUser"];
}

- (BOOL)execute:(NSString *)callbackId action:(NSString *)action args:(NSDictionary *)args {
    if ([action compare:@"getUserInfo"] == NSOrderedSame) {
        [self sendSuccessResult:callbackId data:[self getUserInfo]];
    } else {
        return NO;
    }
    return YES;
}

- (void)sendUserChangeEvent {
    [self sendEvent:@"userChange" data:[self getUserInfo]];
}

- (NSDictionary *)getUserInfo {
    if (self.user) {
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        if (self.user.nickName && self.user.nickName.length > 0) {
            [userInfo setValue:self.user.nickName forKey:@"nickName"];
        }
        
        return userInfo.copy;
    }
    
    return nil;
}
@end

//MARK: - JJHybridWebViewPlugin
@interface JJHybridView (JJHybridWebViewPlugin)

- (void)setTitle:(NSString *)title subtitle:(NSString *)subtitle icon:(NSString *)icon alignmentLeft:(BOOL)alignmentLeft;

@end

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
        
        [self.hybridView setTitle:title subtitle:subtitle icon:iconURL alignmentLeft:alignmentLeft];
        
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

@interface JJHybridView ()<JJHybridWebImageButtonDelegate, JJHybridHost>

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
@property (nonatomic, copy) NSString *userSetIconURL;
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

- (void)addPlugin:(JJHybridPlugin *)plugin {
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

- (void)setUser:(JJHybridUser *)user {
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

- (void)setHeaderColor:(UIColor *)color {
    self.headerView.backgroundColor = color;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    [self.webView setOpaque:NO];
    [self.webView setBackgroundColor:backgroundColor];
}

- (void)setTitleTextColot:(UIColor *)color {
    [self.titleLabel setTextColor:color];
    [self.subtitleLabel setTextColor:color];
    [self.firstMenuButton setTitleColor:color forState:UIControlStateNormal];
    [self.secondMenuButton setTitleColor:color forState:UIControlStateNormal];
}

- (void)setBackIcon:(UIImage *)image {
    [self.backButton setImage:image forState:UIControlStateNormal];
}

- (void)setCloseIcon:(UIImage *)image {
    [self.closeButton setImage:image forState:UIControlStateNormal];
}

- (void)setMoreMenuIcon:(UIImage *)image {
    self.moreMenuImage = image;
}

- (void)setProgressColor:(UIColor *)color {
    self.progressView.progressTintColor = color;
}

- (void)setTitle:(NSString *)title subtitle:(NSString *)subtitle icon:(NSString *)icon alignmentLeft:(BOOL)alignmentLeft {
    self.userSetTitle = title;
    self.userSetSubtitle = subtitle;
    self.userSetIconURL = icon;
    self.titleAlignmentLeft = alignmentLeft;
    
    [self setTitleInternal:title subtitle:subtitle icon:icon alignmentLeft:alignmentLeft];
}

- (void)hideHeader:(BOOL)hide {
    self.headerView.hidden = hide;
    
    [self setNeedsLayout];
}

- (UIView *)getErrorView {
    
    return [UIView new];
}

- (void)viewWillAppear {
    self.isViewWillAppear = YES;
}

- (void)viewdidAppear {
    self.isViewWillAppear = NO;
    
    if (self.isViewAppear || ![self isDiplayInScreen]) {
        return;
    }
    
    self.isViewAppear = YES;
    
    [self.engine handleViewAppear];
    
    [self.webViewPlugin sendVisibleEvent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAppActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notificationAppResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    
    [self startPageShow:NO];
}

- (void)viewWillDisappear {
    self.isViewWillDisappear = YES;
    
    [self startPageHide:NO];
}

- (void)viewDidDisappear {
    self.isViewWillDisappear = NO;
    
    if (!self.isViewAppear) {
        return;
    }
    
    self.isViewAppear = NO;
    
    [self.engine handleViewDisAppear];
    
    [self.webViewPlugin sendInvisibleEvent];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)startPageShow:(BOOL)newPage {
    if (newPage) {
        NSString *url = [self getURL];
        
        if (url.length) {
            NSURLComponents *coms = [NSURLComponents componentsWithString:url];
            coms.query = nil;
            coms.fragment = nil;
            
            self.staticsticUrl = coms.string;
        }
    }
    
    if (self.isViewAppear && self.staticsticUrl.length) {
        //事件上报
    }
}

- (void)startPageHide:(BOOL)loadFailed {
    if (self.staticsticUrl.length) {
        //事件上报
    }
    
    if (loadFailed) {
        self.staticsticUrl = nil;
    }
}

- (NSString *)getStartExtInfo {
    NSString *title = [self.engine getTitle];
    if (self.titleLabel.text.length) {
        title = self.titleLabel.text;
    }
    NSString *jsonStr = @"";

    if (title.length) {
        NSDictionary *dic = @{@"title": title};
        NSError * error = nil;
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        if (jsonData) {
            jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
    }
    
    return jsonStr;
}

- (void)executeJavascript:(NSString *)js completionHandler:(void (^)(NSString * _Nonnull, NSError * _Nonnull))completionHandler {
    [self.engine executeJavascript:js completionHandler:completionHandler];
}

- (void)executeJavascript:(NSString *)js {
    [self.engine executeJavascript:js completionHandler:nil];
}

- (void)addJavascriptHandler:(NSString *)name handler:(void (^)(id _Nonnull))handler {
    [self.engine addJavascriptHandler:name handler:handler];
}

// KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"]) {
        if (self.superScrollView && !self.superScrollView.dragging && !self.superScrollView.tracking) {
            CGFloat offsetX = self.superScrollView.contentOffset.x;
            CGFloat pageWidth = self.superScrollView.frame.size.width;
            
            int page = floor((offsetX - pageWidth / 2) / pageWidth ) + 1;
            
            if (self.currentPage != page) {
                self.currentPage = page;
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(onTabChange) object:nil];
                [self performSelector:@selector(onTabChange) withObject:nil afterDelay:0.3];
            }
        }
    }
}

//MARK: - Private
- (void)addObserver {
    self.superScrollView = [self getSuperScrollView];
    
    if (self.superScrollView && self.superScrollView.pagingEnabled) {
        self.currentPage = -1;
        
        [self.superScrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)removeObserver {
    if (self.superScrollView && self.superScrollView.pagingEnabled) {
        [self.superScrollView removeObserver:self forKeyPath:@"contentOffset"];
        
        self.superScrollView = nil;
    }
}

- (void)onTabChange {
    if (self.isViewWillAppear || self.isViewWillDisappear) {
        return;
    }
    
    if ([self isDiplayInScreen]) {
        [self viewdidAppear];
    } else {
        [self viewDidDisappear];
    }
}

- (UIScrollView *)getSuperScrollView {
    for (UIView *next = [self superview]; next; next = next.superview) {
        if ([next isKindOfClass:[UIScrollView class]]) {
            return (UIScrollView *)next;
        }
    }
    return nil;
}

// 判断view当前是否可见
- (BOOL)isDiplayInScreen {
    // 若view隐藏
    if (self.hidden) {
        return NO;
    }
    // 若没有superView
    if (!self.superview) {
        return NO;
    }
    
    // 转换view对应window的rect
    CGRect rect = [self.superview convertRect:self.frame toView:nil];
    if (CGRectIsEmpty(rect) || CGRectIsNull(rect)) {
        return NO;
    }
    // 若size为CGRectZero
    if (CGSizeEqualToSize(rect.size, CGSizeZero)) {
        return NO;
    }
    
    // 获取该view与window 交叉的rect
    CGRect screenRect = [UIScreen mainScreen].bounds;
    CGRect intersectionRect = CGRectIntersection(rect, screenRect);
    if (CGRectIsEmpty(intersectionRect) || CGRectIsNull(intersectionRect)) {
        return NO;
    }
    
    return YES;
}

- (void)notificationAppActive {
    [self.webViewPlugin sendVisibleEvent];
}

- (void)notificationAppResignActive {
    [self.webViewPlugin sendInvisibleEvent];
}

- (void)setTitleInternal:(NSString *)title subtitle:(NSString *)subtitle icon:(NSString *)iconURL alignmentLeft:(BOOL)alignmentLeft {
    [self.titleLabel setText:title];
    [self.subtitleLabel setText:subtitle];

    if(subtitle && subtitle.length > 0) {
        self.subtitleLabel.hidden = NO;
    } else {
        self.subtitleLabel.hidden = YES;
    }

    if(iconURL && iconURL.length > 0) {
        self.titleIcon.hidden = NO;

        [self.titleIcon setImageWithURL:iconURL placeholder:nil];
    } else {
        self.titleIcon.hidden = YES;
    }

    [self setNeedsLayout];
}

- (void)setThemeTypeInternal:(JJHybridViewThemeType)type {
    if(type == JJHybridViewThemeTypeDark) {
        UIColor * color = [UIColor whiteColor];

        [self.titleLabel setTextColor:color];
        [self.subtitleLabel setTextColor:color];

        [self.backButton setImage:[JJHybridResource imageWithName:@"hybrid_nav_back"] forState:UIControlStateNormal];
        [self.closeButton setImage:[JJHybridResource imageWithName:@"hybrid_nav_close"] forState:UIControlStateNormal];

        [self.firstMenuButton setTitleColor:color forState:UIControlStateNormal];
        [self.secondMenuButton setTitleColor:color forState:UIControlStateNormal];
        
        self.progressView.progressTintColor = [UIColor colorWithRed:0.32 green:0.59 blue:0.95 alpha:1.00];
    } else {
        UIColor * color = [UIColor colorWithRed:0.07f green:0.07f blue:0.07f alpha:1.f];

        [self.titleLabel setTextColor:color];
        [self.subtitleLabel setTextColor:color];

        [self.backButton setImage:[JJHybridResource imageWithName:@"hybrid_nav_back_dark"] forState:UIControlStateNormal];
        [self.closeButton setImage:[JJHybridResource imageWithName:@"hybrid_nav_close_dark"] forState:UIControlStateNormal];

        [self.firstMenuButton setTitleColor:color forState:UIControlStateNormal];
        [self.secondMenuButton setTitleColor:color forState:UIControlStateNormal];
        
        self.progressView.progressTintColor = [UIColor colorWithRed:1.0 green:0.67 blue:0.33 alpha:1.0];
    }
}

- (void)setCloseButtonHidden:(BOOL)hidden {
    if (self.showCloseAlways) {
        hidden = NO;
    }
    
    self.closeButton.hidden = hidden;
    
    [self setNeedsLayout];
}

- (void)startLoadingProgress {
    self.progressView.hidden = YES;
    self.indicatorView.hidden = YES;

    [self.progressTimer invalidate];

    if(self.progressType == JJHybridViewProgressTypeDefault) {
        self.progressView.hidden = NO;
        self.progressView.progress = 0;

        self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:0.01666
                                                              target:self
                                                            selector:@selector(loadingProgressUpdate)
                                                            userInfo:nil
                                                             repeats:YES];
    } else {
        self.indicatorView.hidden = NO;

        if(self.themeType == JJHybridViewThemeTypeLight) {
            self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        } else {
            self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        }

        [self.indicatorView startAnimating];
    }
}

- (void)stopLoadingProgress {
    self.progressView.hidden = YES;
    self.indicatorView.hidden = YES;

    if (self.progressTimer) {
        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
    [self.indicatorView stopAnimating];
}

-(void)loadingProgressUpdate {
    float newProgress = self.progressView.progress + 0.015;
    [self.progressView setProgress:newProgress animated:YES];

    if(self.progressView.progress >= 0.95) {
        self.progressView.progress = 0.95;

        [self.progressTimer invalidate];
        self.progressTimer = nil;
    }
}

-(void)showErrorView:(BOOL)show {
    if(!self.errorView){
        self.errorView = [self getErrorView];
    }

    if(self.errorView) {
        if(!self.errorView.superview) {
            self.errorView.translatesAutoresizingMaskIntoConstraints = NO;

            [self addSubview:self.errorView];

            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.errorView
                                                             attribute:NSLayoutAttributeCenterX
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterX
                                                            multiplier:1.0
                                                              constant:0]];

            [self addConstraint:[NSLayoutConstraint constraintWithItem:self.errorView
                                                             attribute:NSLayoutAttributeCenterY
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self
                                                             attribute:NSLayoutAttributeCenterY
                                                            multiplier:1.0
                                                              constant:0]];
        }

        self.errorView.hidden = !show;
    }

    if(show) {
        self.webView.hidden = YES;
    } else {
        self.webView.hidden = NO;
    }
}

- (void)setLoadState:(JJHybridViewLoadState)loadState {
    _loadState = loadState;
}

- (void)showDebugView {
    __weak typeof(self) weakself = self;

    UIAlertController * controller = [UIAlertController alertControllerWithTitle:@"WebView测试菜单"
                                                                         message:[weakself getURL]
                                                                  preferredStyle:UIAlertControllerStyleAlert];

    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeURL;
        textField.returnKeyType = UIReturnKeyGo;
        textField.placeholder = @"请输入URL";
    }];

    UIAlertAction * action = [UIAlertAction actionWithTitle:@"打开URL"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                        NSString * urlStr = controller.textFields[0].text;

                                                        if(urlStr && urlStr.length > 0) {
                                                            [weakself loadUrlString:urlStr];
                                                        }
                                                    }];
    [controller addAction:action];

    action = [UIAlertAction actionWithTitle:@"复制URL"
                                      style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * _Nonnull action) {
                                        NSString * url = weakself.lastLoadingURL.absoluteString;

                                        if(url && url.length > 0) {
                                            UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
                                            pasteboard.string = url;
                                        }
                                    }];
    [controller addAction:action];

    action = [UIAlertAction actionWithTitle:@"前进"
                                      style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * _Nonnull action) {
                                        [weakself goForward];
                                    }];
    [controller addAction:action];

    action = [UIAlertAction actionWithTitle:@"后退"
                                      style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * _Nonnull action) {
                                        [weakself goBack];
                                    }];
    [controller addAction:action];

    action = [UIAlertAction actionWithTitle:@"刷新"
                                      style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * _Nonnull action) {
                                        [weakself reload];
                                    }];
    [controller addAction:action];

    action = [UIAlertAction actionWithTitle:@"页面调试"
                                      style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * _Nonnull action) {
                                        [weakself executeJavascript:@"javascript:(function () { var script = document.createElement('script'); script.src='//cdn.jsdelivr.net/npm/eruda'; document.body.appendChild(script); script.onload = function () { eruda.init() } })();"];
                                    }];
    [controller addAction:action];

    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        textField.returnKeyType = UIReturnKeyGo;
        textField.placeholder = @"请输入javascript";
    }];
    
    action = [UIAlertAction actionWithTitle:@"执行javascript"
                                      style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * _Nonnull action) {
                                        NSString * js = controller.textFields[1].text;
                                         
                                        if(js && js.length > 0) {
                                            [weakself.engine executeJavascript:js completionHandler:^(NSString * _Nonnull result, NSError * _Nonnull error) {
                                                NSString * message = result;
                                                 
                                                if(error) {
                                                    message = [NSString stringWithFormat:@"%@", error];
                                                }

                                                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"执行结果"
                                                                                                    message:message
                                                                                                    delegate:nil
                                                                                        cancelButtonTitle:@"确定"
                                                                                        otherButtonTitles:nil, nil];
                                                 
                                                [alertView show];
                                            }];
                                            
                                        }
                                    }];
    [controller addAction:action];

    UIAlertAction * actionCancel = [UIAlertAction actionWithTitle:@"取消"
                                                            style:UIAlertActionStyleCancel
                                                          handler:nil];
    [controller addAction:actionCancel];
    
    [self jjHybridPresentViewController:controller];
}

//MARK: - JJHybridWebImageButtonDelegate
- (void)jjHybridWebImageLoadFinished {
    [self setNeedsLayout];
}

//MARK: - JJHybridHost
- (BOOL)jjHybridShouldOverrideUrl:(NSURL *)url {
    BOOL shouldOverride = NO;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(jjHybridViewShouldOverrideUrl:)]) {
        shouldOverride =  [self.delegate jjHybridViewShouldOverrideUrl:url];
    }

    if (!shouldOverride) {
        NSString * scheme = url.scheme;
        NSString * host = url.host;
        NSString * query = url.query;
        
        // 处理类似tel mailto等等需要外部调用的url
        if([self.externalSchemeSet containsObject:scheme] ||
           [host isEqualToString:@"itunes.apple.com"] ||
           (query && [query rangeOfString:@"_external_"].location != NSNotFound)) {
            if (@available(iOS 10.0, *)) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            } else {
                [[UIApplication sharedApplication] openURL:url];
            }

            shouldOverride = YES;
        }
    }
    
    if(!shouldOverride) {
        self.lastLoadingURL = url;
    }

    return shouldOverride;
}

- (void)jjHybridOnRequestLoadStart {
    [self showErrorView:NO];
    
    [self startLoadingProgress];
    
    [self setLoadState:JJHybridViewLoadStateLoading];
}

- (void)jjHybridOnRequestLoadFinished {
    //Nothing to do
}

- (void)jjHybridOnRequestLoadError {
    [self jjHybridOnPageLoadError];
}

- (void)jjHybridOnPageLoadStart {
    if (self.delegate && [self.delegate respondsToSelector:@selector(jjHybridViewOnPageLoadStarted)]) {
        [self.delegate jjHybridViewOnPageLoadStarted];
    }
    
    [self setMenu:nil];
    self.userSetTitle = nil;
    self.userSetSubtitle = nil;
    self.userSetIconURL = nil;
    
    [self setCloseButtonHidden:![self.engine canGoBack]];
}

- (void)jjHybridOnPageLoadFinished {
    if (self.delegate && [self.delegate respondsToSelector:@selector(jjHybridViewOnPageLoadFinished)]) {
        [self.delegate jjHybridViewOnPageLoadFinished];
    }
    
    NSString * title = nil;
    NSString * subtitle = nil;
    
    if(self.userSetTitle.length || self.userSetIconURL.length) {
        title = self.userSetTitle;
    } else {
        title = [self getTitle];
    }

    if(self.userSetSubtitle && self.userSetSubtitle.length > 0) {
        subtitle = self.userSetSubtitle;
    }

    [self setTitleInternal:title subtitle:subtitle icon:self.userSetIconURL alignmentLeft:self.titleAlignmentLeft];

    [self stopLoadingProgress];

    if(self.loadState != JJHybridViewLoadStateError) {
        [self setLoadState:JJHybridViewLoadStateFinished];
    }

    [self setCloseButtonHidden:![self.engine canGoBack]];
    
    // 页面加载完成给页面事件，方便设置菜单什么的
    [self.webViewPlugin sendOnLoadEvent];
    
    [self startPageShow:YES];
}

- (void)jjHybridOnPageLoadError {
    if (self.delegate && [self.delegate respondsToSelector:@selector(jjHybridViewOnPageLoadError)]) {
        [self.delegate jjHybridViewOnPageLoadError];
    }
    
    [self stopLoadingProgress];
    
    [self showErrorView:YES];
    
    [self setTitleInternal:nil subtitle:nil icon:nil alignmentLeft:NO];
    
    [self setLoadState:(JJHybridViewLoadStateError)];
    
    [self startPageHide:YES];
}

- (void)jjHybridOnTitleChanged:(NSString *)title {
    // Nothing to do
}

- (void)jjHybridOnCanGoBackChanged:(BOOL)canGoBack {
    [self setCloseButtonHidden:!canGoBack];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(jjHybridViewOnCanGoBackChanged:)]) {
        [self.delegate jjHybridViewOnCanGoBackChanged:canGoBack];
    }
}

- (void)jjHybridPresentViewController:(UIViewController *)controller {
    if (self.delegate && [self.delegate respondsToSelector:@selector(jjHybridViewOnPresentViewController:)]) {
        [self.delegate jjHybridViewOnPresentViewController:controller];
    }
}

@end
#pragma clang diagnostic pop
