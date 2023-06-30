//
//  CAKeyframeAnimationView1.m
//  JJDraw
//
//  Created by xiedong on 2020/10/29.
//

#import "CAKeyframeAnimationView1.h"

@interface CAKeyframeAnimationView1()

@property (nonatomic, strong) UIImageView *layerView;

@property (nonatomic, strong) UIBezierPath *path;

@end

@implementation CAKeyframeAnimationView1

- (UIImageView *)defaultImageView {
    UIImageView *imageView = [UIImageView new];
    imageView.image = JJTImage(@"Draw/pig");
    
    return imageView;
}

- (void)setupView {
    self.layerView = [self defaultImageView];
    [self addSubview:self.layerView];
    
    [self addPath];
}

- (void)setupConstraints {
    [self.layerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(0);
        make.top.offset(50);
        make.width.height.offset(30);
    }];
}

- (void)addPath {
    UIBezierPath *path = [UIBezierPath bezierPath];
    self.path = path;
    // moveToPoint 设置起点
    [path moveToPoint:CGPointMake(20, 100)];
    // endPoint & controlPoint
    [path addCurveToPoint:CGPointMake(300, 100) controlPoint1:CGPointMake(100, 0) controlPoint2:CGPointMake(200, 200)];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.lineWidth = 1;
    shapeLayer.strokeColor = UIColor.redColor.CGColor;
    shapeLayer.fillColor = nil;
    shapeLayer.path = path.CGPath;
    [self.layer addSublayer:shapeLayer];
}

- (void)startAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.duration = 10;
    animation.rotationMode = kCAAnimationRotateAuto;
    animation.path = self.path.CGPath;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    [self.layerView.layer addAnimation:animation forKey:nil];
}

@end
