//
//  JJLogMacro.h
//  JJBase
//
//  Created by xiedong on 2020/10/21.
//  Copyright © 2020 xiedong. All rights reserved.
//

#ifndef JJLogMacro_h
#define JJLogMacro_h

//MARK: Log
/**
 1. VA_ARGS是一个可变参数的宏，这个可变参数的宏是新的C99规范中新增的。宏前面加上##的作用在于，可变参数的个数为0 是，这里的##起到把前面多余的”，“去掉的作用，否则会编译出错
 2. FILE宏在预编译时会替换成当前的源文件名
 3. LINE宏在预编译时会替换成当前的行号
 4. FUNCTION宏在预编译时会替换成当前的函数名称
 
 eg:
 JJLog(@"JJLog");
 
 打印  2020-10-21 16:15:02.796649+0800 JJAppMain[18159:264422] JJLog
 
 JJDeBugLog(@"JJDeBugLog");
 
 打印 2020-10-21 16:15:02.796896+0800 JJAppMain[18159:264422] -[TestViewController viewDidLoad] [行号 21] JJDeBugLog
 
 JJAllLog(@"JJAllLog");
 
 打印 2020-10-21 16:15:02.797083+0800 JJAppMain[18159:264422] [文件名:/Users/xiedong/Â≠¶‰π†/AppÊû∂ÊûÑ/JJApp/JJAppMain/JJAppMain/TestViewController.m]
    [函数名:-[TestViewController viewDidLoad]]
    [行号:22]
    JJAllLog
 
 JJMyLog(@"JJMyLog");
 
 打印 [TestViewController.m]:[行号:23] JJMyLog
 
 */
#ifdef DEBUG
#define JJLog(...) NSLog(__VA_ARGS__)
#define JJDeBugLog(fmt, ...) NSLog((@"%s [行号 %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#define JJAllLog(fmt, ...) NSLog((@"[文件名:%s]\n [函数名:%s]\n [行号:%d]\n" fmt), __FILE__, __FUNCTION__, __LINE__, ##__VA_ARGS__)
#define JJMyLog(fmt, ...) fprintf(stderr, "[%s]:[行号:%d] %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],__LINE__,[[NSString stringWithFormat:fmt, ##__VA_ARGS__] UTF8String])
#else
#define JJLog(...)
#define JJDeBugLog(...)
#define JJAllLog(...)
#define JJMyLog(...)
#endif

#endif /* JJLogMacro_h */
