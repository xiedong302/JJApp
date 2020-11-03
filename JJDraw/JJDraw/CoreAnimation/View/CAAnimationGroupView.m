//
//  CAAnimationGroupView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/29.
//

#import "CAAnimationGroupView.h"

/**
 * 具体需求
 * 1. 内部头像放大/缩小，无限循环c_layer
 * 2. 放大时，同时有一张半透明图同时放大
 * 3. 点击缩放整个视图
 */

#define CABreathAnimationKey @"CABreathAnimationKey"
#define CABreathAnimationName @"CABreathAnimationName"
#define CABreathScaleName @"CABreathScaleName"

CGFloat CAHearhSizeWidth = 200;
CGFloat CAHearhSizeHeight = 200.0f;

@interface CAAnimationGroupView()

@property (nonatomic, strong) UIImageView *layerView;

@end

@implementation CAAnimationGroupView

- (UIImageView *)defaultImageView {
    UIImageView *imageView = [UIImageView new];
    imageView.image = JJTImage(@"Draw/pig");
    
    return imageView;
}

- (void)setupView {
    self.layerView = [self defaultImageView];
    [self addSubview:self.layerView];
    
}

- (void)setupConstraints {
    [self.layerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.top.offset(100);
        make.width.height.offset(100);
    }];
}

- (void)startAnimation {
    
    // 呼吸动画
    [self addBreathAnimation];
    // 缩放动画
//    [self addScaleAnimation];
}

- (void)addBreathAnimation {
    if (![self.layerView.layer animationForKey:CABreathAnimationKey]) {
        
        // 添加缩放
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.values = @[@1.0f,@1.4f,@1.f];
        //定义应用给定关键帧段的时间。数组中的每个值都是一个介于0.0和1.0之间的浮点数字，用于定义应用相应关键帧值的时间点（指定为动画总持续时间的一部分）。数组中的每个连续值必须大于或等于上一个值。通常，数组中的元素数应与Values属性中的元素数或Path属性中的控制点数匹配
        //keyTimes的值为0.0，0.5，1.0（当然必须转换为NSNumber），也就是说1到2帧运行到总时间的50%，2到3帧运行到8秒结束。
        animation.keyTimes = @[@0,@0.5,@1.f];
        // 缩放动画时长
        animation.duration = 1; //1000ms
        // 重复次数
        animation.repeatCount = MAXFLOAT;
        //kCAMediaTimingFunctionEaseInEaseOut(淡入淡出)
        //kCAMediaTimingFunctionEaseIn(淡入)
        //kCAMediaTimingFunctionEaseOut(淡出)
        //kCAMediaTimingFunctionDefault(默认,匀速)
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        // 为动画命名
        [animation setValue:CABreathAnimationName forKey:CABreathAnimationKey];
        [self.layerView.layer addAnimation:animation forKey:CABreathAnimationKey];
        
        // 添加半透明
        CALayer *breathLayer = [CALayer layer];
        // 位置保持一致
        breathLayer.position = CGPointMake(self.layerView.jj_width / 2, self.layerView.jj_height / 2);
        // 大小保持一致
        breathLayer.bounds = self.layerView.bounds;
        breathLayer.backgroundColor = UIColor.clearColor.CGColor;
        breathLayer.contents = (__bridge id)JJTImage(@"Draw/pig").CGImage;
        // 填充方式
        breathLayer.contentsGravity = kCAGravityResizeAspect;
        [self.layerView.layer addSublayer:breathLayer];
        
        CAKeyframeAnimation *scaleAniamtion = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        scaleAniamtion.values = @[@1.0f,@2.4f];
        scaleAniamtion.keyTimes = @[@0,@1.f];
        scaleAniamtion.duration = animation.duration;
        scaleAniamtion.repeatCount = MAXFLOAT;
        scaleAniamtion.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        
        CAKeyframeAnimation *opacityAniamtion = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
        opacityAniamtion.values = @[@1.f,@0.f];
        opacityAniamtion.keyTimes = @[@0.f,@1.f];
        opacityAniamtion.duration = animation.duration;
        opacityAniamtion.repeatCount = MAXFLOAT;
        opacityAniamtion.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
     
        // 动画组
        CAAnimationGroup *group = [CAAnimationGroup animation];
        group.animations = @[scaleAniamtion, opacityAniamtion];
        // 动画结束是否移除（默认YES）
        group.removedOnCompletion = NO;
        // 填充方式
        group.fillMode = kCAFillModeForwards;
        // 时长
        group.duration = animation.duration;
        // 重读次数
        group.repeatCount = MAXFLOAT;
        // 添加动画组
        [breathLayer addAnimation:group forKey:CABreathScaleName];
        
    }
}

- (void)addScaleAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    // 缩放变化
    animation.values = @[@1.0f,@0.8f,@1.f];
    // 帧时间占比
    animation.keyTimes = @[@0,@.05,@1.0f];
    // 时长
    animation.duration = 0.35;
    // 出现方式
    animation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                  [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [self.layerView.layer addAnimation:animation forKey:nil];
}

@end
