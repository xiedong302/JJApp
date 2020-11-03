//
//  CGBaseLayer.h
//  JJDraw
//
//  Created by xiedong on 2020/10/30.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

//__covariant 代表接受任意类型
@interface CGBaseLayer <__covariant T> : CALayer

/**
 * 子类绘制重写此函数
 */
- (void)layerDrawInContext:(CGContextRef)ctx;

/**
 * 子类发起开始绘制
 */
- (void)layerNotifiDisplayChanged;

@end

NS_ASSUME_NONNULL_END
