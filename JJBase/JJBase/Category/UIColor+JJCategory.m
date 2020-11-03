//
//  UIColor+JJCategory.m
//  JJBase
//
//  Created by xiedong on 2020/9/27.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "UIColor+JJCategory.h"

@implementation UIColor (JJCategory)

+ (UIColor *)jj_colorWithHexValue:(NSString *)hexValue {
    if (!hexValue || hexValue.length < 6) return nil;
    
    //默认进来的颜色是合法的
    NSString *cString = [hexValue stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].uppercaseString;
    
    if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    
    if (cString.length < 6) return nil;
    
    unsigned int a,r,g,b;
    NSRange range = NSMakeRange(0, 2);
    if (cString.length == 8) {
        NSString *aStr = [cString substringWithRange:range];
        
        range.location += 2;
        NSString *rStr = [cString substringWithRange:range];
        
        range.location += 2;
        NSString *gStr = [cString substringWithRange:range];
        
        range.location += 2;
        NSString *bStr = [cString substringWithRange:range];
        
        [[NSScanner scannerWithString:aStr] scanHexInt:&a];
        [[NSScanner scannerWithString:rStr] scanHexInt:&r];
        [[NSScanner scannerWithString:gStr] scanHexInt:&g];
        [[NSScanner scannerWithString:bStr] scanHexInt:&b];
        
        return [UIColor colorWithRed:(r / 255.0f) green:(g / 255.0f) blue:(b / 255.0f) alpha:(a / 255.0f)];
    }
    else {
        NSString *rStr = [cString substringWithRange:range];
        
        range.location += 2;
        NSString *gStr = [cString substringWithRange:range];
        
        range.location += 2;
        NSString *bStr = [cString substringWithRange:range];
        
        [[NSScanner scannerWithString:rStr] scanHexInt:&r];
        [[NSScanner scannerWithString:gStr] scanHexInt:&g];
        [[NSScanner scannerWithString:bStr] scanHexInt:&b];
        
        return [UIColor colorWithRed:(r / 255.0f) green:(g / 255.0f) blue:(b / 255.0f) alpha:1.0f];
    }
}

- (NSString *)jj_HexValue {
    size_t cpts = CGColorGetNumberOfComponents(self.CGColor);
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    if (cpts == 4) {
        CGFloat a = components[3];
        return  [NSString stringWithFormat:@"%02lX%02lX%02lX%02lX",lroundf(a * 255),lroundf(r * 255),lroundf(g * 255),lroundf(b * 255)];
    }
    else {
        return  [NSString stringWithFormat:@"%02lX%02lX%02lX",lroundf(r * 255),lroundf(g * 255),lroundf(b * 255)];
    }
}
@end
