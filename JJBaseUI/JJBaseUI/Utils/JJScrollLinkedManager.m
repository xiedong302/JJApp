//
//  JJScrollLinkedManager.m
//  JJBaseUI
//
//  Created by xiedong on 2020/9/24.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJScrollLinkedManager.h"

static void * const JJScrollLinkedKVOContext = (void*)&JJScrollLinkedKVOContext;

@interface JJScrollLinkedManager()
{
    NSHashTable *_firstAddScrollView;
    NSHashTable *_scrollViews;
    BOOL _syncScrolling; //避免递归调用
    CGPoint _currentOffset;
}

@end
@implementation JJScrollLinkedManager

//MARK: - private
- (instancetype)init {
    if (self = [super init]) {
        _firstAddScrollView = [NSHashTable weakObjectsHashTable];
        _scrollViews = [NSHashTable weakObjectsHashTable];
        _syncScrolling = NO;
        _currentOffset = CGPointZero;
    }
    return self;
}

- (void)dealloc {
    for (UIScrollView *scrollView in _scrollViews) {
        [scrollView removeObserver:self forKeyPath:@"contentOffset" context:JJScrollLinkedKVOContext];
    }
    
    [_scrollViews removeAllObjects];
    [_firstAddScrollView removeAllObjects];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == JJScrollLinkedKVOContext) {
        if (_syncScrolling) {
            return;
        }
        
        _syncScrolling = YES;
        
        UIScrollView *scrollView = (UIScrollView *)object;
        if ([_firstAddScrollView containsObject:scrollView]) {
            //新加入的ScrollView第一次contentOffSet变化多半是因为首次布局导致的，需要忽略
            scrollView.contentOffset = _currentOffset;
            
            [_firstAddScrollView removeObject:scrollView];
        } else {
            _currentOffset = scrollView.contentOffset;
            
            for (UIScrollView *sv in _scrollViews) {
                if (sv != scrollView) {
                    sv.contentOffset = _currentOffset;
                }
            }
        }
        
        _syncScrolling = NO;
    }
}

//MARK: - public
- (void)addScrollView:(UIScrollView *)scrollView {
    scrollView.contentOffset = _currentOffset;
    
    if (![_scrollViews containsObject:scrollView]) {
        [scrollView addObserver:self forKeyPath:@"contentOffset" options:(NSKeyValueObservingOptionNew) context:JJScrollLinkedKVOContext];
    }
    
    [_scrollViews addObject:scrollView];
    [_firstAddScrollView addObject:scrollView];
}

- (void)removeScrollView:(UIScrollView *)scrollView {
    if ([_scrollViews containsObject:scrollView]) {
        [scrollView removeObserver:self forKeyPath:@"contentOffset" context:JJScrollLinkedKVOContext];
    }
    
    [_scrollViews removeObject:scrollView];
    [_firstAddScrollView removeObject:scrollView];
}
@end
