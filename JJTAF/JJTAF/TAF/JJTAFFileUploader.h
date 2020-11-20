//
//  JJTAFFileUploader.h
//  JJTAF
//
//  Created by xiedong on 2020/11/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJTAFFileUploader : NSObject

+ (void)upload:(NSString *)fileName path:(NSString *)path uploadPath:(NSString *)uploadPath;

+ (void)uploadSync:(NSString *)fileName path:(NSString *)path uploadPath:(NSString *)uploadPath;

@end

NS_ASSUME_NONNULL_END
