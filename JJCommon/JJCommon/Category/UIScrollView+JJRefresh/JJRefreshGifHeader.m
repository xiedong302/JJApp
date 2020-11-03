//
//  JJRefreshGifHeader.m
//  JJCommon
//
//  Created by xiedong on 2020/10/25.
//

#import "JJRefreshGifHeader.h"

static NSString * const JJRefreshStyleAutoPathPrefix = @"";
static NSString * const JJRefreshStyleLightPathPrefix = @"";
static NSString * const JJRefreshStyleDarkPathPrefix = @"";
static NSInteger JJRefreshHeaderGIFImageCount = 10;

@implementation JJRefreshGifHeader

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
}

- (void)prepare {
    [super prepare];
    
    self.mj_h = 50;
    
    [self.gifView mas_makeConstraints:^(MASConstraintMaker *make) {
            
    }];
    
    [self.stateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
    }];
    self.lastUpdatedTimeLabel.hidden = YES;
    self.style = JJRefreshStyleAuto;
    
}

/**
 下来刷新，根据需求
 */
- (void)setStyle:(JJRefreshStyle)style {
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < JJRefreshHeaderGIFImageCount; i++) {
        UIImage *image;
        if (JJRefreshStyleAuto == style) {
            NSString *str = [NSString stringWithFormat:@"%@/gif/%d",JJRefreshStyleAutoPathPrefix, i];
            image = JJTImage(str);
        } else if (JJRefreshStyleLight == style) {
            NSString *str = [NSString stringWithFormat:@"%@/gif/%d",JJRefreshStyleLightPathPrefix, i];
            image = JJRImage(str);
        } else if (JJRefreshStyleDark == style) {
            NSString *str = [NSString stringWithFormat:@"%@/gif/%d",JJRefreshStyleDarkPathPrefix, i];
            image = JJRImage(str);
        }
        
        [images addObject:image];
    }
    
    [self setImages:images duration:2 forState:MJRefreshStatePulling];
    [self setImages:images duration:2 forState:MJRefreshStateRefreshing];
    
    if (JJRefreshStyleAuto == style) {
        NSString *staticImgPath = [NSString stringWithFormat:@"%@/下拉刷新-静态",JJRefreshStyleAutoPathPrefix];
        self.gifView.image = JJTImage(staticImgPath);
    } else if (JJRefreshStyleLight == style) {
        NSString *staticImgPath = [NSString stringWithFormat:@"%@/下拉刷新-静态",JJRefreshStyleLightPathPrefix];
        self.gifView.image = JJTImage(staticImgPath);
    } else if (JJRefreshStyleDark == style) {
        NSString *staticImgPath = [NSString stringWithFormat:@"%@/下拉刷新-静态",JJRefreshStyleDarkPathPrefix];
        self.gifView.image = JJTImage(staticImgPath);
    }
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
- (void)setState:(MJRefreshState)state {
    
    MJRefreshCheckState;
    
    // 触发震动反馈
    if (MJRefreshStatePulling == state) {
        [JJFeedbackUtil vibrate];
    }
    
    switch (state) {
        case MJRefreshStateIdle:
            self.stateLabel.text = @"下拉刷新";
            break;
        case MJRefreshStatePulling:
            self.stateLabel.text = @"松开刷新";
            break;
        case MJRefreshStateRefreshing:
            self.stateLabel.text = @"刷新中...";
            break;
        default:
            break;
    }
}

@end
