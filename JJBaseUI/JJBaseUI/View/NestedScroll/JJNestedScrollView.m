//
//  JJNestedScrollView.m
//  JJBaseUI
//
//  Created by xiedong on 2020/10/22.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJNestedScrollView.h"
#import "UIScrollView+JJNested.h"
#import <MJRefresh/MJRefresh.h>

@interface JJNestedScrollView()

//顶部view
@property (nonatomic, strong) UIView *topView;
//底部view
@property (nonatomic, strong) UIView *bottomView;
//嵌套ScrollView的 Y偏移量
@property (nonatomic, assign) CGFloat subLastOffsetY;
//当前view的size
@property (nonatomic, assign) CGSize currentSize;

@end
@implementation JJNestedScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.jj_suportNestedScroll = YES;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.pagingEnabled = NO;
    }
    return self;
}

- (void)addTopView:(UIView *)topView bottomView:(UIView *)bottomView {
    self.topView = topView;
    self.bottomView = bottomView;
    [self addSubview:topView];
    [self addSubview:bottomView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.top.centerX.equalTo(self);
    }];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.centerX.equalTo(self);
        make.top.equalTo(self.topView.mas_bottom);
        make.height.equalTo(@(self.frame.size.height));
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CGSizeEqualToSize(self.frame.size, self.currentSize) && self.topView && self.bottomView) {
        self.currentSize = self.frame.size;
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(self.frame.size.height));
        }];
    }
}

//MARK: - UIScrollView+JJNested.h
- (void)jj_subScrollViewBeginDragging:(UIScrollView *)subScrollView {
    [super jj_subScrollViewBeginDragging:subScrollView];
    self.subLastOffsetY = subScrollView.contentOffset.y;
}

- (void)jj_subScrollViewDidScroll:(UIScrollView *)subScrollView {
    [super jj_subScrollViewDidScroll:subScrollView];
    CGFloat topHeight = [self getNestedTopViewHeight];
    CGFloat diffOffsetY = subScrollView.contentOffset.y - self.subLastOffsetY;
    if (diffOffsetY == 0) {
        return;
    }
    CGFloat contentOffsetY = self.contentOffset.y + diffOffsetY;
    if (diffOffsetY > 0) { // 上拉
        if (self.contentOffset.y < topHeight && subScrollView.contentOffset.y > 0) { //scrollView跟随上移
            [self jj_setContentOffsetY:MIN(contentOffsetY, topHeight)];
            [subScrollView jj_setContentOffsetY:self.subLastOffsetY];
        } else {
            self.subLastOffsetY = subScrollView.contentOffset.y;
        }
    } else { //下拉
        if (subScrollView.isDragging && subScrollView.contentOffset.y <= 0 && (self.mj_header || self.contentOffset.y > 0)) { // scrollView跟随下移
            [self jj_setContentOffsetY:MAX(contentOffsetY, 0)];
            self.subLastOffsetY = 0;
            [subScrollView jj_setContentOffsetY:self.subLastOffsetY];
        } else {
            self.subLastOffsetY = subScrollView.contentOffset.y;
        }
    }
}

- (BOOL)jj_gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer subScrollView:(UIScrollView *)subScrollView {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        if (self.mj_header && subScrollView.contentOffset.y == 0 && [pan velocityInView:self].y > 0 && fabs([pan velocityInView:self].x) < fabs([pan velocityInView:self].y)) {
            return YES;
        }
    }
    return [super jj_gestureRecognizerShouldBegin:gestureRecognizer subScrollView:subScrollView];
}

//MARK: - Private
- (CGFloat)getNestedTopViewHeight {
    return self.topView.bounds.size.height;
}

- (void)setContentOffset:(CGPoint)contentOffset {
    if (!self.mj_footer) { //嵌套滚动时禁止下方的bounces效果
        if (self.contentOffset.y > [self getNestedTopViewHeight]) {
            self.bounces = NO;
        } else {
            self.bounces = YES;
        }
        contentOffset.y = MIN(contentOffset.y, [self getNestedTopViewHeight]);
    }
    [super setContentOffset:contentOffset];
}
@end
