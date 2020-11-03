//
//  CGViewController.m
//  JJDraw
//
//  Created by xiedong on 2020/10/30.
//

#import "CGViewController.h"

static NSString * const UITableViewCellIdentifier = @"CGViewControllerCell";

@interface CGViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation CGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"CoreGraphics";
    
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:UITableViewCellIdentifier];
    
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *str =  self.dataSource[indexPath.row];
    
    if (IsValidateString(str)) {
        NSDictionary *dic = @{@"className":str};
        [JJRouter navigate:[JJRouterDrawCGDetail jj_buildURLWithQueryParams:dic]];
    }
}

//MARK: - Getter && Setter

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 50;
        [_tableView registerClass:UITableViewCell.class forCellReuseIdentifier:UITableViewCellIdentifier];
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    return _tableView;
}

- (NSArray *)dataSource {
    if (!_dataSource) {
        _dataSource = @[@"CGLineView",
                        @"CGGradientView",
                        @"CGGradientView1",
                        @"CGContextCustomView",];
    }
    return _dataSource;
}

@end
