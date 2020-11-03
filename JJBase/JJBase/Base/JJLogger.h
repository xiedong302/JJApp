//
//  JJLogger.h
//  JJBase
//
//  Created by xiedong on 2020/10/22.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT void JJTagLog(NSString *identifier, NSString *format, ...) NS_FORMAT_FUNCTION(2, 3) NS_NO_TAIL_CALL;
FOUNDATION_EXPORT void JJTagLogFile(NSString *identifier, NSString *format, ...) NS_FORMAT_FUNCTION(2, 3) NS_NO_TAIL_CALL;

@interface JJLogger : NSObject

+ (void)logForIdentifier:(NSString *)identifier message:(NSString *)msg toFile:(BOOL)toFile;

+ (void)uploadForIdentifier:(NSString *)identifier;

+ (NSString *)logFilePathForIdentifier:(NSString *)identifier;

+ (void)setDebug:(BOOL)debuggable;

@end

NS_ASSUME_NONNULL_END
