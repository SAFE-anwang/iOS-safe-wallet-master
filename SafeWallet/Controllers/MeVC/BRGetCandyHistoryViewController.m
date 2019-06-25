//
//  BRGetCandyHistoryViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/23.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRGetCandyHistoryViewController.h"
#import "BRCandyHistoryCell.h"
#import "BRCandyHistoryDetailController.h"
#import "BRCoreDataManager.h"
#import "BRGetCandyEntity+CoreDataProperties.h"
#import <MJRefresh.h>
#import "AppTool.h"
#import "BRSafeUtils.h"
#import "BRListEmptyView.h"

@interface BRGetCandyHistoryViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *historyTableView;

@property (nonatomic,strong) NSMutableArray *dataSouce;

@property (nonatomic,assign) int page;

@property (nonatomic,assign) int pageSize;

@property (nonatomic,strong) BRListEmptyView *lishEmptyView;

@end

@implementation BRGetCandyHistoryViewController

- (NSMutableArray *)dataSouce {
    if(_dataSouce == nil) {
        _dataSouce = [NSMutableArray array];
    }
    return _dataSouce;
}

- (BRListEmptyView *)lishEmptyView {
    if(_lishEmptyView == nil) {
        _lishEmptyView = [[BRListEmptyView alloc] init];
        _lishEmptyView.titleLabel.text = NSLocalizedString(@"No candy record yet", nil);
        _lishEmptyView.hidden = YES;
    }
    return _lishEmptyView;
}

- (UITableView *)historyTableView {
    if(_historyTableView == nil) {
        _historyTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height - SafeAreaBottomHeight) style:UITableViewStylePlain];
        _historyTableView.backgroundColor = [UIColor whiteColor];
        _historyTableView.delegate = self;
        _historyTableView.dataSource = self;
        _historyTableView.showsVerticalScrollIndicator = NO;
        _historyTableView.estimatedSectionHeaderHeight = 0;
        _historyTableView.estimatedSectionFooterHeight = 0;
        _historyTableView.estimatedRowHeight = 0;
        _historyTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _historyTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.navigationItem.title = NSLocalizedString(@"Candy record", nil);
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnClick)];
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.historyTableView];
    
    [self refreshSetting];
    
    [self.view addSubview:self.lishEmptyView];
    [self.lishEmptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.centerY.equalTo(self.view.mas_centerY).offset(-40);
        make.height.equalTo(@(40));
    }];
}

- (void) returnClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshSetting {
    self.pageSize = 50;
    
    @WeakObj(self);
    //..下拉刷新
    self.historyTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [selfWeak loadNewData];
    }];
    [self.historyTableView.mj_header beginRefreshing];
    
    //..上拉加载更多
    self.historyTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [selfWeak loadData];
    }];
    self.historyTableView.mj_footer.hidden = YES;
}

- (void) loadNewData {
    self.page = 0;
    NSArray *newArray = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] objectsSortedBy:@"blockTime" ascending:NO offset:self.page limit:self.pageSize entity:@"BRGetCandyEntity"]];
    if(newArray.count == 0) {
#warning Language International
//        [AppTool showMessage:@"暂无数据" showView:self.view];
        [self.historyTableView.mj_header endRefreshing];
        self.historyTableView.mj_footer.hidden = YES;
        self.historyTableView.hidden = YES;
        self.lishEmptyView.hidden = NO;
        return;
    }
    self.historyTableView.hidden = NO;
    self.lishEmptyView.hidden = YES;
    [self.dataSouce removeAllObjects];
    [self.dataSouce addObjectsFromArray:newArray];
    if(self.dataSouce.count == self.pageSize) {
        self.historyTableView.mj_footer.hidden = NO;
    }
    [self.historyTableView.mj_header endRefreshing];
    [self.historyTableView reloadData];
}

- (void) loadData {
    @WeakObj(self);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        NSArray *nextArray = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] objectsSortedBy:@"blockTime" ascending:NO offset:(self.page + 1) * self.pageSize limit:self.pageSize entity:@"BRGetCandyEntity"]];
        if(nextArray.count == 0) {
            [AppTool showMessage:NSLocalizedString(@"No more data yet", nil) showView:selfWeak.view];
            [selfWeak.historyTableView.mj_footer endRefreshing];
            self.historyTableView.mj_footer.hidden = YES;
            return;
        }
        self.page += 1;
        [selfWeak.dataSouce addObjectsFromArray:nextArray];
        [selfWeak.historyTableView.mj_footer endRefreshing];
        [selfWeak.historyTableView reloadData];
    });
}

#pragma mark - UITableViewDataSource UITableViewDeleagate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSouce.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"BRCandyHistoryCell";
    BRCandyHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[BRCandyHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    BRGetCandyEntity *getCandyEntity = self.dataSouce[indexPath.row];
    cell.assetNameLable.text = getCandyEntity.assetName;
    cell.amountLable.text = [BRSafeUtils amountForAssetAmount:[getCandyEntity.candyAmount unsignedLongLongValue] decimals:[getCandyEntity.decimals integerValue]];
    cell.addressLable.text = getCandyEntity.address;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BRCandyHistoryDetailController *detailVc = [[BRCandyHistoryDetailController alloc] init];
    detailVc.getCandyEntity = self.dataSouce[indexPath.row];
    [self.navigationController pushViewController:detailVc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
