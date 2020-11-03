//
//  CATransitionView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/29.
//

#import "CATransitionView.h"

#pragma clang diagnostic push

#pragma clang diagnostic ignored "-Wdeprecated-declarations"

typedef NS_ENUM(NSInteger, AnimationType) {
    Fade = 1,                   //淡入淡出
    Push,                       //推挤
    Reveal,                     //揭开
    MoveIn,                     //覆盖
    Cube,                       //立方体
    SuckEffect,                 //吮吸
    OglFlip,                    //翻转
    RippleEffect,               //波纹
    PageCurl,                   //翻页
    PageUnCurl,                 //反翻页
    CameraIrisHollowOpen,       //开镜头
    CameraIrisHollowClose,      //关镜头
    CurlDown,                   //下翻页
    CurlUp,                     //上翻页
    FlipFromLeft,               //左翻转
    FlipFromRight,              //右翻转
};

@interface CATransitionView()

// 子类型
@property (nonatomic, assign) int subType;

@property (nonatomic, strong) NSDictionary *dict;

@property (nonatomic, strong) NSArray *btns;

@end
@implementation CATransitionView

- (void)setupView {
    _subType = 0;
    
    self.backgroundColor = UIColor.redColor;
    [self addBackgroundImage:@"Draw/timg"];
    
    NSArray *array = @[@(Fade),
                       @(Push),
                       @(Reveal),
                       @(MoveIn),
                       @(Cube),
                       @(SuckEffect),
                       @(OglFlip),
                       @(RippleEffect),
                       @(PageCurl),
                       @(PageUnCurl),
                       @(CameraIrisHollowOpen),
                       @(CameraIrisHollowClose),
                       @(CurlDown),
                       @(CurlUp),
                       @(FlipFromLeft),
                       @(FlipFromRight)];
    
    NSMutableArray *btns = [NSMutableArray arrayWithCapacity:self.dict.count];
    for (NSNumber *number in array) {
        UIButton *button = [UIButton new];
        [button setTitle:self.dict[number] forState:UIControlStateNormal];
        [button setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [button setBackgroundColor:UIColor.brownColor];
        button.tag = number.integerValue;
        [button addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        [btns addObject:button];
    }
    
    self.btns = [btns copy];

}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.offset(0);
    }];
    
    [self updateBtnsConstraints];
}

- (void)updateBtnsConstraints {
    
    UIButton *lastBtn = nil;
    NSInteger left = 10;
    for (UIButton *btn in self.btns) {
        
        if (lastBtn) {
            NSInteger index = [self.btns indexOfObject:lastBtn];
            if (index == self.btns.count / 2 - 1) {
                lastBtn = nil;
                left = 180;
            }
        }
        
        if (lastBtn) {
            [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(lastBtn.mas_bottom).offset(10);
                make.left.offset(left);
                make.width.offset(150);
                make.height.offset(40);
            }];
        } else {
            [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.offset(10);
                make.left.offset(left);
                make.width.offset(150);
                make.height.offset(40);
            }];
        }
        
        
        lastBtn = btn;
    }
}

