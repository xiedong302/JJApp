//
//  JJViewController.m
//  JJBaseUI
//
//  Created by xiedong on 2020/9/25.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJViewController.h"

@interface JJViewController ()

@end

@implementation JJViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.jj_hidesNavigationBarWhenPush = NO;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)dealloc {
    JJLog(@"[JJViewController] %@ dealloc",[self class]);
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = UIColor.whiteColor;
    
    //设置navigationBar的颜色，如果是vc的root，等到viewWillAppear就有点晚了
    if (self.navigationController.viewControllers.firstObject == self) {
        [self updateNavigationBarStyle];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self setNavigationBarBack];
    
    //设置navigationBar的颜色 主要是处理push和pop的时候的过渡效果
    if (!self.jj_hidesNavigationBarWhenPush) {
        [self.transitionCoordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
            [self updateNavigationBarStyle];
        } completion:nil];
    }
    
    [self.navigationController setNavigationBarHidden:self.jj_hidesNavigationBarWhenPush animated:animated];
    
    //横竖屏处理，如果willAppear的VC不支持当前的横竖屏状态就强制旋转，否则保持不变
    {
        UIInterfaceOrientation interfaceOrientation = UIApplication.sharedApplication.statusBarOrientation;
        
        if (interfaceOrientation == UIInterfaceOrientationPortrait) {
            if (self.supportedInterfaceOrientations && UIInterfaceOrientationMaskPortrait) {
                //Nothing to do
            } else if (self.supportedInterfaceOrientations && UIInterfaceOrientationMaskLandscapeLeft) {
                [self updateDeviceOrientation:UIDeviceOrientationLandscapeLeft];
            } else if (self.supportedInterfaceOrientations && UIInterfaceOrientationMaskLandscapeRight) {
                [self updateDeviceOrientation:UIDeviceOrientationLandscapeRight];
            }
        }
        else if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
            if (self.supportedInterfaceOrientations && UIInterfaceOrientationMaskPortrait) {
                [self updateDeviceOrientation:UIDeviceOrientationPortrait];
            } else if (self.supportedInterfaceOrientations && UIInterfaceOrientationMaskLandscapeLeft) {
                //Nothing to do
            } else if (self.supportedInterfaceOrientations && UIInterfaceOrientationMaskLandscapeRight) {
                [self updateDeviceOrientation:UIDeviceOrientationLandscapeRight];
            }
        }
        else if (interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
            if (self.supportedInterfaceOrientations && UIInterfaceOrientationMaskPortrait) {
                [self updateDeviceOrientation:UIDeviceOrientationPortrait];
            } else if (self.supportedInterfaceOrientations && UIInterfaceOrientationMaskLandscapeLeft) {
                [self updateDeviceOrientation:UIDeviceOrientationLandscapeLeft];
            } else if (self.supportedInterfaceOrientations && UIInterfaceOrientationMaskLandscapeRight) {
                //Nothing to do
            }
        }
    
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 设置navigationBar的颜色
    if (!self.hidesBottomBarWhenPushed) {
        [self updateNavigationBarStyle];
    }
    
    // 只有在前台才需要注册网络通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChangeNotification:)
                                                 name:JJReachabilityChangeNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // 只有在前台才需要注册网络通知
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:JJReachabilityChangeNotification
                                                  object:nil];
}

- (UIUserInterfaceStyle)overrideUserInterfaceStyle {
    // 单个页面不遵循暗黑模式，设置为对应的模式，则强制限制该元素与其子元素以设置的模式进行展示，不跟随系统模式改变进行改变
    return UIUserInterfaceStyleLight;
}

- (BOOL)shouldAutorotate {
    // 设置是否让页面支持自动旋转屏幕
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    // 设置当前页面支持的屏幕方向
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    // 设置当前页面默认第一次进入的时候的显示的屏幕方向
    return UIInterfaceOrientationPortrait;
}

