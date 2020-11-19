//
//  JJMainTabBarController.m
//  JJAppMain
//
//  Created by xiedong on 2020/10/23.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJMainTabBarController.h"
#import "JJMainNavigationController.h"

@interface JJMainTabBarController ()<UITabBarControllerDelegate>

@end

@implementation JJMainTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    // tabBar 不透明，重要效果是布局终止位置会在tabBar上面
    self.tabBar.translucent = NO;
    self.tabBar.barTintColor = UIColor.jj_contentBkgColor;
    self.tabBar.tintColor = UIColor.jj_brandColor;
    [self loadTabs];
    [self configDefaultMainPage];
    
    //其他的业务
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self tabBarHeightForIOS11BugFix];
}

- (UIUserInterfaceStyle)overrideUserInterfaceStyle {
    return UIUserInterfaceStyleLight;
}

- (BOOL)shouldAutorotate {
    return self.selectedViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.selectedViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.selectedViewController.preferredInterfaceOrientationForPresentation;
}

- (BOOL)prefersStatusBarHidden {
    return self.selectedViewController.prefersStatusBarHidden;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.selectedViewController.preferredStatusBarStyle;
}

- (void)handleRouter:(NSDictionary *)params {
    NSURL *targetUrl = params[KJJRouterParamURL];
    NSInteger targetIndex = NSNotFound;
    
    if ([targetUrl.absoluteString hasPrefix:JJRouterMineMain]) {
        targetIndex = 0;
    }
    
    if (targetIndex >= self.viewControllers.count) {
        return;
    }
    
    // Pop old NavigationController
    JJMainNavigationController *originNac = self.selectedViewController;
    [originNac popToRootViewControllerAnimated:NO];
    
    // change new NavigationController
    self.selectedIndex = targetIndex;
    
    JJMainNavigationController *targetNav = self.viewControllers[targetIndex];
    
    if ([targetNav.topViewController respondsToSelector:@selector(handleRouter:)]) {
        [targetNav.topViewController handleRouter:params];
    }
}

//MARK: - Private
- (void)tabBarHeightForIOS11BugFix {
    // bug fix: 在iOS11的TabBar在竖屏时高度为49，切换到横屏后高度为32，从横屏返回到竖屏时高度没有动态改变，仍是32，造成tabBar布局错乱
    if (self.tabBar.jj_height == 32) {
        self.tabBar.jj_height = 49;
    }
}

- (void)loadTabs {
    NSMutableArray *childArray = [NSMutableArray arrayWithCapacity:2];
    
    NSArray *classes = @[@"JJMainHomeViewController", @"JJMainMineViewController"];
    NSArray *titles = @[@"首页",@"我的"];
    NSArray *images = @[@"Tabbar/首页-默认",@"Tabbar/首页-默认"];
    NSArray *selectedImages = @[@"Tabbar/首页-选中",@"Tabbar/首页-选中"];
    
    for (int i = 0; i < classes.count; i++) {
        JJMainNavigationController *nav = [self loadTabNavigationControll:classes[i]
                                                                    title:titles[i]
                                                                    image:images[i]
                                                            selectedImage:selectedImages[i]];
        [childArray addObject:nav];
    }
    
    [self setViewControllers:childArray animated:YES];
}

- (JJMainNavigationController *)loadTabNavigationControll:(NSString *)className title:(NSString *)title image:(NSString *)imagePath selectedImage:(NSString *)selectedImagePath {
    UIViewController *controller = [[NSClassFromString(className) alloc] init];
    controller.hidesBottomBarWhenPushed = NO;
    
    JJMainNavigationController * nav = [[JJMainNavigationController alloc] initWithRootViewController:controller];
    nav.tabBarItem.title = title;
//    [nav.tabBarItem setTitleTextAttributes:@{
//            NSFontAttributeName:[UIFont jj_fontOfSize:12]
//    } forState:UIControlStateNormal];
    nav.tabBarItem.image = [JJTImage(imagePath) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.selectedImage = [JJTImage(selectedImagePath) imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    nav.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -2);
    return nav;
}

- (void)configDefaultMainPage {
//    [self setSelectedIndex:0];
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    //实现切换tab的时候，view有一个过渡的动画效果
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    [self.view.layer addAnimation:transition forKey:nil];
}

//MARK: - Public
- (void)pushViewController:(UIViewController *)controller {
    JJMainNavigationController *vc = self.selectedViewController;
    [vc pushViewController:controller animated:YES];
}

- (UIViewController *)visibleViewController {
    JJMainNavigationController *vc = self.selectedViewController;
    return vc.visibleViewController;
}

- (void)openURL:(NSString *)URLString {
    JJRouterNavigate(URLString);
}
@end
