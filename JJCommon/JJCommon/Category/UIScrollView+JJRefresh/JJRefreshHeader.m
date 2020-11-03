//
//  JJRefreshHeader.m
//  JJCommon
//
//  Created by xiedong on 2020/10/25.
//

#import "JJRefreshHeader.h"

@interface JJRefreshHeader()

@property (nonatomic, strong) UILabel *refreshLabel;
@property (nonatomic, strong) UIImageView *refreshImg;

@end
@implementation JJRefreshHeader

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
}

- (void)prepare {
    [super prepare];
    
    self.mj_h = 50;
    
    [self addSubview:self.refreshLabel];
    [self addSubview:self.refreshImg];
    
    [self.refreshLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
    }];
    
    [self.refreshImg mas_makeConstraints:^(MASConstraintMaker *make) {
            
    }];
}

#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    
    // 忽略UIScrollView横向滚动，header的位置保持不变
    self.mj_x = self.scrollView.mj_offsetX;
}

#pragma mark 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    
}

#pragma mark 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];
    
}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;
    
    // 触发震动反馈
    if (MJRefreshStatePulling == state) {
        [JJFeedbackUtil vibrate];
    }
    
    switch (state) {
        case MJRefreshStateIdle:
            self.refreshLabel.text = @"下拉刷新";
            self.refreshImg.hidden = YES;
            break;
        case MJRefreshStatePulling:
            self.refreshLabel.text = @"松开刷新";
            self.refreshImg.hidden = YES;
            break;
        case MJRefreshStateRefreshing:
            self.refreshLabel.text = @"正在刷新";
            self.refreshImg.hidden = NO;
            break;
        default:
            break;
    }
}
#pragma mark 监听拖拽比例（控件被拖出来的比例）
- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
}

//MARK: - Setter & Getter
- (UILabel *)refreshLabel {
    if (!_refreshLabel) {
        _refreshLabel = [[UILabel alloc] init];
        _refreshLabel.font = [UIFont jj_fontOfSize:15];
        _refreshLabel.textColor = UIColor.jj_textSecondary1Color;
    }
    return _refreshLabel;
}

- (UIImageView *)refreshImg {
    if (!_refreshImg) {
        _refreshImg = [[UIImageView alloc] init];
        _refreshImg.image = JJTImage(@"");
    }
    return _refreshImg;
}


@end
