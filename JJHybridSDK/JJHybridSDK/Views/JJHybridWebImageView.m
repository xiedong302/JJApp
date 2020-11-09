//
//  JJHybridWebImageView.m
//  JJHybridSDK
//
//  Created by xiedong on 2020/11/9.
//

#import "JJHybridWebImageView.h"
#import "JJHybridHttpsAvoidURLSession.h"

@interface JJHybridWebImageView ()

@property (nonatomic, strong) NSURLSessionTask *imageDataTask;

@end

@implementation JJHybridWebImageView

- (void)dealloc {
    [self cancelDownload];
}

- (void)setImageWithURL:(NSString *)url placeholder:(UIImage *)placeholder {
    [self cancelDownload];
    
    __weak typeof(self) weakSelf = self;
    
    self.imageDataTask = [[JJHybridHttpsAvoidURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:url] completionHandler:^(NSData * _Nonnull data, NSURLResponse * _Nonnull response, NSError * _Nonnull error) {
        __strong JJHybridWebImageView * strongSelf = weakSelf;
        
        if (!strongSelf) {
            return;
        }
        
        UIImage *image = nil;
        
        if (!error) {
            image = [UIImage imageWithData:data];
        }
        
        if (!image) {
            image = placeholder;
        }
        
        if (image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *scaleImage = image;
                
                CGFloat height = strongSelf.frame.size.height;
                CGFloat heightScale = height / image.size.height;
                CGFloat scaleImageWidth = image.size.width * heightScale;
                
                UIGraphicsBeginImageContextWithOptions(CGSizeMake(scaleImageWidth, height), NO, UIScreen.mainScreen.scale);
                [image drawInRect:CGRectMake(0, 0, scaleImageWidth, height)];
                scaleImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                [strongSelf setImage:scaleImage];
            });
        }
    }];
    
    [self.imageDataTask resume];
}

- (void)cancelDownload {
    if (self.imageDataTask) {
        [self.imageDataTask cancel];
        
        self.imageDataTask = nil;
    }
}
@end
