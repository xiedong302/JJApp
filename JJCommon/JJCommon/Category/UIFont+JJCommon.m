//
//  UIFont+JJCommon.m
//  JJCommon
//
//  Created by xiedong on 2020/10/24.
//

#import "UIFont+JJCommon.h"

@implementation UIFont (JJCommon)

+ (UIFont *)jj_fontOfSize:(CGFloat)size {
    return [UIFont systemFontOfSize:size];
}

+ (UIFont *)jj_boldFontOfSize:(CGFloat)size {
    return [UIFont boldSystemFontOfSize:size];
}
@end
