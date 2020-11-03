//
//  CGBaseView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/30.
//

#import "CGBaseView.h"

@implementation CGBaseView

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    
    // 压到栈顶来进行绘制
    UIGraphicsPushContext(context);
    
    [self viewDrawRect:rect context:context];
    
    UIGraphicsPopContext();
    
    CGContextRestoreGState(context);
}

- (void)viewDrawRect:(CGRect)rect context:(CGContextRef)ctx { }

- (void)viewNotifiDisplayChanged {
    [self setNeedsDisplay];
}

@end
