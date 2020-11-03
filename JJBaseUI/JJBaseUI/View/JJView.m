//
//  JJView.m
//  JJBaseUI
//
//  Created by xiedong on 2020/9/25.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJView.h"

@implementation JJView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupView];
        [self setupConstraints];
    }
    return self;
}

- (void)setupView {}

- (void)setupConstraints {}

- (void)viewWillAppear {}

- (void)viewDidAppear {}

- (void)viewWillDisappear {}

- (void)viewDidDisappear {}

@end
