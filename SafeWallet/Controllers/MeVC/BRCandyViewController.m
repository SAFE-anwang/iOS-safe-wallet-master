//
//  BRCandyViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/23.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRCandyViewController.h"
#import "BRPublishCandyViewController.h"
#import "BRGetCandyViewController.h"
#import "BRGetCandyHistoryViewController.h"

@interface BRCandyViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *candyTableview;

@end

@implementation BRCandyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"Candy",nil);
    self.view.backgroundColor = [UIColor whiteColor];
    [self initCandyTableview];
}

- (void)initCandyTableview {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height - SafeAreaBottomHeight) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.estimatedRowHeight = 0;
    tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    [self.view addSubview:tableView];
    self.candyTableview = tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"cellId";
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.imageView.image = [UIImage imageNamed:@"tg"];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (indexPath.row == 0) {
        
        cell.textLabel.text = NSLocalizedString(@"Publish candy",nil);
        
    } else if (indexPath.row == 1) {
        
        cell.textLabel.text = NSLocalizedString(@"Get candy",nil);
        
    } else {
        
        cell.textLabel.text = NSLocalizedString(@"Got Record",nil);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        
        BRPublishCandyViewController *publishVc = [[BRPublishCandyViewController alloc] init];
        [self.navigationController pushViewController:publishVc animated:YES];
        
    } else if (indexPath.row == 1) {
        
        BRGetCandyViewController *getVc = [[BRGetCandyViewController alloc] init];
        [self.navigationController pushViewController:getVc animated:YES];
        
    } else {
        
        BRGetCandyHistoryViewController *historyVc = [[BRGetCandyHistoryViewController alloc] init];
        [self.navigationController pushViewController:historyVc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
