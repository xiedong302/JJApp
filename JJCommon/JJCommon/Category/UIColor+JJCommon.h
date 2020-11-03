//
//  UIColor+JJCommon.h
//  JJCommon
//
//  Created by xiedong on 2020/10/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (JJCommon)

// 品牌色
+ (UIColor *)jj_brandColor;

// 背景色
+ (UIColor *)jj_bkgColor;

// 内容背景色
+ (UIColor *)jj_contentBkgColor;

// 主文字色
+ (UIColor *)jj_textMajorColor;

// 次文字色
+ (UIColor *)jj_textMinorColor;

// 次文字色
+ (UIColor *)jj_textSecondary1Color;

// 次文字色
+ (UIColor *)jj_textSecondary2Color;

// 次文字色
+ (UIColor *)jj_textSecondary3Color;

// 分隔线色
+ (UIColor *)jj_splitColor;



@end

NS_ASSUME_NONNULL_END
