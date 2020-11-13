//
//  JJThemeColor.m
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJThemeColor.h"
#import "JJBundleResource.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@interface JJThemeColor()

@property (nonatomic, copy) NSString *resourceSuffix;

@property (nonatomic, strong) UIColor *resolvedColor;

@property (nonatomic, assign) unsigned alpha;

@end
@implementation JJThemeColor {
    NSString *_moduleName;
    NSString *_colorName;
}

- (instancetype)initWithModuleName:(NSString *)moduleName colorName:(NSString *)colorName {
    _moduleName = [moduleName copy];
    _colorName = [colorName copy];
    
    _resourceSuffix = nil;
    _alpha = 255;
    
    return self;
}

+ (instancetype)colorWithModuleName:(NSString *)moduleName colorName:(NSString *)colorName {
    return [[JJThemeColor alloc] initWithModuleName:moduleName colorName:colorName];
}

- (NSString *)moduleName {
    return _moduleName;
}

- (NSString *)colorName {
    return _colorName;
}

- (UIColor *)resolvedColor {
    NSString *resourceSuffix = [JJBundleResource overrideSuffix];
    
    if (!_resolvedColor || ![NSString jj_isEqual:resourceSuffix to:_resourceSuffix]) {
        _resourceSuffix = [resourceSuffix copy];
        
        UIColor *color = [JJBundleResource colorForName:_colorName inBundle:_moduleName];
        
        color = color?:UIColor.clearColor; //没有获取到颜色保护
        
        if (_alpha != 255) {
            color = [color colorWithAlphaComponent:_alpha / 255.0];
        }
        
        _resolvedColor = color;
    }
    
    return _resolvedColor;
}

//MARK: - NSProxy
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.resolvedColor methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.resolvedColor];
}

//MARK: - NSObject
- (BOOL)isKindOfClass:(Class)aClass {
    if (aClass == JJThemeColor.class) {
        return YES;
    }
    
    return [self.resolvedColor isKindOfClass:aClass];
}

//MARK: - NSCopying
- (id)copy {
    return [self copyWithZone:nil];
}

- (id)copyWithZone:(NSZone *)zone {
    JJThemeColor *color = [[JJThemeColor alloc] initWithModuleName:_moduleName colorName:_colorName];
    color.alpha = _alpha;
    
    return color;
}

//MARK: - UIColor

- (UIColor *)colorWithAlphaComponent:(CGFloat)alpha {
    JJThemeColor *color = [self copy];
    color.alpha = 255 * alpha;
    
    return (UIColor *)color;
}


@end
