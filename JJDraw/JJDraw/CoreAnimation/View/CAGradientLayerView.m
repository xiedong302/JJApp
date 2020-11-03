//
//  CAGradientLayerView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/28.
//

#import "CAGradientLayerView.h"

@implementation CAGradientLayerView

- (void)startAnimation {
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
//    gradientLayer.locations = @[@0.25,@0.5,@0.25];
    
    gradientLayer.colors = @[(__bridge id)UIColor.redColor.CGColor,
                             (__bridge id)UIColor.yellowColor.CGColor];
    
    // 左上角的位置
    gradientLayer.startPoint = CGPointMake(0, 0);
    // 右下角的位置
    gradientLayer.endPoint = CGPointMake(1, 1);
    
    // start point , end point 决定了颜色变化的走向
    // locations 颜色变化的区间
    
    [self.layer addSublayer:gradientLayer];
}

@end
