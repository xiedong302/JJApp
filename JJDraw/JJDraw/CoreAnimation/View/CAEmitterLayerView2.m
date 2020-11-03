//
//  CAEmitterLayerView2.m
//  JJDraw
//
//  Created by xiedong on 2020/10/28.
//

#import "CAEmitterLayerView2.h"

@interface CAEmitterLikeButton : UIButton

@property (nonatomic, strong) CAEmitterLayer *explosionLayer;

@end

@implementation CAEmitterLikeButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupExplosionLayer];
    }
    return self;
}

- (void)setupExplosionLayer {
    
    // CAEmitterLayer
    CAEmitterLayer *explosionLayer = [CAEmitterLayer layer];
    [self.layer addSublayer:explosionLayer];
    self.explosionLayer = explosionLayer;
    // 发射源尺寸大小
    explosionLayer.emitterSize = CGSizeMake(self.jj_width - 20, self.jj_height - 20);
    // 发射形状 圆形模式发射
    explosionLayer.emitterShape = kCAEmitterLayerCircle;
    // 发射模式 轮廓模式 从形状的边界上发射粒子
    explosionLayer.emitterMode = kCAEmitterLayerOutline;
    // 发射源位置
    explosionLayer.position = CGPointMake(self.jj_width * 0.5, self.jj_height * 0.5);
    // renderMode：渲染模式
    explosionLayer.renderMode = kCAEmitterLayerOldestFirst;
    
    // CAEmitterCell
    CAEmitterCell *explosionCell = [CAEmitterCell emitterCell];
    // 粒子名字
    explosionCell.name = @"explosionCell";
    // 透明值变化速度
    explosionCell.alphaSpeed = -1.0f;
    // 透明值变化范围
    explosionCell.alphaRange = 0.10;
    // 每秒产生的例子数量的系数
    explosionCell.birthRate = 0;
    // 生命周期
    explosionCell.lifetime = 1;
    // 生命周期范围
    explosionCell.lifetimeRange = 0.51;
    // 粒子速度
    explosionCell.velocity = 20.f;
    // 粒子速度范围
    explosionCell.velocityRange = 10.f;
    // 缩放比例
    explosionCell.scale = 0.08;
    // 缩放比例范围
    explosionCell.scaleRange = 0.02;
    // 粒子内容
    explosionCell.contents = (__bridge id)JJTImage(@"Draw/spark_red").CGImage;
    
    explosionLayer.emitterCells = @[explosionCell];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        // 通过关键帧动画
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.values = @[@1.5,@2.0,@0.8,@1.0];
        animation.duration = 0.5;
        animation.calculationMode = kCAAnimationCubic;
        
        [self.layer addAnimation:animation forKey:nil];
        
        // 让放大动画先执行，在执行爆炸动画
        [self performSelector:@selector(startLikeAnimation) withObject:nil afterDelay:0.25];
    } else {
        [self stopLikeAnimation];
    }
}

- (void)startLikeAnimation {
    
    [self.explosionLayer setValue:@1000 forKeyPath:@"emitterCells.explosionCell.birthRate"];
    
    // 开始动画
    self.explosionLayer.beginTime = CACurrentMediaTime();
    
    // 延迟执行停止动画
    [self performSelector:@selector(stopLikeAnimation) withObject:nil afterDelay:0.15];
}

- (void)stopLikeAnimation {
    
    [self.explosionLayer setValue:@0 forKeyPath:@"emitterCells.explosionCell.birthRate"];
    
    // 移除动画
    [self.explosionLayer removeAllAnimations];
    
}

@end

@interface CAEmitterLayerView2()

@property (nonatomic, strong) CAEmitterLikeButton *likeButton;

@end

@implementation CAEmitterLayerView2

- (void)setupView {
    CAEmitterLikeButton *button = [[CAEmitterLikeButton alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    self.likeButton = button;
    [button setImage:JJRImage(@"Draw/like_normal") forState:UIControlStateNormal];
    [button setImage:JJRImage(@"Draw/like_selected") forState:UIControlStateSelected];
    [button addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
}


- (void)clickBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
}

@end
