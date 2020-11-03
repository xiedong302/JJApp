//
//  CGGradientView1.m
//  JJDraw
//
//  Created by xiedong on 2020/10/30.
//

#import "CGGradientView1.h"

@interface CGGradientView1()

@property (nonatomic, strong) UILabel *label;
@end

@implementation CGGradientView1

- (void)setupView {
    {
        UILabel *label = [UILabel new];
        label.text = @"坚持学习，慢慢积累";
        [self addSubview:label];
        self.label = label;
    }
}

- (void)setupConstraints {
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
    }];
}

- (void)viewDrawRect:(CGRect)rect context:(CGContextRef)ctx {
    [super viewDrawRect:rect context:ctx];
    
    self.label.textColor = [self gradientColorWithColors:@[UIColor.redColor, UIColor.blueColor, UIColor.brownColor] size:self.label.bounds.size];
    
}
- (UIColor *)gradientColorWithColors:(NSArray<UIColor *> *)colors size:(CGSize)size {
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:colors.count];
    for (UIColor *color in colors) {
        [array addObject:(__bridge id)color.CGColor];
    }
    
    UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)array, NULL);
    CGPoint startPoint = CGPointMake(0, 0);
    CGPoint endPoint = CGPointMake(size.width, size.height);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    
    UIGraphicsEndImageContext();
    
    UIColor *color = [UIColor colorWithPatternImage:newImage];
    return color;
}

@end
