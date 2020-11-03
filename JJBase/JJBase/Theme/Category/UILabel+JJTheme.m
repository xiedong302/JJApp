//
//  UILabel+JJTheme.m
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "UILabel+JJTheme.h"
#import "UIView+JJTheme.h"
#import "JJThemeColor.h"

@implementation UILabel (JJTheme)

- (void)jjtheme_updateColors {
    [super jjtheme_updateColors];
    
    UIColor *textColor = self.textColor;
    
    if ([textColor isKindOfClass:JJThemeColor.class]) {
        // 解决换肤不实时更新的问题，可能是判断了color相等之后就直接rerun了
        self.textColor = nil;
        self.textColor = textColor;
    }
    
    UIColor *shadowColor = self.shadowColor;
    if ([shadowColor isKindOfClass:JJThemeColor.class]) {
        self.shadowColor = shadowColor;
    }
}
@end
