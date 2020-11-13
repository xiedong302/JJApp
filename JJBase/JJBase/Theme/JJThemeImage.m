//
//  JJThemeImage.m
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JJThemeImage.h"
#import "JJThemeCommon.h"
#import "JJBundleResource.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

static UIImage * __imageFromColor(UIColor *color) {
    UIImage *image = nil;
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

typedef NS_OPTIONS(NSUInteger, JJThemeImageOperation) {
    JJThemeImageOperation1 = 1 << 0,
    JJThemeImageOperation2 = 1 << 1,
    JJThemeImageOperation3 = 1 << 2,
    JJThemeImageOperation4 = 1 << 3,
    JJThemeImageOperation5 = 1 << 4,
    JJThemeImageOperation6 = 1 << 5,
    JJThemeImageOperation7 = 1 << 6,
    JJThemeImageOperation8 = 1 << 7,
    JJThemeImageOperation9 = 1 << 8,
    JJThemeImageOperation10 = 1 << 9,
    JJThemeImageOperation11 = 1 << 10,
    JJThemeImageOperation12 = 1 << 11,
    
};

@interface JJThemeImage()

@property (nonatomic, copy) NSString *resourceSuffix;

@property (nonatomic, strong) UIImage *resolvedImage;

@property (nonatomic, assign) JJThemeImageOperation imageOperation;

@property (nonatomic, assign) UIEdgeInsets capInsets;
@property (nonatomic, assign) UIImageResizingMode resizingMode;
@property (nonatomic, assign) UIEdgeInsets alignmentInsets;
@property (nonatomic, assign) UIImageRenderingMode renderingMode;
@property (nonatomic, assign) CGFloat baselineOffset;
@property (nonatomic, copy) UIImageConfiguration *configuration;
@property (nonatomic, copy) UIImageSymbolConfiguration *symbolConfiguration;
@property (nonatomic, copy) UIColor *tintColor;
@end

@implementation JJThemeImage {
    NSString *_moduleName;
    NSString *_resName;
    BOOL _isColor;
    BOOL _cacheable;
}

- (instancetype)initImageWithModuleName:(NSString *)moduleName resName:(NSString *)resName isColor:(BOOL)isColor cacheable:(BOOL)cacheables {
    _moduleName = [moduleName copy];
    _resName = [resName copy];
    _isColor = isColor;
    _cacheable = cacheables;
    
    _resourceSuffix = nil;
    _imageOperation = 0;
    
    return self;
}
//MARK: private
+ (UIImage *)stubImage {
    static UIImage *image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        image = __imageFromColor(UIColor.clearColor);
    });
    return image;
}

- (UIImage *)resolvedImage {
    NSString *suffix = [JJBundleResource overrideSuffix];

    if (!_resolvedImage || ![NSString jj_isEqual:_resourceSuffix to:suffix]) {
        _resourceSuffix = suffix;
        
        UIImage *image = nil;
        
        if (_isColor){
            UIColor *color = [JJBundleResource colorForName:_resName inBundle:_moduleName];
            image = __imageFromColor(color);
        } else {
            image = [JJBundleResource imageForName:_resName inBundle:_moduleName cacheable:_cacheable];
        }
        
        image = image ?: [JJThemeImage stubImage]; //没有获取到图片保护
        
        if ((_imageOperation & JJThemeImageOperation1) != 0) {
            image = [image resizableImageWithCapInsets:_capInsets];
        }
        
        if((_imageOperation & JJThemeImageOperation2) != 0) {
            image = [image resizableImageWithCapInsets:_capInsets resizingMode:_resizingMode];
        }
        
        if((_imageOperation & JJThemeImageOperation3) != 0) {
            image = [image imageWithAlignmentRectInsets:_alignmentInsets];
        }
        
        if((_imageOperation & JJThemeImageOperation4) != 0) {
            image = [image imageWithRenderingMode:_renderingMode];
        }
        
        if((_imageOperation & JJThemeImageOperation5) != 0) {
            image = [image imageFlippedForRightToLeftLayoutDirection];
        }
        
        if((_imageOperation & JJThemeImageOperation6) != 0) {
            image = [image imageWithHorizontallyFlippedOrientation];
        }
        
        if((_imageOperation & JJThemeImageOperation7) != 0) {
            image = [image imageWithBaselineOffsetFromBottom:_baselineOffset];
        }
        
        if((_imageOperation & JJThemeImageOperation8) != 0) {
            image = [image imageWithoutBaseline];
        }
        
        if((_imageOperation & JJThemeImageOperation9) != 0) {
            image = [image imageWithConfiguration:_configuration];
        }

        if((_imageOperation & JJThemeImageOperation10) != 0) {
            image = [image imageByApplyingSymbolConfiguration:_symbolConfiguration];
        }

        if((_imageOperation & JJThemeImageOperation11) != 0) {
            image = [image imageWithTintColor:_tintColor];
        }
        
        if((_imageOperation & JJThemeImageOperation12) != 0) {
            image = [image imageWithTintColor:_tintColor renderingMode:_renderingMode];
        }
        
        _resolvedImage = image;
    }
    
    return _resolvedImage;
}

//MARK: public
+ (instancetype)imageWithModuleName:(NSString *)moduleName imageName:(NSString *)imageName cacheable:(BOOL)cacheables {
    return [[JJThemeImage alloc] initImageWithModuleName:moduleName resName:imageName isColor:NO cacheable:cacheables];
}

