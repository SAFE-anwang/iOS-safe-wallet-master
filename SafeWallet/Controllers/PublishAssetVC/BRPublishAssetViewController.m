//
//  BRPublishAssetViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/23.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPublishAssetViewController.h"
#import "BRPublishAssetTitleCell.h"
#import "BRPublishAssetEditViewController.h"
#import "BRAdditionalDistributionAssetViewController.h"
#import "BRPublishCandyViewController.h"
#import "BRGetCandyViewController.h"
#import "BRPeerManager.h"
#import "BRSafeUtils.h"
#import "BRAlertView.h"

//@interface BRPublishAssetViewController () <UITableViewDelegate, UITableViewDataSource>
//
//@property (nonatomic, strong) UITableView *tableView;
//
//@end

@implementation BRPublishAssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = NSLocalizedString(@"SAFE wallet", nil);
    
    [self creatUI];
}

//- (UITableView *)tableView {
//    if(_tableView == nil) {
//        _tableView = [[UITableView alloc] init];
//        _tableView.dataSource = self;
//        _tableView.delegate = self;
//        _tableView.showsVerticalScrollIndicator = NO;
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    }
//    return _tableView;
//}
//
//#pragma mark - 创建UI
//- (void) creatUI {
//    [self.view addSubview:self.tableView];
//
//    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view.mas_left);
//        make.right.equalTo(self.view.mas_right);
//        make.top.equalTo(self.view.mas_top);
//        make.bottom.equalTo(self.view.mas_bottom);
//    }];
//}
//
//#pragma mark - UITableViewDelegate UITableViewDataSource
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 4;
//}
//
//- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString  *publishAssettTitleString = @"BRPublishAssetTitleCell";
//    BRPublishAssetTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssettTitleString];
//    if(cell == nil) {
//        cell = [[BRPublishAssetTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssettTitleString];
//    }
//    if(indexPath.row == 0) {
//        cell.title.text = @"发行资产";
//    } else if (indexPath.row == 1) {
//        cell.title.text = @"追加发行";
//    } else if (indexPath.row == 2) {
//        cell.title.text = @"发放糖果";
//    } else {
//        cell.title.text = @"领取糖果";
//    }
//    return cell;
//}
//
//-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if(indexPath.row == 0) {
//        BRPublishAssetEditViewController *publishAssetEditVC = [[BRPublishAssetEditViewController alloc] init];
//        publishAssetEditVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:publishAssetEditVC animated:YES];
//    } else if (indexPath.row == 1) {
//        BRAdditionalDistributionAssetViewController *additionalDistributionAssetVC = [[BRAdditionalDistributionAssetViewController alloc] init];
//        additionalDistributionAssetVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:additionalDistributionAssetVC animated:YES];
//    } else if (indexPath.row == 2) {
//        BRPublishCandyViewController *publishCandyVC = [[BRPublishCandyViewController alloc] init];
//        publishCandyVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:publishCandyVC animated:YES];
//    } else if (indexPath.row == 3) {
//        BRGetCandyViewController *getCandyVC = [[BRGetCandyViewController alloc] init];
//        getCandyVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:getCandyVC animated:YES];
//    }
//}
//
//- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 100;
//}

