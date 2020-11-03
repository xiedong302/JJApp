//
//  TestViewController.m
//  JJAppMain
//
//  Created by xiedong on 2020/9/27.
//  Copyright © 2020 xiedong. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()
{
    NSInteger _currentPage;
    JJPageControl *_pageControl;
}
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = UIColor.whiteColor;
    
    _currentPage = 0;
    
    JJPageControl *control = [JJPageControl pageControl];
    [control setNumberOfPages:5];
    [control setCurrentPage:_currentPage];
    [self.view addSubview:control];
    _pageControl = control;
    [control mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.offset(200);
        make.height.offset(10);
    }];
    
    NSTimer *time = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:time forMode:NSRunLoopCommonModes];
    
    // Do any additional setup after loading the view.
}

- (void)timerAction {
    _currentPage++;
    if (_currentPage >= 5) {
        _currentPage = 0;
    }
    [_pageControl setCurrentPage:_currentPage];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
