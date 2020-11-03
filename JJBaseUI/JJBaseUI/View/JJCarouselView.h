//
//  JJCarouselView.h
//  JJBaseUI
//
//  Created by xiedong on 2020/10/24.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JJCarouselView;

@protocol JJCarouselViewDelegate <NSObject>

- (Class)carouselView:(JJCarouselView *)carouselView itemClassForIndex:(NSInteger)index;

- (NSInteger)numberOfItemInCarouselView:(JJCarouselView *)carouselView;

- (void)carouselView:(JJCarouselView *)carouseView congfigCell:(__kindof UICollectionViewCell *)cell index:(NSInteger)index;

- (void)carouselView:(JJCarouselView *)carouselView itemDidScrollToIndex:(NSInteger)index;

- (void)carouselView:(JJCarouselView *)carouselView itemDidSelectAtIndex:(NSInteger)index;

@end

@interface JJCarouselView : UIView

///////////////////////  滚动控制接口  /////////////////////
@property (nonatomic, weak) id<JJCarouselViewDelegate> delegate;

@property (nonatomic, strong) UICollectionView *collectionView;

/* 滚动方向， 默认UICollectionViewScrollDirectionHorizontal*/
@property (nonatomic, assign) UICollectionViewScrollDirection scrollDirection;

/* 自动滚动， 默认YES*/
@property (nonatomic, assign) BOOL autoScroll;

/* 滚动时间间隔， 默认3s*/
@property (nonatomic, assign) NSTimeInterval autoScrollInteval;

/* 是否无限滚动， 默认YES*/
@property (nonatomic, assign) BOOL infiniteLoop;

/* 是否显示分页控件， 默认YES*/
@property (nonatomic, assign) BOOL showPageControl;

- (void)reloadData;
@end

NS_ASSUME_NONNULL_END
