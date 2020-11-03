//
//  JJBundleResourceMarco.h
//  JJBase
//
//  Created by xiedong on 2020/9/28.
//  Copyright © 2020 xiedong. All rights reserved.
//

#ifndef JJBundleResourceMarco_h
#define JJBundleResourceMarco_h

//MARK: - module name marco

#define JJR_BUNDLE_SUFFIX @"Resource"

#define _JJR_STRING(x) #x
#define JJR_STRING(x) _JJR_STRING(x)

#define JJR_BUNDLE(name) name JJR_BUNDLE_SUFFIX

#ifdef JJR_MODULE
#define JJR_SELF_BUNDLE @JJR_STRING(JJR_MODULE)JJR_BUNDLE_SUFFIX
#else
#define JJR_SELF_BUNDLE nil
#endif

//MARK: - Helper marco

//MARK: String

#define JJRStr(name) ([JJBundleResource stringForName:name inBundle:JJR_SELF_BUNDLE])

#define JJRStrInModule(name, module) ([JJBundleResource stringForName:name inBundle:JJR_BUNDLE(module)])

//MARK: Color

#define JJRColor(name) ([JJBundleResource colorForName:name inBundle:JJR_SELF_BUNDLE])

#define JJRColorInModule(name, module) ([JJBundleResource colorForName:name inBundle:JJR_BUNDLE(module)])

//MARK: Image

#define JJRImage(name) ([JJBundleResource imageForName:name inBundle:JJR_SELF_BUNDLE cacheable:YES])

#define JJRImageInModule(name, module) ([JJBundleResource imageForName:name inBundle:JJR_BUNDLE(module) cacheable:YES])

#define JJRImageNoCache(name) ([JJBundleResource imageForName:name inBundle:JJR_SELF_BUNDLE cacheable:NO])

#define JJRImageNoCacheInModule(name, module) ([JJBundleResource imageForName:name inBundle:JJR_BUNDLE(module) cacheable:YES])

//MARK: Data

#define JJRData(name) ([JJBundleResource dataForName:name inBundle:JJR_SELF_BUNDLE cacheable:YES])

#define JJRDataInModule(name, module) ([JJBundleResource dataForName:name inBundle:JJR_BUNDLE(module) cacheable:YES])

#define JJRDataNoCache(name) ([JJBundleResource dataForName:name inBundle:JJR_SELF_BUNDLE cacheable:NO])

#define JJRDataNoCacheInModule(name, module) ([JJBundleResource dataForName:name inBundle:JJR_BUNDLE(module) cacheable:NO])

//MARK: Array

#define JJRArray(name) ([JJBundleResource arrayForName:name inBundle:JJR_SELF_BUNDLE cacheable:YES])

#define JJRArrayInModule(name, module) ([JJBundleResource arrayForName:name inBundle:JJR_BUNDLE(module) cacheable:YES])

#define JJRArrayNoCache(name) ([JJBundleResource arrayForName:name inBundle:JJR_SELF_BUNDLE cacheable:NO])

#define JJRArrayNoCacheInModule(name, module) ([JJBundleResource arrayForName:name inBundle:JJR_BUNDLE(module) cacheable:NO])

//MARK: Dictionary

#define JJRDict(name) ([JJBundleResource dictionaryForName:name inBundle:JJR_SELF_BUNDLE cacheable:YES])

#define JJRDictInModule(name, module) ([JJBundleResource dictionaryForName:name inBundle:JJR_BUNDLE(module) cacheable:YES])

#define JJRDictNoCache(name) ([JJBundleResource dictionaryForName:name inBundle:JJR_SELF_BUNDLE cacheable:NO])

#define JJRDictNoCacheInModule(name, module) ([JJBundleResource dictionaryForName:name inBundle:JJR_BUNDLE(module) cacheable:NO])

//MARK: FilePath

#define JJRFilePath(name) ([JJBundleResource filePathForName:name inBundle:JJR_SELF_BUNDLE cacheable:YES])

#define JJRFilePathInModule(name, module) ([JJBundleResource filePathForName:name inBundle:(module) cacheable:YES])

#define JJRFilePathNoCache(name) ([JJBundleResource filePathForName:name inBundle:JJR_SELF_BUNDLE cacheable:NO])

#define JJRFilePathNoCacheInModule(name, module) ([JJBundleResource filePathForName:name inBundle:(module) cacheable:NO])

#endif /* JJBundleResourceMarco_h */
