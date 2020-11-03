//
//  UIButton+JJTheme.m
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "UIButton+JJTheme.h"
#import "UIView+JJTheme.h"
#import "JJThemeColor.h"
#import "JJThemeImage.h"

@implementation UIButton (JJTheme)

- (NSArray *)jjtheme_states {
    //TODO: 不支持复合状态
    return @[
        @(UIControlStateNormal),
        @(UIControlStateHighlighted),
        @(UIControlStateDisabled),
        @(UIControlStateSelected),
        @(1 << 3)/*UIControlStateFocused*/
    ];
}

- (void)jjtheme_updateColors {
    [super jjtheme_updateColors];
    
    NSArray *states = [self jjtheme_states];
    UIColor *color;
    
    for (NSNumber *state in states) {
        color = [self titleColorForState:state.unsignedIntegerValue];
        if ([color isKindOfClass:JJThemeColor.class]) {
            [self setTitleColor:color forState:state.unsignedIntegerValue];
        }
        
        color = [self titleShadowColorForState:state.unsignedIntegerValue];
        if ([color isKindOfClass:JJThemeColor.class]) {
            [self setTitleShadowColor:color forState:state.unsignedIntegerValue];
        }
    }
}

- (void)jjtheme_updateImages {
    [super jjtheme_updateImages];
    
    NSArray *states = [self jjtheme_states];
    UIImage *image;
    
    for (NSNumber *state in states) {
        image = [self imageForState:state.unsignedIntegerValue];
        if ([image isKindOfClass:JJThemeImage.class]) {
            // 不copy的话无法生效， 内部应该做了判断
            [self setImage:[image copy] forState:state.unsignedIntegerValue];
        }
        
        image = [self backgroundImageForState:state.unsignedIntegerValue];
        if ([image isKindOfClass:JJThemeImage.class]) {
            // 不copy的话无法生效， 内部应该做了判断
            [self setBackgroundImage:[image copy] forState:state.unsignedIntegerValue];
        }
    }
}


@end
