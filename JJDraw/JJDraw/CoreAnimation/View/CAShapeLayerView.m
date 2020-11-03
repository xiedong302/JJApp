//
//  CAShapeLayerView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/28.
//

#import "CAShapeLayerView.h"

@implementation CAShapeLayerView

- (void)startAnimation {
    CGRect rect = CGRectMake(10, 10, 100, 100);
    CGSize radiu = CGSizeMake(20, 20);
    UIRectCorner corners1 = UIRectCornerTopLeft | UIRectCornerTopRight;
//    UIRectCorner corners2 = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    // create path
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:corners1 cornerRadii:radiu];
    
    // create shape layer
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    // stroke color 笔画颜色
    shapeLayer.strokeColor = UIColor.redColor.CGColor;
    // fill color 填充颜色
    shapeLayer.fillColor = UIColor.yellowColor.CGColor;
    // line width 线段宽度
    shapeLayer.lineWidth = 2;
    // 形状路径链接样式
    shapeLayer.lineJoin = kCALineJoinRound;
    // 形状路径线帽样式
    shapeLayer.lineCap = kCALineCapRound;
    // shape layer 绘制图形路径
    shapeLayer.path = path.CGPath;
    
    [self.layer addSublayer:shapeLayer];
}

@end
