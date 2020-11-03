//
//  JJPopupView.h
//  JJBaseUI
//
//  Created by xiedong on 2020/9/25.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JJPopupView;
@protocol JJPopupViewDelegate <NSObject>

- (void)jjPopupView:(JJPopupView *)popupView didHide:(BOOL)touchOutside;

@end

typedef void(^JJPopupViewContraintsHandler)(UIView *popView);

@interface JJPopupView : UIView

@property (nonatomic, weak) id<JJPopupViewDelegate> delegate;

@property (nonatomic, strong, nullable) UIView *contentView;

@property (nonatomic, assign) CGSize contentSize;

@property (nonatomic, assign) BOOL outsideTouchable;

@property (nonatomic, assign) BOOL hidesWhenTouchOutside;

@property (nonatomic, assign, readonly) BOOL isShowing;

@property (nonatomic, strong, nullable) id context;

- (void)showAsDropdownForView:(UIView *)anchorView buOffset:(CGPoint)offset;

- (void)showInView:(UIView *)parentView atPosition:(CGPoint)position;

- (void)hide;

- (void)showInView:(UIView *)parentView contraintsHandler:(JJPopupViewContraintsHandler)handler;

@end

NS_ASSUME_NONNULL_END
