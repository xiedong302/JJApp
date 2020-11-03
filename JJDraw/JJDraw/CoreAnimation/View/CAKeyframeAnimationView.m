//
//  CAKeyframeAnimationView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/29.
//

#import "CAKeyframeAnimationView.h"

@interface CAKeyframeAnimationView()

@property (nonatomic, strong) UIImageView *layerView;

@end

@implementation CAKeyframeAnimationView

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
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    animation.values = @[@(jj_angleToRadians(-3)),
                         @(jj_angleToRadians(5)),
                         @(jj_angleToRadians(-3))];
    animation.duration = 1;
    animation.repeatCount = MAXFLOAT;
    animation.speed = 2;
    animation.autoreverses = YES;
    [self.layerView.layer addAnimation:animation forKey:nil];
}

@end
