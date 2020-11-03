//
//  CGContextCustomView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/30.
//

#import "CGContextCustomView.h"

@interface CGContextCustomView()

@end
@implementation CGContextCustomView


- (void)viewDrawRect:(CGRect)rect context:(CGContextRef)ctx {
    [super viewDrawRect:rect context:ctx];
    
    [self customDrawImage:rect context:ctx];
}

- (void)customDrawImage:(CGRect)rect context:(CGContextRef)ctx {
    // 开始绘制
    CGRect newRect = CGRectInset(rect, 50, 50);
    // 第二个参数 opaque 不透明
//    UIGraphicsBeginImageContextWithOptions(newRect.size, YES, UIScreen.mainScreen.scale);
    
    // 设置整个背景色
//    [UIColor.redColor setFill];
//    UIRectFill(newRect);
    
    // 不能直接这样fill 这样的fill或在当前父view的layer直接绘制 imageview的层级在上面
    CGContextSetFillColorWithColor(ctx, UIColor.redColor.CGColor);
    CGContextFillRect(ctx, newRect);
    
    // 带圆角的矩形
    CGPathRef path = CGPathCreateWithRoundedRect(newRect, 10, 10, nil);

    // 设置阴影
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 10, [UIColor.blackColor colorWithAlphaComponent:0.01].CGColor);

    // 设置path 白色
    CGContextSetFillColorWithColor(ctx, UIColor.whiteColor.CGColor);
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);

    // 清除阴影
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 0, nil);
//
    // 绘制图片
    [JJTImage(@"Draw/pig") drawInRect:CGRectMake(130, 50, 50, 50)];

    // 绘制文字
    [@"持续学习，一直输出" drawInRect:CGRectMake(100, 110, 200, 20)
                    withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],
                                     NSForegroundColorAttributeName:UIColor.blueColor}];
    
//    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//
//    UIGraphicsEndImageContext();
//
//    return newImage;
}

// 绘制两个view的方式
- (UIImage *)customImageWithView1:(UIView *)view1 view2:(UIView *)view2 {
    
    CGRect rect = CGRectMake(0, 0, MAX(CGRectGetWidth(view1.frame), CGRectGetWidth(view2.frame)), CGRectGetHeight(view1.frame) + CGRectGetHeight(view2.frame));
    
    CGFloat scale = UIScreen.mainScreen.scale;
    
    UIGraphicsBeginImageContextWithOptions(rect.size, YES, 0);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGLayerRef layer1 = CGLayerCreateWithContext(ctx, CGSizeMake(rect.size.width * scale, view1.frame.size.height * scale), nil);
    
    CGLayerRef layer2 = CGLayerCreateWithContext(ctx, CGSizeMake(rect.size.width * scale, view2.frame.size.height * scale), nil);
    
    CGContextRef view1Ctx = CGLayerGetContext(layer1);
    
    CGContextRef view2Ctx = CGLayerGetContext(layer2);
    
    CGContextScaleCTM(view1Ctx, scale, scale);
    
    CGContextScaleCTM(view2Ctx, scale, scale);
    
    [view1.layer renderInContext:view1Ctx];
    
    [view2.layer renderInContext:view2Ctx];
    
    CGContextDrawLayerInRect(ctx, CGRectMake(0, 0, rect.size.width, view1.frame.size.height), layer1);
    
    CGContextDrawLayerInRect(ctx, CGRectMake(0, view1.frame.size.height, rect.size.width, view2.frame.size.height), layer2);
    
    CGLayerRelease(layer1);
    
    CGLayerRelease(layer2);
    
    [@"持续输出" drawInRect:CGRectMake(0, 0, 100, 20) withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13],
                                                                      NSForegroundColorAttributeName:UIColor.whiteColor}];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

@end
