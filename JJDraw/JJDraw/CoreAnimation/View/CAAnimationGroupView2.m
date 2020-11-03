//
//  CAAnimationGroupView2.m
//  JJDraw
//
//  Created by xiedong on 2020/10/30.
//

#import "CAAnimationGroupView2.h"

@interface CAAnimationGroupView2()

@property (nonatomic, strong) UILabel *numberLaber;

@property (nonatomic, strong) UIButton *addBtn;

@property (nonatomic, assign) NSInteger danceCount;

@end
@implementation CAAnimationGroupView2

- (void)setupView {
    
    self.danceCount = 1;
    
    {
        UILabel *label = [UILabel new];
        label.text = [NSString stringWithFormat:@"+ %zd",self.danceCount];
        label.font = [UIFont fontWithName:@"AvenirNext-BoldItalic" size:50];
        label.textColor = UIColor.blackColor;
        [self addSubview:label];
        self.numberLaber = label;
    }
    
    {
        UIButton *btn = [UIButton new];
        [btn setTitle:@"点击+" forState:UIControlStateNormal];
        [btn setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(clickAddBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        self.addBtn = btn;
    }
}

- (void)setupConstraints {
    
    [self.numberLaber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
 
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.offset(0);
        make.bottom.offset(-10);
        make.width.height.offset(100);
    }];
}

- (void)clickAddBtn {
    
    self.danceCount ++;
    
    self.numberLaber.text = [NSString stringWithFormat:@"+ %zd",self.danceCount];
    
    [self labelDanceAnimation];
}

- (void)labelDanceAnimation {
    CGFloat duration = 0.4;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = duration;
    group.removedOnCompletion = YES;
    group.fillMode = kCAFillModeForwards;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // 透明度
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @0.f;
    opacityAnimation.toValue = @1.0;
    opacityAnimation.duration = duration * 0.4;
    
    // 缩放
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    
    scaleAnimation.values = @[@3.f, @1.f, @1.2f, @1.f];
    
    scaleAnimation.keyTimes = @[@0.f,@0.16f, @0.28f, @0.4f];
    
    group.animations = @[opacityAnimation, scaleAnimation];
    
    [self.numberLaber.layer addAnimation:group forKey:nil];
}


@end
