//
//  CGDetailViewController.m
//  JJDraw
//
//  Created by xiedong on 2020/10/30.
//

#import "CGDetailViewController.h"
#import "CGBaseView.h"

@interface CGDetailViewController ()

@property (nonatomic, strong) CGBaseView *baseView;

@property (nonatomic, copy) NSString *className;

@end

@implementation CGDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"CGDetailViewController";
    
    if (IsValidateString(self.className)) {
        Class cls = NSClassFromString(self.className);
        self.baseView = [[cls alloc] init];
        [self.view addSubview:self.baseView];
        
        [self.baseView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.offset(0);
            make.top.offset(10);
            make.left.offset(10);
            make.right.offset(-10);
            make.height.equalTo(self.baseView.mas_width);
        }];
    }
}

- (void)handleRouter:(NSDictionary *)params {
    if (IsValidateDict(params)) {
        self.className = params[@"className"];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.baseView) {
        [self.baseView viewNotifiDisplayChanged];
    }
}

@end
