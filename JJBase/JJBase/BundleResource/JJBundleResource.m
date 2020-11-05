//
//  JJBundleResource.m
//  JJBase
//
//  Created by xiedong on 2020/9/28.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJBundleResource.h"
#import "UIColor+JJCategory.h"

//MARK: - static func
static NSException * markException(NSString * format, ...) NS_NO_TAIL_CALL {
    va_list args;
    va_start(args, format);
    
    NSString *msg = [[NSString alloc] initWithFormat:format arguments:args];
    
    va_end(args);
    
    return [NSException exceptionWithName:@"JJBundleResourceException" reason:msg userInfo:nil];
}

static inline id makeResourceKey(NSString *value1, NSString *value2, NSString *value3, NSString *value4) {
    NSUInteger result = 1;
    NSUInteger prime = 31;
    
    result = prime * result + value1.hash;
    result = prime * result + value2.hash;
    result = prime * result + value3.hash;
    result = prime * result + value4.hash;
    
    return @(result);
}

static inline NSString * makeBundleName(NSString *bundleName, NSString *overrideSuffix) {
    if (overrideSuffix && overrideSuffix.length > 0) {
        if ([bundleName hasSuffix:@".bundle"]) {
            //去掉.bundle
            bundleName = [bundleName substringToIndex:bundleName.length - 7];
            bundleName = [NSString stringWithFormat:@"%@.%@.bundle",bundleName,overrideSuffix];
        } else {
            bundleName = [NSString stringWithFormat:@"%@.%@.bundle",bundleName,overrideSuffix];
        }
    } else if (![bundleName hasSuffix:@".bundle"]) {
        bundleName = [NSString stringWithFormat:@"%@.bundle",bundleName];
    }
    
    return bundleName;
}

static inline NSString * makeResourcePath(NSString *bundleName, NSString *subPath, NSString *resourcePath) {
    NSString *path = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:bundleName];
    
    if (subPath && subPath.length > 0) {
        path = [path stringByAppendingPathComponent:subPath];
    }
    
    path = [path stringByAppendingPathComponent:resourcePath];
    
    if (![[NSFileManager defaultManager] isReadableFileAtPath:path]) {
        path = nil;
    }
    
    return path;
}

// 简易计算对象占用的内存大小， 效率优先
static NSUInteger objectSize(id object) {
    if (object) {
        if ([object isKindOfClass:NSString.class]) {
            NSString *str = (NSString *)object;
            if (str.length > 0) {
                // 取 首、尾、中三个字符，判断是否为ASCII字符
                // 如果全是， 就用字符串长度
                // 如果不全是， 就用字符串长度*2(简易计算，不考虑变长的编码方式)
                unichar c1 = [str characterAtIndex:0];
                unichar c2 = [str characterAtIndex:str.length / 2];
                unichar c3 = [str characterAtIndex:str.length - 1];
                
                if (isascii(c1) && isascii(c2) && isascii(c3)) {
                    return str.length;
                } else {
                    return str.length * 2;
                }
            }
        } else if ([object isKindOfClass:UIColor.class]) {
            return 64; //通过malloc_size获取
        } else if ([object isKindOfClass:UIImage.class]) {
            CGImageRef ref = [(UIImage *)object CGImage];
            return CGImageGetHeight(ref) * CGImageGetBytesPerRow(ref);
        } else if ([object isKindOfClass:NSDate.class]) {
            return [(NSData*)object length];
        } else if ([object isKindOfClass:NSDictionary.class]) {
            NSDictionary *dict = (NSDictionary *)object;
            
            if (dict.count > 0) {
                return objectSize(dict.allKeys) + objectSize(dict.allValues);
            }
        } else if ([object isKindOfClass:NSArray.class]) {
            NSArray *array = (NSArray *)object;
            
            if (array.count > 0) {
                // 取首、尾、中三个对象，取平均长度*count
                id o1 = [array objectAtIndex:0];
                id o2 = [array objectAtIndex: array.count / 2];
                id o3 = [array objectAtIndex:array.count - 1];
                
                return (objectSize(o1) + objectSize(o2) + objectSize(o3)) / 3 * array.count;
            }
        }
    }
    
    return 64;
}


