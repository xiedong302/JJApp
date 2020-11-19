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
    if (!self.jjtheme_isInited) {
        self.jjtheme_isInited = YES;
        self.jjtheme_resourceSuffix = [JJBundleResource overrideSuffix];
    } else if (parent) {
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

- (void)setJjtheme_isInited:(BOOL)jjtheme_isInited {
    NSNumber *obj = [NSNumber numberWithBool:jjtheme_isInited];
    objc_setAssociatedObject(self, @selector(jjtheme_isInited), obj, OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)jjtheme_isInited {
    NSNumber *isInited = objc_getAssociatedObject(self, @selector(jjtheme_isInited));
    return isInited.boolValue;
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
