//
//  BRPublishAssetNextViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/9.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPublishAssetNextViewController.h"
#import "BRPublishAssetCell.h"
#import "BRPublishAssetNextCell.h"
#import "BRPublishAssetEditViewController.h"

@interface BRPublishAssetNextViewController () <UITableViewDelegate, UITableViewDataSource, BRPublishAssetNextCellDelegate>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation BRPublishAssetNextViewController

- (UITableView *)tableView {
    if(_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Asset issuance", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self creatUI];
}

#pragma mark - 创建UI
- (void) creatUI {
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

#pragma mark - UITalbeViewDelegate UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    } else if(indexPath.row == 1 || indexPath.row == 2) {
        static NSString *publishAssetString = @"BRPublishAssetCell";
        BRPublishAssetCell *cell = [tableView dequeueReusableCellWithIdentifier: publishAssetString];
        if(cell == nil) {
            cell = [[BRPublishAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
#warning Language International
        if(indexPath.row == 1) {
            cell.title.text = @"应用ID:";
        } else if (indexPath.row == 2) {
            cell.title.text = @"管理员地址:";
        }
        return cell;
    } else {
        static NSString *publishAssetNextString = @"BRPublishAssetNextCell";
        BRPublishAssetNextCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetNextString];
        if(cell == nil) {
            cell = [[BRPublishAssetNextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetNextString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        return cell;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        return 50;
    } else if (indexPath.row == 1 || indexPath.row == 2) {
        return 40;
    }
    return 80;
}

#pragma mark - BRPublishAssetNextCellDelegate
- (void)publishAssetNextCellLoadPublishDetails {
    BRPublishAssetEditViewController *publishAssetEditVC = [[BRPublishAssetEditViewController alloc] init];
    [self.navigationController pushViewController:publishAssetEditVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

@end
