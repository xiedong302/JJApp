//
//  UIImageView+ImageLoader.h
//  JJBaseUI
//
//  Created by xiedong on 2020/9/24.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^JJImageLoaderCompletionBlock)(UIImage * _Nullable image, NSError * _Nullable error);

@interface UIImageView (ImageLoader)

- (void)jj_setImageWithUrlString:(nullable NSString *)urlString;

- (void)jj_setImageWithUrlString:(nullable NSString *)urlString
                placeholderImage:(nullable UIImage *)placeholder;

- (void)jj_setImageWithUrlString:(nullable NSString *)urlString
                placeholderImage:(nullable UIImage *)placeholder
                       completed:(nullable JJImageLoaderCompletionBlock)compltedBlock;

- (void)jj_setImageWithUrl:(nullable NSURL *)url;

- (void)jj_setImageWithUrl:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder;

- (void)jj_setImageWithUrl:(nullable NSURL *)url
          placeholderImage:(nullable UIImage *)placeholder
                 completed:(nullable JJImageLoaderCompletionBlock)compltedBlock;

@end

NS_ASSUME_NONNULL_END
