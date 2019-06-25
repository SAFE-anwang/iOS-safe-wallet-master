//
//  BRGetCandyViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/23.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRGetCandyViewController.h"
#import "BRGetCandyCell.h"
#import "BRPutCandyEntity+CoreDataProperties.h"
#import "BRSafeUtils.h"
#import <MJRefresh.h>
#import "AppTool.h"
#import "BRWalletManager.h"
#import "BRBlockSafeEntity+CoreDataProperties.h"
#import "BRBlackHoleAddressSafeEntity+CoreDataProperties.h"
#import "BRBlockAvailableSafeEntity+CoreDataProperties.h"
#import "BRIssueDataEnity+CoreDataProperties.h"
#import "BRBubbleView.h"
#import "BRPeerManager.h"
#import "BRListEmptyView.h"
#import "BRCoreDataManager.h"
#import "BRCandyNumberEntity+CoreDataProperties.h"

@interface BRGetCandyViewController ()<UITableViewDelegate, UITableViewDataSource, BRGetCandyCellDelegate>

@property (nonatomic,strong) UITableView *getCandyTableview;
@property (nonatomic,strong) UIView *alertView;
@property (nonatomic,strong) UIVisualEffectView *effectView;
@property (nonatomic,assign) BOOL hasDone;//是否已经领取完

@property (nonatomic,strong) NSMutableArray *dataSouce;

@property (nonatomic,assign) int page;

@property (nonatomic,assign) int pageSize;

@property (nonatomic,strong) NSFetchRequest *fetchRequest;

@property (nonatomic,strong) NSData *txId;

@property (nonatomic,assign) uint64_t safeTotalAmount;

@property (nonatomic,strong) NSArray *blockAvailableSafeArray;

@property (nonatomic,strong) BRPutCandyEntity *txPutCandyEntity;

@property (nonatomic,assign) int addressIndex;

@property (nonatomic,strong) BRListEmptyView *lishEmptyView;

@property (nonatomic, strong) id syncFinishedObserver; // 同步完成通知

@property (nonatomic,strong) UIView *doorPlankView;

@property (nonatomic,assign) BOOL isAvailable; // 延迟点击标志

@property (nonatomic,assign) BOOL isHUDShow; // 是否显示弹框

@property (nonatomic,assign) BOOL isChainComplete;

@end

@implementation BRGetCandyViewController

- (UIView *)doorPlankView {
    if(_doorPlankView == nil) {
        _doorPlankView = [[UIView alloc] init];
        _doorPlankView.backgroundColor = [UIColor clearColor];
        _doorPlankView.hidden = YES;
    }
    return _doorPlankView;
}

- (NSMutableArray *)dataSouce {
    if(_dataSouce == nil) {
        _dataSouce = [NSMutableArray array];
    }
    return _dataSouce;
}

- (NSFetchRequest *)fetchRequest {
    if(_fetchRequest == nil) {
        _fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"BRPutCandyEntity"];
        _fetchRequest.predicate = [NSPredicate predicateWithFormat:@"isGetState = %@", @(1)];
        _fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"txTime" ascending:YES]];
    }
    return _fetchRequest;
}

- (UITableView *)getCandyTableview {
    if(_getCandyTableview == nil) {
        _getCandyTableview = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height - SafeAreaBottomHeight)];
        _getCandyTableview.backgroundColor = [UIColor whiteColor];
        _getCandyTableview.delegate = self;
        _getCandyTableview.dataSource = self;
        _getCandyTableview.showsVerticalScrollIndicator = NO;
        _getCandyTableview.estimatedSectionHeaderHeight = 0;
        _getCandyTableview.estimatedSectionFooterHeight = 0;
        _getCandyTableview.estimatedRowHeight = 0;
        _getCandyTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_getCandyTableview];
    }
    return _getCandyTableview;
}

