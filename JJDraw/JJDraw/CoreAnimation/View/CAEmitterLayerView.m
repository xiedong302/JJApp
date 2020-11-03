//
//  CAEmitterLayerView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/28.
//

#import "CAEmitterLayerView.h"

@interface CAEmitterLayerView()

@property (nonatomic, strong) CAEmitterLayer *colorBallLayer;

@property (nonatomic, strong) UILabel *descLabel;

@end
@implementation CAEmitterLayerView

- (void)setupView {
    self.backgroundColor = UIColor.blackColor;
    
    self.descLabel = [UILabel new];
    self.descLabel.textColor = UIColor.whiteColor;
    self.descLabel.text = @"清点或拖拽来改变发射源位置";
    [self addSubview:self.descLabel];
 
    
}

- (void)setupConstraints {
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.offset(10);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.offset(0);
    }];
    if (!self.colorBallLayer) {
        [self setupEmitter];
    }
}

- (void)setupEmitter {
    // 1. 设置CAMitterLayer
    CAEmitterLayer *colorBallLayer = [CAEmitterLayer layer];
    [self.layer addSublayer:colorBallLayer];
    self.colorBallLayer = colorBallLayer;
    
    // 发射源的尺寸大小
    colorBallLayer.emitterSize = self.frame.size;
    // 发射源的形状
    colorBallLayer.emitterShape = kCAEmitterLayerPoint;
    // 发射模式
    colorBallLayer.emitterMode = kCAEmitterLayerPoints;
    // 例子发射形状的中心点
//    colorBallLayer.emitterPosition = CGPointMake(self.bounds.size.width, 0.f);
    
    colorBallLayer.emitterPosition = CGPointMake(0, 0.f);
    
    // 2. 配置CAMitterCell
    CAEmitterCell *colorBallCell = [CAEmitterCell emitterCell];
    // 粒子名称
    colorBallCell.name = @"colorBallCell";
    // 粒子产生率 默认为0
    colorBallCell.birthRate = 20.f;
    // 粒子生命周期
    colorBallCell.lifetime = 10.0;
    // 粒子速度 默认为0
    colorBallCell.velocity = 40.f;
    // 粒子速度平均量
    colorBallCell.velocityRange = 100.f;
    // x,y,z三个方向上的加速度，三者默认都是0
    colorBallCell.yAcceleration = 15.0;
    // 指定纬度，纬度角代表了在x-z轴平面坐标系中与x轴的夹角，默认为0
//    colorBallCell.emissionLongitude = M_PI; //向左
    colorBallCell.emissionLongitude = 0; //向右
    // 发射角度范围 默认为0， 以锥形分布开的发射角度，角度用弧度制。粒子均匀分布在这个锥形范围内
//    colorBallCell.emissionRange = M_PI_4; // 围绕x轴向左90度
    colorBallCell.emissionRange = -M_PI_4; // 围绕x轴向右90度
    // 缩放比例 默认1
    colorBallCell.scale = 0.2;
    // 缩放比例范围 默认0
    colorBallCell.scaleRange = 0.1;
    // 在生命周期内的缩放速度， 默认是0
    colorBallCell.scaleSpeed = 0.02;
    // 粒子的内容，为CGImageRef的对象
    colorBallCell.contents = (__bridge id)JJTImage(@"Draw/circle_white").CGImage;
    // 颜色
    colorBallCell.color = [UIColor colorWithRed:0.5 green:0.f blue:0.5 alpha:1.f].CGColor;
    // 粒子颜色red green blue alpha能改变的范围， 默认为0
    colorBallCell.redRange = 1.f;
    colorBallCell.greenRange = 1.f;
    colorBallCell.alphaRange = 0.8f;
    // 粒子颜色red green blue alpha在生命周期内的改变速度， 默认为0
    colorBallCell.blueSpeed = 1.f;
    colorBallCell.alphaSpeed = -0.1f;
    
    // 添加
    colorBallLayer.emitterCells = @[colorBallCell];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [self locationFromTouchEvent:event];
    [self setBallInPostion:point];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [self locationFromTouchEvent:event];
    [self setBallInPostion:point];
}

/**
 * 获取手指所在的点
 */
- (CGPoint)locationFromTouchEvent:(UIEvent *)event {
    UITouch *touch = [[event allTouches] anyObject];
    return [touch locationInView:self];
}

/**
 * 移动发射源到某个点上
 */
- (void)setBallInPostion:(CGPoint)position {
    
    // 创建动画基础
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"emitterCells.colorBallCell.scale"];
    animation.fromValue = @0.2f;
    animation.toValue = @0.5f;
    animation.duration = 1.f;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    // 用事务包装隐式动画
    [CATransaction begin];
    // 设置是否禁止由于该事务组内的属性更改而出发的操作
    [CATransaction setDisableActions:YES];
    // 为colorBallLayer 添加动画
    [self.colorBallLayer addAnimation:animation forKey:nil];
    // 为colorBallLayer 指定位置添加动画效果
    [self.colorBallLayer setValue:[NSValue valueWithCGPoint:position] forKeyPath:@"emitterPosition"];
    [CATransaction commit];
}

@end
