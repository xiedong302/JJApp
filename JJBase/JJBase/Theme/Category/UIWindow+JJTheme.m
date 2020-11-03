//
//  UIWindow+JJTheme.m
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "UIWindow+JJTheme.h"
#import "UIViewController+JJTheme.h"
#import "UIView+JJTheme.h"

@implementation UIWindow (JJTheme)

- (void)jjtheme_windowThemeDidUpdate {
    
    UIView *snapshot = [self snapshotViewAfterScreenUpdates:NO];
    
    //TODO: 直接加载window上的view目前不支持切换主题
//    UIView *rootVCView = self.rootViewController.view;
//    
//    for (UIView *subView in rootVCView.subviews) {
//        if (subView != rootVCView) {
//            [subView jjtheme_themeDidUpdate];
//        }
//    }
    
    [self.rootViewController jjtheme_themeDidUpdate];
    
    [self addSubview:snapshot];
    
    [UIView animateWithDuration:0.2f animations:^{
        snapshot.alpha = 0;
    } completion:^(BOOL finished) {
        [snapshot removeFromSuperview];
    }];
}
@end