- (BRListEmptyView *)lishEmptyView {
    if(_lishEmptyView == nil) {
        _lishEmptyView = [[BRListEmptyView alloc] init];
        _lishEmptyView.titleLabel.text = NSLocalizedString(@"No receivable candy yet", nil);
        _lishEmptyView.hidden = YES;
    }
    return _lishEmptyView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.title = NSLocalizedString(@"Receive candy", nil);
    self.view.backgroundColor = [UIColor whiteColor];
//    dispatch_async(dispatch_queue_create("updataGetCandy", NULL), ^{
        if([BRPeerManager sharedInstance].syncProgress >= 1) {
            BRLog(@"xxxxxxxxxxxx =========");
            NSArray *allList = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] fetchEntity:@"BRPutCandyEntity" withPredicate:nil]];
            BRLog(@"=========== %lu", (unsigned long)allList.count);
            [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlockAndWait:^{
                for(BRPutCandyEntity *e in allList) {
//                    if([e.isGetState integerValue] == 1 && [BRPeerManager sharedInstance].lastBlockHeight > [e.blockHeight unsignedLongLongValue] + [e.candyExpired integerValue] * BLOCKS_PER_MONTH - 2) {
//                        e.isGetState = @(3);
//                    }
                    
                    if ([e.isGetState integerValue] == 1 && [e.blockHeight unsignedLongLongValue] < TEST_START_SPOS_HEIGHT) {
                        long long diffBlock = 0;
                        long long diffHeight = [e.blockHeight unsignedLongLongValue] + [e.candyExpired integerValue] * BLOCKS_PER_MONTH - TEST_START_SPOS_HEIGHT;
                        if (diffHeight > 0) {
                            diffBlock = ([e.blockHeight unsignedLongLongValue] + [e.candyExpired integerValue] * BLOCKS_PER_MONTH - TEST_START_SPOS_HEIGHT) * TEST_START_SPOS_BlockTimeRatio + TEST_START_SPOS_HEIGHT - 3 * BLOCKS_SPOS_PER_DAY;
                        } else {
                            diffBlock = [e.blockHeight unsignedLongLongValue] + [e.candyExpired integerValue] * BLOCKS_PER_MONTH - 2;
                        }
                        
                        if([BRPeerManager sharedInstance].lastBlockHeight > diffBlock) {
                            e.isGetState = @(3);
                        }
                    } else if ([e.isGetState integerValue] == 1 && [BRPeerManager sharedInstance].lastBlockHeight > [e.blockHeight unsignedLongLongValue] + [e.candyExpired integerValue] * BLOCKS_SPOS_PER_MONTH - 3 * BLOCKS_SPOS_PER_DAY) {
                         e.isGetState = @(3);
                    }
                }
                [[BRCoreDataManager sharedInstance] saveContext:[BRCoreDataManager sharedInstance].contextForCurrentThread];
            }];
        }
//        dispatch_async(dispatch_get_main_queue(), ^{
            [self refreshSetting];
//        });
//    });
   
    [self creatEffectView];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnClick)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"DESC", nil) style:UIBarButtonItemStylePlain target:self action:@selector(updateSortDescriptor:)];
    
    [self.view addSubview:self.doorPlankView];
    [self.doorPlankView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
    
    [self.view addSubview:self.lishEmptyView];
    [self.lishEmptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.centerY.equalTo(self.view.mas_centerY).offset(-40);
        make.height.equalTo(@(40));
    }];
  
    self.syncFinishedObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerChainDownloadIsCompleteNotification object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           if(!self.isChainComplete) {
                                                               dispatch_async(dispatch_get_main_queue(), ^{
                                                                   [self updateCandyData];
                                                               });
                                                           }
                                                       }];
}

- (void) updateSortDescriptor:(UIBarButtonItem *) barBtn {
    if([barBtn.title isEqualToString:NSLocalizedString(@"DESC", nil)]) {
        self.fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"txTime" ascending:NO]];
        [barBtn setTitle:NSLocalizedString(@"ASC", nil)];
    } else {
        self.fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"txTime" ascending:YES]];
        [barBtn setTitle:NSLocalizedString(@"DESC", nil)];
    }
    [self.getCandyTableview scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO]; 
    [self loadNewData];
}

- (void)dealloc {
    if (self.syncFinishedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.syncFinishedObserver];
}

- (void) updateCandyData {
    self.isChainComplete = YES;
    NSArray *allList = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] fetchEntity:@"BRPutCandyEntity" withPredicate:nil]];
    [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlockAndWait:^{
        for(BRPutCandyEntity *e in allList) {
//            if([e.isGetState integerValue] == 1 && [BRPeerManager sharedInstance].lastBlockHeight > [e.blockHeight unsignedLongLongValue] + [e.candyExpired integerValue] * BLOCKS_PER_MONTH - 2) {
//                e.isGetState = @(3);
//            }
            if ([e.isGetState integerValue] == 1 && [e.blockHeight unsignedLongLongValue] < TEST_START_SPOS_HEIGHT) {
                long long diffBlock = 0;
                long long diffHeight = [e.blockHeight unsignedLongLongValue] + [e.candyExpired integerValue] * BLOCKS_PER_MONTH - TEST_START_SPOS_HEIGHT;
                if (diffHeight > 0) {
                    diffBlock = ([e.blockHeight unsignedLongLongValue] + [e.candyExpired integerValue] * BLOCKS_PER_MONTH - TEST_START_SPOS_HEIGHT) * TEST_START_SPOS_BlockTimeRatio + TEST_START_SPOS_HEIGHT - 3 * BLOCKS_SPOS_PER_DAY;
                } else {
                    diffBlock = [e.blockHeight unsignedLongLongValue] + [e.candyExpired integerValue] * BLOCKS_PER_MONTH - 2;
                }
                
                if([BRPeerManager sharedInstance].lastBlockHeight > diffBlock) {
                    e.isGetState = @(3);
                }
            } else if ([e.isGetState integerValue] == 1 && [BRPeerManager sharedInstance].lastBlockHeight > [e.blockHeight unsignedLongLongValue] + [e.candyExpired integerValue] * BLOCKS_SPOS_PER_MONTH - 3 * BLOCKS_SPOS_PER_DAY) {
                e.isGetState = @(3);
            }
        }
        [[BRCoreDataManager sharedInstance] saveContext:[BRCoreDataManager sharedInstance].contextForCurrentThread];
    }];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BRPutCandyEntity"];
    request.predicate = [NSPredicate predicateWithFormat:@"isGetState != %@", @(1)];
    NSArray *newArray = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] fetchObjects:request]];
    NSMutableArray *newDataSource = [self.dataSouce copy];
    BOOL isDeleteData = NO;
    for(int i=0; i<newArray.count; i++) {
        BRPutCandyEntity *isGetCandy = newArray[i];
        for(int j=0; j<self.dataSouce.count; j++) {
            BRPutCandyEntity *currentCandy = self.dataSouce[j];
            if([isGetCandy.txId isEqual:currentCandy.txId]) {
                isDeleteData = YES;
                [self.dataSouce removeObject:currentCandy];
                break;
            }
        }
    }
