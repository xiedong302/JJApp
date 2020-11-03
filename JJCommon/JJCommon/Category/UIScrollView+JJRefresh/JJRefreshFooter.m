//
//  JJRefreshFooter.m
//  JJCommon
//
//  Created by xiedong on 2020/10/25.
//

#import "JJRefreshFooter.h"

#pragma clang diagnostic push

#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface JJRefreshFooter()

@property (nonatomic, strong) UILabel *refreshLabel;

@property (nonatomic, strong) UIActivityIndicatorView *loading;

@end
@implementation JJRefreshFooter

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
}
- (void)prepare {
    [super prepare];
    
    // 显示就开始刷新
    self.triggerAutomaticallyRefreshPercent = 0.01;
    
    self.mj_h = 50;
    
    [self addSubview:self.refreshLabel];
    [self addSubview:self.loading];
}

- (void)placeSubviews {
    [super placeSubviews];
    
    self.refreshLabel.frame = self.bounds;
    self.loading.center = CGPointMake(30, self.mj_h * 0.5);
}

- (void)setState:(MJRefreshState)state {
    MJRefreshCheckState;
    
    switch (state) {
        case MJRefreshStateIdle:
            self.refreshLabel.text = @"上拉加载更多";
            [self.loading stopAnimating];
            break;
        case MJRefreshStateRefreshing:
            self.refreshLabel.text = @"数据加载中...";
            [self.loading startAnimating];
            break;
        case MJRefreshStateNoMoreData:
            self.refreshLabel.text = @"暂无更多数据";
            [self.loading stopAnimating];
            break;
        default:
            break;
    }
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

- (UIActivityIndicatorView *)loading {
    if (!_loading) {
        _loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    return _loading;
}
@end

#pragma clang diagnostic pop
