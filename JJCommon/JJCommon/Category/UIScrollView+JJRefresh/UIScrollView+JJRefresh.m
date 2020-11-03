//
//  UIScrollView+JJRefresh.m
//  JJCommon
//
//  Created by xiedong on 2020/10/24.
//

#import "UIScrollView+JJRefresh.h"
#import <objc/runtime.h>
#import <MJRefresh/MJRefresh.h>
#import "JJRefreshHeader.h"
#import "JJRefreshGifHeader.h"
#import "JJRefreshFooter.h"

//MARK: - JJRefreshTarget
@interface JJRefreshTarget : NSObject

@property (nonatomic, weak) id target;

@property (nonatomic, assign) SEL selector;

@end

@implementation JJRefreshTarget

@end

//MARK: - UIScrollView+JJRefresh
@implementation UIScrollView (JJRefresh)

- (JJRefreshStyle)jj_refreshStyle {
    JJRefreshHeader *header = (JJRefreshHeader *)self.mj_header;
    return header.style;
}

- (void)setJj_refreshStyle:(JJRefreshStyle)jj_refreshStyle {
    JJRefreshHeader *header = (JJRefreshHeader *)self.mj_header;
    header.style = jj_refreshStyle;
}

- (BOOL)jj_enablePullRefresh {
    return self.mj_header != nil;
}

- (void)setJj_enablePullRefresh:(BOOL)jj_enablePullRefresh {
    if (jj_enablePullRefresh) {
        if (!self.mj_header) {
            self.mj_header = [JJRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(jj_onPullRefresh)];
        }
    } else {
        self.mj_header = nil;
    }
}

- (BOOL)jj_enableLoadMore {
    return self.mj_footer != nil;
}

- (void)setJj_enableLoadMore:(BOOL)jj_enableLoadMore {
    if (jj_enableLoadMore) {
        if (!self.mj_footer) {
            self.mj_footer = [JJRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(jj_onLoadMore)];
        }
    } else {
        self.mj_footer = nil;
    }
}

- (void)jj_setPullRefreshTarget:(id)target selector:(SEL)selector {
    JJRefreshTarget *t = [[JJRefreshTarget alloc] init];
    t.target = target;
    t.selector = selector;
    
    objc_setAssociatedObject(self, @selector(jj_enablePullRefresh), t, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)jj_setLoadMoreTarget:(id)target selector:(SEL)selector {
    JJRefreshTarget *t = [[JJRefreshTarget alloc] init];
    t.target = target;
    t.selector = selector;
    
    objc_setAssociatedObject(self, @selector(jj_enableLoadMore), t, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)jj_beginPullRefresh {
    [self.mj_header beginRefreshing];
}

- (void)jj_beginLoadMore {
    [self.mj_footer beginRefreshing];
}

- (void)jj_endPullRefresh {
    [self.mj_header endRefreshing];
}

- (void)jj_endLoadMore {
    [self jj_endLoadMore:NO];
}

- (void)jj_endLoadMore:(BOOL)noMoreData {
    if (noMoreData) {
        [self.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.mj_footer endRefreshing];
    }
}

//MARK: - Private
- (void)jj_onPullRefresh {
    JJRefreshTarget *t = objc_getAssociatedObject(self, @selector(jj_enablePullRefresh));
    
    if (t && [t respondsToSelector:t.selector]) {
        MJRefreshMsgSend(MJRefreshMsgTarget(t.target), t.selector, self);
    }
}

- (void)jj_onLoadMore {
    JJRefreshTarget *t = objc_getAssociatedObject(self, @selector(jj_enableLoadMore));
    
    if (t && [t respondsToSelector:t.selector]) {
        MJRefreshMsgSend(MJRefreshMsgTarget(t.target), t.selector, self);
    }
}
@end
