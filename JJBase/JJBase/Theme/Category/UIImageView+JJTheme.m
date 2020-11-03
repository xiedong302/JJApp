//
//  UIImageView+JJTheme.m
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "UIImageView+JJTheme.h"
#import "JJThemeCommon.h"
#import "UIView+JJTheme.h"
#import "JJThemeColor.h"
#import "JJThemeImage.h"
#import <objc/runtime.h>

@implementation UIImageView (JJTheme)

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

- (void)setJjtheme_highlightedImage:(UIImage *)image {
    if ([image isKindOfClass:JJThemeImage.class]) {
        objc_setAssociatedObject(self, @selector(jjtheme_highlightedImage), image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    } else {
        objc_setAssociatedObject(self, @selector(jjtheme_highlightedImage), nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    [self setJjtheme_highlightedImage:image];
}

- (UIImage *)jjtheme_highlightedImage {
    return objc_getAssociatedObject(self, @selector(jjtheme_highlightedImage));
}

- (instancetype)jjtheme_initWithImage:(UIImage *)image {
    UIImageView *imageView = [self jjtheme_initWithImage:image];
    
    if ([image isKindOfClass:JJThemeImage.class]) {
        objc_setAssociatedObject(self, @selector(jjtheme_image), image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return imageView;
}

- (instancetype)jjtheme_initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    UIImageView *imageView = [self jjtheme_initWithImage:image highlightedImage:highlightedImage];
    
    if ([image isKindOfClass:JJThemeImage.class]) {
        objc_setAssociatedObject(self, @selector(jjtheme_image), image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    if ([highlightedImage isKindOfClass:JJThemeImage.class]) {
        objc_setAssociatedObject(self, @selector(jjtheme_highlightedImage), image, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return imageView;
}

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jjtheme_swizzleSelector(self, @selector(initWithImage:), @selector(jjtheme_initWithImage:));
        jjtheme_swizzleSelector(self, @selector(initWithImage:highlightedImage:), @selector(jjtheme_initWithImage:highlightedImage:));
        jjtheme_swizzleSelector(self, @selector(setImage:), @selector(setJjtheme_image:));
        jjtheme_swizzleSelector(self, @selector(setHighlightedImage:), @selector(setJjtheme_highlightedImage:));
    });
}

- (void)jjtheme_updateImages {
    [super jjtheme_updateImages];
    
    UIImage *image = self.jjtheme_image;
    
    if (image) {
        self.image = image;
    }
    
    image = self.jjtheme_highlightedImage;
    
    if (image) {
        self.highlightedImage = image;
    }
    
}
@end
