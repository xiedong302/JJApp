//
//  CGGradientView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/30.
//

#import "CGGradientView.h"

@implementation CGGradientView

- (void)viewDrawRect:(CGRect)rect context:(CGContextRef)ctx {
    [super viewDrawRect:rect context:ctx];
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    // 模拟路径
    NSArray *points = [self getTestPoints];
    
    CGPoint firstPoint,lastPoint;
    for (int i = 0; i < points.count; i++) {
        CGPoint point = [points[i] CGPointValue];
        if (i == 0) {
            CGPathMoveToPoint(path, NULL, point.x, point.y);
            firstPoint = point;
        } else {
            CGPathAddLineToPoint(path, NULL, point.x, point.y);
        }
        lastPoint = point;
    }
    CGPathAddLineToPoint(path, NULL, lastPoint.x, 200);
    CGPathAddLineToPoint(path, NULL, firstPoint.x, 200);
    // 合拢
    CGPathCloseSubpath(path);
    
    // 配置路径
    CGContextAddPath(ctx, path);
    // clio
    CGContextClip(ctx);
    // CGColorSpaceRed
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // 颜色
    NSArray *colors = @[(__bridge id)UIColor.redColor.CGColor, (__bridge id)UIColor.brownColor.CGColor];
    // locations
    CGFloat locations[2] = {0.0, 1.0};
    // CGGradientRef
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, locations);
    // CGRect
    CGRect pathRect = CGPathGetBoundingBox(path);
    // startPoint
    CGPoint startPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMinY(pathRect));
    // endPoint
    CGPoint endPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMaxY(pathRect));
    // 绘制函数
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, kCGGradientDrawsBeforeStartLocation /*0*/);
    
    // 释放
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    CGPathRelease(path);
    
}

- (NSArray *)getTestPoints {
    CGFloat x = 10;
    NSMutableArray *arr = [NSMutableArray array];
    for (int i = 0; i < 400; i++) {
        CGPoint point = CGPointMake(x, (CGFloat)(arc4random() % 50 + 100));
        [arr addObject:@(point)];
        ++x;
    }
    return arr.copy;
}
@end
