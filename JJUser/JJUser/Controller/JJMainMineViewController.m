//
//  JJMainMineViewController.m
//  JJUser
//
//  Created by xiedong on 2020/10/24.
//

#import "JJMainMineViewController.h"

@interface JJMainMineViewController ()

@end

@implementation JJMainMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"mine";
    self.view.backgroundColor = UIColor.yellowColor;
    // Do any additional setup after loading the view.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    JJRouterNavigate(JJRouterDrawCG);
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
