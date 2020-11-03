//
//  UINavigationBar+JJTheme.m
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "UINavigationBar+JJTheme.h"
#import "UIView+JJTheme.h"
#import "JJThemeColor.h"

@implementation UINavigationBar (JJTheme)

- (void)jjtheme_updateColors {
    [super jjtheme_updateColors];
    
    UIColor *color = self.barTintColor;
    
    if ([color isKindOfClass:JJThemeColor.class]) {
        self.barTintColor = color;
    }
}
@end
