//
//  JJMainRootController.m
//  JJAppMain
//
//  Created by xiedong on 2020/10/23.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJMainRootController.h"
#import <JJBase/JJBase.h>
#import "JJMainLaunchController.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

@interface JJMainRootController ()<JJRouterDelegate, JJMainLaunchControllerDelegate>

@property (nonatomic, strong) JJMainLaunchController *launchController;

@property (nonatomic, strong) UIViewController *currentController;

@end

@implementation JJMainRootController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [JJRouter registerDelegate:self];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveNotification:) name:@"__DebugExitMainTabBar__" object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self applyTheme];
    
    [self updateGeneralAppearance];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    [self addChildViewController:self.launchController];
    
    self.currentController = self.launchController;
    
    [self.view addSubview:self.launchController.view];
    
    [self.launchController didMoveToParentViewController:self];
    self.launchController.view.frame = self.view.bounds;
    self.launchController.delegate = self;
    // Do any additional setup after loading the view.
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
    // TODO: 目前不需要跟随系统
//    if (@available(iOS 13, *)) {
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(applyTheme) object:nil];
//        [self performSelector:@selector(applyTheme) withObject:nil afterDelay:0.3];
//    }
}

- (BOOL)shouldAutorotate {
    return self.currentController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.currentController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.currentController.preferredInterfaceOrientationForPresentation;
}

- (BOOL)prefersStatusBarHidden {
    return self.currentController.prefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.currentController.preferredStatusBarStyle;
}


//MARK: - JJRouterDelegaet
- (UIViewController *)viewControllerForParams:(NSDictionary *)params {
    NSURL *targetUrl = params[KJJRouterParamURL];
    
    if ([targetUrl.absoluteString hasPrefix:JJRouterMineMain]) {
        return self.tabBarController;
    }
    return nil;
}

- (void)showViewController:(UIViewController *)controller present:(BOOL)present {
    if (present) {
        [self.visibleViewController presentViewController:controller animated:YES completion:nil];
    } else {
        controller == self.tabBarController ? : [self.tabBarController pushViewController:controller];
    }
}

- (UIViewController *)visibleViewController {
    return self.currentController == self.launchController ? self.launchController : [self.tabBarController visibleViewController];
}

- (UIViewController *)rootViewController {
    return self;
}

//MARK: - JJMainLaunchControllerDelegate
- (void)launchController:(JJMainLaunchController *)controller openURL:(NSString *)URLString {
    [self.launchController willMoveToParentViewController:nil];
    [self addChildViewController:self.tabBarController];
    
    self.launchController.view.alpha = 1;
    self.tabBarController.view.alpha = 0;
    
    [self transitionFromViewController:self.launchController
                      toViewController:self.tabBarController
                              duration:URLString.length ? 0.2 : 0.3
                               options:UIViewAnimationOptionCurveEaseInOut //如果要跳转的话，动画跑快一点
                            animations:^{
        self.launchController.view.alpha = 0;
        self.tabBarController.view.alpha = 1;
    } completion:^(BOOL finished) {
        [self.launchController removeFromParentViewController];
        self.launchController = nil;
        
        [self.tabBarController didMoveToParentViewController:self];
        [self.tabBarController openURL:URLString];
        
        self.currentController = self.tabBarController;
    }];
}

//MARK: - notif
- (void)didReceiveNotification:(NSNotification *)notificaiton {
    if ([notificaiton.name isEqualToString:@"__DebugExitMainTabBar__"]) {
        [self.tabBarController willMoveToParentViewController:nil];
        [self.tabBarController.view removeFromSuperview];
        [self.tabBarController removeFromParentViewController];
        self.tabBarController = nil;
        self.currentController = nil;
    }
}

//MARK: - Setter && Getter
- (void)setCurrentController:(UIViewController *)currentController {
    _currentController = currentController;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (JJMainLaunchController *)launchController {
    if (!_launchController) {
        _launchController = [[JJMainLaunchController alloc] init];
    }
    return _launchController;
}

- (JJMainTabBarController *)tabBarController {
    if (!_tabBarController) {
        _tabBarController = [[JJMainTabBarController alloc] init];
    }
    return _tabBarController;
}
//MARK: - Private
- (void)applyTheme {
    
}

- (void)updateGeneralAppearance {
    
    //全部设置UITexFiled光标颜色
    [UITextField appearance].tintColor = [UIColor redColor];
}

@end

#pragma clang diagnostic pop
