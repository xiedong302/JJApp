//
//  JJUserService.m
//  JJUserSDK
//
//  Created by xiedong on 2020/11/20.
//

#import "JJUserService.h"
#import "JJUserInfoModel.h"
#import "JJUserSDKDBManager.h"
#import "JJUserSDKDBHelper.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

@interface JJUserService ()<JJTAFHandlerDelegate>

@property (nonatomic, strong) JJTAFHandler *handler;

@end
@implementation JJUserService {
    void *IsOnJJUserServiceWorkQueueKey;
}

+ (instancetype)sharedInstance {
    static JJUserService *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JJUserService alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        dispatch_queue_t workQueue = dispatch_queue_create("JJUserService_WorkQueue", DISPATCH_QUEUE_SERIAL);
        IsOnJJUserServiceWorkQueueKey = &IsOnJJUserServiceWorkQueueKey;
        void *nonNullUnusedPointer = (__bridge void *)self;
        dispatch_queue_set_specific(workQueue, IsOnJJUserServiceWorkQueueKey, nonNullUnusedPointer, NULL);
        
        _handler = [[JJTAFHandler alloc] initWithSerialQueue:workQueue delegate:self];
        
        _userInfoData = [[JJUserSDKDBManager getUserDBHelper] getUserDetailInfo];
        
        [self addObserver];
    }
    return self;
}

- (void)addObserver {
    // 监听网络变化
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyNetworkStatusChanged:) name:JJTAFReachabilityChangeNotification object:nil];
    // App到前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifyAppStateChanged:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)notifyNetworkStatusChanged:(NSNotification *)notification {
    
}

- (void)notifyAppStateChanged:(NSNotification *)notification {
    
}

//串行处理
- (void)executeSerial:(void (^)())block {
    if (dispatch_get_specific(IsOnJJUserServiceWorkQueueKey)) {
        block();
    } else {
        [self.handler postBlock:block forKey:nil];
    }
}

//MARK: - JJTAFHandlerDelegate
- (void)handleMessage:(int)what object:(id)anObject {
    
}

- (void)initUserStatus {
    if (!self.userInfoData) {
        JJUserInfoModel *info = [[JJUserInfoModel alloc] init];
        info.uid = @"234-AE4-FA-Q123";
        info.nickName = @"xiedong";
        info.sex = @"1";
        info.phone = @"13545861221";
        info.birthday = @"1993-11-10";
        info.headPic = @"www.headPic.com";
        info.remarks = @"try study";
        info.province = @"湖北";
        info.city = @"武汉";
        
        [[JJUserSDKDBManager getUserDBHelper] updateUserDetailInfo:info];
    }
}
@end

#pragma clang diagnostic pop
