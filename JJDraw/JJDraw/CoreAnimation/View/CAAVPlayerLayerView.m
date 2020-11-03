//
//  CAAVPlayerLayerView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/29.
//

#import "CAAVPlayerLayerView.h"
#import <AVFoundation/AVFoundation.h>

@interface CAAVPlayerLayerView()

@property (nonatomic, strong) AVPlayer *player;

@end

@implementation CAAVPlayerLayerView

- (void)setupView {
    
    
    self.tintColor = UIColor.redColor;
    
    NSString *filePath = JJRFilePath(@"cyborg.m4v");
    // 创建player对象
    self.player = [AVPlayer playerWithURL:[NSURL fileURLWithPath:filePath]];
    // 播放
    [self.player play];
    
    // 创建和配置AVPlayerLayer
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    playerLayer.bounds = CGRectMake(0, 0, 300, 170);
    playerLayer.position = CGPointMake(200, 100); //中心点就是这个位置 很重要
    playerLayer.borderColor = UIColor.blueColor.CGColor;
    playerLayer.borderWidth = 1.0;
    playerLayer.shadowOffset = CGSizeMake(0, 3);
    playerLayer.shadowOpacity = 0.80;
    
    // 添加透视投影
    self.layer.sublayerTransform = CATransform3DMakePerspective(1000);
    [self.layer addSublayer:playerLayer];
    
    // add slider for test
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(60, 200, 200, 20)];
    slider.minimumValue = -1.0;
    slider.maximumValue = 1.0;
    slider.continuous = NO;
    slider.value = 0;
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventTouchDragInside];
    [self addSubview:slider];
    
    UIButton *spinBtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 250, 50, 50)];
    [spinBtn setBackgroundColor:UIColor.brownColor];
    [spinBtn setTitle:@"spin" forState:UIControlStateNormal];
    [spinBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [spinBtn addTarget:self action:@selector(spinClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:spinBtn];
    
}

- (void)sliderValueChanged:(UISlider *)sender {
    CALayer *layer = self.layer.sublayers[0];
    layer.transform = CATransform3DMakeRotation(sender.value, 0, 1, 0);
}

- (void)spinClick {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.x"];
    animation.duration = 1.25f;
    animation.toValue = @(jj_angleToRadians(360));
    
    CALayer *layer = self.layer.sublayers[0];
    [layer addAnimation:animation forKey:nil];
}

- (void)stopAnimation {
    [self.player pause];
}

// 透视投影修改m34的值
static CATransform3D CATransform3DMakePerspective(CGFloat z) {
    CATransform3D t = CATransform3DIdentity;
    t.m34 = - 1.0 / z;
    return t;
}
@end
