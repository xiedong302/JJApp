//
//  CGBaseLayer.m
//  JJDraw
//
//  Created by xiedong on 2020/10/30.
//

#import "CGBaseLayer.h"

@implementation CGBaseLayer

- (void)drawInContext:(CGContextRef)ctx {
    [super drawInContext:ctx];
    
    CGContextSaveGState(ctx);
    
    UIGraphicsPushContext(ctx);
    
    [self layerDrawInContext:ctx];
    
    UIGraphicsPopContext();
    
    CGContextRestoreGState(ctx);
    
}

- (void)layerDrawInContext:(CGContextRef)ctx {}

- (void)layerNotifiDisplayChanged {
    [self setNeedsDisplay];
}

@end