//    dispatch_async(dispatch_get_main_queue(), ^{
    if(isDeleteData) {
        if(self.dataSouce.count <= 10) {
            [self loadNewData];
        } else {
            [self.getCandyTableview reloadData];
        }
    }
//    });
}

- (void) loadNewData {
    self.page = 0;
    self.fetchRequest.fetchOffset = self.page * self.pageSize;
    self.fetchRequest.fetchLimit = self.pageSize;
//    dispatch_async(dispatch_queue_create("updataGetCandy", NULL), ^{
        NSArray *newArray = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] fetchObjects:self.fetchRequest]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if(newArray.count == 0) {
                [self.getCandyTableview.mj_header endRefreshing];
                self.getCandyTableview.mj_footer.hidden = YES;
                self.lishEmptyView.hidden = NO;
                self.getCandyTableview.hidden = YES;
                return;
            }
            self.lishEmptyView.hidden = YES;
            self.getCandyTableview.hidden = NO;
            [self.dataSouce removeAllObjects];
            [self.dataSouce addObjectsFromArray:newArray];
            if(self.dataSouce.count == self.pageSize) {
                self.getCandyTableview.mj_footer.hidden = NO;
            }
            [self.getCandyTableview.mj_header endRefreshing];
            [self.getCandyTableview reloadData];
        });
//    });
}

- (void) loadData {
    @WeakObj(self);
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//        dispatch_async(dispatch_queue_create("updataGetCandy", NULL), ^{
            self.fetchRequest.fetchOffset = (selfWeak.page + 1) * selfWeak.pageSize;
            self.fetchRequest.fetchLimit = selfWeak.pageSize;
            NSArray *nextArray = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] fetchObjects:self.fetchRequest]];
            dispatch_async(dispatch_get_main_queue(), ^{
                if(nextArray.count == 0) {
                    [AppTool showMessage:NSLocalizedString(@"No more data yet", nil) showView:selfWeak.view];
                    [selfWeak.getCandyTableview.mj_footer endRefreshing];
                    selfWeak.getCandyTableview.mj_footer.hidden = YES;
                    return;
                }
                self.page += 1;
                [selfWeak.dataSouce addObjectsFromArray:nextArray];
                [selfWeak.getCandyTableview.mj_footer endRefreshing];
                [selfWeak.getCandyTableview reloadData];
            });
        });
//    });
}

- (void) returnClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)refreshSetting {
    self.pageSize = 50;
    
    @WeakObj(self);
    //..下拉刷新
    self.getCandyTableview.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [selfWeak loadNewData];
    }];
    [self.getCandyTableview.mj_header beginRefreshing];
    
    //..上拉加载更多
    self.getCandyTableview.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [selfWeak loadData];
    }];
    self.getCandyTableview.mj_footer.hidden = YES;
}

- (void)creatEffectView {
    
    //模糊背景
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.hidden = YES;
    effectView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height);
    effectView.alpha = 0.3f;
    [self.view addSubview:effectView];
    self.effectView = effectView;
}

