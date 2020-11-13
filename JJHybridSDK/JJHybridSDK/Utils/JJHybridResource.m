//
//  JJHybridResource.m
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/12.
//

#import "JJHybridResource.h"

@implementation JJHybridResource

+ (UIImage *)imageWithName:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"JJHybridSDKResource" ofType:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    
    return [UIImage imageWithContentsOfFile:[bundle pathForResource:[NSString stringWithFormat:@"%@@%f",name,UIScreen.mainScreen.scale] ofType:@"png"]];
}
@end
