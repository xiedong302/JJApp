//
//  JJMainNavigationController.m
//  JJAppMain
//
//  Created by xiedong on 2020/10/23.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJMainNavigationController.h"

@interface JJMainNavigationController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, assign, getter=isPushing) BOOL pushing;

@end

@implementation JJMainNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    // 调用[setNavigationBarHidden:animation:]之后，滑动效果会消失，这里需要手动处理一下
    self.interactivePopGestureRecognizer.enabled = YES;
    self.interactivePopGestureRecognizer.delegate = self;
    
    // 解决push时右上角黑块的问题
    self.view.backgroundColor = UIColor.whiteColor;
    
    // navigationBar不透明，重要效果是布局起始位置会在navigationBar的下面
    self.navigationBar.translucent = NO;
    
    // 隐藏navigationBar下面的分割线
    self.navigationBar.shadowImage = [[UIImage alloc] init];
    // Do any additional setup after loading the view.
}

- (UIUserInterfaceStyle)overrideUserInterfaceStyle {
    return self.topViewController.overrideUserInterfaceStyle;
}

- (BOOL)shouldAutorotate {
    return self.topViewController.shouldAutorotate;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return self.topViewController.supportedInterfaceOrientations;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return self.topViewController.preferredInterfaceOrientationForPresentation;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.topViewController.preferredStatusBarStyle;
}

- (BOOL)prefersStatusBarHidden {
    return self.topViewController.prefersStatusBarHidden;
}

- (NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
    
    //fix bug 在Xcode12 + ios14上 popToRootViewControllerAnimated的animation为YES时， 存在tabBar不显示问题
    if (@available(iOS 14.0, *)) {
        if (animated) {
            UIViewController *lastVC = self.viewControllers.lastObject;
            lastVC.hidesBottomBarWhenPushed = NO;
        }
    }
    
    return [super popToRootViewControllerAnimated:animated];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.isPushing) {
        return;
    } else {
        self.pushing = YES;
    }
    
    [super pushViewController:viewController animated:animated];
}
//MARK: - UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    self.pushing = NO;
    //处理UIScrollView横向滚动跟滑动返回冲突的问题
    //目前方案有点坑
    UIScrollView *scrollView = [self findHorizontalScrollView:viewController.view level:0];
    if (scrollView) {
        [scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.interactivePopGestureRecognizer];
    }
}

//MARK: - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    //最后一个不能返回
    return self.viewControllers.count > 1;
}
//MARK: - Private
- (UIScrollView *)findHorizontalScrollView:(UIView *)root level:(NSInteger)level {
    if ([root isKindOfClass:UIScrollView.class]) {
        UIScrollView *scrollView = (UIScrollView *)root;
        //可以横向滚动
        if (scrollView.contentSize.width > scrollView.frame.size.width) {
            return scrollView;
        }
    }
    
    if (root.subviews.count > 0) {
        for (UIView *child in root.subviews) {
            if ([child isKindOfClass:UIScrollView.class]) {
                UIScrollView *scrollView = (UIScrollView *)child;
                //可以横向滚动
                if (scrollView.contentSize.width > scrollView.frame.size.width) {
                    return scrollView;
                }
            }
            
            // 最多只查找4层，避免效率问题
            if (level <= 3) {
                UIScrollView *scrollView = [self findHorizontalScrollView:child level:level + 1];
                if (scrollView) {
                    return scrollView;
                }
            }
        }
    }
    
    return nil;
}
@end
