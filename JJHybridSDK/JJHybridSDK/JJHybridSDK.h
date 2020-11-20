//
//  JJHybridSDK.h
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/6.
//

/**
 *          JJHybridView  对外提供使用
 *          URL地址通过中间者      JJHybridEngin   来让   JJHybridWebView 加载
 *          JJHybridPlugin     通过   JJHybridEngin   来让  JJHybridPluginManager 管理plugin
 *          需要执行的js 通过 JJHybridPlugin  到 JJHybridPluginManager 到 JJHybridEngin 到  JJHybridWebView 去执行
 *
 *          JJHybridPlugin
 *          JJHybridPluginManager
 *          JJHybridEngin
 *          JJHybridWebView
 */
#import <Foundation/Foundation.h>

//! Project version number for JJHybridSDK.
FOUNDATION_EXPORT double JJHybridSDKVersionNumber;

//! Project version string for JJHybridSDK.
FOUNDATION_EXPORT const unsigned char JJHybridSDKVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <JJHybridSDK/PublicHeader.h>
#import <JJHybridSDK/JJHybridView.h>
#import <JJHybridSDK/JJHybridPlugin.h>
#import <JJHybridSDK/JJHybridUser.h>

