//
//  JJViewController.h
//  JJBaseUI
//
//  Created by xiedong on 2020/9/25.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 项目的基础VC
 */
@interface JJViewController : UIViewController

@property (nonatomic, assign, readonly) UIEdgeInsets jj_safeAreaInset; //frame布局使用

@property (nonatomic, strong, readonly) id jj_safeAreaLayoutGuideLeft; //autoLayout布局使用
@property (nonatomic, strong, readonly) id jj_safeAreaLayoutGuideTop; //autoLayout布局使用
@property (nonatomic, strong, readonly) id jj_safeAreaLayoutGuideRight; //autoLayout布局使用
@property (nonatomic, strong, readonly) id jj_safeAreaLayoutGuideBottom; //autoLayout布局使用

@property (nonatomic, strong, readonly) UIColor *jj_navigationBarColor; //navigationBar颜色 覆盖getter自定义
@property (nonatomic, strong, readonly) UIImage *jj_navigationBarBackImage; //navigationBar返回按钮图片 覆盖getter自定义
@property (nonatomic, strong, readonly) UIImage *jj_navigationBarBackgroundImage; //navigationBar背景图片 覆盖getter自定义
@property (nonatomic, strong, readonly) UIColor *jj_navigationBarTitleColor; //navigationBar标题颜色 覆盖getter自定义
@property (nonatomic, strong, readonly) UIFont *jj_navigationBarTitleFont; //navigationBar标题字体 覆盖getter自定义

@property (nonatomic, assign) BOOL jj_hidesNavigationBarWhenPush; //是否隐藏navigationBar 默认NO

@property (nonatomic, assign, readonly) BOOL jj_isNetworkAvailable; //是否网络可用

@property (nonatomic, assign, readonly) BOOL jj_isPresented; //是否是presented, 一般不需要直接使用

- (void)jj_networkStateDidChange:(BOOL)available;

- (void)jj_dismiss; //退出vc 会根据vc是否是presented来选择退出的方式
@end

NS_ASSUME_NONNULL_END