- (void)creatAlertView {
    
    CGFloat margin = 20;
    CGFloat height = 0;
    CGFloat lableHeight = 0;
    if (self.hasDone) {
        height = 120;
        lableHeight = 20;
    } else {
        height = 160;
        lableHeight = 60;
    }
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(margin, 0, SCREEN_WIDTH - margin * 2, height)];
    alertView.backgroundColor = [UIColor whiteColor];
    alertView.center = self.view.center;
    alertView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.4f].CGColor;
    alertView.layer.borderWidth = 1.f;
    alertView.layer.cornerRadius = 6.f;
    alertView.clipsToBounds = YES;
    [self.view addSubview:alertView];
    self.alertView = alertView;
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH - margin * 2, lableHeight)];
#warning Language International
    if (self.hasDone) {
        lable.text = @"已经领取完了!";
    } else {
        lable.text = @"恭喜你!\n一共领取到\n100个SAFE!";
    }
    lable.numberOfLines = 0;
    lable.textColor = [UIColor blackColor];
    lable.font = [UIFont systemFontOfSize:16.f];
    lable.textAlignment = NSTextAlignmentCenter;
    [alertView addSubview:lable];
    
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sureButton.frame = CGRectMake(0, CGRectGetMaxY(lable.frame) + 30, SCREEN_WIDTH - margin * 2, 40);
    sureButton.backgroundColor = MAIN_COLOR;
    [sureButton setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sureButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [alertView addSubview:sureButton];
    [sureButton addTarget:self action:@selector(hideAlertView) forControlEvents:UIControlEventTouchUpInside];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSouce.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"BRGetCandyCell";
    BRGetCandyCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[BRGetCandyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = [UIColor clearColor];
    }
    cell.delegate = self;
    cell.indexPath = indexPath;
    if(indexPath.row < self.dataSouce.count) {
        BRPutCandyEntity *putCandyEntity = self.dataSouce[indexPath.row];
        cell.assetNameLable.text = putCandyEntity.assetName;
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = @"yyyy/MM/dd HH:mm";
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:[putCandyEntity.txTime doubleValue]];
        int candtExpiredDay = [putCandyEntity.candyExpired integerValue] * 30 * 24 * 3600;
        
    //    if([putCandyEntity.isGetState integerValue] == 0) {
    //         [cell.getButton setTitle:@"不可领取" forState:UIControlStateNormal];
    //    } else if ([putCandyEntity.isGetState integerValue] == 1) {
    //         [cell.getButton setTitle:@"领取" forState:UIControlStateNormal];
    //    } else if ([putCandyEntity.isGetState integerValue] == 2) {
    //         [cell.getButton setTitle:@"已领取" forState:UIControlStateNormal];
    //    } else {
    //         [cell.getButton setTitle:@"过期" forState:UIControlStateNormal];
    //    }
        [cell.getButton setTitle:NSLocalizedString(@"Receive", nil) forState:UIControlStateNormal];
        cell.getButton.backgroundColor = MAIN_COLOR;
        cell.getButton.enabled = YES;

        BRLog(@"========== %@ %ld %@", putCandyEntity.assetName, [putCandyEntity.decimals integerValue], putCandyEntity.assetId);
        cell.timeLable.text = [fmt stringFromDate:date];
        cell.amountLable.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Total ", nil), [BRSafeUtils amountForAssetAmount:[putCandyEntity.candyAmount unsignedLongLongValue] decimals:[putCandyEntity.decimals integerValue]]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

- (BOOL) currentIsGetCandy:(NSData *) txHash {
    NSArray *newCurrentList = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] entity:@"BRPutCandyEntity" objectsMatching:[NSPredicate predicateWithFormat:@"txId = %@ AND isGetState = %@", txHash, @(2)]]];
    if(newCurrentList.count > 0) {
        [AppTool showMessage:NSLocalizedString(@"Received", nil) showView:self.view];
        [self.dataSouce removeObject:self.txPutCandyEntity];
        [self.getCandyTableview reloadData];
        if(self.dataSouce.count <= 10) {
            [self loadNewData];
        }
        return YES;
    }
    return NO;
}

- (void) loadCandyHasExpired {
    [AppTool showMessage:NSLocalizedString(@"Candy has expired", nil) showView:self.view];
    NSArray *putCandyArray = [[BRCoreDataManager sharedInstance] entity:@"BRPutCandyEntity" objectsMatching:[NSPredicate predicateWithFormat:@"txId = %@", self.txPutCandyEntity.txId]];
    if(putCandyArray.count > 0) {
        [[BRCoreDataManager  sharedInstance].contextForCurrentThread performBlockAndWait:^{
            for(BRPutCandyEntity *putCandyEntity in putCandyArray) {
                putCandyEntity.isGetState = @(3);
            }
            [[BRCoreDataManager sharedInstance] saveContext:[BRCoreDataManager  sharedInstance].contextForCurrentThread];
        }];
    }
    [self.dataSouce removeObject:self.txPutCandyEntity];
    [self.getCandyTableview reloadData];
    if(self.dataSouce.count <= 10) {
        [self loadNewData];
    }
}

#pragma mark - BRGetCandyCellDelegate
- (void)getCandyCellIndex:(NSIndexPath *)indexPath {
    if(self.isAvailable) return;
    self.isAvailable = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.isAvailable = NO;
    });
