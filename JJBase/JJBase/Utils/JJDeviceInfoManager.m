//
//  JJDeviceInfoManager.m
//  JJBase
//
//  Created by xiedong on 2020/9/27.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJDeviceInfoManager.h"
#import <UIKit/UIKit.h>
#import "sys/utsname.h"

static NSString * const kJJAppLaunchTimeKey = @"JJAppLaunchTimeKey";

@implementation JJDeviceInfoManager

/**
 build号
 */
+ (NSString *)jj_appBuildVersion {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    return [infoDict objectForKey:@"CFBundleVersion"];
}

/**
 版本号
 */
+ (NSString *)jj_appShortVersion {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    return [infoDict objectForKey:@"CFBundleShortVersionString"];
}

/**
 app名字
 */
+ (NSString *)jj_appName {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    return [infoDict objectForKey:@"CFBundleDisplayName"];
}

/**
 最后一次打开app的时间
 */
+ (NSString *)jj_appLastLaunchTime {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kJJAppLaunchTimeKey];;
}

/**
 更新app打开的时间
 */
+ (void)jj_appUpdateLaunchTime {
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy年MM月dd日 HH:mm:ss"];
    NSString *dateStr = [format stringFromDate:[NSDate date]];
    [[NSUserDefaults standardUserDefaults] setObject:dateStr forKey:kJJAppLaunchTimeKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 系统版本号
 */
+ (NSString *)jj_deviceSystemVersion {
    return [UIDevice currentDevice].systemVersion;
}

/**
 设备名称
 */
+ (NSString *)jj_deviceName {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    //模拟器
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";
    
    // iPhone https://www.theiphonewiki.com/wiki/List_of_iPhones
    
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4 (GSM)";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4 (GSM Rev A)";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4 (CDMA)";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (Global)";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (Global)";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (Global)";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE(1st generation)";
    
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7 (GSM)";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"iPhone 7 (Global)";
    
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus (GSM)";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus (Global)";
    
    if ([deviceString isEqualToString:@"iPhone10,1"])    return @"iPhone 8 (GSM)";
    if ([deviceString isEqualToString:@"iPhone10,4"])    return @"iPhone 8 (Global)";
    
    if ([deviceString isEqualToString:@"iPhone10,2"])    return @"iPhone 8 Plus (GSM)";
    if ([deviceString isEqualToString:@"iPhone10,5"])    return @"iPhone 8 Plus (Global)";
    
    if ([deviceString isEqualToString:@"iPhone10,3"])    return @"iPhone X (GSM)";
    if ([deviceString isEqualToString:@"iPhone10,6"])    return @"iPhone X (Global)";
    
    if ([deviceString isEqualToString:@"iPhone11,8"])    return @"iPhone XR";
    if ([deviceString isEqualToString:@"iPhone11,2"])    return @"iPhone XS";
    
    if ([deviceString isEqualToString:@"iPhone11,4"])    return @"iPhone XS Max (GSM)";
    if ([deviceString isEqualToString:@"iPhone11,6"])    return @"iPhone XS Max (Global)";
    
    if ([deviceString isEqualToString:@"iPhone12,1"])    return @"iPhone 11";
    if ([deviceString isEqualToString:@"iPhone12,3"])    return @"iPhone 11 Pro";
    if ([deviceString isEqualToString:@"iPhone12,5"])    return @"iPhone 11 Pro Max";
    
    if ([deviceString isEqualToString:@"iPhone12,8"])    return @"iPhone SE(2nd generation)";
    
    if ([deviceString isEqualToString:@"iPhone13,1"])    return @"iPhone 12 mini";
    if ([deviceString isEqualToString:@"iPhone13,2"])    return @"iPhone 12";
    if ([deviceString isEqualToString:@"iPhone13,3"])    return @"iPhone 12 Pro";
    if ([deviceString isEqualToString:@"iPhone13,4"])    return @"iPhone 12 Pro Max";
    
    // iPad https://www.theiphonewiki.com/wiki/List_of_iPads
    
    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad 1G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2 (Rev A)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3 (Global)";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (Global)";
    if ([deviceString isEqualToString:@"iPad6,11"])      return @"iPad 5";
    if ([deviceString isEqualToString:@"iPad6,12"])      return @"iPad 5";
    if ([deviceString isEqualToString:@"iPad7,5"])      return @"iPad 6";
    if ([deviceString isEqualToString:@"iPad7,6"])      return @"iPad 6";
    if ([deviceString isEqualToString:@"iPad7,11"])      return @"iPad 7";
    if ([deviceString isEqualToString:@"iPad7,12"])      return @"iPad 7";
    if ([deviceString isEqualToString:@"iPad11,6"])      return @"iPad 8";
    if ([deviceString isEqualToString:@"iPad11,7"])      return @"iPad 8";
    
    // iPad Air https://www.theiphonewiki.com/wiki/List_of_iPad_Airs
    
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,3"])      return @"iPad Air";
    
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air2";
    
    if ([deviceString isEqualToString:@"iPad11,3"])      return @"iPad Air3";
    if ([deviceString isEqualToString:@"iPad11,4"])      return @"iPad Air3";
    
    if ([deviceString isEqualToString:@"iPad13,1"])      return @"iPad Air4";
    if ([deviceString isEqualToString:@"iPad13,2"])      return @"iPad Air4";
    
    // iPad Pro https://www.theiphonewiki.com/wiki/List_of_iPad_Pros
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro (12.9-inch)";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro (12.9-inch)";
    
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro (9.7-inch)";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro (9.7-inch)";
    
    if ([deviceString isEqualToString:@"iPad7,1"])      return @"iPad Pro2 (12.9-inch)";
    if ([deviceString isEqualToString:@"iPad7,2"])      return @"iPad Pro2 (12.9-inch)";
    
    if ([deviceString isEqualToString:@"iPad7,3"])      return @"iPad Pro (10.5-inch)";
    if ([deviceString isEqualToString:@"iPad7,4"])      return @"iPad Pro (10.5-inch)";
    
    if ([deviceString isEqualToString:@"iPad8,1"])      return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,2"])      return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,3"])      return @"iPad Pro (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,4"])      return @"iPad Pro (11-inch)";
    
    if ([deviceString isEqualToString:@"iPad8,5"])      return @"iPad Pro3 (12.9-inch)";
    if ([deviceString isEqualToString:@"iPad8,6"])      return @"iPad Pro3 (12.9-inch)";
    if ([deviceString isEqualToString:@"iPad8,7"])      return @"iPad Pro3 (12.9-inch)";
    if ([deviceString isEqualToString:@"iPad8,8"])      return @"iPad Pro3 (12.9-inch)";
    
    if ([deviceString isEqualToString:@"iPad8,9"])      return @"iPad Pro2 (11-inch)";
    if ([deviceString isEqualToString:@"iPad8,10"])      return @"iPad Pro2 (11-inch)";
    
    if ([deviceString isEqualToString:@"iPad8,11"])      return @"iPad Pro4 (12.9-inch)";
    if ([deviceString isEqualToString:@"iPad8,12"])      return @"iPad Pro4 (12.9-inch)";
    
    // iPad mini https://www.theiphonewiki.com/wiki/List_of_iPad_minis
    
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad mini (GSM)";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad mini (Global)";
    
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad mini2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad mini2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad mini2 (Global)";
    
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad mini3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad mini3 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad mini3 (Global)";
    
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad mini4";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad mini4";
    
    if ([deviceString isEqualToString:@"iPad11,1"])      return @"iPad mini5";
    if ([deviceString isEqualToString:@"iPad11,2"])      return @"iPad mini5";
    
    // iPod touch https://www.theiphonewiki.com/wiki/List_of_iPod_touches
    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod touch1";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod touch2";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod touch3";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod touch4";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod touch5";
    if ([deviceString isEqualToString:@"iPod7,1"])      return @"iPod touch6";
    if ([deviceString isEqualToString:@"iPod9,1"])      return @"iPod touch7";
    
    return deviceString;;
}

/**
 判断设备时候是刘海屏
 */
+ (BOOL)jj_deviceIsIphoneXStyle {
    BOOL isIphoneX = NO;
    
    if (UIDevice.currentDevice.userInterfaceIdiom != UIUserInterfaceIdiomPhone) {
        //判断是否是手机或者ipad
        return isIphoneX;
    }
    
    if (@available(iOS 11.0, *)) {
        UIWindow *mainWindow = UIApplication.sharedApplication.delegate.window;
    
        if (mainWindow.safeAreaInsets.bottom > 0.0) {
            isIphoneX = YES;
        }
    }
    
    return isIphoneX;
}
@end
