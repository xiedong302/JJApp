//
//  UIViewController+JJTheme.m
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "UIViewController+JJTheme.h"
#import "JJThemeCommon.h"
#import <objc/runtime.h>
#import "JJBundleResource.h"
#import "UIView+JJTheme.h"

@implementation UIViewController (JJTheme)

- (void)jjtheme_willMoveToParentViewController:(UIViewController *)parent {
    if (parent) {
        NSString *suffix = [JJBundleResource overrideSuffix];
        
        if (![NSString jj_isEqual:suffix to:self.jjtheme_resourceSuffix]) {
            self.jjtheme_resourceSuffix = suffix;
            
            [self jjtheme_themeDidUpdate];
        }
    }
    
    [self jjtheme_willMoveToParentViewController:parent];
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //willMoveToParentViewController
        jjtheme_swizzleSelector(self, @selector(willMoveToParentViewController:), @selector(jjtheme_willMoveToParentViewController:));
    });
}

- (void)setJjtheme_resourceSuffix:(NSString *)suffix {
    objc_setAssociatedObject(self, @selector(jjtheme_resourceSuffix), suffix, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)jjtheme_resourceSuffix {
    return objc_getAssociatedObject(self, @selector(jjtheme_resourceSuffix));
}

- (void)jjtheme_themeDidUpdate {
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.presentedViewController jjtheme_themeDidUpdate];
    
    for (UIViewController *child in self.childViewControllers) {
        [child jjtheme_themeDidUpdate];
    }
    
    if (self.viewLoaded) {
        [self.view jjtheme_themeDidUpdate];
    }
}

@end
