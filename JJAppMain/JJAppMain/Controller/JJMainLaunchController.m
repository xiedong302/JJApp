//
//  JJMainLaunchController.m
//  JJAppMain
//
//  Created by xiedong on 2020/10/23.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJMainLaunchController.h"
#import "JJMainLaunchGuideView.h"
#import "JJMainLaunchADView.h"

@interface JJMainLaunchController ()<JJMainLaunchADViewDelegate,JJMainLaunchGuideViewDelegate>

@property (nonatomic, strong) JJMainLaunchGuideView *guideView;

@property (nonatomic, strong) JJMainLaunchADView *adView;

@end

@implementation JJMainLaunchController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *launchScreenView = [self launchScreenView];
    launchScreenView.frame = self.view.bounds;
    
    [self.view addSubview:launchScreenView];
    
    [self showLaunchView];
}

- (void)showLaunchView {
    if ([JJMainLaunchGuideView needShowGuide]) {
        self.guideView = [[JJMainLaunchGuideView alloc] init];
        self.guideView.frame = self.view.frame;
        self.guideView.delegate = self;
        
        [self.view addSubview:self.guideView];
    } else {
        self.adView = [[JJMainLaunchADView alloc] init];
        self.adView.frame = self.view.frame;
        self.adView.delegate = self;
        
        [self.view addSubview:self.adView];
    }
}

- (UIUserInterfaceStyle)overrideUserInterfaceStyle {
    return UIUserInterfaceStyleLight;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersStatusBarHidden {
    
    // 启动屏如果设置为YES， 两个问题：
    // 1. statusBar从LaunchScreen去换过来的时候会闪一下
    // 2. 后续的页面，主要是首页，会跳动一下
    return NO;;
}

//MARK: - JJMainLaunchADViewDelegate
- (void)launchADView:(JJMainLaunchADView *)view openURL:(NSString *)url {
    [self openURL:url];
}

//MARK: - JJMainLaunchGuideViewDelegate
- (void)launchGuideView:(JJMainLaunchGuideView *)view openURL:(NSString *)url {
    [self openURL:url];
}

//MARK: - private
- (UIView *)launchScreenView {
    UIStoryboard *launch = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
    UIViewController *controller = [launch instantiateInitialViewController];
    return controller.view;
}

- (void)openURL:(NSString *)url {
    __strong id<JJMainLaunchControllerDelegate> delegate = self.delegate;
    
    if (delegate && [delegate respondsToSelector:@selector(launchController:openURL:)]) {
        [delegate launchController:self openURL:url];
    }
}
@end
