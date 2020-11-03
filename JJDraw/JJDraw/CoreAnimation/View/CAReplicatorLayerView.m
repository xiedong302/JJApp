//
//  CAReplicatorLayerView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/28.
//

#import "CAReplicatorLayerView.h"

@interface CAReplicatorLayerView()

@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation CAReplicatorLayerView

- (void)setupView {
    self.imageView = [UIImageView new];
    self.imageView.image = JJTImage(@"Draw/timg");
    [self addSubview:self.imageView];
}

- (void)setupConstraints {
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.centerX.offset(0);
        make.width.height.offset(50);
    }];
}

+ (Class)layerClass {
    return [CAReplicatorLayer class];;
}

- (void)startAnimation {
    CAReplicatorLayer *replicatorLayer = (CAReplicatorLayer *)self.layer;
//    replicatorLayer.frame = self.imageView.frame;
    replicatorLayer.instanceCount = 2;

    CATransform3D transform = CATransform3DIdentity;
    //间隔
    CGFloat vatocalOfset = replicatorLayer.bounds.size.height + 2;
    transform = CATransform3DTranslate(transform, 0, vatocalOfset, 0);
//    transform = CATransform3DScale(transform, -1, -1, 0);
    transform = CATransform3DRotate(transform, M_PI, 1, 0, 0);

    replicatorLayer.instanceTransform = transform;

    // k - 0.7 = 0.3;
    replicatorLayer.instanceAlphaOffset = -0.7;
    
    [self addMusicAnimation];
    
    [self addDotLoading];
}

- (void)addMusicAnimation {
    CAReplicatorLayer *layer = [CAReplicatorLayer layer];
    CGFloat height = 200;
    layer.frame = CGRectMake(0, 0, height, height);
    layer.backgroundColor = UIColor.brownColor.CGColor;
    [self.layer addSublayer:layer];
    
    // 创建音量条
    CALayer *volumeLayer = [CALayer layer];
    volumeLayer.backgroundColor = UIColor.redColor.CGColor;
    CGFloat volumnWidth = 30;
    volumeLayer.bounds = CGRectMake(0, 0, volumnWidth, 100);
    volumeLayer.anchorPoint = CGPointMake(0, 1);
    volumeLayer.position = CGPointMake(0, height);
    [layer addSublayer:volumeLayer];
    
    // 对音量条添加动画
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale.y"];
    animation.toValue = @0;
    animation.duration = 0.75;
    animation.repeatCount = MAXFLOAT;
    animation.autoreverses = YES;
    [volumeLayer addAnimation:animation forKey:nil];
    
    // 设置音量条的个数
    layer.instanceCount = 5;
    // 设置延时
    layer.instanceDelay = 0.35;
    // 设置透明度递减
    layer.instanceAlphaOffset = - 0.15;
    // 对每个音量条移动距离
    layer.instanceTransform = CATransform3DMakeTranslation(volumnWidth + 10, 0, 0);
}

- (void)addDotLoading {
    CAReplicatorLayer *layer = [CAReplicatorLayer layer];
    layer.frame = CGRectMake(210, 200, 100, 100);
    layer.backgroundColor = UIColor.brownColor.CGColor;
    [self.layer addSublayer:layer];
    
    // 创建小圆点
    CALayer *dotLayer = [CALayer layer];
    dotLayer.bounds = CGRectMake(0, 0, 10, 10);
    dotLayer.position = CGPointMake(50, 20);
    dotLayer.backgroundColor = UIColor.yellowColor.CGColor;
    dotLayer.cornerRadius = 5;
//    dotLayer.masksToBounds = YES;
    [layer addSublayer:dotLayer];
    
    // 添加缩放动画
    CFTimeInterval duration = 1;
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    animation.duration = 1;
    animation.fromValue = @1;
    animation.toValue = @0.1;
    animation.repeatCount = MAXFLOAT;
    [dotLayer addAnimation:animation forKey:nil];
    
    // 设置音量条的个数
    int count = 12;
    layer.instanceCount = count;
    // 设置延时
    layer.instanceDelay = (CFTimeInterval)(duration / (CGFloat)count);
    // 对每个音量条移动距离
    layer.instanceTransform = CATransform3DMakeRotation(M_PI * 2 / (CGFloat)count, 0, 0, 1);
    
    dotLayer.transform = CATransform3DMakeScale(0.01, 0.01, 0.01);
}

@end