static BOOL _debuggable = NO;

@interface JJBundleResource() <NSCacheDelegate>
{
    NSCache *_cache;
    NSCache *_cache2; //二级缓存用于保存一些小对象
    
    NSString *_l10nPath;
    
    NSString *_overrideSuffix;
}

@end

@implementation JJBundleResource

+ (instancetype)bundleResource {
    static JJBundleResource *resource = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        resource = [[JJBundleResource alloc] init];
    });
    return resource;
}

- (instancetype)init {
    if (self = [super init]) {
        
        _cache = [[NSCache alloc] init];
        _cache.name = @"JJBundleResourceCache";
        // iOS App能够使用的最大内存约为物理内存的一半 参考https://stackoverflow.com/questions/5887248/ios-app-maximum-memory-budgets
        // Resource缓存最多占app内存的1/3
        _cache.totalCostLimit = (NSUInteger)NSProcessInfo.processInfo.physicalMemory / 2 / 3;
        _cache.delegate = self;
        
        _cache2 = [[NSCache alloc] init];
        _cache2.name = @"JJBundleResourceCache2";
        _cache2.delegate = self;
        
        _l10nPath = [NSString stringWithFormat:@"%@.lproj", NSBundle.mainBundle.preferredLocalizations.firstObject];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

//MARK: - private
- (NSString *)stringForName:(NSString *)name inBundle:(NSString *)bundleName {
    NSString *string = nil;
    
    NSString *overrideSuffix = _overrideSuffix;
    
    id key = makeResourceKey(bundleName, name, @"string", overrideSuffix);
    
    string = [_cache objectForKey:key];
    
    if (string && ![string isKindOfClass:NSString.class]) {
        NSLog(@"[JJBundleResource] Need NSString for %@ in %@, but got %@",name, bundleName, NSStringFromClass(string.class));
        
        string = nil;
    }
    
    if (!string) {
        if (overrideSuffix.length > 0) {
            string = [self stringForName:name inBundle:makeBundleName(bundleName, overrideSuffix) inFile:@"strings.strings"];
        }
        
        if (!string) {
            string = [self stringForName:name inBundle:makeBundleName(bundleName, nil) inFile:@"strings.strings"];
        }
        
        if (string) {
            [_cache setObject:string forKey:key cost:objectSize(string)];
        }
    }
    
    return string;
}

- (UIColor *)colorForName:(NSString *)name inBundle:(NSString *)bundleName {
    UIColor *color = nil;
    
    NSString *overrideSuffix = _overrideSuffix;
    
    id key = makeResourceKey(bundleName, name, @"color", overrideSuffix);
    
    color = [_cache objectForKey:key];
    
    if (color && ![color isKindOfClass:UIColor.class]) {
        NSLog(@"[JJBundleResource] Need UIColor for %@ in %@, but got %@",name, bundleName, NSStringFromClass(color.class));
        
        color = nil;
    }
    
    if (!color) {
        NSString *value = nil;
        
        if (overrideSuffix.length > 0) {
            value = [self stringForName:name inBundle:makeBundleName(bundleName, overrideSuffix) inFile:@"colors.strings"];
        }
        
        if (!value) {
            value = [self stringForName:name inBundle:makeBundleName(bundleName, nil) inFile:@"colors.strings"];
        }
        
        if (value) {
            //颜色值二级缓存，同样的颜色值不重复生成UIColor对象
            id key2 = makeResourceKey(value, @"color", nil, nil);
            
            color = [_cache2 objectForKey:key2];
            
            if (color && ![color isKindOfClass:UIColor.class]) {
                NSLog(@"[JJBundleResource] Need UIColor for %@ in %@, but got %@",name, bundleName, NSStringFromClass(color.class));
                
                color = nil;
            }
            
            if (!color) {
                color = [UIColor jj_colorWithHexValue:value];
                
                if (color) {
                    [_cache2 setObject:color forKey:key2];
                }
            }
            
            if (color) {
                [_cache setObject:color forKey:key cost:objectSize(color)];
            }
        }
    }
    
    return color;
}

- (NSString *)stringForName:(NSString *)name inBundle:(NSString *)bundleName inFile:(NSString *)file {
    NSString *string = nil;
    
    NSDictionary *l10nDict = [self stringDictionaryFromFile:file inBundle:bundleName subPath:_l10nPath];
    
    if (l10nDict) {
        string = [l10nDict objectForKey:name];
    }
    
    if (!string) {
        NSDictionary *defaultDict = [self stringDictionaryFromFile:file inBundle:bundleName subPath:nil];
        
        if (defaultDict) {
            string = [defaultDict objectForKey:name];
        }
    }
    
    if (string && ![string isKindOfClass:NSString.class]) {
        NSLog(@"[JJBundleResource] Need NSString for %@, but got %@",name, NSStringFromClass(string.class));
        
        string = nil;
    }
    
    return string;
}

- (NSDictionary *)stringDictionaryFromFile:(NSString *)file inBundle:(NSString *)bundleName subPath:(NSString *)subPath {
    NSDictionary *dict = nil;
    
    id key = makeResourceKey(bundleName, subPath, file, nil);
    
    dict = [_cache2 objectForKey:key];
    
    if (dict && ![dict isKindOfClass:NSDictionary.class]) {
        NSLog(@"[JJBundleResource] Need NSDictionary for %@/%@/%@, but got %@",bundleName,subPath,file , NSStringFromClass(dict.class));
        
        dict = nil;
    }
    
    if (!dict) {
        NSString *path = makeResourcePath(bundleName, subPath, file);
        
        if (path && path.length > 0) {
            dict = [NSDictionary dictionaryWithContentsOfFile:path];
        }
        
        if (dict) {
            [_cache2 setObject:dict forKey:key];
        }
    }
    
    return dict;
}

- (UIImage *)imageForName:(NSString *)name inBundle:(NSString *)bundleName cacheable:(BOOL)cacheable {
    UIImage *image = nil;
    
    NSString *overrideSuffix = _overrideSuffix;
    
    id key = makeResourceKey(bundleName, name, @"image", overrideSuffix);
    
    image = [_cache objectForKey:key];
    
    if (image && ![image isKindOfClass:UIImage.class]) {
        NSLog(@"[JJBundleResource] Need UIImage for %@ in %@, but got %@",name, bundleName, NSStringFromClass(image.class));
        
        image = nil;
    }
    
    if (!image) {
        if (overrideSuffix.length > 0) {
            image = [self imageForName2:name inBundle:makeBundleName(bundleName, overrideSuffix)];
        }
        
        if (!image) {
            image = [self imageForName2:name inBundle:makeBundleName(bundleName, nil)];
        }
        
        if(cacheable && image) {
            [_cache setObject:image forKey:key cost:objectSize(image)];
        }
    }
    
    return image;
}

- (UIImage *)imageForName2:(NSString *)name inBundle:(NSString *)bundleName {
    //目前只支持png和jpg
    UIImage *image = [self imageForName3:name inBundle:bundleName subPath:_l10nPath type:@"png"];
    
    if (!image) {
        image = [self imageForName3:name inBundle:bundleName subPath:nil type:@"png"];
    }
    
    if (!image) {
        image = [self imageForName3:name inBundle:bundleName subPath:_l10nPath type:@"jpg"];
    }
    
    if (!image) {
        image = [self imageForName3:name inBundle:bundleName subPath:nil type:@"jpg"];
    }
    
    return image;
}

- (UIImage *)imageForName3:(NSString *)name inBundle:(NSString *)bundleName subPath:(NSString *)subPath type:(NSString *)type {
    UIImage *image = nil;
    
    NSString *imagePath = nil;
    
    //转成int，有效的避免一些兼容问题
    int scale = MAX((int)UIScreen.mainScreen.scale, 0);
    int originScale = scale;
    
    while (scale >= 1) {
        NSString *fullImageName = nil;
        
        if (scale == 1) { // 1x的图基本没用
            fullImageName = [NSString stringWithFormat:@"%@.%@",name,type];
        } else {
            fullImageName = [NSString stringWithFormat:@"%@@%dx.%@",name,scale,type];
        }
        
        imagePath = makeResourcePath(bundleName, subPath, fullImageName);
        
        if (imagePath && imagePath > 0) {
            break;
        }
        
        // 这里只支持高scale设备使用低scale的图，不支持低scale设备使用高scale的图
        // 后面可以考虑支持
        scale--;
    }
    
    if(imagePath && imagePath.length > 0) {
        if (originScale != scale) {
            NSLog(@"[JJBundleResource] Image scale does not much device sacel for %@/%@/%@",bundleName,subPath,name);
        }
        
        //创建CGImageRef要比 [UIImage imageWithContentFile:]快很多
        CGDataProviderRef dataProviderRef = CGDataProviderCreateWithFilename(imagePath.UTF8String);
        
        if (dataProviderRef) {
            
            CGImageRef imageRef = NULL;
            
            if ([type compare:@"png" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
                imageRef = CGImageCreateWithPNGDataProvider(dataProviderRef, NULL, NO, kCGRenderingIntentDefault);
            } else {
                imageRef = CGImageCreateWithJPEGDataProvider(dataProviderRef, NULL, NO, kCGRenderingIntentDefault);
            }
            
            if (imageRef) {
                image = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
                
                CGImageRelease(imageRef);
            } else {
                NSLog(@"[JJBundleResource] Create CGImage failed for %@/%@/%@",bundleName,subPath,name);
                
                //图片解析不出来，可能是图片扩展名和实际格式不一致， UIImage的兼容性会好一些
                image = [UIImage imageWithContentsOfFile:imagePath];
            }
            CGDataProviderRelease(dataProviderRef);
        }
    }
    
    return image;
}

- (NSData *)dataForName:(NSString *)name inBundle:(NSString *)bundleName cacheable:(BOOL)cacheable {
    NSData *data = nil;
    
    NSString *overrideSuffix = _overrideSuffix;
    
    id key = makeResourceKey(bundleName, name, @"data", overrideSuffix);
    
    data = [_cache objectForKey:key];
    
    if (data && ![data isKindOfClass:NSData.class]) {
        NSLog(@"[JJBundleResource] Need NSData for %@ in %@, but got %@",name, bundleName, NSStringFromClass(data.class));
        
        data = nil;
    }
    
    if (!data) {
        if (overrideSuffix.length > 0) {
            data = [self dataForName2:name inBundle:makeBundleName(bundleName, overrideSuffix)];
        }
        
        if (!data) {
            data = [self dataForName2:name inBundle:makeBundleName(bundleName, nil)];
        }
        
        if (cacheable && data) {
            [_cache setObject:data forKey:key cost:objectSize(data)];
        }
    }
    
    return data;
}

- (NSData *)dataForName2:(NSString *)name inBundle:(NSString *)bundleName {
    NSData *data = nil;
    
    NSString *path = makeResourcePath(bundleName, _l10nPath, name);
    
    if (path && path.length > 0) {
        data = [NSData dataWithContentsOfFile:path];
    }
    
    if (!data) {
        path = makeResourcePath(bundleName, nil, name);
        
        if (path && path.length > 0) {
            data = [NSData dataWithContentsOfFile:path];
        }
    }
    
    return data;
}

- (NSArray *)arrayForName:(NSString *)name inBundle:(NSString *)bundleName cacheable:(BOOL)cacheable {
    NSArray *array = nil;
    
    NSString *overrideSuffix = _overrideSuffix;
    
    id key = makeResourceKey(bundleName, name, @"array", overrideSuffix);
    
    array = [_cache objectForKey:key];
    
    if (array && ![array isKindOfClass:NSArray.class]) {
        NSLog(@"[JJBundleResource] Need NSArray for %@ in %@, but got %@",name, bundleName, NSStringFromClass(array.class));
        
        array = nil;
    }
    
    if (!array) {
        if (overrideSuffix.length > 0) {
            array = [self arrayForName2:name inBundle:makeBundleName(bundleName, overrideSuffix)];
        }
        
        if (!array) {
            array = [self arrayForName2:name inBundle:makeBundleName(bundleName, nil)];
        }
        
        if (cacheable && array) {
            [_cache setObject:array forKey:key cost:objectSize(array)];
        }
    }
    
    return array;
}

- (NSArray *)arrayForName2:(NSString *)name inBundle:(NSString *)bundleName {
    NSArray *array = nil;
    
    NSString *path = makeResourcePath(bundleName, _l10nPath, name);
    
    if (path && path.length > 0) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        if (data) {
            NSError *error = nil;
            id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            if (!error && result && [result isKindOfClass:NSArray.class]) {
                array = result;
            }
        }
    }
    
    if (!array) {
        
        path = makeResourcePath(bundleName, nil, name);
        
        if (path && path.length > 0) {
            NSData *data = [NSData dataWithContentsOfFile:path];
            
            if (data) {
                NSError *error = nil;
                id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                
                if (!error && result && [result isKindOfClass:NSArray.class]) {
                    array = result;
                }
            }
        }
    }
    
    return array;
}

- (NSDictionary *)dictionaryForName:(NSString *)name inBundle:(NSString *)bundleName cacheable:(BOOL)cacheable {
    NSDictionary *dict = nil;
    
    NSString *overrideSuffix = _overrideSuffix;
    
    id key = makeResourceKey(bundleName, name, @"dictionary", overrideSuffix);
    
    dict = [_cache objectForKey:key];
    
    if (dict && ![dict isKindOfClass:NSDictionary.class]) {
        NSLog(@"[JJBundleResource] Need NSDictionary for %@ in %@, but got %@",name, bundleName, NSStringFromClass(dict.class));
        
        dict = nil;
    }
    
    if (!dict) {
        if (overrideSuffix.length > 0) {
            dict = [self dictionaryForName2:name inBundle:makeBundleName(bundleName, overrideSuffix)];
        }
        
        if (!dict) {
            dict = [self dictionaryForName2:name inBundle:makeBundleName(bundleName, nil)];
        }
        
        if (cacheable && dict) {
            [_cache setObject:dict forKey:key cost:objectSize(dict)];
        }
    }
    
    return dict;
}

- (NSDictionary *)dictionaryForName2:(NSString *)name inBundle:(NSString *)bundleName {
    NSDictionary *dict = nil;
    
    NSString *path = makeResourcePath(bundleName, _l10nPath, name);
    
    if (path && path.length > 0) {
        dict = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    
    if (!dict) {
        
        path = makeResourcePath(bundleName, nil, name);
        
        if (path && path.length > 0) {
            dict = [[NSDictionary alloc] initWithContentsOfFile:path];
        }
    }
    
    return dict;
}

- (NSString *)filePathForName:(NSString *)name inBundle:(NSString *)bundleName cacheable:(BOOL)cacheable {
    NSString *str = nil;
    
    NSString *overrideSuffix = _overrideSuffix;
    
    id key = makeResourceKey(bundleName, name, @"filePath", overrideSuffix);
    
    str = [_cache objectForKey:key];
    
    if (str && ![str isKindOfClass:NSString.class]) {
        NSLog(@"[JJBundleResource] Need FilePath for %@ in %@, but got %@",name, bundleName, NSStringFromClass(str.class));
        
        str = nil;
    }
    
    if (!str) {
        if (overrideSuffix.length > 0) {
            str = [self filePathForName2:name inBundle:makeBundleName(bundleName, overrideSuffix)];
        }
        
        if (!str) {
            str = [self filePathForName2:name inBundle:makeBundleName(bundleName, nil)];
        }
        
        if (cacheable && str) {
            [_cache setObject:str forKey:key cost:objectSize(str)];
        }
    }
    
    return str;
}

- (NSString *)filePathForName2:(NSString *)name inBundle:(NSString *)bundleName {

    NSString *path = makeResourcePath(bundleName, _l10nPath, name);
    
    if (!path) {
        path = makeResourcePath(bundleName, nil, name);
    }
    
    return path;
}

- (NSString *)overrideSuffix {
    return _overrideSuffix;
}

- (void)setOverrideSuffix:(NSString *)overrideSuffix {
    if (overrideSuffix && overrideSuffix.length > 0) {
        _overrideSuffix = [overrideSuffix copy];
    } else {
        _overrideSuffix = nil;
    }
    
    [self clearCache];
}

- (void)clearCache {
    [_cache removeAllObjects];
    [_cache2 removeAllObjects];
}

- (void)setDebug:(BOOL)debuggable {
    _debuggable = debuggable;
}

- (void)onNotification:(NSNotification *)notification {
    if ([notification.name isEqualToString:UIApplicationDidReceiveMemoryWarningNotification]) {
        [self clearCache];
    }
}

//MARK: - public
+ (NSString *)stringForName:(NSString *)name inBundle:(NSString *)bundleName {
    NSString *string = [[JJBundleResource bundleResource] stringForName:name inBundle:bundleName];
    
    if (_debuggable && string == nil) {
        @throw markException(@"can not found string for %@ in %@",name, bundleName);
    }
    
    return string;
}

+ (UIColor *)colorForName:(NSString *)name inBundle:(NSString *)bundleName {
    UIColor *color = [[JJBundleResource bundleResource] colorForName:name inBundle:bundleName];
    
    if (_debuggable && color == nil) {
        @throw markException(@"can not found color for %@ in %@",name, bundleName);
    }
    
    return color;
}

+ (UIImage *)imageForName:(NSString *)name inBundle:(NSString *)bundleName cacheable:(BOOL)cacheable {
    UIImage *image = [[JJBundleResource bundleResource] imageForName:name inBundle:bundleName cacheable:cacheable];
    
    if (_debuggable && image == nil) {
        @throw markException(@"can not found image for %@ in %@",name, bundleName);
    }
    
    return image;
}

+ (NSArray *)arrayForName:(NSString *)name inBundle:(NSString *)bundleName cacheable:(BOOL)cacheable {
    NSArray *array = [[JJBundleResource bundleResource] arrayForName:name inBundle:bundleName cacheable:cacheable];
    
    if (_debuggable && array == nil) {
        @throw markException(@"can not found array for %@ in %@",name, bundleName);
    }
    
    return array;
}

+ (NSData *)dataForName:(NSString *)name inBundle:(NSString *)bundleName cacheable:(BOOL)cacheable {
    NSData *data = [[JJBundleResource bundleResource] dataForName:name inBundle:bundleName cacheable:cacheable];
    
    if (_debuggable && data == nil) {
        @throw markException(@"can not found data for %@ in %@",name, bundleName);
    }
    
    return data;
}

+ (NSDictionary *)dictionaryForName:(NSString *)name inBundle:(NSString *)bundleName cacheable:(BOOL)cacheable {
    NSDictionary *dict =  [[JJBundleResource bundleResource] dictionaryForName:name inBundle:bundleName cacheable:cacheable];
    
    if (_debuggable && dict == nil) {
        @throw markException(@"can not found dict for %@ in %@",name, bundleName);
    }
    
    return dict;
}

+ (NSString *)filePathForName:(NSString *)name inBundle:(NSString *)bundleName cacheable:(BOOL)cacheable {
    NSString *filePath = [[JJBundleResource bundleResource] filePathForName:name inBundle:bundleName cacheable:cacheable];
    
    if (_debuggable && filePath == nil) {
        @throw markException(@"can not found file path %@ in %@",name, bundleName);
    }
    
    return filePath;
}

+ (NSString *)overrideSuffix {
    return [[JJBundleResource bundleResource] overrideSuffix];
}

+ (void)setOverrideSuffix:(NSString *)overrideSuffix {
    [[JJBundleResource bundleResource] setOverrideSuffix:overrideSuffix];
}

+ (void)clearCache {
    [[JJBundleResource bundleResource] clearCache];
}

+ (void)setDebug:(BOOL)debuggable {
    [[JJBundleResource bundleResource] setDebug:debuggable];
}
@end
