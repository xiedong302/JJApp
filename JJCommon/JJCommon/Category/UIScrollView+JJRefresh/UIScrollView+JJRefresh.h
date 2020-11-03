//
//  UIScrollView+JJRefresh.h
//  JJCommon
//
//  Created by xiedong on 2020/10/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, JJRefreshStyle) {
    JJRefreshStyleAuto,
    JJRefreshStyleLight,
    JJRefreshStyleDark,
};

@interface UIScrollView (JJRefresh)

@property (nonatomic, assign) BOOL jj_enablePullRefresh;
@property (nonatomic, assign) BOOL jj_enableLoadMore;

//默认跟着主题走
@property (nonatomic, assign) JJRefreshStyle jj_refreshStyle;

- (void)jj_setPullRefreshTarget:(id)target selector:(SEL)selector;

- (void)jj_setLoadMoreTarget:(id)target selector:(SEL)selector;

- (void)jj_beginPullRefresh;

- (void)jj_beginLoadMore;

- (void)jj_endPullRefresh;

- (void)jj_endLoadMore;

- (void)jj_endLoadMore:(BOOL)noMoreData;

@end

NS_ASSUME_NONNULL_END
