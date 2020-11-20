//
//  JJUserService.h
//  JJUserSDK
//
//  Created by xiedong on 2020/11/20.
//

#import <Foundation/Foundation.h>

@class JJUserInfoModel;
NS_ASSUME_NONNULL_BEGIN

@interface JJUserService : NSObject

@property (nonatomic, strong) JJUserInfoModel *userInfoData;

+ (instancetype)sharedInstance;

/**
 * 初始化用户状态： 用来自动登录
 */
- (void)initUserStatus;

@end

NS_ASSUME_NONNULL_END
