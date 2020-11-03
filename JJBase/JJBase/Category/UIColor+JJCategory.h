//
//  UIColor+JJCategory.h
//  JJBase
//
//  Created by xiedong on 2020/9/27.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (JJCategory)

/**
 @param hexValue 0x 或者 # 开头的，支持 6位 或者 带透明度的8位
 @return UIColor
 */
+ (UIColor *)jj_colorWithHexValue:(NSString *)hexValue;

/**
 @return 返回十六进制颜色值
 */
- (NSString *)jj_HexValue;
@end

NS_ASSUME_NONNULL_END
