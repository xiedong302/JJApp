//
//  JJNSData.h
//  JJBase
//
//  Created by xiedong on 2020/10/23.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJNSData : NSObject

+ (NSData *)toZippedData:(NSData *)data;

+ (NSData *)toUnzippedData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
