//
//  CATransform3DView1.m
//  JJDraw
//
//  Created by xiedong on 2020/10/28.
//

#import "CATransform3DView1.h"

@interface CATransform3DView1 ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UIImageView *layerView1;
@property (nonatomic, strong) UIImageView *layerView2;

@end

@implementation CATransform3DView1

- (UIImageView *)defaultImageView {
    UIImageView *imageView = [UIImageView new];
    imageView.image = JJTImage(@"Draw/timg");
    
    return imageView;
}

- (void)setupView {
    
    self.layerView1 = [self defaultImageView];
    self.layerView2 = [self defaultImageView];
    self.containerView = [UIView new];
    self.containerView.backgroundColor = UIColor.blueColor;
    [self addSubview:self.containerView];
    [self.containerView addSubview:self.layerView1];
    [self.containerView addSubview:self.layerView2];
    
}

- (void)setupConstraints {
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.offset(-10);
        make.left.offset(10);
        make.right.offset(-10);
        make.height.equalTo(self.containerView.mas_height);
    }];
    
    [self.layerView1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.offset(10);
        make.bottom.offset(-10);
        make.left.offset(10);
    }];
    
    [self.layerView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.layerView1.mas_right).offset(20);
        make.top.offset(10);
        make.bottom.offset(-10);
        make.right.offset(-10);
        make.width.equalTo(self.layerView1);
    }];
}

- (void)startAnimation {
    CATransform3D prespective = CATransform3DIdentity;
    prespective.m34 = -1.0f/500.0;
    self.containerView.layer.sublayerTransform = prespective; // for subLayer
    
    CATransform3D transform1 = CATransform3DMakeRotation(M_PI_4, 0, 1, 0);
    CATransform3D transform2 = CATransform3DMakeRotation(-M_PI_4, 0, 1, 0);
    self.layerView1.layer.transform = transform1;
    self.layerView2.layer.transform = transform2;
}
@end
