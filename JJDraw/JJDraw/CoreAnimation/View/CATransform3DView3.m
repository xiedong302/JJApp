//
//  CATransform3DView3.m
//  JJDraw
//
//  Created by xiedong on 2020/10/28.
//

#import "CATransform3DView3.h"

@interface CATransform3DView3()

@property (nonatomic, strong) CALayer *rootLayer;

@end

@implementation CATransform3DView3

- (void)setupView {
    self.rootLayer = [CALayer layer];
    // 应用透视转换
    CATransform3D transform = CATransform3DMakePerspective(1000);
    self.rootLayer.sublayerTransform = transform;
    [self.layer addSublayer:self.rootLayer];
    
    // 颜色数组
    NSArray *colors = @[[UIColor colorWithRed:0.263 green:0.769 blue:0.319 alpha:1.000],
                        [UIColor colorWithRed:0.990 green:0.759 blue:0.145 alpha:1.000],
                        [UIColor colorWithRed:0.084 green:0.398 blue:0.979 alpha:1.000]];
    
    // 添加3个图层
    [self addLayerWithColors:colors];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.rootLayer.frame = self.bounds;
    
}

- (void)addLayerWithColors:(NSArray *)colors {
    
    for (UIColor *color in colors) {
        CALayer *layer = [CALayer layer];
        layer.backgroundColor = color.CGColor;
        layer.bounds = CGRectMake(0, 0, 200, 200);
        // 位置
        layer.position = CGPointMake(160, 190);
        // 透明度
        layer.opacity = 0.80;
        layer.cornerRadius = 10;
        layer.borderColor = UIColor.whiteColor.CGColor;
        layer.borderWidth = 1.0;
        layer.shadowOffset = CGSizeMake(0, 2);
        layer.shadowColor = UIColor.darkGrayColor.CGColor;
        layer.shadowOpacity = 0.35;
        // 是否光栅化
        layer.shouldRasterize = YES;
        [self.rootLayer addSublayer:layer];
    }
    
}

// 透视投影修改m34的值
static CATransform3D CATransform3DMakePerspective(CGFloat z) {
    CATransform3D t = CATransform3DIdentity;
    t.m34 = - 1.0 / z;
    return t;
}

- (void)startAnimation {
    // 创建基本动画 围绕Y轴和Z轴旋转
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(jj_angleToRadians(85), 0, 1, 1)];
    animation.duration = 1.5;
    animation.repeatCount = MAXFLOAT;
    // 自动翻转
    animation.autoreverses = YES;
    
    // 定义动画步调的计时函数
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    int tx = 0;
    for (CALayer *layer in self.rootLayer.sublayers) {
        // 为图层添加动画
        [layer addAnimation:animation forKey:nil];
        
        //创建沿着X轴平移的动画
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        animation.fromValue = [NSValue valueWithCATransform3D:layer.transform];
        animation.toValue = [NSNumber numberWithInt:tx];
        animation.duration = 1.5;
        animation.repeatCount = MAXFLOAT;
        // 自动翻转
        animation.autoreverses = YES;
        
        // 定义动画步调的计时函数
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        [layer addAnimation:animation forKey:nil];
        tx += 40;
    }
}

@end
