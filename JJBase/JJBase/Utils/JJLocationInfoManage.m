//
//  JJLocationInfoManage.m
//  JJBase
//
//  Created by xiedong on 2020/9/27.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "JJLocationInfoManage.h"

@interface JJLocationInfoManage()<CLLocationManagerDelegate>

@property (nonatomic, weak) id<JJLocationInfoManageDelegate> delegate;

@property (nonatomic, strong) CLLocationManager *locManager;

@end

@implementation JJLocationInfoManage

+ (instancetype)defaultManager {
    static JJLocationInfoManage *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JJLocationInfoManage alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        self.locManager = [[CLLocationManager alloc] init];
        self.locManager.delegate = self;
        //默认精度100m
        self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
        //横向移动距离之后更新
        self.locManager.distanceFilter = 10.f;
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
}

- (void)jj_setLocationDesireAccuracy:(CLLocationAccuracy)accuracy {
    self.locManager.desiredAccuracy = accuracy;
}

- (void)jj_setLocationDistanceFilter:(CLLocationDistance)distance {
    self.locManager.distanceFilter = distance;
}

- (void)jj_startUpdateLocation:(id<JJLocationInfoManageDelegate>)delegate {
    
    _delegate = delegate;
    
    if ([self.locManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
        [self.locManager requestAlwaysAuthorization];
        [self.locManager requestWhenInUseAuthorization];
    }
    
    [self.locManager startUpdatingLocation];
}

- (void)jj_stopUpdateLocation {
    [self.locManager stopUpdatingLocation];
}

//MARK: - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    [self jj_stopUpdateLocation];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(jj_locationInfoManager:didFailWithError:)]) {
        [self.delegate jj_locationInfoManager:self didFailWithError:error];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self jj_stopUpdateLocation];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    __weak typeof(self) weakSelf = self;
    [geocoder reverseGeocodeLocation:[locations lastObject] completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error || !placemarks.count) {
            return;
        }
        
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(jj_locationInfoManager:didFindPlacemark:location:)]) {
            [weakSelf.delegate jj_locationInfoManager:weakSelf didFindPlacemark:[placemarks firstObject] location:[locations lastObject]];
        }
    }];
}

//MARK: - public
+ (void)jj_setLocationDesireAccuracy:(CLLocationAccuracy)accuracy {
    [[JJLocationInfoManage defaultManager] jj_setLocationDesireAccuracy:accuracy];
}

+ (void)jj_setLocationDistanceFilter:(CLLocationDistance)distance {
    [[JJLocationInfoManage defaultManager] jj_setLocationDistanceFilter:distance];
}

+ (void)jj_startUpdateLocation:(id<JJLocationInfoManageDelegate>)delegate {
    [[JJLocationInfoManage defaultManager] jj_startUpdateLocation:delegate];
}

+ (void)jj_stopUpdateLocation {
    [[JJLocationInfoManage defaultManager] jj_stopUpdateLocation];
}

@end
