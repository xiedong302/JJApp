//
//  CAEmitterLayerView1.m
//  JJDraw
//
//  Created by xiedong on 2020/10/28.
//

#import "CAEmitterLayerView1.h"

@interface CAEmitterLayerView1()

@property (nonatomic, strong) CAEmitterLayer *rainLayer;

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIButton *startBtn;

@property (nonatomic, strong) UIButton *bigBtn;

@property (nonatomic, strong) UIButton *smallBtn;

@end

@implementation CAEmitterLayerView1

- (UIButton *)defaultBtn {
    UIButton *btn = [[UIButton alloc] init];
    [btn setBackgroundColor:UIColor.whiteColor];
    [btn setTitleColor:UIColor.grayColor forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}


- (void)setupView {
    self.imageView = [UIImageView new];
    self.imageView.image = JJTImage(@"Draw/rain");
    [self addSubview:self.imageView];
    
    self.startBtn = [self defaultBtn];
    [self.startBtn setTitle:@"雨停了" forState:UIControlStateNormal];
    [self.startBtn setTitle:@"下雨" forState:UIControlStateSelected];
    [self.startBtn setTitleColor:UIColor.redColor forState:UIControlStateSelected];
    [self addSubview:self.startBtn];
    
    self.bigBtn = [self defaultBtn];
    [self.bigBtn setTitle:@"下大点" forState:UIControlStateNormal];
    [self addSubview:self.bigBtn];
    
    self.smallBtn = [self defaultBtn];
    [self.smallBtn setTitle:@"太大了" forState:UIControlStateNormal];
    [self addSubview:self.smallBtn];
}

- (void)setupConstraints {
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    [self.startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.bottom.offset(-10);
        make.height.offset(40);
    }];
    
    [self.bigBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.startBtn.mas_right).offset(10);
        make.bottom.offset(-10);
        make.height.offset(40);
        make.width.equalTo(self.startBtn);
    }];
    
    [self.smallBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bigBtn.mas_right).offset(10);
        make.bottom.offset(-10);
        make.height.offset(40);
        make.width.equalTo(self.startBtn);
        make.right.offset(-10);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.bottom.offset(0);
    }];
    
    if (!self.rainLayer) {
        [self setupRainLayer];
    }
}


- (void)clickBtn:(UIButton *)sender {
    if (sender == self.startBtn) {
     
        [self.rainLayer setValue:sender.selected ? @1.f : @0.f  forKeyPath:@"birthRate"];
        sender.selected = !sender.selected;
        
        return;
    }
    
    NSInteger rate = 1;
    CGFloat scale = 0.05;
    
    if (sender == self.bigBtn) {
        if (self.rainLayer.birthRate < 30) {
            [self.rainLayer setValue:@(self.rainLayer.birthRate + rate) forKeyPath:@"birthRate"];
            [self.rainLayer setValue:@(self.rainLayer.scale + scale) forKeyPath:@"scale"];
        }
    }
    if (sender == self.smallBtn) {
        if (self.rainLayer.birthRate > 1) {
            [self.rainLayer setValue:@(self.rainLayer.birthRate - rate) forKeyPath:@"birthRate"];
            [self.rainLayer setValue:@(self.rainLayer.scale - scale) forKeyPath:@"scale"];
        }
    }
}

- (void)setupRainLayer {
    // 1.设置layer
    CAEmitterLayer *rainLayer = [CAEmitterLayer layer];
    [self.imageView.layer addSublayer:rainLayer];
    self.rainLayer = rainLayer;
    
    // 发射大小 发射形状 发射模式 发射位置(y最好不要设置为0 最好<0)
    rainLayer.emitterSize = self.frame.size;
    rainLayer.emitterShape = kCAEmitterLayerLine;
    rainLayer.emitterMode = kCAEmitterLayerSurface;
    rainLayer.emitterPosition = CGPointMake(self.frame.size.width * 0.5, -10);
    
    // 2.配置cell
    CAEmitterCell *cell = [CAEmitterCell emitterCell];
    // 粒子内容
    cell.contents = (__bridge id)JJRImage(@"Draw/rain_white").CGImage;
    // 每秒产生的例子数量的系数
    cell.birthRate = 25.f;
    // 粒子的生命周期
    cell.lifetime = 20.f;
    // speed粒子速度，图层的速率。用于将父时间缩放为本地时间，例如，如果速率是2，则本地时间的进度是父时间的两倍。默认值为1
    cell.speed = 10.f;
    // 粒子速度系数 默认1.0
    cell.velocity = 10.f;
    // 每个发射物的初始平均范围，默认等于0
    cell.velocityRange = 10.f;
    // 粒子在y方向的加速度
    cell.yAcceleration = 1000.f;
    // 粒子缩放比例
    cell.scale = 0.1f;
    // 粒子缩放比例范围
    cell.scaleRange = 0.f;
    
    // 添加
    rainLayer.emitterCells = @[cell];
    
}
@end
