//
//  JJRouterPlaceholderUtil.m
//  JJBase
//
//  Created by xiedong on 2020/10/21.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJRouterPlaceholderUtil.h"
#import <AdSupport/AdSupport.h>

@implementation JJRouterPlaceholderUtil

+ (BOOL)hasPlaceholder:(NSString *)originURL {
    if (IsValidateString(originURL)) {
        NSURLComponents *components = [NSURLComponents componentsWithString:originURL];
        
        if (components && components.queryItems) {
            for (NSURLQueryItem *item in components.queryItems) {
                if ([item.value isEqualToString:@"${jj_imei}"] ||
                    [item.value isEqualToString:@"${jj_mac}"] ||
                    [item.value isEqualToString:@"${jj_phone}"] ||
                    [item.value isEqualToString:@"${jj_sysver}"] ||
                    [item.value isEqualToString:@"${jj_appver}"]) {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

+ (NSString *)buildFullURL:(NSString *)originURL {
    if (originURL) {
        NSURLComponents *components = [NSURLComponents componentsWithString:originURL];
        
        if (components && components.queryItems) {
            NSMutableArray *newItems = [NSMutableArray arrayWithCapacity:components.queryItems.count];
            
            for (NSURLQueryItem *item in components.queryItems) {
                if ([item.value isEqualToString:@"${jj_imei}"]) {
                    [newItems addObject:[NSURLQueryItem queryItemWithName:item.name value:[self IDFV]]];
                }
                else if ([item.value isEqualToString:@"${jj_mac}"]) {
                    [newItems addObject:[NSURLQueryItem queryItemWithName:item.name value:[self IDFA]]];
                }
                else if ([item.value isEqualToString:@"${jj_phone}"]) {
                    [newItems addObject:[NSURLQueryItem queryItemWithName:item.name value:[self DeviceModel]]];
                }
                else if ([item.value isEqualToString:@"${jj_sysver}"]) {
                    [newItems addObject:[NSURLQueryItem queryItemWithName:item.name value:[self SysVersionName]]];
                }
                else if ([item.value isEqualToString:@"${jj_appver}"]) {
                    [newItems addObject:[NSURLQueryItem queryItemWithName:item.name value:[self AppVersionName]]];
                }
            }
            
            components.queryItems = newItems;
            NSURL *URL = [components URL];
            
            if (URL) {
                return [URL absoluteString];
            }
        }
    }
    return originURL;
}

+ (NSString *)DeviceModel {
    NSString *model = [[UIDevice currentDevice] model];
    
    if (model) {
        return [model stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    return nil;
}

+ (NSString *)SysVersionName {
    return [[UIDevice currentDevice] systemVersion];
}

+ (NSString *)AppVersionName {
    NSString *version = [JJDeviceInfoManager jj_appShortVersion];
    
    if (version) {
        return [version stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    return nil;
}

+ (NSString *)IDFV {
    NSUUID *uuid = [UIDevice currentDevice].identifierForVendor;
    
    if (uuid) {
        return [uuid UUIDString];
    }
    return nil;
}

+ (NSString *)IDFA {
    NSUUID *uuid = [ASIdentifierManager sharedManager].advertisingIdentifier;
    
    if (uuid) {
        return [uuid UUIDString];
    }
    return nil;
}

@end
