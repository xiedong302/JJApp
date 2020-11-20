//
//  JJUserSDKDBHelper.h
//  JJUserSDK
//
//  Created by xiedong on 2020/11/20.
//

#import <JJTAF/JJTAF.h>

@class JJUserInfoModel;
#define JJDatabaseUserInfoVersion 1

NS_ASSUME_NONNULL_BEGIN

@interface JJUserSDKDBHelper : JJTAFFMDBHelper

- (BOOL)updateUserDetailInfo:(JJUserInfoModel *)infoModel;

- (JJUserInfoModel *)getUserDetailInfo;

@end

NS_ASSUME_NONNULL_END
