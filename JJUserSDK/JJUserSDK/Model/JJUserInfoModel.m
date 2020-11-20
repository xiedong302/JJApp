//
//  JJUserInfoModel.m
//  JJUserSDK
//
//  Created by xiedong on 2020/11/20.
//

#import "JJUserInfoModel.h"

@implementation JJUserInfoModel

- (id)copyWithZone:(NSZone *)zone {
    JJUserInfoModel *origin = self;
    
    JJUserInfoModel *newCopy = nil;
    
    if (origin) {
        newCopy = [[[JJUserInfoModel class] allocWithZone:zone] init];
        
        newCopy.uid = origin.uid;
        newCopy.nickName = origin.nickName;
        newCopy.sex = origin.sex;
        newCopy.phone = origin.phone;
        newCopy.birthday = origin.birthday;
        newCopy.headPic = origin.headPic;
        newCopy.remarks = origin.remarks;
        newCopy.province = origin.province;
        newCopy.city = origin.city;
    }
    
    return newCopy;
}
@end
