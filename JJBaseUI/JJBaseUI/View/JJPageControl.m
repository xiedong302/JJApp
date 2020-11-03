//
//  JJPageControl.m
//  JJBaseUI
//
//  Created by xiedong on 2020/10/24.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJPageControl.h"

static CGFloat controlMargin = 4.0f;
static CGFloat controlHeight = 3.0f;
static CGFloat controlSelectWidth = 12.5f;
static CGFloat controlNormalWidth = 5.0f;
static CGFloat controlCornerRaduis = 1.5f;

@interface JJPageControl()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSMutableArray *dotsArray;
@property (nonatomic, assign) NSInteger lastPage;

@end

@implementation JJPageControl

+ (instancetype)pageControl {
    JJPageControl *pageControl = [[JJPageControl alloc] init];
    pageControl.dotsArray = [[NSMutableArray alloc] init];
    pageControl.normalColor = UIColor.jj_pageControlNormalColor;
    pageControl.selectedColor = UIColor.jj_pageControlSelectedColor;
    return pageControl;
}

//MARK: - Private
- (void)loadPages {
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    [self addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.bottom.offset(0);
    }];
    _dotsArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < _numberOfPages; i ++) {
        UIView *view = [[UIView alloc] init];
        if (i == _currentPage) {
            view.backgroundColor = _selectedColor;
        } else {
            view.backgroundColor = _normalColor;
        }
        view.layer.cornerRadius = controlCornerRaduis;
        [self.contentView addSubview:view];
        [_dotsArray addObject:view];
    }
    [self setSubviewConstraints];
}

- (void)setSubviewConstraints {
    UIView *lastView = nil;
    
    for (UIView *view in _dotsArray) {
        NSInteger index = [_dotsArray indexOfObject:view];
        CGFloat currentWidth = index == _currentPage ? controlSelectWidth : controlNormalWidth;
        [view mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (lastView) {
                make.left.equalTo(lastView.mas_right).offset(controlMargin);
            } else {
                make.left.equalTo(self.contentView);
            }
            make.centerY.offset(0);
            make.height.offset(controlHeight);
            make.width.offset(currentWidth);
            if (index == _dotsArray.count - 1) make.right.equalTo(self.contentView);
        }];
        
        lastView = view;
    }
}

- (void)updateView {
    if (_numberOfPages <= 0) {
        return;
    }
    
    NSInteger currentIndex = MIN(_currentPage, self.dotsArray.count - 1);
    currentIndex = MAX(0, currentIndex);
    
    NSInteger lastIndex = MIN(_lastPage, self.dotsArray.count - 1);
    lastIndex = MAX(0, lastIndex);
    
    UIView *currentView = self.dotsArray[currentIndex];
    UIView *lastView = self.dotsArray[lastIndex];
    
    lastView.backgroundColor = _normalColor;
    currentView.backgroundColor = _selectedColor;
    
    [self setSubviewConstraints];
    
    [UIView animateWithDuration:0.2f animations:^{
        [self layoutIfNeeded];
    }];
}

//MARK: Setter & Getter
- (void)setNumberOfPages:(NSInteger)numberOfPages {
    if (_numberOfPages == numberOfPages) {
        return;
    }
    
    _numberOfPages = numberOfPages;
    [self loadPages];
}

- (void)setCurrentPage:(NSInteger)currentPage {
    if (_currentPage == currentPage) {
        return;
    }
    
    if (currentPage > _numberOfPages - 1) {
        return;
    }
    
    _lastPage = _currentPage;
    _currentPage = currentPage;
    [self updateView];
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
    }
    return _contentView;
}
@end
