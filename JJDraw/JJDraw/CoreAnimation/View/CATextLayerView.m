//
//  CATextLayerView.m
//  JJDraw
//
//  Created by xiedong on 2020/10/28.
//

#import "CATextLayerView.h"

@implementation CATextLayerView

- (void)startAnimation {
    
    CATextLayer *textLayer =[CATextLayer layer];
    textLayer.frame = CGRectMake(10, 10, 300, 100);
    [self.layer addSublayer:textLayer];
    
    // 字体颜色
    textLayer.foregroundColor = UIColor.brownColor.CGColor;
    // 对齐方式
    textLayer.alignmentMode = kCAAlignmentJustified;
    // 环绕在边界范围内
    textLayer.wrapped = YES;
    
    UIFont *font = [UIFont systemFontOfSize:15];
    
    // set layer font
    CFStringRef fontName = (__bridge CFStringRef)font.fontName;
    CGFontRef fontRef = CGFontCreateWithFontName(fontName);
    textLayer.font = fontRef;
    textLayer.fontSize = font.pointSize;
    //设置retain渲染
    textLayer.contentsScale = UIScreen.mainScreen.scale;
    CGFontRelease(fontRef);
    
    textLayer.string = @"坚持积累技术，积累和学习也许是目前最短改变自身现状的唯一捷径;";
    
}

@end
