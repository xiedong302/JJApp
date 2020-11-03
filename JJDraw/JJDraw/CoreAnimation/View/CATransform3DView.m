//
//  CATransform3DView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/27.
//

#import "CATransform3DView.h"

@interface CATransform3DView()

@property (nonatomic, strong) UIImageView *layerView;


@end
@implementation CATransform3DView

- (UIImageView *)defaultImageView {
    UIImageView *imageView = [UIImageView new];
    imageView.image = JJTImage(@"Draw/timg");
    
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
        make.width.height.offset(50);
    }];
    
}



- (void)startAnimation {
    // 沿着z轴旋转
    CATransform3D tranform = CATransform3DMakeRotation(M_PI_4, 0, 0, 1);
    self.layerView.layer.transform = tranform;
    
    CATransform3D transform  = CATransform3DIdentity;
    transform.m34 = -1.0f/500.0;
    transform = CATransform3DRotate(transform, M_PI, 0, 1, 0);
    self.layerView.layer.transform = transform;
    self.layerView.layer.doubleSided = YES; //if no ,the view hidden
    
    
}

@end
