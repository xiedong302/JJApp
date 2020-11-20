//
//  JJUserManager.m
//  JJUserSDK
//
//  Created by xiedong on 2020/11/20.
//

#import "JJUserManager.h"
#import "JJUserService.h"

@implementation JJUserManager

+ (void)autoLogin {
    [[JJUserService sharedInstance] initUserStatus];
}
@end
