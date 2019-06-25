//
//  BRNetWatcherViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/7.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRNetWatcherViewController.h"
#import "BRNetWorkNodeCell.h"
#import "BRBlockInfoCell.h"

@interface BRNetWatcherViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *networkNodeBtn;

@property (nonatomic, strong) UIButton  *blockBtn;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, assign) BOOL isNetWorkNodeData;

@end

@implementation BRNetWatcherViewController

- (UIButton *)networkNodeBtn {
    if(_networkNodeBtn == nil) {
        _networkNodeBtn = [[UIButton alloc] init];
#warning Language International
        [_networkNodeBtn setTitle:@"网络节点" forState:UIControlStateNormal];
        _networkNodeBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_networkNodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _networkNodeBtn.backgroundColor = MAIN_COLOR;
        _networkNodeBtn.layer.cornerRadius = 3;
        _networkNodeBtn.layer.masksToBounds = YES;
        [_networkNodeBtn addTarget:self action:@selector(loadNetworkNodeData) forControlEvents:UIControlEventTouchUpInside];
    }
    return _networkNodeBtn;
}

- (UIButton *)blockBtn {
    if(_blockBtn == nil) {
        _blockBtn = [[UIButton alloc] init];
#warning Language International
        [_blockBtn setTitle:@"区块" forState:UIControlStateNormal];
        _blockBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_blockBtn setTitleColor:ColorFromRGB255(106, 106, 106) forState:UIControlStateNormal];
        _blockBtn.backgroundColor = ColorFromRGB255(205, 205, 205);
        _blockBtn.layer.cornerRadius = 3;
        _blockBtn.layer.masksToBounds = YES;
        [_blockBtn addTarget:self action:@selector(loadBlockData) forControlEvents:UIControlEventTouchUpInside];
    }
    return _blockBtn;
}

- (UITableView *)tableView {
    if(_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = NO;
    }
    return _tableView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
#warning Language International
    self.navigationItem.title = @"网络监视器";
    self.view.backgroundColor = [UIColor whiteColor];
    self.isNetWorkNodeData = YES;
    [self creatUI];
}

#pragma mark - 创建UI
- (void) creatUI {
    [self.view addSubview:self.networkNodeBtn];
    [self.view addSubview:self.blockBtn];
    [self.view addSubview:self.tableView];
    
    [self.networkNodeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(27 + SafeAreaViewHeight);
        make.left.equalTo(self.view.mas_left).offset(30);
        make.right.equalTo(self.blockBtn.mas_left).offset(-25);
        make.width.equalTo(self.blockBtn.mas_width);
        make.height.equalTo(@(30));
    }];
    
    [self.blockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(27 + SafeAreaViewHeight);
        make.left.equalTo(self.networkNodeBtn.mas_right).offset(25);
        make.right.equalTo(self.view.mas_right).offset(-30);
        make.width.equalTo(self.networkNodeBtn.mas_width);
        make.height.equalTo(@(30));
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.networkNodeBtn.mas_bottom).offset(15);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom).offset(SafeAreaBottomHeight);
    }];
}

#pragma mark - 加载网络节点数据
- (void) loadNetworkNodeData {
    [self.blockBtn setTitleColor:ColorFromRGB255(106, 106, 106) forState:UIControlStateNormal];
    self.blockBtn.backgroundColor = ColorFromRGB255(205, 205, 205);
    [self.networkNodeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.networkNodeBtn.backgroundColor = MAIN_COLOR;
    self.isNetWorkNodeData = YES;
    
    [self.tableView reloadData];
}

#pragma mark - 加载区块数据
- (void) loadBlockData {
    [self.networkNodeBtn setTitleColor:ColorFromRGB255(106, 106, 106) forState:UIControlStateNormal];
    self.networkNodeBtn.backgroundColor = ColorFromRGB255(205, 205, 205);
    [self.blockBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.blockBtn.backgroundColor = MAIN_COLOR;
    self.isNetWorkNodeData = NO;
    
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *netWorkNodeString = @"BRNetWorkNodeCell";
    static NSString *blockString = @"BRBlockInfoCell";
    if(self.isNetWorkNodeData) {
        BRNetWorkNodeCell *cell = [tableView dequeueReusableCellWithIdentifier:netWorkNodeString];
        if(cell == nil) {
            cell = [[BRNetWorkNodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:netWorkNodeString];
        }
        cell.iPAddress.text = @"45.15.12.12";
        cell.blockNumber.text = @"45454weqweqqewblocks";
        cell.coinName.text = @"safe core safe core safe core safe core safe core";
        cell.protocolName.text = @"protocol:70121";
        cell.speed.text = @"12321ms";
        return  cell;
    } else {
        BRBlockInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:blockString];
        if(cell == nil) {
            cell = [[BRBlockInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:blockString];
        }
        cell.blockNumber.text = @"515121313123341313213";
        cell.time.text = @"2018/09/04 上午 05:10";
        cell.block_1.text = @"00000000000000000";
        cell.block_2.text = @"00000000000000000";
        cell.block_3.text = @"00000000000000000";
        cell.block_4.text = @"00000000000000000";
        cell.block_5.text = @"00000000000000000";
        cell.block_6.text = @"00000000000000000";
        cell.block_7.text = @"00000000000000000";
        cell.block_8.text = @"00000000000000000";
        return cell;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

@end