- (void)clickBtn:(UIButton *)sender {
    
    // 定义subType类型
    NSString *subTypeString;
    switch (_subType) {
        case 0:
            subTypeString = kCATransitionFromLeft;
            break;
        case 1:
            subTypeString = kCATransitionFromBottom;
            break;
        case 2:
            subTypeString = kCATransitionFromRight;
            break;
        case 3:
            subTypeString = kCATransitionFromTop;
            break;
        default:
            break;
    }
    
    ++_subType;
    if (_subType > 3) {
        _subType = 0;
    }
    
    // 定义animatioType
    AnimationType animationType = sender.tag;
    switch (animationType) {
        case Fade:
            [self addTransitionWithType:kCATransitionFade subType:subTypeString];
            break;
        case Push:
            [self addTransitionWithType:kCATransitionPush subType:subTypeString];
            break;
        case Reveal:
            [self addTransitionWithType:kCATransitionReveal subType:subTypeString];
            break;
        case MoveIn:
            [self addTransitionWithType:kCATransitionMoveIn subType:subTypeString];
            break;
        case Cube:
            [self addTransitionWithType:@"cube" subType:subTypeString];
            break;
        case SuckEffect:
            [self addTransitionWithType:@"suckEffect" subType:subTypeString];
            break;
        case OglFlip:
            [self addTransitionWithType:@"oglFlip" subType:subTypeString];
            break;
        case RippleEffect:
            [self addTransitionWithType:@"rippleEffect" subType:subTypeString];
            break;
        case PageCurl:
            [self addTransitionWithType:@"pageCurl" subType:subTypeString];
            break;
        case PageUnCurl:
            [self addTransitionWithType:@"pageUnCurl" subType:subTypeString];
            break;
        case CameraIrisHollowOpen:
            [self addTransitionWithType:@"cameraIrisHollowOpen" subType:subTypeString];
            break;
        case CameraIrisHollowClose:
            [self addTransitionWithType:@"cameraIrisHollowClose" subType:subTypeString];
            break;
        case CurlDown:
            [self addAnimationTransition:(UIViewAnimationTransitionCurlDown)];
            break;
        case CurlUp:
            [self addAnimationTransition:(UIViewAnimationTransitionCurlUp)];
            break;
        case FlipFromLeft:
            [self addAnimationTransition:(UIViewAnimationTransitionFlipFromLeft)];
            break;
        case FlipFromRight:
            [self addAnimationTransition:(UIViewAnimationTransitionFlipFromRight)];
            break;
        default:
            break;
    }
    
    
    static int i = 0;
    if (i == 0) {
        [self addBackgroundImage:@"Draw/pig"];
        i = 1;
    } else {
        i = 0;
        [self addBackgroundImage:@"Draw/timg"];
    }
}

//MARK: - CATransition 动画实现
- (void)addTransitionWithType:(NSString *)type subType:(NSString *)subType {
    // 创建CATransition对象
    CATransition *animation = [[CATransition alloc] init];
    
    // 设置运动的时间
    animation.duration = 1.0;
    // 设置运动类型
    animation.type = type;
    if (subType.length > 0) {
        animation.subtype = subType;
    }
    // 给view增加动画
    [self.layer addAnimation:animation forKey:@"animation"];
}
//MARK: - 给view添加动画
- (void)addAnimationTransition:(UIViewAnimationTransition)transition {
    [UIView animateWithDuration:1.0 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
        [UIView setAnimationTransition:transition forView:self cache:YES];
    }];
}

//MARK: - 给view添加背景图
- (void)addBackgroundImage:(NSString *)imageName {
    self.layer.contents = (__bridge id)JJTImage(imageName).CGImage;
    self.contentMode = UIViewContentModeScaleAspectFit;
    self.layer.contentsGravity = kCAGravityResizeAspect;
}

//MARK: - Getter
- (NSDictionary *)dict {
    if (!_dict) {
        _dict = @{
            @(Fade):@"淡化效果",
            @(Push):@"push效果",
            @(Reveal):@"揭开效果",
            @(MoveIn):@"覆盖效果",
            @(Cube):@"3D立方体效果",
            @(SuckEffect):@"吮吸效果",
            @(OglFlip):@"翻转效果",
            @(RippleEffect):@"波纹效果",
            @(PageCurl):@"翻页效果",
            @(PageUnCurl):@"反翻页效果",
            @(CameraIrisHollowOpen):@"开镜头效果",
            @(CameraIrisHollowClose):@"关镜头效果",
            @(CurlDown):@"下翻页效果",
            @(CurlUp):@"上翻页效果",
            @(FlipFromLeft):@"左翻页效果",
            @(FlipFromRight):@"右翻页效果",
        };
    }
    return _dict;
}


@end

#pragma clang diagnostic pop
