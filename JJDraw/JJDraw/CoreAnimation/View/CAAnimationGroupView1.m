//
//  CAAnimationGroupView1.m
//  JJDraw
//
//  Created by xiedong on 2020/10/29.
//

#import "CAAnimationGroupView1.h"

/**
 音乐旋转动画
 */
@interface CAAnimationGroupView1Container : CABaseView

// 专辑背景视图
@property (nonatomic, strong) UIView *albumContainer;
@property (nonatomic, strong) UIImageView *album;

// 动画layer 方便reset的时候，移除所有layer的动画
@property (nonatomic, strong) NSMutableArray *noteLayers;

@end


@implementation CAAnimationGroupView1Container


- (void)setupView {
    
    self.noteLayers = [NSMutableArray array];
    
    // 专辑背景
    self.albumContainer = [UIView new];
    self.albumContainer.layer.contents = (__bridge id)JJTImage(@"Draw/music_cover").CGImage;
    self.albumContainer.contentMode = UIViewContentModeScaleAspectFit;
    self.albumContainer.layer.contentsGravity = kCAGravityResizeAspect;
    [self addSubview:self.albumContainer];
    
    // 封面
    self.album = [[UIImageView alloc] initWithImage:JJTImage(@"Draw/pig")];
    self.album.layer.cornerRadius = 25;
    self.album.layer.masksToBounds = YES;
    [self.albumContainer addSubview:self.album];
}

- (void)setupConstraints {
    [self.albumContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [self.album mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.width.height.offset(50);
    }];
}


- (void)startAnimation {
    
    [self resetView];
    
    [self rotationAlbumContainer];
    
    [self addNoteLayers];
}

- (void)resetView {
    [self.albumContainer.layer removeAllAnimations];
    
    [self.noteLayers enumerateObjectsUsingBlock:^(CALayer *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperlayer];
    }];
}

- (void)rotationAlbumContainer {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.toValue = [NSNumber numberWithFloat:M_PI * 2];
    animation.duration = 6.0f;
    animation.repeatCount = MAXFLOAT;
    animation.cumulative = YES;
    [self.albumContainer.layer addAnimation:animation forKey:nil];
}

- (void)addNoteLayers {
    
    [self addNoteLayerAnimation:@"Draw/music_note1" delay:0.f];
    [self addNoteLayerAnimation:@"Draw/music_note2" delay:1.f];
    [self addNoteLayerAnimation:@"Draw/music_note1" delay:2.f];
}

- (void)addNoteLayerAnimation:(NSString *)imageName delay:(CGFloat)delay {
    
    CGFloat rate = 12;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = rate / 4.0f;
    group.beginTime = CACurrentMediaTime() + delay;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    group.repeatCount = MAXFLOAT;
    
    // path animation
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    // X轴左右偏移量 调整与背景图之间的间距
    CGFloat sideXLength = 60.f;
    // Y轴上下偏移量 调整与背景图之间的间距
    CGFloat sideYLength = 140.f;
    
    // 贝塞尔曲线开始点   最下面 偏左一点
    CGPoint beginPoint = CGPointMake(CGRectGetMidX(self.bounds) - 10, CGRectGetMaxX(self.bounds));
    
    // 结束点
    CGPoint endPoint = CGPointMake(beginPoint.x - sideXLength, beginPoint.y - sideYLength);
    
    // 控制点的长度
    CGFloat controlLength = 60;
    
    // 控制点
    CGPoint controlPoint = CGPointMake(beginPoint.x - sideXLength / 2.0 - controlLength, beginPoint.y - sideYLength / 2.0 + controlLength);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:beginPoint];
    [path addQuadCurveToPoint:endPoint controlPoint:controlPoint];
    
    pathAnimation.path = path.CGPath;
    
    // 旋转动画
    CAKeyframeAnimation *rotationAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    
    rotationAnimation.values = @[[NSNumber numberWithFloat:0],
                                 [NSNumber numberWithFloat:M_PI * 0.10],
                                 [NSNumber numberWithFloat:M_PI * -0.10]];
    
    // 透明
    CAKeyframeAnimation *opacityAnimation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    
    opacityAnimation.values = @[[NSNumber numberWithFloat:0],
                                [NSNumber numberWithFloat:0.2f],
                                [NSNumber numberWithFloat:0.7f],
                                [NSNumber numberWithFloat:0.2f],
                                [NSNumber numberWithFloat:0]];
    
    // 缩放
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    scaleAnimation.toValue = @2.0f;
    scaleAnimation.fromValue = @1.0f;
    
    group.animations = @[pathAnimation, rotationAnimation, opacityAnimation, scaleAnimation];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.opacity = 0;
    layer.contents = (__bridge id)JJTImage(imageName).CGImage;
    layer.frame = CGRectMake(beginPoint.x, beginPoint.y, 10, 10);
    
    [self.layer addSublayer:layer];
    [self.noteLayers addObject:layer];
    
    [layer addAnimation:group forKey:nil];
    
}

@end

@interface CAAnimationGroupView1 ()

@property (nonatomic, strong) CAAnimationGroupView1Container *containerView;

@end

@implementation CAAnimationGroupView1

- (void)setupView {
    
    self.backgroundColor = UIColor.redColor;
    self.containerView = [[CAAnimationGroupView1Container alloc] init];
    [self addSubview:self.containerView];
}

- (void)setupConstraints {
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.width.height.offset(100);
    }];
}

- (void)startAnimation {
    [self.containerView startAnimation];
}
@end
