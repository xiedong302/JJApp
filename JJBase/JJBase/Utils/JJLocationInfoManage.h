//
//  JJLocationInfoManage.h
//  JJBase
//
//  Created by xiedong on 2020/9/27.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@class JJLocationInfoManage;

@protocol JJLocationInfoManageDelegate <NSObject>

- (void)jj_locationInfoManager:(JJLocationInfoManage *)manager didFailWithError:(NSError *)error;

- (void)jj_locationInfoManager:(JJLocationInfoManage *)manager didFindPlacemark:(CLPlacemark *)placemark location:(CLLocation *)location;

@end

@interface JJLocationInfoManage : NSObject

+ (void)jj_setLocationDesireAccuracy:(CLLocationAccuracy)accuracy;

+ (void)jj_setLocationDistanceFilter:(CLLocationDistance)distance;

+ (void)jj_startUpdateLocation:(id<JJLocationInfoManageDelegate>)delegate;

+ (void)jj_stopUpdateLocation;

@end

NS_ASSUME_NONNULL_END
