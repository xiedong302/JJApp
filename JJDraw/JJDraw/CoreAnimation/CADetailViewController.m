//
//  CADetailViewController.m
//  JJDraw
//
//  Created by xiedong on 2020/10/28.
//

#import "CADetailViewController.h"
#import "CABaseView.h"
@interface CADetailViewController ()

@property (nonatomic, copy) NSString *className;
@property (nonatomic, strong) CABaseView *baseView;
@end

@implementation CADetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"CADetailViewController";
    
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


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    if (self.baseView) {
        [self.baseView stopAnimation];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.baseView) {
        [self.baseView startAnimation];
    }
}

- (void)handleRouter:(NSDictionary *)params {
    if (IsValidateDict(params)) {
        self.className = params[@"className"];
    }
}

@end
