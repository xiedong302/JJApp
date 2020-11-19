//
//  UIView+JJTheme.m
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "UIView+JJTheme.h"
#import "JJThemeCommon.h"
#import <objc/runtime.h>
#import "JJBundleResource.h"
#import "JJThemeColor.h"

static void (*jjtheme_original_setBackgroungColor)(UIView *, SEL, UIColor *);

static void jjtheme_setBackgroundColor(UIView * self, SEL _cmd, UIColor *color) {
    if ([color isKindOfClass:JJThemeColor.class]) {
        self.jjtheme_backgroundColor = color;
    } else {
        self.jjtheme_backgroundColor = nil;
    }
    
    jjtheme_original_setBackgroungColor(self, _cmd, color);
}

@implementation UIView (JJTheme)

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

- (void)setJjtheme_backgroundColor:(UIColor *)color {
    objc_setAssociatedObject(self, @selector(jjtheme_backgroundColor), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIColor *)jjtheme_backgroundColor {
    return objc_getAssociatedObject(self, @selector(jjtheme_backgroundColor));
}

- (UIColor *)jjtheme_tintColor {
    return objc_getAssociatedObject(self, @selector(jjtheme_tintColor));
}

- (void)setJjtheme_tintColor:(UIColor *)color {
    if ([color isKindOfClass:JJThemeColor.class]) {
        objc_setAssociatedObject(self, @selector(jjtheme_tintColor), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, @selector(jjtheme_tintColor), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self setJjtheme_tintColor:color];
}

- (void)jjtheme_willMoveToSuperview:(UIView *)superView {
    if (!self.jjtheme_isInited) {
        self.jjtheme_isInited = YES;
        self.jjtheme_resourceSuffix = [JJBundleResource overrideSuffix];
    } else if (superView) {
        NSString *suffix = [JJBundleResource overrideSuffix];
        
        if (![NSString jj_isEqual:suffix to:self.jjtheme_resourceSuffix]) {
            self.jjtheme_resourceSuffix = suffix;
            
            [self jjtheme_themeDidUpdate];
        }
    }
    
    [self jjtheme_willMoveToSuperview:superView];
}


+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //backgroundColor, UI_APPEARANCE_SELECTOR的property不能swizzle
        Method method = class_getInstanceMethod(self, @selector(setBackgroundColor:));
        jjtheme_original_setBackgroungColor = (void *)method_getImplementation(method);
        method_setImplementation(method, (IMP)jjtheme_setBackgroundColor);
        
        //tintColor
        jjtheme_swizzleSelector(self, @selector(setTintColor:), @selector(setJjtheme_tintColor:));
        
        //willMoveToSuperview
        jjtheme_swizzleSelector(self, @selector(willMoveToSuperview:), @selector(jjtheme_willMoveToSuperview:));
    });
}

- (void)jjtheme_themeDidUpdate {
    for (UIView *subview in self.subviews) {
        [subview jjtheme_themeDidUpdate];
    }
    
    [self jjtheme_updateColors];
    [self jjtheme_updateImages];
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)jjtheme_updateColors {
    UIColor *backgroundColor = self.jjtheme_backgroundColor;
    if (backgroundColor) {
        // 解决iOS11换肤不实时更新的问题，可能setBgc内部判断值未变化时直接return了
        self.backgroundColor = nil;
        self.backgroundColor = backgroundColor;
    }
    
    UIColor *tintColor = self.jjtheme_tintColor;
    if (tintColor) {
        self.tintColor = tintColor;
    }
}

- (void)jjtheme_updateImages {
    
}

@end
