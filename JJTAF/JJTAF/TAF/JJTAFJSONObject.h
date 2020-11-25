//
//  JJTAFJSONObject.h
//  JJTAF
//
//  Created by xiedong on 2020/11/23.
//

#import <Foundation/Foundation.h>

@class JJTAFJSONArray;
@class JJTAFJSONObject;

NS_ASSUME_NONNULL_BEGIN

@interface JJTAFJSONBase : NSObject

@end

@interface JJTAFJSONArray : JJTAFJSONBase

@property (nonatomic, readonly) NSUInteger count;

@property (nonatomic, readonly) NSArray *array;

+ (instancetype)jsonArrayWithString:(NSString *)string;

- (JJTAFJSONObject *)objectAtIndex:(NSUInteger)index;

- (JJTAFJSONArray *)arrayAtIndex:(NSUInteger)index;

- (NSString *)stringAtIndex:(NSUInteger)index;

- (BOOL)boolAtIndex:(NSUInteger)index;

- (int)intAtIndex:(NSUInteger)index;

- (unsigned int)unsignedIntAtIndex:(NSUInteger)index;

- (long)longAtIndex:(NSUInteger)index;

- (unsigned long)unsignedLongAtIndex:(NSUInteger)index;

- (long long)longLongAtIndex:(NSUInteger)index;

- (unsigned long long)unsignedLongLongAtIndex:(NSUInteger)index;

- (NSInteger)integerAtIndex:(NSUInteger)index;

- (NSUInteger)unsignedIntegerAtIndex:(NSUInteger)index;

- (float)floatAtIndex:(NSUInteger)index;

- (double)doubleAtIndex:(NSUInteger)index;

@end

@interface JJTAFJSONObject : JJTAFJSONBase

@property (nonatomic, readonly) NSUInteger count;

@property (nonatomic, readonly) NSDictionary *dictionary;

+ (instancetype)jsonObjectWithString:(NSString *)string;

+ (instancetype)jsonObjectWithDictionary:(NSDictionary *)dict;

- (JJTAFJSONObject *)objectForKey:(NSString *)key;

- (JJTAFJSONArray *)arrayForKey:(NSString *)key;

- (NSString *)stringForKey:(NSString *)key;

- (BOOL)boolForKey:(NSString *)key;

- (int)intForKey:(NSString *)key;

- (unsigned int)unsignedIntForKey:(NSString *)key;

- (long)longAForKey:(NSString *)key;

- (unsigned long)unsignedLongForKey:(NSString *)key;

- (long long)longLongForKey:(NSString *)key;

- (unsigned long long)unsignedLongLongForKey:(NSString *)key;

- (NSInteger)integerForKey:(NSString *)key;

- (NSUInteger)unsignedIntegerForKey:(NSString *)key;

- (float)floatForKey:(NSString *)key;

- (double)doubleForKey:(NSString *)key;

@end


NS_ASSUME_NONNULL_END
