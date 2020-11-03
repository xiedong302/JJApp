//
//  UIView+JJTheme.h
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (JJTheme)

@property (nonatomic, copy, nullable) UIColor *jjtheme_backgroundColor;

@property (nonatomic, copy) NSString *jjtheme_resourceSuffix;

- (void)jjtheme_themeDidUpdate NS_REQUIRES_SUPER;

- (void)jjtheme_updateColors NS_REQUIRES_SUPER;

- (void)jjtheme_updateImages NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
