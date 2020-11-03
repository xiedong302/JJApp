//
//  CADynamicAnimatorView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/29.
//

#import "CADynamicAnimatorView.h"

/**
 * 使用2D物理引擎分两个步骤
 * 1. 添加行为（绑定view）
 * 2. 把行为添加在容器中（绑定view的父view）
 */
@interface CADynamicAnimatorView()

@property (nonatomic, strong) UIDynamicAnimator *animator1;
@property (nonatomic, strong) UIDynamicAnimator *animator2;
@property (nonatomic, strong) UIAttachmentBehavior *attachmentBehavier;

@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UIImageView *imageView2;
@property (nonatomic, strong) UIImageView *imageView3;

@end

@implementation CADynamicAnimatorView

- (UIImageView *)defaultImageView:(NSString *)imageName {
    UIImageView *imageView = [UIImageView new];
    imageView.image = JJTImage(imageName);
    imageView.userInteractionEnabled = YES;
    imageView.layer.cornerRadius = 25;
    imageView.layer.masksToBounds = YES;
    return imageView;
}

- (void)setupView {
    self.imageView1 = [self defaultImageView:@"Draw/ball1"];
    self.imageView1.frame = CGRectMake(20, 100, 50, 50);
    [self addSubview:self.imageView1];
    
    self.imageView2 = [self defaultImageView:@"Draw/ball2"];
    self.imageView2.frame = CGRectMake(300, 100, 50, 50);
    [self addSubview:self.imageView2];
    
    self.imageView3 = [self defaultImageView:@"Draw/ball3"];
    self.imageView3.frame = CGRectMake(100, 300, 50, 50);
    [self addSubview:self.imageView3];
    
    // 物理引擎
    [self animator1];
    _animator2 = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    
    // 创建自由落体行为-重力
    UIGravityBehavior *gravity = [[UIGravityBehavior alloc] initWithItems:@[self.imageView1,self.imageView2,self.imageView3]];
    // 重力行为有一个属性是重力加速度，设置值越大速度增长越快，默认是1
    gravity.magnitude = 2;
    // 添加到容器
    [_animator1 addBehavior:gravity];
    
    // 碰撞行为
    UICollisionBehavior *collision = [[UICollisionBehavior alloc] initWithItems:@[self.imageView1,self.imageView2,self.imageView3]];
    // 设置边缘 (父view的bounds)
    collision.translatesReferenceBoundsIntoBoundary = YES;
    
    // 利用贝塞尔曲线限制边界
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 300, 300)];
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = UIColor.redColor.CGColor;
    shapeLayer.fillColor = nil;
    shapeLayer.lineWidth = 5;
    [self.layer addSublayer:shapeLayer];
    
    [collision addBoundaryWithIdentifier:@"circle" forPath:path];
    [_animator1 addBehavior:collision];
    
    // 模拟捕捉行为
    // 捕捉行为需要在创建时就给与一个点
    // 捕捉行为有一个防震系数属性，设置的越大，振幅就越小
    CGPoint point = CGPointMake(10, 400);
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.imageView2 snapToPoint:point];
    snap.damping = 1;
    [_animator1 addBehavior:snap];
    
    // 其他行为的拓展
    UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.imageView2]];
    /**
     * elasticity 弹性系数
     * friction 摩擦系数
     * density 密度
     * resistance 抵抗力
     * angularResistance 角度阻力
     * charge 冲击
     * anchored 锚定
     * allowsRotation 允许旋转
     */
    itemBehavior.elasticity = .6;
    [_animator1 addBehavior:itemBehavior];
    
    // 添加手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAuction:)];
    [self.imageView1 addGestureRecognizer:pan];
}

- (void)setupConstraints {
    
    
}

- (UIDynamicAnimator *)animator1 {
    if (!_animator1) {
        /**
         * 创建一个物理仿真器
         * 容器（里面放一些行为）
         * ReferenceView:关联的view
         */
        _animator1 = [[UIDynamicAnimator alloc] initWithReferenceView:self];
    }
    return _animator1;
}

- (void)panAuction:(UIPanGestureRecognizer *)ges {
    if (ges.state == UIGestureRecognizerStateBegan) {
        
        UIOffset offset = UIOffsetMake(-10, -10);
        
        /**
         * offsetFromCenter 偏离中心幅度
         * attachedToAnchor 附加到锚点 手势点击的位置
         */
        // UIAttachmentBehavior 附着行为
        _attachmentBehavier = [[UIAttachmentBehavior alloc] initWithItem:self.imageView1 offsetFromCenter:offset attachedToAnchor:[ges locationInView:self]];
        
        [_animator1 addBehavior:_attachmentBehavier];
        
    } else if (ges.state == UIGestureRecognizerStateChanged) {
        
        // 设置锚点
        [_attachmentBehavier setAnchorPoint:[ges locationInView:self]];
        
    } else if (ges.state == UIGestureRecognizerStateEnded ||
               ges.state == UIGestureRecognizerStateFailed ||
               ges.state == UIGestureRecognizerStateCancelled) {
        
        // 移除
        [_animator1 removeBehavior:_attachmentBehavier];
        
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self moveImageView3:touches];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self moveImageView3:touches];
}

- (void)moveImageView3:(NSSet<UITouch *> *)touches {
    // 获取手指对应的触摸对象
    UITouch *touch = [touches anyObject];
    
    // 获取触摸点
    CGPoint point = [touch locationInView:self];
    
    // 创建捕捉行为
    UISnapBehavior *snap = [[UISnapBehavior alloc] initWithItem:self.imageView3 snapToPoint:point];
    snap.damping = 1;
    
    // 清空之前的并再次开始
    [_animator2 removeAllBehaviors];
    [_animator2 addBehavior:snap];
}

@end
