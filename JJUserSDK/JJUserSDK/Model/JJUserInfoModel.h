//
//  JJUserInfoModel.h
//  JJUserSDK
//
//  Created by xiedong on 2020/11/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JJUserInfoModel : NSObject <NSCopying>

@property (nonatomic, copy) NSString *uid;          // 用户名

@property (nonatomic, copy) NSString *nickName;     // 昵称

@property (nonatomic, copy) NSString *sex;          // 性别（1-男，2-女）

@property (nonatomic, copy) NSString *phone;        // 手机

@property (nonatomic, copy) NSString *birthday;     // 生日

@property (nonatomic, copy) NSString *headPic;      // 头像

@property (nonatomic, copy) NSString *remarks;      // 个人说明

@property (nonatomic, copy) NSString *province;     // 省份

@property (nonatomic, copy) NSString *city;         // 城市

@end

NS_ASSUME_NONNULL_END
