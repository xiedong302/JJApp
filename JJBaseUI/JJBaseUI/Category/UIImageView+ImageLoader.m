//
//  UIImageView+ImageLoader.m
//  JJBaseUI
//
//  Created by xiedong on 2020/9/24.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "UIImageView+ImageLoader.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation UIImageView (ImageLoader)

- (void)jj_setImageWithUrlString:(NSString *)urlString {
    [self jj_setImageWithUrlString:urlString placeholderImage:nil completed:nil];
}

- (void)jj_setImageWithUrlString:(NSString *)urlString placeholderImage:(UIImage *)placeholder {
    [self jj_setImageWithUrlString:urlString placeholderImage:placeholder completed:nil];
}

- (void)jj_setImageWithUrlString:(NSString *)urlString placeholderImage:(UIImage *)placeholder completed:(JJImageLoaderCompletionBlock)compltedBlock {
    [self jj_setImageWithUrl:[NSURL URLWithString:urlString] placeholderImage:placeholder completed:compltedBlock];
}

- (void)jj_setImageWithUrl:(NSURL *)url {
    [self jj_setImageWithUrl:url placeholderImage:nil completed:nil];
}

- (void)jj_setImageWithUrl:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self jj_setImageWithUrl:url placeholderImage:placeholder completed:nil];
}

- (void)jj_setImageWithUrl:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(JJImageLoaderCompletionBlock)compltedBlock {
    
    if ([self respondsToSelector:@selector(sd_setImageWithURL:placeholderImage:options:completed:)]) {
        SDWebImageOptions options = SDWebImageAllowInvalidSSLCertificates;
        
        [self sd_setImageWithURL:url placeholderImage:placeholder options:options completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (compltedBlock) {
                compltedBlock(image, error);
            }
        }];
    } else {
        //TODO: 自己实现下载 搞起来
    }
}

@end
