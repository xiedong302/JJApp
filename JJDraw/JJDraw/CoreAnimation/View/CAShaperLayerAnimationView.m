//
//  CAShaperLayerAnimationView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/29.
//

#import "CAShaperLayerAnimationView.h"

/**
 * 动画拆分
 * 1. 2个圆（一个固定圆，一个拖拽圆）
 * 2. 贝塞尔曲线，求得关键点
 * 3. 固定圆比例缩小
 * 4. 拖拽到一定距离的时候需要断开
 * 5. 断开之后有个圆的反弹效果
 */
@interface CAShaperLayerAnimationView()

// 圆
@property (nonatomic, strong) UIView *view1;
@property (nonatomic, strong) UIView *view2;

// shapeLayer图层
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

// 坐标记录
@property (nonatomic, assign) CGPoint oldViewCenter;
@property (nonatomic, assign) CGRect oldViewFrame;
@property (nonatomic, assign) CGFloat r1;

@end

@implementation CAShaperLayerAnimationView

- (void)setupView {
    self.view1 = [UIView new];
    self.view1.backgroundColor = UIColor.brownColor;
    self.view1.layer.cornerRadius = 20;
    [self addSubview:self.view1];
    
    self.view2 = [UIView new];
    self.view2.backgroundColor = UIColor.brownColor;
    self.view2.layer.cornerRadius = 20;
    self.view2.userInteractionEnabled = YES;
    [self addSubview:self.view2];
    
    UILabel *label = [UILabel new];
    label.text = @"+99";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = UIColor.whiteColor;
    [self.view2 addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    // 添加手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAuction:)];
    [self.view2 addGestureRecognizer:pan];
    
    // 初始化
    self.shapeLayer = [CAShapeLayer layer];
    
}

- (void)setupConstraints {
    
    [self.view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.width.height.offset(40);
    }];
    
    [self.view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view1);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (_r1 <= 0) {
        _oldViewFrame = self.view1.frame;
        _oldViewCenter = self.view1.center;
        _r1 = CGRectGetWidth(self.view1.frame) / 2;
    }
    
    
}

- (void)panAuction:(UIPanGestureRecognizer *)ges {
    if (ges.state == UIGestureRecognizerStateChanged) {
        
        // 1. view2跟着手指一起移动
        _view2.center = [ges locationInView:self];
        
        // 当拖拽到一定距离之后，则移出来
        // 那么就是r1半径缩减到一定距离
        // 在caculPoint 方法中，更新r1值
        // 在拖拽if中判断，如果低于9
        if (_r1 < 9) {
            _view1.hidden = YES;
            [_shapeLayer removeFromSuperlayer];
        }
        
        // 2 计算6个关键点，并画出贝塞尔曲线
        [self caculPoint];
        
    } else if (ges.state == UIGestureRecognizerStateEnded ||
               ges.state == UIGestureRecognizerStateCancelled ||
               ges.state == UIGestureRecognizerStateFailed) {
        // 思考 回弹时 那些属性/组件要做调整
        // view2 位置恢复 shapeLayer消失
        //
        [_shapeLayer removeFromSuperlayer];
        
        // 加上弹跳效果动画
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
            self.view2.center = self.oldViewCenter;
        } completion:^(BOOL finished) {
            self.view1.hidden = NO;
            self.view1.frame = self.oldViewFrame;
            self.r1 = self.oldViewFrame.size.width / 2;
            self.view1.layer.cornerRadius = self.r1;
        }];
    }
}

- (void)caculPoint {
    
    // 1. 初始化一直顶点
    CGPoint center1 = _view1.center;
    CGPoint center2 = _view2.center;
    
    // 2. 计算出斜边d的长度（根据勾股定理）
    // d= √((x2-x1)•(x2-x1) + (y1-y2)•(y1-y2));
    CGFloat dis = sqrtf(pow((center2.x - center1.x), 2) + pow((center1.y - center2.y), 2));
    
    // 3 计算sin cos
    CGFloat sinValue = (center2.x - center1.x)/dis;
    CGFloat cosValue = (center1.y - center2.y)/dis;
    
    // 4 半径
    CGFloat r1 = CGRectGetWidth(_oldViewFrame) / 2 - dis / 20;
    CGFloat r2 = CGRectGetWidth(_view2.bounds) / 2;
     
    // 更新r1的值
    _r1 = r1;
    
    // 5. 计算6个关键点
    CGPoint pA = CGPointMake(center1.x - r1 * cosValue, center1.y - r1 * sinValue);
    CGPoint pB = CGPointMake(center1.x + r1 * cosValue, center1.y + r1 * sinValue);
    CGPoint pC = CGPointMake(center2.x + r2 * cosValue, center2.y + r2 * sinValue);
    CGPoint pD = CGPointMake(center2.x - r2 * cosValue, center2.y - r2 * sinValue);
    
    CGPoint pO = CGPointMake(pA.x + dis/2*sinValue, pA.y - dis/2*cosValue);
    CGPoint pP = CGPointMake(pB.x + dis/2*sinValue, pB.y - dis/2*cosValue);
    
    // 6 绘制贝塞尔曲线
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:pA];
    [path addQuadCurveToPoint:pD controlPoint:pO];
    [path addLineToPoint:pC];
    [path addQuadCurveToPoint:pB controlPoint:pP];
    [path closePath];
    
    if (_view1.hidden) {
        return;
    }
    
    _shapeLayer.path = path.CGPath;
    _shapeLayer.fillColor = UIColor.brownColor.CGColor;
    [self.layer insertSublayer:_shapeLayer below:_view2.layer];
    
    // 重新计算view1的位置
    _view1.center = _oldViewCenter;
    _view1.bounds = CGRectMake(0, 0, r1 * 2, r1 * 2);
    _view1.layer.cornerRadius = r1;
    
}


@end