#pragma mark - 创建UI
#warning Localizable.string
- (void) creatUI {
    CGFloat margin = 10;
    CGFloat width = (SCREEN_WIDTH - margin * 3) / 2;
    UIView *leftView = [[UIView alloc] init];
    CGFloat fontSize = 15.0f;
    leftView.backgroundColor = ColorFromRGB255(28, 175, 212);
    leftView.layer.cornerRadius = 5.0;
    leftView.layer.masksToBounds = YES;
    [self.view addSubview:leftView];
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(margin);
        make.top.equalTo(self.view.mas_top).offset(margin + SafeAreaViewHeight);
        make.width.equalTo(@(width));
        make.height.equalTo(@(width));
    }];
    
    UIButton *leftBtn = [[UIButton alloc] initWithFrame:leftView.bounds];
    [leftBtn addTarget:self action:@selector(loadPublishAssetEditVC) forControlEvents:UIControlEventTouchUpInside];
    [leftView addSubview:leftBtn];
    [leftBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftView.mas_left);
        make.right.equalTo(leftView.mas_right);
        make.top.equalTo(leftView.mas_top);
        make.bottom.equalTo(leftView.mas_bottom);
    }];
    
    UIImageView *leftImageView = [[UIImageView alloc] init];
    leftImageView.image = [UIImage imageNamed:@"ps_zcfx"];
    [leftView addSubview:leftImageView];
    [leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(leftView.mas_width).multipliedBy(0.4);
        make.center.equalTo(leftView);
    }];
    UILabel *leftLabel = [[UILabel alloc] init];
    leftLabel.text = NSLocalizedString(@"Asset issuance", nil);
    leftLabel.font = [UIFont systemFontOfSize:fontSize];
    leftLabel.textAlignment = NSTextAlignmentCenter;
    leftLabel.textColor = [UIColor whiteColor];
    [leftView addSubview:leftLabel];
    [leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftView.mas_left);
        make.right.equalTo(leftView.mas_right);
        make.bottom.equalTo(leftView.mas_bottom).offset(-5);
        
        make.height.equalTo(@(20));
    }];
    
    UIView *rightTopleftView = [[UIView alloc] init];
    rightTopleftView.backgroundColor = ColorFromRGB255(127, 189, 47);
    rightTopleftView.layer.cornerRadius = 5.0;
    rightTopleftView.layer.masksToBounds = YES;
    [self.view addSubview:rightTopleftView];
    [rightTopleftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(leftView.mas_right).offset(margin);
        make.top.equalTo(self.view.mas_top).offset(margin + SafeAreaViewHeight);
        make.width.equalTo(@(width));
        make.height.equalTo(@(width));
    }];

    UIButton *rightTopleftButton = [[UIButton alloc] init];
    [rightTopleftButton addTarget:self action:@selector(laodAdditionalDistributionAssetVC) forControlEvents:UIControlEventTouchUpInside];
    [rightTopleftView addSubview:rightTopleftButton];
    [rightTopleftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rightTopleftView.mas_left);
        make.right.equalTo(rightTopleftView.mas_right);
        make.top.equalTo(rightTopleftView.mas_top);
        make.bottom.equalTo(rightTopleftView.mas_bottom);
    }];

    UIImageView *rightTopLeftImageView = [[UIImageView alloc] init];
    rightTopLeftImageView.image = [UIImage imageNamed:@"ps_zczjfa"];
    [rightTopleftView addSubview:rightTopLeftImageView];
    [rightTopLeftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(rightTopleftView);
        make.width.height.equalTo(rightTopleftView.mas_width).multipliedBy(0.4);
    }];
    UILabel *rightTopLeftLabel = [[UILabel alloc] init];
    rightTopLeftLabel.text = NSLocalizedString(@"Additional issue", nil);
    rightTopLeftLabel.textColor = [UIColor whiteColor];
    rightTopLeftLabel.font = [UIFont systemFontOfSize:fontSize];
    rightTopLeftLabel.textAlignment = NSTextAlignmentCenter;
    [rightTopleftView addSubview:rightTopLeftLabel];
    [rightTopLeftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rightTopleftView.mas_left);
        make.right.equalTo(rightTopleftView.mas_right);
        make.height.equalTo(@(20));
        make.bottom.equalTo(rightTopleftView.mas_bottom).offset(-5);
    }];

    UIView *rightTopRightView = [[UIView alloc] init];
    rightTopRightView.backgroundColor = ColorFromRGB255(217, 148, 41);
    rightTopRightView.layer.cornerRadius = 5.0;
    rightTopRightView.layer.masksToBounds = YES;
    [self.view addSubview:rightTopRightView];
    [rightTopRightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(margin);
        make.top.equalTo(leftView.mas_bottom).offset(margin);
        make.width.equalTo(@(width));
        make.height.equalTo(@(width));
    }];

    UIButton *rightTopRightBtn = [[UIButton alloc] init];
    [rightTopRightBtn addTarget:self action:@selector(loadPublishCandyVC) forControlEvents:UIControlEventTouchUpInside];
    [rightTopRightView addSubview:rightTopRightBtn];
    [rightTopRightBtn  mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rightTopRightView.mas_left);
        make.right.equalTo(rightTopRightView.mas_right);
        make.top.equalTo(rightTopRightView.mas_top);
        make.bottom.equalTo(rightTopRightView.mas_bottom);
    }];

    UIImageView *rightTopRightImageView = [[UIImageView alloc] init];
    rightTopRightImageView.image = [UIImage imageNamed:@"ps_fftg"];
    [rightTopRightView addSubview:rightTopRightImageView];
    [rightTopRightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(rightTopRightView);
        make.width.height.mas_equalTo(rightTopRightView.mas_width).multipliedBy(0.4);
    }];
