//
//  JJWebViewController.m
//  JJBaseUI
//
//  Created by xiedong on 2020/11/6.
//

#import "JJWebViewController.h"
#import "JJWebView.h"

@interface JJWebViewController ()<JJWebViewDelegate>

@property (nonatomic, copy) NSString *url;

@property (nonatomic, strong) JJWebView *webView;

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@end

@implementation JJWebViewController

//MARK: - LifeCircle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _webView = [[JJWebView alloc] init];
        _webView.webViewDelegate = self;
        _statusBarStyle = UIStatusBarStyleDefault;
    }
    return self;
}

- (instancetype)initWithURL:(NSString *)url {
    self = [super init];
    if (self) {
        _url = url;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"网页";
    
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.jj_safeAreaLayoutGuideLeft);
        make.right.equalTo(self.jj_safeAreaLayoutGuideRight);
        make.bottom.equalTo(self.jj_safeAreaLayoutGuideBottom);
    }];
    
    
    if (self.url) {
        [self.webView loadUrlString:self.url];
    }
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarStyle;
}

// MARK: - Router
- (void)handleRouter:(NSDictionary *)params {
    NSURL *URL = params[KJJRouterParamURL];
    self.url = URL.absoluteString;
}

//MARK: - JJWebViewDelegate
- (void)jjwebViewOnCloseView {
    // 正要被显示
    if (self.isBeingPresented || self.isMovingToParentViewController) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeSelf];
        });
    } else {
        [self removeSelf];
    }
}

- (void)jjwebViewSetStatusBarStyle:(UIStatusBarStyle)statusBarStyle {
    if (self.statusBarStyle != statusBarStyle) {
        self.statusBarStyle = statusBarStyle;
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

//MARK: - Private
- (void)removeSelf {
    if (self.jj_isPresented) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        if (self.navigationController.topViewController == self) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            NSMutableArray *controllers = [self.navigationController.viewControllers mutableCopy];
            [controllers removeObject:self];
            
            [self.navigationController setViewControllers:controllers animated:YES];
        }
    }
}

@end
