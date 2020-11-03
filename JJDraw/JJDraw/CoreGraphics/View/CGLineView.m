//
//  CGLineView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/30.
//

#import "CGLineView.h"

@implementation CGLineView

- (void)viewDrawRect:(CGRect)rect context:(CGContextRef)ctx {
    [super viewDrawRect:rect context:ctx];
    
    // 填充色
    CGContextSetFillColorWithColor(ctx, UIColor.clearColor.CGColor);
    // 线宽
    CGContextSetLineWidth(ctx, 1);
    // 线结束的样式
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    // 绘制虚线  5线长度 1间距
    CGFloat lengths[2] = {5,1};
    CGContextSetLineDash(ctx, 0, lengths, 2);
    
    // 第一波绘制线
    // 描边色
    CGContextSetStrokeColorWithColor(ctx, UIColor.redColor.CGColor);
    
    // 收集绘制路径
    CGContextMoveToPoint(ctx, 0, 100);
    CGContextAddLineToPoint(ctx, 350, 100);
    
    // 开始绘制
    CGContextDrawPath(ctx, kCGPathStroke);
    
    // 第二波绘制 矩形
    CGContextSetFillColorWithColor(ctx, UIColor.brownColor.CGColor);
    CGContextFillRect(ctx, CGRectMake(10, 10, 50, 50));
    
    // 第三波绘制 椭圆
    CGContextSetFillColorWithColor(ctx, UIColor.yellowColor.CGColor);
    CGContextFillEllipseInRect(ctx, CGRectMake(10, 200, 100, 50));
    
    // 第四波绘制 不规则矩形
    CGFloat otherLengths[2] = {1,0};
    CGContextSetLineDash(ctx, 0, otherLengths, 2);
    CGContextSetStrokeColorWithColor(ctx, UIColor.orangeColor.CGColor);
    CGContextStrokeRect(ctx, CGRectMake(10, 110, 20, 20));
    
    // 第五波绘制 用stroke绘制线
    CGContextMoveToPoint(ctx, 50, 110);
    CGContextAddLineToPoint(ctx, 60, 110);
    CGContextAddLineToPoint(ctx, 60, 120);
    // 合并起始点
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
}
@end
