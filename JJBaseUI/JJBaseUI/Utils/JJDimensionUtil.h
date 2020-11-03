//
//  JJDimensionUtil.h
//  JJBaseUI
//
//  Created by xiedong on 2020/9/24.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define JJWidth(width) ([JJDimensionUtil scaleWidth:width])
#define JJHeight(height) ([JJDimensionUtil scaleHeight:height])

@interface JJDimensionUtil : NSObject

+ (CGFloat)scaleWidth:(CGFloat)width;

+ (CGFloat)scaleHeight:(CGFloat)height;

@end

NS_ASSUME_NONNULL_END
