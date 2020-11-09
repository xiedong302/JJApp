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
#import "JJHybridWebViewPlugin.h"

//MARK: - JJHybridViewMenuItem
@implementation JJHybridViewMenuItem

@end

//MARK: - JJHybridView
@interface JJHybridView ()

@property (nonatomic, copy) NSString *hybridUA; //自定义UA

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) JJHybridWebImageButton *backButton;
@property (nonatomic, strong) JJHybridWebImageButton *closeButton;

@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) JJHybridWebImageView *titleIcon;
@property (nonatomic, strong) UILabel *subTitleLabel;
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

@property (nonatomic, copy) NSURL *loadLoadingURL;

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


- (void)initHybridView {
    
}

- (void)initEngine {
    
}

- (void)removeFromSuperview {
    [super removeFromSuperview];
    
    
}

//MARK: - Action

- (void)setLoadState:(JJHybridViewLoadState)loadState {
    
}

- (void)setTitle:(NSString *)title subtitle:(NSString *)subtitle icon:(NSString *)icon alignmentLeft:(BOOL)alignmentLeft {
    
}

- (void)setMenu:(NSArray<JJHybridViewMenuItem *> *)items {
    
}

@end
