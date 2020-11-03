//
//  CATransform3DView2.m
//  JJDraw
//
//  Created by xiedong on 2020/10/28.
//

#import "CATransform3DView2.h"

@interface CATransform3DView2 ()

@property (nonatomic, strong) UIView *containterView;

@property (nonatomic, strong) NSArray *faces;

@end
@implementation CATransform3DView2

- (void)setupView {
    
    self.containterView = [UIView new];
    [self addSubview:self.containterView];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:6];
    for (int i  = 0; i < 6; i++) {
        UIView *view = [self randomColorViewWithIndex:i];
        [array addObject:view];
        [self.containterView addSubview:view];
    }
    self.faces = array.copy;
}

- (void)setupConstraints {
    [self.containterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.width.height.offset(300);
    }];
    
    for (UIView *view in self.faces) {
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.offset(0);
            make.width.height.offset(200);
        }];
    }
}

- (UIView *)randomColorViewWithIndex:(int)index {
    
    UIView *view = [UIView new];
    CGFloat a = arc4random() % 255 / 255.0;
    CGFloat g = arc4random() % 255 / 255.0;
    CGFloat b = arc4random() % 255 / 255.0;
    UIColor *randromColor = [UIColor colorWithRed:a green:g blue:b alpha:1];
    view.backgroundColor = randromColor;
    
    UILabel *label = [[UILabel alloc] init];
    label.textColor = UIColor.blackColor;
    label.font = [UIFont boldSystemFontOfSize:30];
    label.text = [NSString stringWithFormat:@"%d",index];
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
    
    return view;
}

- (void)startAnimation {
    //super layer
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = -1.0/500.0;
    perspective = CATransform3DRotate(perspective, -M_PI_4, 1, 0, 0);
    perspective = CATransform3DRotate(perspective, -M_PI_4, 0, 1, 0);
    self.containterView.layer.sublayerTransform = perspective;
    
    // add 1  最里面
    CATransform3D transform = CATransform3DMakeTranslation(0, 0, 100);
    [self addSubLayerTransform:transform index:0];
    
    // add 2  最右面
    transform = CATransform3DMakeTranslation(100, 0, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
    [self addSubLayerTransform:transform index:1];
    
    // add 3  最下面
    transform = CATransform3DMakeTranslation(0, -100, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 1, 0, 0);
    [self addSubLayerTransform:transform index:2];
    
    // add 4  最上面
    transform = CATransform3DMakeTranslation(0, 100, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 1, 0, 0);
    [self addSubLayerTransform:transform index:3];
    
    // add 5 最左面
    transform = CATransform3DMakeTranslation(-100, 0, 0);
    transform = CATransform3DRotate(transform, M_PI_2, 0, 1, 0);
    [self addSubLayerTransform:transform index:4];
    
    // add 6 最外面
    transform = CATransform3DMakeTranslation(0, 0, -100);
    [self addSubLayerTransform:transform index:5];

}

- (void)addSubLayerTransform:(CATransform3D)transform index:(int)index{
    if (index >= 0 && index < self.faces.count) {
        UIView *view = self.faces[index];
        view.layer.transform = transform;
    }
}
@end
