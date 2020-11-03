//
//  JJPageControl.h
//  JJBaseUI
//
//  Created by xiedong on 2020/10/24.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// PageControl 默认在frame的中间布局
@interface JJPageControl : UIView

+ (instancetype)pageControl;

@property (nonatomic, assign) NSInteger numberOfPages;
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) UIColor *selectedColor;

@end

NS_ASSUME_NONNULL_END
