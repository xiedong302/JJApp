//
//  JJTAFData.h
//  JJTAF
//
//  Created by xiedong on 2020/11/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJTAFData : NSObject

+ (NSData *)toZippedData:(NSData *)data;

+ (NSData *)toUnzippedData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
