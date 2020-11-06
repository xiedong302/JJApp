//
//  JJWebViewController.m
//  JJBaseUI
//
//  Created by xiedong on 2020/11/6.
//

#import "JJWebViewController.h"

@interface JJWebViewController ()

@property (nonatomic, copy) NSString *url;

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@end

@implementation JJWebViewController

//MARK: - LifeCircle
- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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
    // Do any additional setup after loading the view.
}

- (UIStatusBarStyle)statusBarStyle {
    return self.statusBarStyle;
}

// MARK: - Router
- (void)handleRouter:(NSDictionary *)params {
    NSURL *URL = params[KJJRouterParamURL];
    self.url = URL.absoluteString;
}

@end