#warning Language International
    UILabel *rightTopRightLabel = [[UILabel alloc] init];
    rightTopRightLabel.text = NSLocalizedString(@"Issuing candy", nil);
    rightTopRightLabel.textColor = [UIColor whiteColor];
    rightTopRightLabel.font = [UIFont systemFontOfSize:fontSize];
    rightTopRightLabel.textAlignment = NSTextAlignmentCenter;
    [rightTopRightView addSubview:rightTopRightLabel];
    [rightTopRightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rightTopRightView.mas_left);
        make.right.equalTo(rightTopRightView.mas_right);
        make.bottom.equalTo(rightTopRightView.mas_bottom).offset(-5);
        make.height.equalTo(@(20));
    }];

    UIView *rightBottomView = [[UIView alloc] init];
    rightBottomView.backgroundColor = ColorFromRGB255(35, 213, 192);
    rightBottomView.layer.cornerRadius = 5.0;
    rightBottomView.layer.masksToBounds = YES;
    [self.view addSubview:rightBottomView];
    [rightBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rightTopRightView.mas_right).offset(margin);
        make.top.equalTo(rightTopleftView.mas_bottom).offset(margin);
        make.width.equalTo(@(width));
        make.height.equalTo(@(width));
    }];

    UIButton *rightBottomBtn = [[UIButton alloc] init];
    [rightBottomBtn addTarget:self action:@selector(loadGetCandyVC) forControlEvents:UIControlEventTouchUpInside];
    [rightBottomView addSubview:rightBottomBtn];
    [rightBottomBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rightBottomView.mas_left);
        make.right.equalTo(rightBottomView.mas_right);
        make.top.equalTo(rightBottomView.mas_top);
        make.bottom.equalTo(rightBottomView.mas_bottom);
    }];

    UIImageView *rightBottomImageView = [[UIImageView alloc] init];
    rightBottomImageView.image = [UIImage imageNamed:@"ps_lqtg"];
    [rightBottomView addSubview:rightBottomImageView];
    [rightBottomImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(rightBottomView.mas_top).offset(22);
        make.center.equalTo(rightBottomView);
        make.width.height.mas_equalTo(rightBottomView.mas_width).multipliedBy(0.4);
    }];
#warning Language International
    UILabel *rightBottomLabel = [[UILabel alloc] init];
    rightBottomLabel.text = NSLocalizedString(@"Receive candy", nil);
    rightBottomLabel.textColor = [UIColor whiteColor];
    rightBottomLabel.font = [UIFont systemFontOfSize:fontSize];
    rightBottomLabel.textAlignment = NSTextAlignmentCenter;
    [rightBottomView addSubview:rightBottomLabel];
    [rightBottomLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rightBottomView.mas_left);
        make.right.equalTo(rightBottomView.mas_right);
        make.bottom.equalTo(rightBottomView.mas_bottom).offset(-5);
        make.height.equalTo(@(20));
    }];
}

