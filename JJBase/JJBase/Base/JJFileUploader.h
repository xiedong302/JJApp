//
//  JJFileUploader.h
//  JJBase
//
//  Created by xiedong on 2020/10/23.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJFileUploader : NSObject

+ (void)upload:(NSString *)fileName path:(NSString *)path uploadPath:(NSString *)uploadPath;

+ (void)uploadSync:(NSString *)fileName path:(NSString *)path uploadPath:(NSString *)uploadPath;

@end

NS_ASSUME_NONNULL_END
