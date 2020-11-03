//
//  JJCarouselView.m
//  JJBaseUI
//
//  Created by xiedong on 2020/10/24.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJCarouselView.h"
#import "JJPageControl.h"

static const NSInteger maxCount = 3000;

@interface JJCarouselView()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) JJPageControl *pageControl;

@property (nonatomic, weak) NSTimer *timer;

@property (nonatomic, weak) UICollectionViewFlowLayout *flowLayout;

@property (nonatomic, assign) NSInteger totalItemCount;

@property (nonatomic, strong) NSMutableArray *registerClassesArray;

@end

@implementation JJCarouselView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initialization];
        [self setupCollectionView];
        [self setupPageControl];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initialization];
    [self setupCollectionView];
    [self setupPageControl];
}

- (void)initialization {
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.autoScroll = YES;
    self.autoScrollInteval = 3.0;
    self.infiniteLoop = YES;
    self.showPageControl = YES;
    
    self.registerClassesArray = [NSMutableArray array];
}

- (void)setupCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout = flowLayout;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor clearColor];
    collectionView.pagingEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.scrollsToTop = NO;
    [self addSubview:collectionView];
    
    self.collectionView = collectionView;
}

- (void)setupPageControl {
    JJPageControl *pageControl = [JJPageControl pageControl];
    [self addSubview:pageControl];
    self.pageControl = pageControl;
    //TODO: pageControl frame may need change
    [pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-5);
        make.centerX.equalTo(self);
        make.height.equalTo(@10);
        make.width.equalTo(@30);
    }];
}

//MARK: - Life circles
- (void)layoutSubviews {
    [super layoutSubviews];
    
    _flowLayout.itemSize = self.frame.size;
    _collectionView.frame = self.bounds;
    if (_collectionView.contentOffset.x == 0 && self.totalItemCount) {
        int targetIndex = 0;
        if (self.infiniteLoop) {
            targetIndex = self.totalItemCount * 0.5;
        }
        
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:(UICollectionViewScrollPositionNone) animated:NO];
    }
}

//解决当父view释放时，当前视图因为被Timer强引用而不能释放的问题
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self invalidateTimer];
    }
}

//解决当timer释放后，回调scrollViewDidScroll时访问野指针导致崩溃
- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

//MARK: - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.totalItemCount;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = [self identifierAtIndexPath:indexPath];
    
    long itemIndex = [self pageControlIndexWithCurrentCellIndex:indexPath.row];
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    [self.delegate carouselView:self congfigCell:cell index:itemIndex];
    
    return cell;
}

//MARK: - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    long itemIndex = [self pageControlIndexWithCurrentCellIndex:indexPath.row];
    
    [self.delegate carouselView:self itemDidSelectAtIndex:itemIndex];
}

//MARK: - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updatePage];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.autoScroll) {
        [self invalidateTimer];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.autoScroll) {
        [self setupTimer];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:self.collectionView];
    [self updatePage];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    int itemIndex = [self currentIndex];
    int indexPageOfControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(carouselView:itemDidScrollToIndex:)]) {
        [self.delegate carouselView:self itemDidScrollToIndex:indexPageOfControl];
    }
}

- (void)updatePage {
    int itemIndex = [self currentIndex];
    int indexPageOfControl = [self pageControlIndexWithCurrentCellIndex:itemIndex];
    
    if ([self.pageControl isKindOfClass:JJPageControl.class]) {
        JJPageControl *pageControl = (JJPageControl *)self.pageControl;
        pageControl.numberOfPages = [self.delegate numberOfItemInCarouselView:self];
        pageControl.currentPage = indexPageOfControl;
    }
}

//MARK: - Private
- (void)setupTimer {
    NSTimer *time = [NSTimer scheduledTimerWithTimeInterval:self.autoScrollInteval target:self selector:@selector(automaticScroll) userInfo:nil repeats:YES];
    _timer = time;
    [[NSRunLoop currentRunLoop] addTimer:time forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer {
    [_timer invalidate];
    _timer = nil;
}

- (void)automaticScroll {
    if (0 == self.totalItemCount) {
        return;
    }
    
    int currentIndex = [self currentIndex];
    int targetIndex = currentIndex++;
    [self scrollToIndex:targetIndex];
}

- (void)scrollToIndex:(NSInteger)targetIndex {
    if (targetIndex >= self.totalItemCount) {
        if (self.infiniteLoop) {
            targetIndex = self.totalItemCount * 0.5;
            [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:(UICollectionViewScrollPositionNone) animated:NO];
        }
        return;
    }
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:(UICollectionViewScrollPositionNone) animated:YES];
}

- (int)currentIndex {
    if (self.collectionView.frame.size.width == 0 || self.collectionView.frame.size.height == 0) {
        return 0;
    }
    
    int index = 0;
    if (self.flowLayout.scrollDirection == UICollectionViewScrollDirectionHorizontal) {
        index = (self.collectionView.contentOffset.x + self.flowLayout.itemSize.width * 0.5) / self.flowLayout.itemSize.width;
    } else {
        index = (self.collectionView.contentOffset.y + self.flowLayout.itemSize.height * 0.5) / self.flowLayout.itemSize.height;
    }
    
    return MAX(0, index);
}

- (int)pageControlIndexWithCurrentCellIndex:(NSInteger)index {
    NSInteger count = [self.delegate numberOfItemInCarouselView:self];
    
    return count == 0 ? 0 : (int)index % count;
}

- (NSString *)identifierAtIndexPath:(NSIndexPath *)indexPath {
    Class class = [self.delegate carouselView:self itemClassForIndex:indexPath.row];
    NSString *identifier = NSStringFromClass(class);
    
    [self autoRegisterClass:class withIdentifier:identifier];
        
    return identifier;
}

- (void)autoRegisterClass:(Class)class withIdentifier:(NSString *)identifier {
    if (![self.registerClassesArray containsObject:class]) {
        [self.collectionView registerClass:class forCellWithReuseIdentifier:identifier];
        [self.registerClassesArray addObject:class];
    }
}

//MARK: - Public
- (void)reloadData {
    [self.collectionView reloadData];
}

//MARK: Setter & Getter
- (void)setAutoScroll:(BOOL)autoScroll {
    _autoScroll = autoScroll;
    
    [self invalidateTimer];
    
    if (_autoScroll) {
        [self setupTimer];
    }
}

- (NSInteger)totalItemCount {
    NSInteger count = [self.delegate numberOfItemInCarouselView:self];
    
    return self.infiniteLoop && count > 1 ? count * maxCount : count;
}

- (void)setScrollDirection:(UICollectionViewScrollDirection)scrollDirection {
    _scrollDirection = scrollDirection;
    
    self.flowLayout.scrollDirection = scrollDirection;
}

- (void)setAutoScrollInteval:(NSTimeInterval)autoScrollInteval {
    _autoScrollInteval = autoScrollInteval;
    
    [self setAutoScroll:self.autoScroll];
}

- (void)setShowPageControl:(BOOL)showPageControl {
    _showPageControl = showPageControl;
    
    self.pageControl.hidden = !showPageControl;
}


@end
