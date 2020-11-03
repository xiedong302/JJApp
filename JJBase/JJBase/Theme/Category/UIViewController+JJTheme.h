//
//  UIViewController+JJTheme.h
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (JJTheme)

@property (nonatomic, copy) NSString *jjtheme_resourceSuffix;

- (void)jjtheme_themeDidUpdate;

@end

NS_ASSUME_NONNULL_END
