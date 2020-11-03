//
//  UIImage+Color.m
//  JJBaseUI
//
//  Created by xiedong on 2020/9/24.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)

+ (instancetype)jj_imageWithColor:(UIColor *)color {
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
