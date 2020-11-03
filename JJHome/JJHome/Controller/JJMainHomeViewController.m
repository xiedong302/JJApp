//
//  JJMainHomeViewController.m
//  JJHome
//
//  Created by xiedong on 2020/10/24.
//

#import "JJMainHomeViewController.h"

@interface JJMainHomeViewController ()

@end

@implementation JJMainHomeViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"home";
    
    self.view.backgroundColor = UIColor.brownColor;
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    JJRouterNavigate(JJRouterDrawCA);
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