#warning Language International
    if([BRPeerManager sharedInstance].syncProgress < 1) {
        [AppTool showMessage:NSLocalizedString(@"Syncing block data, please wait ...", nil) showView:self.view];
        return;
    }
    if([BRWalletManager sharedInstance].walletDisbled){
        [[BRWalletManager sharedInstance] userLockedOut];
        return;
    }
    if(indexPath.row >= self.dataSouce.count) return;
    self.txPutCandyEntity = self.dataSouce[indexPath.row];
//    BRLog(@"======= %ld", self.txPutCandyEntity.blockHeight.integerValue);
    if([self currentIsGetCandy:self.txPutCandyEntity.txId]) {
        return;
    }
    
    if ([self.txPutCandyEntity.blockHeight unsignedLongLongValue] < TEST_START_SPOS_HEIGHT) {
        long long diffBlock = 0;
        long long diffHeight = ([self.txPutCandyEntity.candyExpired integerValue] * BLOCKS_PER_MONTH + [self.txPutCandyEntity.blockHeight longLongValue] - TEST_START_SPOS_HEIGHT);
        if (diffHeight > 0) {
            diffBlock = ([self.txPutCandyEntity.candyExpired integerValue] * BLOCKS_PER_MONTH - TEST_START_SPOS_HEIGHT + [self.txPutCandyEntity.blockHeight unsignedLongLongValue]) * TEST_START_SPOS_BlockTimeRatio + TEST_START_SPOS_HEIGHT - 3 * BLOCKS_SPOS_PER_DAY;
        } else {
            diffBlock = [self.txPutCandyEntity.candyExpired integerValue] * BLOCKS_PER_MONTH + [self.txPutCandyEntity.blockHeight unsignedLongLongValue] - 2;
        }
        
        if([BRPeerManager sharedInstance].lastBlockHeight > diffBlock) {
            [self loadCandyHasExpired];
            return;
        }
    } else if ([BRPeerManager sharedInstance].lastBlockHeight > [self.txPutCandyEntity.blockHeight unsignedLongLongValue] + [self.txPutCandyEntity.candyExpired integerValue] * BLOCKS_SPOS_PER_MONTH - 3 * BLOCKS_SPOS_PER_DAY) {
        [self loadCandyHasExpired];
        return;
    }
//    if([BRPeerManager sharedInstance].lastBlockHeight > [self.txPutCandyEntity.blockHeight unsignedLongLongValue] + [self.txPutCandyEntity.candyExpired integerValue] * BLOCKS_PER_MONTH - 2) {
//        [AppTool showMessage:NSLocalizedString(@"Candy has expired", nil) showView:self.view];
//        NSArray *putCandyArray = [[BRCoreDataManager sharedInstance] entity:@"BRPutCandyEntity" objectsMatching:[NSPredicate predicateWithFormat:@"txId = %@", self.txPutCandyEntity.txId]];
//        if(putCandyArray.count > 0) {
//            [[BRCoreDataManager  sharedInstance].contextForCurrentThread performBlockAndWait:^{
//                for(BRPutCandyEntity *putCandyEntity in putCandyArray) {
//                    putCandyEntity.isGetState = @(3);
//                }
//                [[BRCoreDataManager sharedInstance] saveContext:[BRCoreDataManager  sharedInstance].contextForCurrentThread];
//            }];
//        }
//        [self.dataSouce removeObject:self.txPutCandyEntity];
//        [self.getCandyTableview reloadData];
//        if(self.dataSouce.count <= 10) {
//            [self loadNewData];
//        }
//        return;
//    }
    NSString *showStr = [BRSafeUtils getCandyTime:self.txPutCandyEntity.blockHeight.integerValue];
    if([showStr length] > 0){
        [AppTool showMessage:showStr showView:self.view];
        return;
    }
    self.safeTotalAmount = 0;
