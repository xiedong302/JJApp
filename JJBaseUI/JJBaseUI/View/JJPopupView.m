//
//  JJPopupView.m
//  JJBaseUI
//
//  Created by xiedong on 2020/9/25.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJPopupView.h"
#import <Masonry/Masonry.h>

@interface JJPopupView()

@property (nonatomic, assign) BOOL isHiding;

@end

@implementation JJPopupView

- (instancetype)init {
    if (self = [super init]) {
        _contentSize = CGSizeZero;
        _outsideTouchable = NO;
        _hidesWhenTouchOutside = YES;
        
        _isHiding = NO;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    
    if (view == self) {
        if (self.hidesWhenTouchOutside) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self performHide:YES];
            });
        }
        
        if (self.outsideTouchable) return nil;
    }
    
    return view;
}

//MARK: - public
- (void)showAsDropdownForView:(UIView *)anchorView buOffset:(CGPoint)offset {
    if (self.isShowing) {
        return;
    }
    
    UIView *superViewToAdd = anchorView.superview;
    CGRect bounds = CGRectMake(0, 0, self.contentSize.width, self.contentSize.height);
    
    for (NSUInteger i = 0; i < 5 ; ++i) {
        if (superViewToAdd && CGRectContainsRect(superViewToAdd.bounds, bounds)) {
            break;;
        }
        
        superViewToAdd = superViewToAdd.superview;
    }
    
    if (superViewToAdd) {
        CGPoint showPos = CGPointZero;
        CGPoint anchorPoint = [anchorView convertPoint:CGPointZero toView:superViewToAdd];
        
        showPos = CGPointMake(anchorPoint.x + (anchorView.bounds.size.width - self.contentSize.width) / 2, anchorPoint.y + anchorView.bounds.size.height);
        
        if (showPos.x < 0) {
            showPos.x = 0;
        }
        
        if (showPos.x + self.contentSize.width > superViewToAdd.bounds.size.width) {
            showPos.x = superViewToAdd.bounds.size.width - self.contentSize.width;
        }
        
        //底部空间不够显示在上面，可能上面的空间也可能不够
        if (showPos.y + self.contentSize.height > superViewToAdd.bounds.size.height) {
            showPos.y = anchorPoint.y - self.contentSize.height;
        }
        
        showPos.x += offset.x;
        
        //如果像是在下面，叫offset 如果在上面，减offset
        if (showPos.y >= anchorPoint.y) {
            showPos.y += offset.y;
        } else {
            showPos.y -= offset.y;
        }
        
        [self showInView:superViewToAdd atPosition:showPos];
    }
}

- (void)showInView:(UIView *)parentView atPosition:(CGPoint)position {
    if (self.isShowing) {
        return;
    }
    
    [parentView addSubview:self];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(parentView);
    }];
    
    //移除所有的子view,重新添加contentView,因为show的时候 contentView可能会发生变化
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addSubview:self.contentView];
    
    self.contentView.frame = CGRectMake(position.x, position.y, self.contentSize.width, self.contentSize.height);
    
    [self performShow];
}

- (void)showInView:(UIView *)parentView contraintsHandler:(JJPopupViewContraintsHandler)handler {
    if (self.isShowing) {
        return;
    }
    
    [parentView addSubview:self];
    
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(parentView);
    }];
    
    //移除所有的子view,重新添加contentView,因为show的时候 contentView可能会发生变化
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self addSubview:self.contentView];
    
    if (handler) {
        handler(self);
    }
    
    [self performShow];
}

- (void)hide {
    if (!self.isShowing) {
        return;
    }
    
    [self performHide:NO];
}


//MARK:- Getter && Setter
- (BOOL)isShowing {
    return self.superview != nil;
}

//MARK: - private
- (void)performShow {
    self.isHiding = NO;
    
    self.alpha = 0;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)performHide:(BOOL)touchOutside {
    if (self.isHiding) {
        return;
    }
    
    self.isHiding = YES;
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.isHiding = NO;
        
        [self removeFromSuperview];
        
        __strong id<JJPopupViewDelegate> delelgate = self.delegate;
        
        if (delelgate && [delelgate respondsToSelector:@selector(jjPopupView:didHide:)]) {
            [delelgate jjPopupView:self didHide:touchOutside];
        }
    }];
}
@end
