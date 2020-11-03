//
//  JJMainLaunchADView.m
//  JJAppMain
//
//  Created by xiedong on 2020/10/23.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJMainLaunchADView.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

@implementation JJMainLaunchADView

- (instancetype)init {
    self = [super init];
    if (self) {
        UIButton *button = [[UIButton alloc] init];
        [button setTitle:@"开启" forState:UIControlStateNormal];
        [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
        button.layer.borderColor = UIColor.yellowColor.CGColor;
        button.layer.borderWidth = 1;
        [button addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.offset(0);
            make.width.height.offset(200);
        }];
    }
    return self;
}
- (void)clickBtn {
    if (_delegate && [_delegate respondsToSelector:@selector(launchADView:openURL:)]) {
        [_delegate launchADView:self openURL:nil];
    }
}

@end

#pragma clang diagnostic pop
