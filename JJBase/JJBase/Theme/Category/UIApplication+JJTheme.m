//
//  UIApplication+JJTheme.m
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "UIApplication+JJTheme.h"
#import "UIWindow+JJTheme.h"

@implementation UIApplication (JJTheme)

- (void)jjtheme_themeDidUpdate {
    for (UIWindow *window in self.windows) {
        [window jjtheme_windowThemeDidUpdate];
    }
}
@end