#pragma markl - 加载BRPublishAssetEditViewController 发行
- (void) loadPublishAssetEditVC {
    if([BRPeerManager sharedInstance].lastBlockHeight < DisableDash_TX_HEIGHT) {
        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"This feature is enabled when the block height is % d", nil), DisableDash_TX_HEIGHT] showView:self.view];
        return;
    }
//    if ([BRPeerManager sharedInstance].lastBlockHeight < TEST_START_SPOS_UNLOCK_HEIGHT && [BRPeerManager sharedInstance].lastBlockHeight >= TEST_START_SPOS_HEIGHT) {
//        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"This feature is enabled when the block height is % d", nil), TEST_START_SPOS_UNLOCK_HEIGHT] showView:nil];
//        return;
//    }
    BRPublishAssetEditViewController *publishAssetEditVC = [[BRPublishAssetEditViewController alloc] init];
    publishAssetEditVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:publishAssetEditVC animated:YES];
}

#pragma mark -加载BRAdditionalDistributionAssetVC 追加
- (void) laodAdditionalDistributionAssetVC {
    if([BRPeerManager sharedInstance].lastBlockHeight < DisableDash_TX_HEIGHT) {
        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"This feature is enabled when the block height is % d", nil), DisableDash_TX_HEIGHT] showView:self.view];
        return;
    }
//    if ([BRPeerManager sharedInstance].lastBlockHeight < TEST_START_SPOS_UNLOCK_HEIGHT && [BRPeerManager sharedInstance].lastBlockHeight >= TEST_START_SPOS_HEIGHT) {
//        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"This feature is enabled when the block height is % d", nil), TEST_START_SPOS_UNLOCK_HEIGHT] showView:nil];
//        return;
//    }
    BRAdditionalDistributionAssetViewController *additionalDistributionAssetVC = [[BRAdditionalDistributionAssetViewController alloc] init];
        additionalDistributionAssetVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:additionalDistributionAssetVC animated:YES];
}

#pragma mark -加载BRPublishCandyViewController
- (void) loadPublishCandyVC  {
    if([BRPeerManager sharedInstance].lastBlockHeight < DisableDash_TX_HEIGHT) {
        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"This feature is enabled when the block height is % d", nil), DisableDash_TX_HEIGHT] showView:self.view];
        return;
    }
//    if ([BRPeerManager sharedInstance].lastBlockHeight < TEST_START_SPOS_UNLOCK_HEIGHT && [BRPeerManager sharedInstance].lastBlockHeight >= TEST_START_SPOS_HEIGHT) {
//        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"This feature is enabled when the block height is % d", nil), TEST_START_SPOS_UNLOCK_HEIGHT] showView:nil];
//        return;
//    }
    BRPublishCandyViewController *publishCandyVC = [[BRPublishCandyViewController alloc] init];
    publishCandyVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:publishCandyVC animated:YES];
}

#pragma mark -加载BRGetCandyViewController
- (void) loadGetCandyVC {
    if([BRPeerManager sharedInstance].lastBlockHeight < DisableDash_TX_HEIGHT) {
        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"This feature is enabled when the block height is % d", nil), DisableDash_TX_HEIGHT] showView:self.view];
        return;
    }
//    if ([BRPeerManager sharedInstance].lastBlockHeight < TEST_START_SPOS_UNLOCK_HEIGHT && [BRPeerManager sharedInstance].lastBlockHeight >= TEST_START_SPOS_HEIGHT) {
//        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"This feature is enabled when the block height is % d", nil), TEST_START_SPOS_UNLOCK_HEIGHT] showView:nil];
//        return;
//    }
    BRGetCandyViewController *getCandyVC = [[BRGetCandyViewController alloc] init];
    getCandyVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:getCandyVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
