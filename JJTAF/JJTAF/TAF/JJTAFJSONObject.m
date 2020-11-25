//
//  JJTAFJSONObject.m
//  JJTAF
//
//  Created by xiedong on 2020/11/23.
//

#import "JJTAFJSONObject.h"

@interface JJTAFJSONArray ()

@property (nonatomic, strong) NSArray *rootArray;

@end

@interface JJTAFJSONObject ()

@property (nonatomic, strong) NSDictionary *rootDict;

@end

//MARK: - JJTAFJSONBase
@implementation JJTAFJSONBase

- (JJTAFJSONObject *)toObject:(id)value {
    if (value && value != [NSNull null] && [value isKindOfClass:NSDictionary.class]) {
        JJTAFJSONObject *object = [[JJTAFJSONObject alloc] init];
        object.rootDict = value;
        
        return object;
    }
    
    return nil;
}

- (JJTAFJSONArray *)toArray:(id)value {
    if (value && value != [NSNull null] && [value isKindOfClass:NSArray.class]) {
        JJTAFJSONArray *object = [[JJTAFJSONArray alloc] init];
        object.rootArray = value;
        
        return object;
    }
    
    return nil;
}

- (NSString *)toString:(id)value {
    if (value && value != [NSNull null]) {
        if ([value isKindOfClass:NSString.class]) {
            return value;
        } else if ([value isKindOfClass:NSNumber.class]) {
            return [value stringValue];
        }
    }
    
    return nil;
}