+ (instancetype)imageWithColorModuleName:(NSString *)moduleName colorName:(NSString *)colorName {
    return [[JJThemeImage alloc] initImageWithModuleName:moduleName resName:colorName isColor:YES cacheable:NO];
}

//MARK: NSProxy
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    return [self.resolvedImage methodSignatureForSelector:sel];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [invocation invokeWithTarget:self.resolvedImage];
}

//MARK : NSObject
- (BOOL)isKindOfClass:(Class)aClass {
    if (aClass == JJThemeImage.class) {
        return YES;
    }
    
    return [self.resolvedImage isKindOfClass:aClass];
}

- (id)copy {
    return [self copyWithZone:nil];
}
- (id)copyWithZone:(NSZone *)zone {
    JJThemeImage *image = [[JJThemeImage alloc] initImageWithModuleName:_moduleName resName:_resName isColor:_isColor cacheable:_cacheable];
    
    image.imageOperation = _imageOperation;
    image.capInsets = _capInsets;
    image.resizingMode = _resizingMode;
    image.alignmentInsets = _alignmentInsets;
    image.renderingMode = _renderingMode;
    image.baselineOffset = _baselineOffset;
    image.configuration = _configuration;
    image.symbolConfiguration = _symbolConfiguration;
    image.tintColor = _tintColor;
    
    return image;
}

//MARK: UIImage
- (UIImage *)resizableImageWithCapInsets:(UIEdgeInsets)capInsets {
    JJThemeImage *image = [self copy];
    image.imageOperation |= JJThemeImageOperation1;
    image.capInsets = capInsets;
    
    return (UIImage *)image;
}


- (UIImage *)resizableImageWithCapInsets:(UIEdgeInsets)capInsets resizingMode:(UIImageResizingMode)resizingMode {
    JJThemeImage * image = [self copy];
    image.imageOperation |= JJThemeImageOperation2;
    image.capInsets = capInsets;
    image.resizingMode = resizingMode;
    
    return (UIImage *)image;
}

- (UIImage *)imageWithAlignmentRectInsets:(UIEdgeInsets)alignmentInsets {
    JJThemeImage * image = [self copy];
    image.imageOperation |= JJThemeImageOperation3;
    image.alignmentInsets = alignmentInsets;
    
    return (UIImage *)image;
}

- (UIImage *)imageWithRenderingMode:(UIImageRenderingMode)renderingMode {
    JJThemeImage * image = [self copy];
    image.imageOperation |= JJThemeImageOperation4;
    image.renderingMode = renderingMode;
    
    return (UIImage *)image;
}

- (UIImage *)imageFlippedForRightToLeftLayoutDirection {
    JJThemeImage * image = [self copy];
    image.imageOperation |= JJThemeImageOperation5;
    
    return (UIImage *)image;
}

- (UIImage *)imageWithHorizontallyFlippedOrientation {
    JJThemeImage * image = [self copy];
    image.imageOperation |= JJThemeImageOperation6;
    
    return (UIImage *)image;
}

- (UIImage *)imageWithBaselineOffsetFromBottom:(CGFloat)baselineOffset {
    JJThemeImage * image = [self copy];
    image.imageOperation |= JJThemeImageOperation7;
    image.baselineOffset = baselineOffset;
    
    return (UIImage *)image;
}

- (UIImage *)imageWithoutBaseline {
    JJThemeImage * image = [self copy];
    image.imageOperation |= JJThemeImageOperation8;
    
    return (UIImage *)image;
}

- (UIImage *)imageWithConfiguration:(UIImageConfiguration *)configuration {
    JJThemeImage * image = [self copy];

    if(configuration) {
        image.imageOperation |= JJThemeImageOperation9;
        image.configuration = configuration;
    }

    return (UIImage *)image;
}

- (UIImage *)imageByApplyingSymbolConfiguration:(UIImageSymbolConfiguration *)configuration {
    JJThemeImage * image = [self copy];

    if(configuration) {
        image.imageOperation |= JJThemeImageOperation10;
        image.symbolConfiguration = configuration;
    }

    return (UIImage *)image;
}

- (UIImage *)imageWithTintColor:(UIColor *)color {
    JJThemeImage * image = [self copy];
    image.imageOperation |= JJThemeImageOperation11;
    image.tintColor = color;
    
    return (UIImage *)image;
}

- (UIImage *)imageWithTintColor:(UIColor *)color renderingMode:(UIImageRenderingMode)renderingMode {
    JJThemeImage * image = [self copy];
    image.imageOperation |= JJThemeImageOperation12;
    image.tintColor = color;
    image.renderingMode = renderingMode;

    return (UIImage *)image;
}

@end

@interface UIImage (JJThemeImage)

@end

@implementation UIImage (JJThemeImage)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        jjtheme_swizzleSelector(self, @selector(isEqual:), @selector(jjtheme_isEqual:));
    });
}

- (BOOL)jjtheme_isEqual:(id)object {
    if ([object isKindOfClass:JJThemeImage.class]) {
        object = ((JJThemeImage *)object).resolvedImage;
    }
    
    return [self jjtheme_isEqual:object];
}

@end
#pragma clang diagnostic pop
