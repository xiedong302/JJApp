//
//  JJHybridJSON.h
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJHybridJSON : NSObject

+ (NSString *)arrayToJSON:(NSArray *)array;

+ (NSString *)dictionaryToJSON:(NSDictionary *)dict;

+ (id)toJSONObject:(NSString *)jsonStr;
@end

NS_ASSUME_NONNULL_END
