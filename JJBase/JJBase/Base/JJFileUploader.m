//
//  JJFileUploader.m
//  JJBase
//
//  Created by xiedong on 2020/10/23.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJFileUploader.h"
#import "JJNSData.h"
#import <CommonCrypto/CommonDigest.h>

@implementation JJFileUploader

+ (instancetype)shared {
    static JJFileUploader *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JJFileUploader alloc] init];
    });
    
    return instance;
}

//MARK: - Public
+ (void)upload:(NSString *)fileName path:(NSString *)path uploadPath:(NSString *)uploadPath {
    [[JJFileUploader shared] upload:fileName path:path uploadPath:uploadPath sync:NO];
}

+ (void)uploadSync:(NSString *)fileName path:(NSString *)path uploadPath:(NSString *)uploadPath {
    [[JJFileUploader shared] upload:fileName path:path uploadPath:uploadPath sync:YES];
}

//MARK: - Private
- (void)upload:(NSString *)fileName path:(NSString *)path uploadPath:(NSString *)uploadPath sync:(BOOL)sync {
    if (!fileName.length || !path.length || !uploadPath.length) {
        return;
    }
    
    dispatch_block_t myBlock = ^{
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            return;
        }
        
        NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
        
        if (!attrs || attrs.fileSize >= 1024 * 1024 * 5) { //最大5M
            return;
        }
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        if (data) {
            data = [JJNSData toZippedData:data];
            
            if (data) {
                
                NSUInteger time = [[NSDate date] timeIntervalSince1970] * 1000;
                
                NSString *fullFileName = [NSString stringWithFormat:@"%@_%@_%@.zip",
                                          fileName,
                                          @(time),
                                          [self randomHash]];
                
                JJLog(@"[JJFileUpload] upload not finish: %@", fullFileName);
            }
        }
    };
    
    if (sync) {
        myBlock();
    } else {
        dispatch_async(dispatch_get_global_queue(0, 0), myBlock);
    }
}

- (NSString *)randomHash {
    //UUID SHA256, 避免文件名冲突
    uint8_t buffer[CC_SHA256_DIGEST_LENGTH];
    
    CC_SHA256_CTX hashCtx;
    CC_SHA256_Init(&hashCtx);
    
    CFUUIDRef uuid = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidStringRef = CFUUIDCreateString(kCFAllocatorDefault, uuid);
    NSString * uuidString = (NSString *)CFBridgingRelease(CFStringCreateCopy(NULL, uuidStringRef));
    CFRelease(uuidStringRef);
    CFRelease(uuid);
    
    NSData * dataUUID = [uuidString dataUsingEncoding:NSUTF8StringEncoding];
    CC_SHA256_Update(&hashCtx, dataUUID.bytes, (CC_LONG)dataUUID.length);
    CC_SHA256_Final(buffer, &hashCtx);
    
    NSMutableString * uuidSHA256String = [NSMutableString stringWithCapacity:64];
    
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; ++i) {
        [uuidSHA256String appendFormat:@"%02x", (unsigned int)buffer[i]];
    }

    return [uuidSHA256String copy];
}

@end
