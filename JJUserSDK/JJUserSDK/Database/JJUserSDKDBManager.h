//
//  JJUserSDKDBManager.h
//  JJUserSDK
//
//  Created by xiedong on 2020/11/20.
//

#import <Foundation/Foundation.h>

@class JJUserSDKDBHelper;

NS_ASSUME_NONNULL_BEGIN

@interface JJUserSDKDBManager : NSObject

+ (JJUserSDKDBHelper *)getUserDBHelper;

@end

NS_ASSUME_NONNULL_END
