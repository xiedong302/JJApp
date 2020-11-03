//
//  JJFeedbackUtil.m
//  JJBaseUI
//
//  Created by xiedong on 2020/9/24.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJFeedbackUtil.h"
#import <AudioToolbox/AudioToolbox.h>

@interface JJFeedbackUtil()

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunguarded-availability"

@property (nonatomic, strong) UIImpactFeedbackGenerator *feedbackGenerator;

#pragma clang diagnostic pop
@end

@implementation JJFeedbackUtil

//MARK: - private
+ (instancetype)sharedInstance {
    static JJFeedbackUtil *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[JJFeedbackUtil alloc] init];
    });
    return _shareInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        if (@available(iOS 10.0, *)) {
            _feedbackGenerator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
            [_feedbackGenerator prepare];
        } else {
            // Fallback on earlier versions
        }
    }
    return self;
}

- (void)vibrate {
    if (@available(iOS 10.0, *)) {
        [self.feedbackGenerator impactOccurred];
    }
    else {
        @try {
            AudioServicesPlaySystemSound(1519);
        } @catch (NSException *exception) {
            
        }
    }
}

//MARK: - public
+ (void)vibrate {
    [[JJFeedbackUtil sharedInstance] vibrate];
}
@end
