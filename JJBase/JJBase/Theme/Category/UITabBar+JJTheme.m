//
//  UITabBar+JJTheme.m
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "UITabBar+JJTheme.h"
#import "UIView+JJTheme.h"
#import "JJThemeColor.h"
#import "JJThemeImage.h"
#import "JJThemeCommon.h"
#import <objc/runtime.h>

@implementation UITabBarItem (JJTheme)

- (void)setJjtheme_image:(UIImage *)image {
    if ([image isKindOfClass:JJThemeImage.class]) {
        objc_setAssociatedObject(self, @selector(jjtheme_image), image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, @selector(jjtheme_image), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self setJjtheme_image:image];
}

- (UIImage *)jjtheme_image {
    return objc_getAssociatedObject(self, @selector(jjtheme_image));
}

- (void)setJjtheme_selectedImage:(UIImage *)image {
    if ([image isKindOfClass:JJThemeImage.class]) {
        objc_setAssociatedObject(self, @selector(jjtheme_selectedImage), image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, @selector(jjtheme_selectedImage), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self setJjtheme_selectedImage:image];
}

- (UIImage *)jjtheme_selectedImage {
    return objc_getAssociatedObject(self, @selector(jjtheme_selectedImage));
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jjtheme_swizzleSelector(self, @selector(setImage:), @selector(setJjtheme_image:));
        jjtheme_swizzleSelector(self, @selector(setSelectedImage:), @selector(setJjtheme_selectedImage:));
    });
}

- (void)jjtheme_themeDidUpdate {
    UIImage *image = self.jjtheme_image;
    
    if (image) {
        self.image = image;
    }
    
    image = self.jjtheme_selectedImage;
    
    if (image) {
        self.selectedImage = image;
    }
}

@end

@implementation UITabBar (JJTheme)

- (void)jjtheme_themeDidUpdate {
    [super jjtheme_themeDidUpdate];
    
    for (UITabBarItem *item in self.items) {
        [item jjtheme_themeDidUpdate];
    }
}

- (void)jjtheme_updateColors {
    [super jjtheme_updateColors];
    
    UIColor *color = self.barTintColor;
    if ([color isKindOfClass:JJThemeColor.class]) {
        self.barTintColor = color;
    }
}

@end
