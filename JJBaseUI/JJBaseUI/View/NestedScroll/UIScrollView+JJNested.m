//
//  UIScrollView+JJNested.m
//  JJBaseUI
//
//  Created by xiedong on 2020/10/22.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "UIScrollView+JJNested.h"
#import <objc/runtime.h>

@implementation UIScrollView (JJNested)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzledInstanceMethod:NSSelectorFromString(@"_scrollViewWillBeginDragging") withMethod:@selector(jj_scrollViewWillBeginDragging)];
        [self swizzledInstanceMethod:NSSelectorFromString(@"_notifyDidScroll") withMethod:@selector(jj_scrollViewDidScroll)];
    });
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    self.jj_superNestedScrollView = [self findSuperNestedScrollView];
    if (self.jj_superNestedScrollView && [self.jj_superNestedScrollView respondsToSelector:@selector(jj_gestureRecognizerShouldBegin:subScrollView:)]) {
        if ([self.jj_superNestedScrollView jj_gestureRecognizerShouldBegin:gestureRecognizer subScrollView:self]) {
            return YES;
        }
    }
    return [super gestureRecognizerShouldBegin:gestureRecognizer];;
}

- (void)jj_scrollViewWillBeginDragging {
    [self jj_scrollViewWillBeginDragging];
    if (self.jj_superNestedScrollView && [self.jj_superNestedScrollView respondsToSelector:@selector(jj_subScrollViewBeginDragging:)]) {
        [self.jj_superNestedScrollView jj_subScrollViewBeginDragging:self];
    }
}

- (void)jj_scrollViewDidScroll {
    [self jj_scrollViewDidScroll];
    if (self.jj_superNestedScrollView && [self.jj_superNestedScrollView respondsToSelector:@selector(jj_subScrollViewDidScroll:)]) {
        [self.jj_superNestedScrollView jj_subScrollViewDidScroll:self];
    }
}

- (UIScrollView *)findSuperNestedScrollView {
    for (UIView *next = [self superview]; next; next = [next superview]) {
        if ([next isKindOfClass:UIScrollView.class] && ((UIScrollView *)next).jj_suportNestedScroll) {
            return (UIScrollView *)next;
        }
    }
    return nil;
}

//MARK: - Getter & Setter

- (BOOL)jj_suportNestedScroll {
    return objc_getAssociatedObject(self, @selector(jj_suportNestedScroll));
}

- (void)setJj_suportNestedScroll:(BOOL)jj_suportNestedScroll {
    objc_setAssociatedObject(self, @selector(jj_suportNestedScroll), @(jj_suportNestedScroll), OBJC_ASSOCIATION_ASSIGN);
}

- (UIScrollView *)jj_superNestedScrollView {
    return objc_getAssociatedObject(self, @selector(jj_superNestedScrollView));
}

- (void)setJj_superNestedScrollView:(UIScrollView *)jj_superNestedScrollView {
    objc_setAssociatedObject(self, @selector(jj_superNestedScrollView), jj_superNestedScrollView, OBJC_ASSOCIATION_ASSIGN);
}

//MARK: - Public
- (void)jj_setContentOffsetY:(CGFloat)offsetY {
    if (self.contentOffset.y != offsetY) {
        self.contentOffset = CGPointMake(0, offsetY);
    }
}

- (void)jj_subScrollViewBeginDragging:(UIScrollView *)subScrollView {
    
}

- (void)jj_subScrollViewDidScroll:(UIScrollView *)subScrollView {
    
}

- (BOOL)jj_gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer subScrollView:(UIScrollView *)subScrollView {
    return NO;
}

//MARK: - Swizzle
+ (void)swizzledInstanceMethod:(SEL)origSelector withMethod:(SEL)newSelector {
    Class cls = [self class];
    Method originalMethod = class_getInstanceMethod(cls, origSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, newSelector);
    
    if (class_addMethod(cls, origSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))) {
        class_replaceMethod(cls, newSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

@end
