//
//  JJToastView.m
//  JJBaseUI
//
//  Created by xiedong on 2020/11/6.
//

#import "JJToastView.h"
#import "JJPopupView.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"

static const NSTimeInterval kShowTime = 2.0f;
static const int MSG_SCHEDULE = 0;
static const int MSG_PROCESS = 1;
static const int MSG_HIDE = 2;

@interface JJToastParam : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, assign) NSTimeInterval time;
@property (nonatomic, strong) UIView *view;

@end

@implementation JJToastParam

@end

@interface JJToastView()<JJHandlerDelegate,JJPopupViewDelegate>

@property (nonatomic, strong) JJHandler *toastHandler;
@property (nonatomic, strong) JJPopupView *toastPopupView;
@property (nonatomic, strong) NSMutableArray *toastArray;
@property (nonatomic, assign) int retryCount;

@end
@implementation JJToastView

+ (instancetype)sharedInstance {
    static JJToastView *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JJToastView alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _toastHandler = [JJHandler mainHandlerWithDelegate:self];
        _toastArray = [NSMutableArray arrayWithCapacity:2];
        _retryCount = 0;
    }
    return self;
}
//MARK: - Public
+ (void)show:(NSString *)text {
    [JJToastView show:text icon:nil];
}

+ (void)show:(NSString *)text icon:(UIImage *)icon {
    [JJToastView show:text icon:icon time:kShowTime];
}

+ (void)show:(NSString *)text icon:(UIImage *)icon time:(NSTimeInterval)time {
    if (!IsValidateString(text)) {
        NSAssert(NO, @"Show toast with invalid text");
        return;
    }
    
    [[JJToastView sharedInstance] scheduleToast:text icon:icon time:time view:nil];
}

//MARK: - JJHandlerDelegate
- (void)handleMessage:(int)what object:(id)anObject {
    switch (what) {
        case MSG_SCHEDULE:
        {
            [self.toastArray addObject:anObject];
            
            [self.toastHandler sendMessage:MSG_PROCESS];
        }
            break;
        case MSG_PROCESS:
        {
            if (self.toastArray.count == 0 || self.toastPopupView.isShowing) {
                return;
            }
            
            // Toast 是全局显示的，所以需要加到window上
            UIWindow *window = [JJRouter rootViewController].view.window;
            
            if (window) {
                JJToastParam *param = self.toastArray.firstObject;
                [self.toastArray removeObjectAtIndex:0];
                
                UIView *toastView = [self buildToastView:param.text icon:param.icon];
                self.toastPopupView.contentView = toastView;
                
                UIView *showInView = window;
                if (param.view && param.view.window) {
                    showInView = param.view;
                }
                
                [self.toastPopupView showInView:showInView contraintsHandler:^(UIView * _Nonnull popView) {
                    [toastView mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.center.equalTo(popView);
                        make.width.lessThanOrEqualTo(popView.mas_width).valueOffset(@(-30));
                    }];
                }];
                
                [self.toastHandler sendMessageDelayed:MSG_HIDE delayMills:param.time * 1000];
                
                self.retryCount = 0;
            } else if (self.retryCount <= 3) {
                self.retryCount += 1;
                
                [self.toastHandler sendMessageDelayed:MSG_PROCESS delayMills:1000];
            } else {
                [self.toastArray removeAllObjects];
            }
        }
            break;
        case MSG_HIDE:
        {
            [self.toastPopupView hide];
        }
            break;
        default:
            break;
    }
}

//MARK: - JJPopupViewDelegate
- (void)jjPopupView:(JJPopupView *)popupView didHide:(BOOL)touchOutside {
    [popupView.contentView removeFromSuperview];
    popupView.contentView = nil;
    
    [self.toastHandler sendMessage:MSG_PROCESS];
}

//MARK: - Private
- (void)scheduleToast:(NSString *)text icon:(UIImage *)icon time:(NSTimeInterval)time view:(UIView *)view {
    JJToastParam *param = [[JJToastParam alloc] init];
    param.text = text;
    param.icon = icon;
    param.time = time;
    param.view = view;
    
    [self.toastHandler sendMessage:MSG_SCHEDULE object:param];
}

- (UIView *)buildToastView:(NSString *)text icon:(UIImage *)icon {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    effectView.layer.cornerRadius = 6;
    effectView.layer.masksToBounds = YES;
    
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    label.numberOfLines = 0;
    
    [effectView.contentView addSubview:label];
    
    if (icon) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:icon];
        imageView.contentMode = UIViewContentModeCenter;
        
        [effectView.contentView addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(effectView.contentView);
            make.top.equalTo(effectView.contentView).offset(15);
            make.width.height.mas_equalTo(37);
        }];
        
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom).offset(10);
            make.left.equalTo(effectView.contentView).offset(18.5);
            make.right.equalTo(effectView.contentView).offset(-18.5);
            make.bottom.equalTo(effectView.contentView).offset(-15);
            make.width.mas_greaterThanOrEqualTo(52);
            
        }];
    } else {
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.equalTo(effectView.contentView).offset(10);
            make.right.bottom.equalTo(effectView.contentView).offset(-10);
        }];
    }
    
    return effectView;
}


//MARK: - Getter & Setter
- (JJPopupView *)toastPopupView {
    if (!_toastPopupView) {
        _toastPopupView = [[JJPopupView alloc] init];
        _toastPopupView.delegate = self;
        _toastPopupView.userInteractionEnabled = NO;
    }
    return _toastPopupView;
}
@end

#pragma clang diagnostic pop
