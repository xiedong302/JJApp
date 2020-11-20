//
//  JJUserSDKDBManager.m
//  JJUserSDK
//
//  Created by xiedong on 2020/11/20.
//

#import "JJUserSDKDBManager.h"
#import "JJUserSDKDBHelper.h"

@implementation JJUserSDKDBManager

+ (JJUserSDKDBHelper *)getUserDBHelper {
    static JJUserSDKDBHelper *database = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        database = [[JJUserSDKDBHelper alloc] initWithName:@"database_user_info.db" version:JJDatabaseUserInfoVersion];
    });
    return database;
}
@end
