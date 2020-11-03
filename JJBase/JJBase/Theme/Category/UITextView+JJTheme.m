//
//  UITextView+JJTheme.m
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "UITextView+JJTheme.h"
#import "UIView+JJTheme.h"
#import "JJThemeColor.h"

@implementation UITextView (JJTheme)

- (void)jjtheme_updateColors {
    [super jjtheme_updateColors];
    
    UIColor *color = self.textColor;
    
    if ([color isKindOfClass:JJThemeColor.class]) {
        self.textColor = color;
    }
}
@end