//    NSArray *blockSafeArray = [NSArray arrayWithArray:[BRBlockSafeEntity objectsMatching:@"blockHeight <= %@", self.txPutCandyEntity.blockHeight]];
//    for(BRBlockSafeEntity *blockSafeEntity in blockSafeArray) {
//        self.safeTotalAmount += [blockSafeEntity.totalAmount unsignedLongLongValue];
//    }
//    NSArray *blackHoleAddressSafeList = [NSArray arrayWithArray:[BRBlackHoleAddressSafeEntity objectsMatching:@"height <= %@", self.txPutCandyEntity.blockHeight]];
//    BRLog(@"%@ %llu", self.txPutCandyEntity.blockHeight, self.safeTotalAmount);
//    uint64_t balcanceBlackHole = 0;
//    for(BRBlackHoleAddressSafeEntity *blackHoleAddressSafeEntity in blackHoleAddressSafeList) {
//        self.safeTotalAmount -= [blackHoleAddressSafeEntity.totalAmount unsignedLongLongValue];
//        balcanceBlackHole += [blackHoleAddressSafeEntity.totalAmount unsignedLongLongValue];
//        BRLog(@"========================%@ %llu", blackHoleAddressSafeEntity.height, balcanceBlackHole);
//    }
//    BRLog(@"%llu %llu %llu", balcanceBlackHole, self.safeTotalAmount);
    self.safeTotalAmount = [BRSafeUtils returnBRBlockSafeEntityTotalAmountSumToHeight:[self.txPutCandyEntity.blockHeight unsignedIntegerValue]] - [BRSafeUtils returnBRBlackHoleAddressSafeEntityTotalAmountSumToHeight:[self.txPutCandyEntity.blockHeight unsignedIntegerValue]];
    BRLog(@"================== safeTotalAmount %llu %@", self.safeTotalAmount, self.txPutCandyEntity.blockHeight);
    self.txId = self.txPutCandyEntity.txId;
    NSArray *addressArray = [[BRCoreDataManager sharedInstance] entity:@"BRBlockAvailableSafeEntity" objectsMatching:[NSPredicate predicateWithFormat:@"height = %@", self.txPutCandyEntity.blockHeight]];
    NSMutableArray *newAddressArray = [NSMutableArray array];
    uint64_t meGetCandyNumber = 0;
    for(BRBlockAvailableSafeEntity *blockAvailableSafeEntity in addressArray) {
        uint64_t candyAmount = (uint64_t)([blockAvailableSafeEntity.amount unsignedLongLongValue] * 1.0 / self.safeTotalAmount * [self.txPutCandyEntity.candyAmount unsignedLongLongValue]);
        if(candyAmount == 0 || candyAmount < (0.0001 * pow(10, self.txPutCandyEntity.decimals.integerValue))) continue;
        meGetCandyNumber += candyAmount;
        [newAddressArray addObject:blockAvailableSafeEntity];
    }
    
    BRLog(@"%llu %llu %llu %llu", meGetCandyNumber, [self.txPutCandyEntity.candyAmount unsignedLongLongValue], [BRSafeUtils returnCandyNumberEntityGetCandyTotalAmount:self.txPutCandyEntity.txId], [self.txPutCandyEntity.candyAmount unsignedLongLongValue] - [BRSafeUtils returnCandyNumberEntityGetCandyTotalAmount:self.txPutCandyEntity.txId]);
    // 判断领取的糖果是否充足
    if (meGetCandyNumber > [self.txPutCandyEntity.candyAmount unsignedLongLongValue] - [BRSafeUtils returnCandyNumberEntityGetCandyTotalAmount:self.txPutCandyEntity.txId]) {
        [AppTool showMessage:NSLocalizedString(@"The candy pool is dry", nil) showView:self.view];
        [self cleanListCandyTx];
        return;
    }
    
    self.blockAvailableSafeArray = [NSArray arrayWithArray:newAddressArray];
    self.addressIndex = 0;
    [self buildGetCandyTx];
//    [self getCandy];
    
}

// TODO: 清理糖果余额不足交易
- (void) cleanListCandyTx {
    NSArray *putCandyArray = [[BRCoreDataManager sharedInstance] entity:@"BRPutCandyEntity" objectsMatching:[NSPredicate predicateWithFormat:@"txId = %@", self.txPutCandyEntity.txId]];
    if(putCandyArray.count > 0) {
        [[BRCoreDataManager  sharedInstance].contextForCurrentThread performBlockAndWait:^{
            for(BRPutCandyEntity *putCandyEntity in putCandyArray) {
                putCandyEntity.isGetState = @(4);
            }
            [[BRCoreDataManager sharedInstance] saveContext:[BRCoreDataManager  sharedInstance].contextForCurrentThread];
        }];
    }
    [self.dataSouce removeObject:self.txPutCandyEntity];
    [self.getCandyTableview reloadData];
    if(self.dataSouce.count <= 10) {
        [self loadNewData];
    }
}

