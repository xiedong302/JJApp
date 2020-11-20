//
//  JJTAFLogger.h
//  JJTAF
//
//  Created by xiedong on 2020/11/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT void JJTAFLog(NSString *identifier, NSString *format, ...) NS_FORMAT_FUNCTION(2, 3) NS_NO_TAIL_CALL;
FOUNDATION_EXPORT void JJTAFLogFile(NSString *identifier, NSString *format, ...) NS_FORMAT_FUNCTION(2, 3) NS_NO_TAIL_CALL;

@interface JJTAFLogger : NSObject

+ (void)logForIdentifier:(NSString *)identifier message:(NSString *)msg toFile:(BOOL)toFile;

+ (void)uploadForIdentifier:(NSString *)identifier;

+ (NSString *)logFilePathForIdentifier:(NSString *)identifier;

+ (void)setDebug:(BOOL)debuggable;

@end

NS_ASSUME_NONNULL_END
