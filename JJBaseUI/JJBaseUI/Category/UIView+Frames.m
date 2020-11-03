//
//  UIView+Frames.m
//  JJBaseUI
//
//  Created by xiedong on 2020/9/24.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "UIView+Frames.h"

@implementation UIView (Frames)

- (void)setJj_x:(CGFloat)jj_x {
    self.jj_left = jj_x;
}

- (CGFloat)jj_x {
    return self.jj_left;
}

- (void)setJj_y:(CGFloat)jj_y {
    self.jj_top = jj_y;
}

- (CGFloat)jj_y {
    return self.jj_top;
}

- (void)setJj_top:(CGFloat)jj_top {
    CGFloat bottom = self.jj_bottom;
    CGRect frame = self.frame;
    frame.origin.y = jj_top;
    frame.size.height = bottom - jj_top;
    self.frame = frame;
}

- (CGFloat)jj_top {
    return self.frame.origin.y;
}

- (void)setJj_bottom:(CGFloat)jj_bottom {
    CGFloat top = self.jj_top;
    CGRect frame = self.frame;
    frame.size.height = jj_bottom - top;
    self.frame = frame;
}

- (CGFloat)jj_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setJj_left:(CGFloat)jj_left {
    CGFloat right = self.jj_right;
    CGRect frame = self.frame;
    frame.origin.x = jj_left;
    frame.size.width = right - jj_left;
    self.frame = frame;
}

- (CGFloat)jj_left {
    return self.frame.origin.x;
}

- (void)setJj_right:(CGFloat)jj_right {
    CGFloat left = self.jj_left;
    CGRect frame = self.frame;
    frame.size.width = jj_right - left;
    self.frame = frame;
}

- (CGFloat)jj_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setJj_width:(CGFloat)jj_width {
    CGRect frame = self.frame;
    frame.size.width = jj_width;
    self.frame = frame;
}

- (CGFloat)jj_width {
    return self.frame.size.width;
}

- (void)setJj_height:(CGFloat)jj_height {
    CGRect frame = self.frame;
    frame.size.height = jj_height;
    self.frame = frame;
}

- (CGFloat)jj_height {
    return self.frame.size.height;
}

- (void)setJj_centerX:(CGFloat)jj_centerX {
    CGPoint center = self.center;
    center.x = jj_centerX;
    self.center = center;
}

- (CGFloat)jj_centerX {
    return self.center.x;
}

- (void)setJj_centerY:(CGFloat)jj_centerY {
    CGPoint center = self.center;
    center.y = jj_centerY;
    self.center = center;
}
- (CGFloat)jj_centerY {
    return self.center.y;
}

- (void)setJj_origin:(CGPoint)jj_origin {
    CGRect frame = self.frame;
    frame.origin = jj_origin;
    self.frame = frame;
}

- (CGPoint)jj_origin {
    return self.frame.origin;
}

- (void)setJj_size:(CGSize)jj_size {
    CGRect frame = self.frame;
    frame.size = jj_size;
    self.frame = frame;
}

- (CGSize)jj_size {
    return self.frame.size;
}

- (CGFloat)jj_maxX {
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)jj_maxY {
    return self.frame.origin.y + self.frame.size.height;
}

- (UIEdgeInsets)jj_safeAreaInsets {
    if (@available(iOS 11.0, *)) {
        return self.safeAreaInsets;
    } else {
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

@end
