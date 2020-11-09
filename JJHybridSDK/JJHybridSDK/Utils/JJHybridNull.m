//
//  JJHybridNull.m
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/9.
//

#import "JJHybridNull.h"

@implementation JJHybridNull

+ (JJHybridNull *)null {
    static JJHybridNull *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JJHybridNull alloc] init];
    });
    return instance;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    // look up method sinmature
    NSMethodSignature *signature = [super methodSignatureForSelector:aSelector];
    if (!signature) {
        for (Class someClass in @[NSString.class,
                                NSMutableString.class,
                                NSNumber.class,
                                NSData.class,
                                NSArray.class,
                                NSMutableArray.class,
                                NSSet.class,
                                NSMutableSet.class,
                                NSDictionary.class,
                                NSMutableDictionary.class,
                                NSDate.class,
                                NSCalendar.class]) {
            @try {
                if ([someClass instancesRespondToSelector:aSelector]) {
                    signature = [someClass instanceMethodSignatureForSelector:aSelector];
                    break;
                }
            } @catch (__unused NSException *exception) {
                
            }
        }
    }
    
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    anInvocation.target = nil;
    [anInvocation invoke];
}

- (NSString *)description {
    return @"JJHybridNull";
}
@end