// TODO: 构建领取糖果交易
- (void) buildGetCandyTx {
    NSArray *newBlockAvailableSafeArray;
    if(self.addressIndex + 200 < self.blockAvailableSafeArray.count) {
        newBlockAvailableSafeArray = [self.blockAvailableSafeArray subarrayWithRange:NSMakeRange(self.addressIndex, 200)];
    } else {
        newBlockAvailableSafeArray = [self.blockAvailableSafeArray subarrayWithRange:NSMakeRange(self.addressIndex, self.blockAvailableSafeArray.count - self.addressIndex)];
    }
    BRTransaction *tx = [[BRWalletManager sharedInstance].wallet transactionForSafeTotalAmount:self.safeTotalAmount address:newBlockAvailableSafeArray putCandyEntity:self.txPutCandyEntity];

    if(!tx) {
        BRBalanceModel *safeModel = [BRWalletManager sharedInstance].wallet.balanceArray.firstObject;
        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"Available balance of SAFE is insufficient , still missing %@%@. Unable to receive candy", nil), [BRSafeUtils showSAFEAmount:[[BRWalletManager sharedInstance].wallet getFeeAmountTransactionForSafeTotalAmount:self.safeTotalAmount address:newBlockAvailableSafeArray putCandyEntity:self.txPutCandyEntity] - [[BRWalletManager sharedInstance].wallet useBalance:safeModel.assetId] + 10000], [[BRSafeUtils showSAFEUint] length] > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"] showView:self.view];
        return;
    } else {
        if(![[BRWalletManager sharedInstance].wallet isSendTransaction:tx]) {
            [AppTool showMessage:NSLocalizedString(@"Operation is too frequent, please wait", nil) showView:self.view];
            return;
        } else if (tx.inputHashes.count > 200) {
            [AppTool showMessage:NSLocalizedString(@"Transaction failed and the transaction size exceeded the maximum.", nil) showView:self.view];
            return;
        }
    }
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    uint64_t amount = 0;
    for(BRBlockAvailableSafeEntity *blockAvailableSafeEntity in newBlockAvailableSafeArray) {
        amount += (uint64_t)([blockAvailableSafeEntity.amount unsignedLongLongValue] * 1.0 / self.safeTotalAmount * [self.txPutCandyEntity.candyAmount unsignedLongLongValue]);
        BRLog(@"%llu %@", [blockAvailableSafeEntity.amount unsignedLongLongValue], blockAvailableSafeEntity.address);
    }
    BRLog(@"%llu", amount);
    uint64_t fee = [manager.wallet feeForCandyTransaction:tx];
    NSString *prompt = @"";//[self promptAssetForAmount:amount + fee fee:fee assetId:self.txPutCandyEntity.assetId];
    self.doorPlankView.hidden = NO;
    CFRunLoopPerformBlock([[NSRunLoop mainRunLoop] getCFRunLoop], kCFRunLoopCommonModes, ^{
        [self confirmTransaction:tx withPrompt:prompt forAmount:fee];
    });
}

- (NSString *)promptAssetForAmount:(uint64_t)amount fee:(uint64_t)fee assetId:(NSData *) assetId{
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSString *prompt = @"";
    NSNumberFormatter *dashFormat = [[NSNumberFormatter alloc] init];
    dashFormat.lenient = YES;
    dashFormat.numberStyle = NSNumberFormatterCurrencyStyle;
    dashFormat.generatesDecimalNumbers = YES;
    dashFormat.negativeFormat = [dashFormat.positiveFormat
                                 stringByReplacingCharactersInRange:[dashFormat.positiveFormat rangeOfString:@"#"]
                                 withString:@"-#"];
    NSArray *issueDataArray = [[BRCoreDataManager sharedInstance] entity:@"BRIssueDataEnity" objectsMatching:[NSPredicate predicateWithFormat:@"assetId = %@", assetId]];
    BRIssueDataEnity *issueDataEntity = issueDataArray.firstObject;
    dashFormat.currencyCode = issueDataEntity.assetName;
    dashFormat.currencySymbol = [issueDataEntity.assetName stringByAppendingString:NARROW_NBSP];
    int pwoNumber = [issueDataEntity.decimals integerValue];
    dashFormat.maximumFractionDigits = pwoNumber;
    dashFormat.minimumFractionDigits = 0; // iOS 8 bug, minimumFractionDigits now has to be set after currencySymbol
    dashFormat.maximum = @(MAX_MONEY/(int64_t)pow(10.0, dashFormat.maximumFractionDigits));
    prompt = [prompt stringByAppendingFormat:NSLocalizedString(@"\n\n     amount： %@", nil),
              [dashFormat stringFromNumber:[(id)[NSDecimalNumber numberWithLongLong:amount - fee]
                                            decimalNumberByMultiplyingByPowerOf10:-dashFormat.maximumFractionDigits]]];
    
    if (fee > 0) {
        prompt = [prompt stringByAppendingFormat:NSLocalizedString(@"\n        fee： +%@", nil),
                  [manager stringForDashAmount:fee]];
        prompt = [prompt stringByAppendingFormat:NSLocalizedString(@"\n          total： %@", nil),
                  [NSString stringWithFormat:@"%@ + %@", [dashFormat stringFromNumber:[(id)[NSDecimalNumber numberWithLongLong:amount - fee]
                                                                                       decimalNumberByMultiplyingByPowerOf10:-dashFormat.maximumFractionDigits]], [manager stringForDashAmount:fee]]];
    }
    return prompt;
}

