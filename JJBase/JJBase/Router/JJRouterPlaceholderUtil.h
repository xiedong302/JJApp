//
//  JJRouterPlaceholderUtil.h
//  JJBase
//
//  Created by xiedong on 2020/10/21.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJRouterPlaceholderUtil : NSObject

+ (BOOL)hasPlaceholder:(NSString *)originURL;

+ (NSString *)buildFullURL:(NSString *)originURL;

@end

NS_ASSUME_NONNULL_END
