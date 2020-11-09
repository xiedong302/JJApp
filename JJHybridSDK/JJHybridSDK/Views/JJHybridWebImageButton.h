//
//  JJHybridWebImageButton.h
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol JJHybridWebImageButtonDelegate <NSObject>

@optional
- (void)jjHybridWebImageLoadFinished;

@end

@interface JJHybridWebImageButton : UIButton

@property (nonatomic, weak) id<JJHybridWebImageButtonDelegate> delegate;

- (void)setImageWithURL:(NSString *)url placeholder:(UIImage *)placeholder;

@end

NS_ASSUME_NONNULL_END
