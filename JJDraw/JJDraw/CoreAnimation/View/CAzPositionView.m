//
//  CAzPositionView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/27.
//

#import "CAzPositionView.h"

@interface CAzPositionView()

@property (nonatomic, strong) UIView *view1;

@property (nonatomic, strong) UIView *view2;

@end

@implementation CAzPositionView

- (void)setupView {
    //除了UIImageView 能够显示图片，layer也可以加载图片
    UIImage *image = JJTImage(@"Draw/timg");
    self.view1 = [[UIView alloc] init];
    self.view1.layer.contents = (__bridge id)image.CGImage;
    self.view1.contentMode = UIViewContentModeScaleAspectFit;
    self.view1.layer.contentsGravity = kCAGravityResizeAspect;
    
    [self addSubview:self.view1];
    
    self.view2 = [[UIView alloc] init];
    self.view2.backgroundColor = UIColor.redColor;
    [self addSubview:self.view2];
    
}

- (void)setupConstraints {
    [self.view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.offset(0);
        make.right.offset(-10);
        make.height.offset(100);
    }];
    
    [self.view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.offset(10);
        make.right.offset(0);
        make.top.equalTo(self.view1.mas_top).offset(20);
        make.height.offset(100);
    }];
}

- (void)startAnimation {
    //将 这个视图置于 其他重叠视图的最前面
    self.view1.layer.zPosition = 1.0;
}

@end
