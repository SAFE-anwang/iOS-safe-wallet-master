//
//  BRCandyHistoryController.m
//  dashwallet
//
//  Created by joker on 2018/7/10.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRCandyTXHistoryController.h"
#import "BRCandyHistoryCell.h"
#import "BRGetCandyEntity+CoreDataProperties.h"
#import "BRCoreDataManager.h"
#import "BRTransaction.h"
#import "NSData+Bitcoin.h"
#import "BRCandyHistoryDetailController.h"
#import "BRListEmptyView.h"

static NSString *kCellReuseID = @"kCellReuseID";

@interface BRCandyTXHistoryController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray<BRGetCandyEntity *> *list;

@property (nonatomic,strong) BRListEmptyView *lishEmptyView;

@end

@implementation BRCandyTXHistoryController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
        [_tableView registerClass:[BRCandyHistoryCell class] forCellReuseIdentifier:kCellReuseID];
        _tableView.rowHeight = 66;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    return _tableView;
}

- (BRListEmptyView *)lishEmptyView {
    if(_lishEmptyView == nil) {
        _lishEmptyView = [[BRListEmptyView alloc] init];
        _lishEmptyView.titleLabel.text = NSLocalizedString(@"No candy available yet", nil);
        _lishEmptyView.hidden = YES;
    }
    return _lishEmptyView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.title = NSLocalizedString(@"Candy record", nil);
    [self.view addSubview:self.lishEmptyView];
    [self.lishEmptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.centerY.equalTo(self.view.mas_centerY).offset(-40);
        make.height.equalTo(@(40));
    }];
//    if(self.list.count == 0) {
//        self.lishEmptyView.hidden = NO;
//        self.tableView.hidden = YES;
//    } else {
//        self.lishEmptyView.hidden = YES;
//        self.tableView.hidden = NO;
//    }
}

- (void)setCandyTx:(BRTransaction *)candyTx {
    _candyTx = candyTx;
    if(self.list == nil) {
        self.list = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] entity:@"BRGetCandyEntity" objectsMatching:[NSPredicate predicateWithFormat:@"txId = %@", [NSData dataWithUInt256:self.candyTx.txHash]]]];
    }
    BRLog(@"LIST.COUNT = %zd", self.list.count);
    if(self.list.count != 0) {
        self.lishEmptyView.hidden = YES;
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    } else {
        self.lishEmptyView.hidden = NO;
        self.tableView.hidden = YES;
    }
}

#pragma mark ------ UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BRCandyHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseID forIndexPath:indexPath];
    cell.candy = self.list[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BRCandyHistoryDetailController *detailVc = [[BRCandyHistoryDetailController alloc] init];
    detailVc.getCandyEntity = self.list[indexPath.row];
    [self.navigationController pushViewController:detailVc animated:YES];
}

@end
