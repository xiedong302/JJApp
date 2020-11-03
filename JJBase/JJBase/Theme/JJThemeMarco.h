//
//  JJThemeMarco.h
//  JJBase
//
//  Created by xiedong on 2020/9/29.
//  Copyright © 2020 xiedong. All rights reserved.
//

#ifndef JJThemeMarco_h
#define JJThemeMarco_h

#import <JJBase/JJThemeColor.h>
#import <JJBase/JJThemeImage.h>

#import <JJBase/JJBundleResourceMarco.h>

//MARK: - Color

#define JJTColor(name) ((UIColor *)[JJThemeColor colorWithModuleName:(JJR_SELF_BUNDLE) colorName:(name)])

#define JJTColorInModule(name, module) ((UIColor *)[JJThemeColor colorWithModuleName:(module) colorName:(name)])

//MARK: - Image

#define JJTImage(name) ((UIImage *)[JJThemeImage imageWithModuleName:(JJR_SELF_BUNDLE) imageName:(name) cacheable:YES])

#define JJTImageInModule(name, module) ((UIImage *)[JJThemeImage imageWithModuleName:(module) imageName:(name) cacheable:YES])

#define JJTImageNoCache(name) ((UIImage *)[JJThemeImage imageWithModuleName:(JJR_SELF_BUNDLE) imageName:(name) cacheable:NO])

#define JJTImageInModuleNoCache(name, module) ((UIImage *)[JJThemeImage imageWithModuleName:(module) imageName:(name) cacheable:NO])

#endif /* JJThemeMarco_h */

