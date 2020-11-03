//
//  UIScrollView+JJNested.h
//  JJBaseUI
//
//  Created by xiedong on 2020/10/22.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScrollView (JJNested)

@property (nonatomic, assign) BOOL jj_suportNestedScroll;

@property (nonatomic, weak) UIScrollView *jj_superNestedScrollView;

- (void)jj_setContentOffsetY:(CGFloat)offsetY;

- (void)jj_subScrollViewBeginDragging:(UIScrollView *)subScrollView;
- (void)jj_subScrollViewDidScroll:(UIScrollView *)subScrollView;
- (BOOL)jj_gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer subScrollView:(UIScrollView *)subScrollView;

@end

NS_ASSUME_NONNULL_END
