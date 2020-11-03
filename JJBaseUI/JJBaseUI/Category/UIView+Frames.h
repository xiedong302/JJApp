//
//  UIView+Frames.h
//  JJBaseUI
//
//  Created by xiedong on 2020/9/24.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Frames)

@property (nonatomic, assign) CGFloat jj_x;
@property (nonatomic, assign) CGFloat jj_y;
@property (nonatomic, assign) CGFloat jj_top;
@property (nonatomic, assign) CGFloat jj_bottom;
@property (nonatomic, assign) CGFloat jj_left;
@property (nonatomic, assign) CGFloat jj_right;
@property (nonatomic, assign) CGFloat jj_width;
@property (nonatomic, assign) CGFloat jj_height;
@property (nonatomic, assign) CGFloat jj_centerX;
@property (nonatomic, assign) CGFloat jj_centerY;
@property (nonatomic, assign) CGSize jj_size;
@property (nonatomic, assign) CGPoint jj_origin;
@property (nonatomic, assign, readonly) CGFloat jj_maxX;
@property (nonatomic, assign, readonly) CGFloat jj_maxY;

@property (nonatomic, assign, readonly) UIEdgeInsets jj_safeAreaInsets;

@end

NS_ASSUME_NONNULL_END