- (BOOL)prefersStatusBarHidden {
    return NO;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    if (@available(iOS 13, *)) {
        return [JJThemeManager isDarkTheme] ? UIStatusBarStyleLightContent : UIStatusBarStyleDarkContent;
    } else {
        return [JJThemeManager isDarkTheme] ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
    }
}

//MARK: - public
- (void)jj_dismiss {
    if (self.jj_isPresented) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)jj_networkStateDidChange:(BOOL)available {}

//MARK: - Getter & Setter
- (UIEdgeInsets)jj_safeAreaInset {
    if (@available(iOS 11.0, *)) {
        return self.view.safeAreaInsets;
    } else {
        return UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0);
    }
}

- (id)jj_safeAreaLayoutGuideTop {
    if (@available(iOS 11.0, *)) {
        return self.view.mas_safeAreaLayoutGuideTop;
    } else {
        return nil;
    }
}

- (id)jj_safeAreaLayoutGuideLeft {
    if (@available(iOS 11.0, *)) {
        return self.view.mas_safeAreaLayoutGuideLeft;
    } else {
        return nil;
    }
}

- (id)jj_safeAreaLayoutGuideBottom {
    if (@available(iOS 11.0, *)) {
        return self.view.mas_safeAreaLayoutGuideBottom;
    } else {
        return nil;
    }
}

- (id)jj_safeAreaLayoutGuideRight {
    if (@available(iOS 11.0, *)) {
        return self.view.mas_safeAreaLayoutGuideRight;
    } else {
        return nil;
    }
}

- (UIColor *)jj_navigationBarColor {
    return UIColor.whiteColor;
}

- (UIImage *)jj_navigationBarBackImage {
    return JJTImage(@"Nav/返回-默认");
}

- (UIImage *)jj_navigationBarBackgroundImage {
    return nil;
}

- (UIColor *)jj_navigationBarTitleColor {
    return nil;
}

- (UIFont *)jj_navigationBarTitleFont {
    return nil;
}

- (BOOL)jj_isPresented {
    return self.presentingViewController || self.isBeingPresented;
}

- (BOOL)jj_isNetworkAvailable {
    return JJNetworkReachable;
}

//MARK: - notification
- (void)reachabilityChangeNotification:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self jj_networkStateDidChange:self.jj_isNetworkAvailable];
    });
}

//MARK: - private

//设置返回按钮
- (void)setNavigationBarBack {
    UIImage *backImage = self.jj_navigationBarBackImage;
    if (backImage.renderingMode != UIImageRenderingModeAlwaysOriginal) {
        backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    self.navigationController.navigationBar.backIndicatorImage = backImage;
    self.navigationController.navigationBar.backIndicatorTransitionMaskImage = backImage;
    //去掉返回按钮的文字
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:(UIBarButtonItemStylePlain)
                                                                            target:nil action:nil];
}

//设置navigationBar的风格
- (void)updateNavigationBarStyle {
    self.navigationController.navigationBar.barTintColor = self.jj_navigationBarColor;
    [self.navigationController.navigationBar setBackgroundImage:self.jj_navigationBarBackgroundImage forBarMetrics:(UIBarMetricsDefault)];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:2];
    UIColor *titleColor = self.jj_navigationBarTitleColor;
    if (titleColor) dic[NSForegroundColorAttributeName] = titleColor;
    UIFont *titleFont = self.jj_navigationBarTitleFont;
    if (titleFont) dic[NSFontAttributeName] = titleFont;
    self.navigationController.navigationBar.titleTextAttributes = dic;
}



- (void)updateDeviceOrientation:(UIDeviceOrientation)orientation {
    @try {
        NSNumber *orientationUnknown = [NSNumber numberWithInt:0];
        [[UIDevice currentDevice] setValue:orientationUnknown forKey:@"orientation"];
        
        NSNumber *orientationTarget = [NSNumber numberWithInteger:orientation];
        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];
    } @catch (NSException *exception) {
        JJLog(@"updateDeviceOrientation failed : %@",exception);
    }
}

@end
