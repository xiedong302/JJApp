//
//  JJHybridJSON.m
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/9.
//

#import "JJHybridJSON.h"
#import "JJHybridNull.h"

@implementation JJHybridJSON

+ (NSString *)arrayToJSON:(NSArray *)array {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:array options:0 error:&error];
    if (error) {
        JJLog(@"NSArray JSONString error : %@", error.userInfo.description);
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (NSString *)dictionaryToJSON:(NSDictionary *)dict {
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    if (error) {
        JJLog(@"NSDictionary JSONString error : %@", error.userInfo.description);
        return nil;
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

+ (id)toJSONObject:(NSString *)jsonStr {
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    if (error) {
        JJLog(@"NSString JSONString error : %@", error.userInfo.description);
        return nil;
    } else {
        if (object == [NSNull null]) {
            object = [JJHybridNull null];
        } else if ([object isKindOfClass:NSArray.class]) {
            object = [JJHybridJSON replaceNSNullFromArray:object];
        } else if ([object isKindOfClass:NSDictionary.class]) {
            object = [JJHybridJSON removelNSNullFromDict:object];
        }
    }
    
    return object;
}

+ (NSArray *)replaceNSNullFromArray:(NSArray *)array {
    if (IsValidateArray(array)) {
        NSMutableArray *temp = [NSMutableArray arrayWithCapacity:array.count];
        NSNull *fuckNull = [NSNull null];
        
        for (NSUInteger i = 0; i < array.count; ++i) {
            if (array[i] == fuckNull) {
                [temp addObject:[JJHybridNull null]];
            } else if ([array[i] isKindOfClass:NSArray.class]) {
                [temp addObject:[JJHybridJSON replaceNSNullFromArray:array[i]]];
            } else if ([array[i] isKindOfClass:NSDictionary.class]) {
                [temp addObject:[JJHybridJSON removelNSNullFromDict:array[i]]];
            } else {
                [temp addObject:array[i]];
            }
        }
        
        return [NSArray arrayWithArray:temp];
    }
    
    return array;
}

+ (NSDictionary *)removelNSNullFromDict:(NSDictionary *)dict {
    if (IsValidateDict(dict)) {
        NSMutableDictionary *temp = [NSMutableDictionary dictionaryWithCapacity:dict.count];
        NSNull *fuckNull = [NSNull null];
        
        for (id key in dict.allKeys) {
            id value = [dict objectForKey:key];
            
            if (value != fuckNull) {
                if ([value isKindOfClass:NSArray.class]) {
                    [temp setValue:[JJHybridJSON replaceNSNullFromArray:value] forKey:key];
                } else if ([value isKindOfClass:NSDictionary.class]) {
                    [temp setValue:[JJHybridJSON removelNSNullFromDict:value] forKey:key];
                } else {
                    [temp setValue:value forKey:key];
                }
            }
        }
        
        return [NSDictionary dictionaryWithDictionary:temp];
    }
    
    return dict;
}
@end
