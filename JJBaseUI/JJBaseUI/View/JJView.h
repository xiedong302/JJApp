//
//  JJView.h
//  JJBaseUI
//
//  Created by xiedong on 2020/9/25.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 项目的基础View
 */
@interface JJView : UIView

/**
 初始化控件
 */
- (void)setupView;

/**
 约束布局
 */
- (void)setupConstraints;

/**
 生命周期
 */
- (void)viewWillAppear;

- (void)viewDidAppear;

- (void)viewWillDisappear;

- (void)viewDidDisappear;

@end

NS_ASSUME_NONNULL_END