- (BOOL)toBool:(id)value {
    if (value && value != [NSNull null]) {
        if ([value isKindOfClass:NSString.class]) {
            if ([value compare:@"true" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
                [value compare:@"yes" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                return YES;
            } else if ([value compare:@"false" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
                       [value compare:@"no" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                return NO;
            } else {
                return [value boolValue];
            }
        } else if ([value isKindOfClass:NSNumber.class]) {
            return [value boolValue];
        }
    }
    
    return NO;
}

- (int)toInt:(id)value {
    if (value && value != [NSNull null]) {
        if ([value isKindOfClass:NSString.class]) {
            return [value intValue];
        } else if ([value isKindOfClass:NSNumber.class]) {
            return [value intValue];
        }
    }
    
    return 0;
}

- (unsigned int)toUnsignedInt:(id)value {
    if (value && value != [NSNull null]) {
        if ([value isKindOfClass:NSString.class]) {
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            return [[nf numberFromString:value] unsignedIntValue];
        } else if ([value isKindOfClass:NSNumber.class]) {
            return [value intValue];
        }
    }
    
    return 0;
}

- (long)toLong:(id)value {
    if (value && value != [NSNull null]) {
        if ([value isKindOfClass:NSString.class]) {
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            return [[nf numberFromString:value] longValue];
        } else if ([value isKindOfClass:NSNumber.class]) {
            return [value intValue];
        }
    }
    
    return 0;
}

- (unsigned long)toUnsignedLong:(id)value {
    if (value && value != [NSNull null]) {
        if ([value isKindOfClass:NSString.class]) {
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            return [[nf numberFromString:value] unsignedLongValue];
        } else if ([value isKindOfClass:NSNumber.class]) {
            return [value intValue];
        }
    }
    
    return 0;
}

- (long long)toLongLong:(id)value {
    if (value && value != [NSNull null]) {
        if ([value isKindOfClass:NSString.class]) {
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            return [[nf numberFromString:value] longLongValue];
        } else if ([value isKindOfClass:NSNumber.class]) {
            return [value intValue];
        }
    }
    
    return 0;
}

- (unsigned long long)toUnsignedLongLong:(id)value {
    if (value && value != [NSNull null]) {
        if ([value isKindOfClass:NSString.class]) {
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            return [[nf numberFromString:value] unsignedLongLongValue];
        } else if ([value isKindOfClass:NSNumber.class]) {
            return [value intValue];
        }
    }
    
    return 0;
}

- (NSInteger)toInteger:(id)value {
    if (value && value != [NSNull null]) {
        if ([value isKindOfClass:NSString.class]) {
            return [value integerValue];
        } else if ([value isKindOfClass:NSNumber.class]) {
            return [value intValue];
        }
    }
    
    return 0;
}

- (NSUInteger)toUnsignedInteger:(id)value {
    if (value && value != [NSNull null]) {
        if ([value isKindOfClass:NSString.class]) {
            NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
            return [[nf numberFromString:value] unsignedIntegerValue];
        } else if ([value isKindOfClass:NSNumber.class]) {
            return [value intValue];
        }
    }
    
    return 0;
}

- (float)toFloat:(id)value {
    if (value && value != [NSNull null]) {
        if ([value isKindOfClass:NSString.class]) {
            return [value floatValue];
        } else if ([value isKindOfClass:NSNumber.class]) {
            return [value intValue];
        }
    }
    
    return 0.0f;
}

- (double)toDouble:(id)value {
    if (value && value != [NSNull null]) {
        if ([value isKindOfClass:NSString.class]) {
            return [value doubleValue];
        } else if ([value isKindOfClass:NSNumber.class]) {
            return [value intValue];
        }
    }
    
    return 0.0f;
}

@end

//MARK: - JJTAFJSONArray
@implementation JJTAFJSONArray

+ (instancetype)jsonArrayWithString:(NSString *)string {
    if (string && [string isKindOfClass:NSString.class]) {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        if (data) {
            NSError *error = nil;
            id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            if (!error && result && [result isKindOfClass:NSArray.class]) {
                JJTAFJSONArray *array = [[JJTAFJSONArray alloc] init];
                array.rootArray = result;
                
                return array;
            }
        }
    }
    
    return nil;
}

- (NSUInteger)count {
    return _rootArray.count;
}

- (NSArray *)array {
    return _rootArray;
}

- (JJTAFJSONObject *)objectAtIndex:(NSUInteger)index {
    if (index >= 0 && index < _rootArray.count) {
        id value = [_rootArray objectAtIndex:index];
        return [self toObject:value];
    }
    
    return nil;
}

- (JJTAFJSONArray *)arrayAtIndex:(NSUInteger)index {
    if (index >= 0 && index < _rootArray.count) {
        id value = [_rootArray objectAtIndex:index];
        return [self toArray:value];
    }
    
    return nil;
}

- (NSString *)stringAtIndex:(NSUInteger)index {
    if (index >= 0 && index < _rootArray.count) {
        id value = [_rootArray objectAtIndex:index];
        return [self toString:value];
    }
    
    return nil;
}

- (BOOL)boolAtIndex:(NSUInteger)index {
    if (index >= 0 && index < _rootArray.count) {
        id value = [_rootArray objectAtIndex:index];
        return [self toBool:value];
    }
    
    return NO;
}

- (int)intAtIndex:(NSUInteger)index {
    if (index >= 0 && index < _rootArray.count) {
        id value = [_rootArray objectAtIndex:index];
        return [self toInt:value];
    }
    
    return 0;
}

- (unsigned int)unsignedIntAtIndex:(NSUInteger)index {
    if (index >= 0 && index < _rootArray.count) {
        id value = [_rootArray objectAtIndex:index];
        return [self toUnsignedInt:value];
    }
    
    return 0;
}

- (long)longAtIndex:(NSUInteger)index {
    if (index >= 0 && index < _rootArray.count) {
        id value = [_rootArray objectAtIndex:index];
        return [self toLong:value];
    }
    
    return 0;
}

- (unsigned long)unsignedLongAtIndex:(NSUInteger)index {
    if (index >= 0 && index < _rootArray.count) {
        id value = [_rootArray objectAtIndex:index];
        return [self toUnsignedLong:value];
    }
    
    return 0;
}

- (long long)longLongAtIndex:(NSUInteger)index {
    if (index >= 0 && index < _rootArray.count) {
        id value = [_rootArray objectAtIndex:index];
        return [self toLongLong:value];
    }
    
    return 0;
}

- (unsigned long long)unsignedLongLongAtIndex:(NSUInteger)index {
    if (index >= 0 && index < _rootArray.count) {
        id value = [_rootArray objectAtIndex:index];
        return [self toUnsignedLongLong:value];
    }
    
    return 0;
}

- (NSInteger)integerAtIndex:(NSUInteger)index {
    if (index >= 0 && index < _rootArray.count) {
        id value = [_rootArray objectAtIndex:index];
        return [self toInteger:value];
    }
    
    return 0;
}

- (NSUInteger)unsignedIntegerAtIndex:(NSUInteger)index {
    if (index >= 0 && index < _rootArray.count) {
        id value = [_rootArray objectAtIndex:index];
        return [self toUnsignedInteger:value];
    }
    
    return 0;
}

- (float)floatAtIndex:(NSUInteger)index {
    if (index >= 0 && index < _rootArray.count) {
        id value = [_rootArray objectAtIndex:index];
        return [self toFloat:value];
    }
    
    return 0.0f;
}

- (double)doubleAtIndex:(NSUInteger)index {
    if (index >= 0 && index < _rootArray.count) {
        id value = [_rootArray objectAtIndex:index];
        return [self toDouble:value];
    }
    
    return 0.0f;
}

- (NSString *)description {
    return _rootArray.description;
}

@end

//MARK: - JJTAFJSONObject
@implementation JJTAFJSONObject

+ (instancetype)jsonObjectWithString:(NSString *)string {
    if (string && [string isKindOfClass:NSString.class]) {
        NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
        
        if (data) {
            NSError *error = nil;
            id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            if (!error && result && [result isKindOfClass:NSDictionary.class]) {
                JJTAFJSONObject *object = [[JJTAFJSONObject alloc] init];
                object.rootDict = result;
                
                return object;
            }
        }
    }
    
    return nil;
}

+ (instancetype)jsonObjectWithDictionary:(NSDictionary *)dict {
    if (dict && [dict isKindOfClass:NSDictionary.class]) {
        JJTAFJSONObject *object = [[JJTAFJSONObject alloc] init];
        object.rootDict = [dict copy];
        
        return object;
    }
    
    return nil;
}

- (NSUInteger)count {
    return _rootDict.count;
}

- (NSDictionary *)dictionary {
    return _rootDict;
}

- (JJTAFJSONObject *)objectForKey:(NSString *)key {
    if (key && key.length > 0) {
        id value = [_rootDict objectForKey:key];
        return [self toObject:value];
    }
    
    return nil;
}

- (JJTAFJSONArray *)arrayForKey:(NSString *)key {
    if (key && key.length > 0) {
        id value = [_rootDict objectForKey:key];
        return [self toArray:value];
    }
    
    return nil;
}

- (NSString *)stringForKey:(NSString *)key {
    if (key && key.length > 0) {
        id value = [_rootDict objectForKey:key];
        return [self toString:value];
    }
    return nil;
}

- (BOOL)boolForKey:(NSString *)key {
    if (key && key.length > 0) {
        id value = [_rootDict objectForKey:key];
        return [self toBool:value];
    }
    return NO;
}

- (int)intForKey:(NSString *)key {
    if (key && key.length > 0) {
        id value = [_rootDict objectForKey:key];
        return [self toInt:value];
    }
    return 0;
}

- (unsigned int)unsignedIntForKey:(NSString *)key {
    if (key && key.length > 0) {
        id value = [_rootDict objectForKey:key];
        return [self toUnsignedInt:value];
    }
    return 0;
}

- (long)longAForKey:(NSString *)key {
    if (key && key.length > 0) {
        id value = [_rootDict objectForKey:key];
        return [self toLong:value];
    }
    return 0;
}

- (unsigned long)unsignedLongForKey:(NSString *)key {
    if (key && key.length > 0) {
        id value = [_rootDict objectForKey:key];
        return [self toUnsignedLong:value];
    }
    return 0;
}

- (long long)longLongForKey:(NSString *)key {
    if (key && key.length > 0) {
        id value = [_rootDict objectForKey:key];
        return [self toLongLong:value];
    }
    return 0;
}

- (unsigned long long)unsignedLongLongForKey:(NSString *)key {
    if (key && key.length > 0) {
        id value = [_rootDict objectForKey:key];
        return [self toUnsignedLongLong:value];
    }
    return 0;
}

- (NSInteger)integerForKey:(NSString *)key {
    if (key && key.length > 0) {
        id value = [_rootDict objectForKey:key];
        return [self toInteger:value];
    }
    return 0;
}

- (NSUInteger)unsignedIntegerForKey:(NSString *)key {
    if (key && key.length > 0) {
        id value = [_rootDict objectForKey:key];
        return [self toUnsignedInteger:value];
    }
    return 0;
}

- (float)floatForKey:(NSString *)key {
    if (key && key.length > 0) {
        id value = [_rootDict objectForKey:key];
        return [self toFloat:value];
    }
    return 0.0f;
}

- (double)doubleForKey:(NSString *)key {
    if (key && key.length > 0) {
        id value = [_rootDict objectForKey:key];
        return [self toDouble:value];
    }
    return 0.0f;
}

- (NSString *)description {
    return _rootDict.description;
}

@end
