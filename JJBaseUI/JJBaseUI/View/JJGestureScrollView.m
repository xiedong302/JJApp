//
//  JJGestureScrollView.m
//  JJBaseUI
//
//  Created by xiedong on 2020/9/28.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJGestureScrollView.h"

typedef NS_ENUM(NSUInteger, JJScrollTranslation) {
    JJScrollTranslationLeft,    //左
    JJScrollTranslationRight,   //右
    JJScrollTranslationUp,     //上
    JJScrollTranslationDowm,  //下
};
@interface JJGestureScrollView() <UIGestureRecognizerDelegate>

@property (nonatomic, assign) JJScrollTranslation translation;

@end
@implementation JJGestureScrollView

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
        UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
        self.translation = [self commitTranslation:[pan translationInView:self]];
    }
    
    UIScrollView *scrollView = (UIScrollView *)gestureRecognizer.view;
    CGFloat total = scrollView.contentOffset.x + scrollView.bounds.size.width;
    if (JJScrollTranslationLeft == self.translation) {
        if (total >= scrollView.contentSize.width) { //往左滑到头了，事件传给下级
            return YES;
        }
    } else if (JJScrollTranslationRight == self.translation) {
        if(scrollView.contentOffset.x <= 0) { //往右滑到头了，事件传给下级
            return YES;
        }
    } else {
        //其他的滑动，事件传给下级
        return YES;
    }
    
    return NO;
}

- (JJScrollTranslation)commitTranslation:(CGPoint)point {
    CGFloat absX = fabs(point.x);
    CGFloat absY = fabs(point.y);
    if (absX > absY) {
        if (point.x > 0) {
            return JJScrollTranslationRight;
        } else {
            return JJScrollTranslationLeft;
        }
    } else {
        if (point.y > 0) {
            return JJScrollTranslationDowm;
        } else {
            return JJScrollTranslationUp;
        }
    }
}

@end
