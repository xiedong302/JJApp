//
//  UIColor+JJCommon.m
//  JJCommon
//
//  Created by xiedong on 2020/10/24.
//

#import "UIColor+JJCommon.h"

@implementation UIColor (JJCommon)

// 品牌色
+ (UIColor *)jj_brandColor {
    return JJTColor(@"jj_common_brand_color");
}

// 背景色
+ (UIColor *)jj_bkgColor {
    return JJTColor(@"jj_common_bkg_color");
}

// 内容背景色
+ (UIColor *)jj_contentBkgColor {
    return JJTColor(@"jj_common_content_bkg_color");
}

// 主文字色
+ (UIColor *)jj_textMajorColor {
    return JJTColor(@"jj_common_text_major_color");
}

// 次文字色
+ (UIColor *)jj_textMinorColor {
    return JJTColor(@"jj_common_text_minor_color");
}

// 次文字色
+ (UIColor *)jj_textSecondary1Color {
    return JJTColor(@"jj_common_text_secondary1_color");
}

// 次文字色
+ (UIColor *)jj_textSecondary2Color {
    return JJTColor(@"jj_common_text_secondary2_color");
}

// 次文字色
+ (UIColor *)jj_textSecondary3Color {
    return JJTColor(@"jj_common_text_secondary3_color");
}

// 分隔线色
+ (UIColor *)jj_splitColor {
    return JJTColor(@"jj_common_split_color");
}


@end