- (void)confirmTransaction:(BRTransaction *)tx withPrompt:(NSString *)prompt forAmount:(uint64_t)amount
{
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    __block BOOL previouslyWasAuthenticated = manager.didAuthenticate;
    @weakify(self);
    
    [manager.wallet signTransaction:tx withPrompt:prompt amount:amount completion:^(BOOL signedTransaction) {
        self.doorPlankView.hidden = YES;
        @strongify(self);
//        [AppTool showHUDView:nil animated:YES];
        if (!signedTransaction) {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:NSLocalizedString(@"couldn't make payment", nil)
                                         message:NSLocalizedString(@"error signing dash transaction", nil)
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"ok", nil)
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
                                           
                                       }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            
            if (!previouslyWasAuthenticated) manager.didAuthenticate = NO;
            
            if (!tx.isSigned) { // double check
                return;
            }
            
            __block BOOL waiting = YES, sent = NO;
           @weakify(self);
            
            // 保存领取状态数据
            NSArray *putCandyArray = [[BRCoreDataManager sharedInstance] entity:@"BRPutCandyEntity" objectsMatching:[NSPredicate predicateWithFormat:@"txId = %@", self.txId]];
            if(putCandyArray.count > 0) {
                [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlockAndWait:^{
                        for(BRPutCandyEntity *putCandyEntity in putCandyArray) {
                            putCandyEntity.isGetState = @(2);
                        }
                        [[BRCoreDataManager sharedInstance] saveContext:[BRCoreDataManager sharedInstance].contextForCurrentThread];
                }];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [AppTool showHUDView:nil animated:YES];
                self.isHUDShow = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(self.isHUDShow) {
                        self.isHUDShow = NO;
                        self.view.window.userInteractionEnabled = true;
                        [AppTool hideHUDView:nil animated:YES];
                        [AppTool showMessage:NSLocalizedString(@"getCandy_sendGetCandyTx", nil) showView:self.view];
                        self.addressIndex += 200;
                        if(self.txId) {
                            [self.dataSouce removeObject:self.txPutCandyEntity];
                            if(self.dataSouce.count <= 10) {
                                [self loadNewData];
                            }
                        }
                        [self.getCandyTableview reloadData];
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            if(self.blockAvailableSafeArray.count > self.addressIndex) {
                                [self buildGetCandyTx];
                            }
                        });
                    }
                });
            });
            /// 防止用户重复点击
            self.view.window.userInteractionEnabled = false;
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                
//            });
            [[BRPeerManager sharedInstance] publishTransaction:tx completion:^(NSError *error) {
                @strongify(self);
                @weakify(self);
                if(!self) return;
                self.isHUDShow = NO;
//                dispatch_async(dispatch_get_main_queue(), ^{
                    [AppTool hideHUDView:nil animated:YES];
//                });
                if (error) {
                    if (! waiting && ! sent) {
                        UIAlertController * alert = [UIAlertController
                                                     alertControllerWithTitle:NSLocalizedString(@"couldn't make payment", nil)
                                                     message:error.localizedDescription
                                                     preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* okButton = [UIAlertAction
                                                   actionWithTitle:NSLocalizedString(@"ok", nil)
                                                   style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       
                                                   }];
                        [alert addAction:okButton];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
//                    [AppTool showMessage:[NSString stringWithFormat:@"%@", error] showView:nil];
                }
                else if (! sent) { //TODO: show full screen sent dialog with tx info, "you sent b10,000 to bob"
                    sent = YES;
                    tx.timestamp = [NSDate timeIntervalSinceReferenceDate];
                    [manager.wallet registerTransaction:tx];
//                    [self.view addSubview:[[[BRBubbleView viewWithText:NSLocalizedString(@"sent!", nil)
//                                                                center:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)] popIn]
//                                           popOutAfterDelay:2.0]];
#warning Language International
                    
                    [AppTool showMessage:NSLocalizedString(@"getCandy_sendGetCandyTx", nil) showView:self.view];
                    self.addressIndex += 200;
                    if(self.txId) {
                        [self.dataSouce removeObject:self.txPutCandyEntity];
                        if(self.dataSouce.count <= 10) {
                            [self loadNewData];
                        }
                    }
                    [self.getCandyTableview reloadData];
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        if(self.blockAvailableSafeArray.count > self.addressIndex) {
                            [self buildGetCandyTx];
                        }
                    });
//                    [self returnClick];
                }
                self.view.window.userInteractionEnabled = true;
                waiting = NO;
            }];
        }
    }];
}

#pragma mark -- MARK:领取
- (void)getCandy{
    //self.hasDone = YES;
    self.hasDone = NO;
    [self creatAlertView];
    
    self.effectView.hidden = NO;
    self.alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity,CGFLOAT_MIN, CGFLOAT_MIN);
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:^(BOOL finished) {
        self.alertView.transform = CGAffineTransformIdentity;
    }];
}

- (void)hideAlertView {
    
    [UIView animateWithDuration:0.1 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.001, 0.001);
                         }
                         completion:^(BOOL finished) {
                             [self.alertView removeFromSuperview];
                             self.effectView.hidden = YES;
                         }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
