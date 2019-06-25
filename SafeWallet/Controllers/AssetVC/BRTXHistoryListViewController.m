//
//  BRTXHistoryListViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/17.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRTXHistoryListViewController.h"
#import "BRCandyHistoryCell.h"
#import "NSData+Bitcoin.h"
#import "BRWalletManager.h"
#import "BRSafeUtils.h"
#import "BRTXHistoryListCell.h"
#import "BRPeerManager.h"

static NSString *kCellReuseID = @"kCellReuseID";
static NSString *txHistoryListCellName = @"BRTXHistoryListCell";

@interface BRTXHistoryListViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *isMeTx;

@property (nonatomic,strong) NSMutableArray *publishTxIndex;

@property (nonatomic, strong) id txStatusObserver;

@end

@implementation BRTXHistoryListViewController

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
        [_tableView registerClass:[BRCandyHistoryCell class] forCellReuseIdentifier:kCellReuseID];
        [_tableView registerClass:[BRTXHistoryListCell class] forCellReuseIdentifier:txHistoryListCellName];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    self.title = NSLocalizedString(@"Recent transaction history", nil);
    
    @weakify(self);
    if (! self.txStatusObserver) {
        self.txStatusObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerTxStatusNotification object:nil
                                                           queue:nil usingBlock:^(NSNotification *note) {
                                                               @strongify(self);
                                                               BRTransaction *updateTx = [[BRWalletManager sharedInstance].wallet
                                                                                    transactionForHash:self.tx.txHash];
                                                               if (updateTx) self.tx = updateTx;
                                                               [self.tableView reloadData];
                                                           }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.txStatusObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.txStatusObserver];
    self.txStatusObserver = nil;
    
    [super viewWillDisappear:animated];
}


- (NSMutableArray *)isMeTx {
    if(_isMeTx == nil) {
        _isMeTx = [NSMutableArray array];
        for(int i=0; i<self.tx.outputAddresses.count; i++) {
            if([[BRWalletManager sharedInstance].wallet containsAddress:self.tx.outputAddresses[i]]) {
                [_isMeTx addObject:@(i)];
            }
        }
    }
    return _isMeTx;
}

- (NSMutableArray *)publishTxIndex {
    if(_publishTxIndex == nil) {
        _publishTxIndex = [NSMutableArray array];
        for(int i=0; i<self.tx.outputAddresses.count; i++) {
            if([self.tx.outputAddresses[i] isEqualToString:BLACK_HOLE_ADDRESS]) continue;
            [_publishTxIndex addObject:@(i)];
        }
    }
    return _publishTxIndex;
}

#pragma mark ------ UITableViewDataSource,UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (![self isSend] && ![self isPushlishAsset] && ![self isPushlishCandy]) ? self.isMeTx.count : ([self isPushlishAsset] ? self.publishTxIndex.count : self.tx.outputAddresses.count);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if((![self isSend] && ![self isPushlishAsset] && ![self isPushlishCandy])) {
        int index = [self.isMeTx[indexPath.row] integerValue];
        if([self.tx.outputUnlockHeights[index] unsignedLongLongValue] > 0) { // [BRPeerManager sharedInstance].lastBlockHeight
            BRTXHistoryListCell *txCell = [tableView dequeueReusableCellWithIdentifier:txHistoryListCellName];
            txCell.selectionStyle = UITableViewCellSelectionStyleNone;
            txCell.assetNameLable.text = [self txAddreessContain:self.tx.outputReserves[index] address:self.tx.outputAddresses[index]];
            txCell.addressLable.text = self.tx.outputAddresses[index];
            if(![BRSafeUtils isSafeTransaction:self.tx.outputReserves[index]]) { // [self.tx.outputReserves[index] length] > 42
                txCell.amountLable.text = [BRSafeUtils amountForAssetAmount:[self.tx.outputAmounts[index] unsignedLongLongValue] decimals:[self returnDecimalBit:self.tx.outputReserves[index]]];
            } else {
                txCell.amountLable.text = [NSString stringWithFormat:@"%@", [BRSafeUtils showSAFEAmount:[self.tx.outputAmounts[index] unsignedLongLongValue]]];
            }
            txCell.lockImageView.hidden = YES;
            NSString *lockTime;
            if (self.tx.blockHeight == INT32_MAX) {
                lockTime = @"0";
            } else {
                long long unlockHeight = [self.tx.outputUnlockHeights[index] unsignedLongLongValue];
                if (unlockHeight > TEST_START_SPOS_HEIGHT) {
                    if (self.tx.blockHeight < TEST_START_SPOS_HEIGHT || self.tx.version == TX_VERSION_NUMBER) {
                        unlockHeight = (unlockHeight - TEST_START_SPOS_HEIGHT) * TEST_START_SPOS_BlockTimeRatio + TEST_START_SPOS_HEIGHT;
                        if(unlockHeight > [BRPeerManager sharedInstance].lastBlockHeight) {
                            lockTime = [NSString stringWithFormat:@"%d", (int)ceill(([self.tx.outputUnlockHeights[index] unsignedLongLongValue] - (uint64_t)self.tx.blockHeight) / (BLOCKS_PER_MONTH * 1.0))];
                            txCell.lockImageView.hidden = NO;
                        } else {
                            lockTime = @"-1";
                        }
                    } else {
                        if([self.tx.outputUnlockHeights[index] unsignedLongLongValue] > [BRPeerManager sharedInstance].lastBlockHeight) {
                            lockTime = [NSString stringWithFormat:@"%d", (int)ceill(([self.tx.outputUnlockHeights[index] unsignedLongLongValue] - (uint64_t)self.tx.blockHeight) / (BLOCKS_SPOS_PER_MONTH * 1.0))];
                            txCell.lockImageView.hidden = NO;
                        } else {
                            lockTime = @"-1";
                        }
                    }
                } else {
                    if([self.tx.outputUnlockHeights[index] unsignedLongLongValue] > [BRPeerManager sharedInstance].lastBlockHeight) {
                        lockTime = [NSString stringWithFormat:@"%d", (int)ceill(([self.tx.outputUnlockHeights[index] unsignedLongLongValue] - (uint64_t)self.tx.blockHeight) / (BLOCKS_PER_MONTH * 1.0))];
                        txCell.lockImageView.hidden = NO;
                    } else {
                        lockTime = @"-1";
                    }
                }
//                if([self.tx.outputUnlockHeights[index] unsignedLongLongValue] > [BRPeerManager sharedInstance].lastBlockHeight) {
//                    lockTime = [NSString stringWithFormat:@"%d", (int)ceill(([self.tx.outputUnlockHeights[index] unsignedLongLongValue] - (uint64_t)self.tx.blockHeight) / (BLOCKS_PER_MONTH * 1.0))];
//                    txCell.lockImageView.hidden = NO;
//                } else {
//                    lockTime = @"-1";
//                }
            }
            if([lockTime isEqualToString:@"0"]) {
                txCell.lockMonthLabel.text = NSLocalizedString(@"Confirming", nil);
            } else if ([lockTime isEqualToString:@"-1"]) {
                txCell.lockMonthLabel.text = NSLocalizedString(@"Unlocked", nil);
            } else {
                txCell.lockMonthLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Locked time:%@ (month)", nil), lockTime];
            }
            if ([self.tx.outputUnlockHeights[index] unsignedLongLongValue] < TEST_START_SPOS_HEIGHT) {
                txCell.lockHeightLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Unlock height:%ld", nil),(long)[self.tx.outputUnlockHeights[index] unsignedLongLongValue]];
            } else {
                if (self.tx.blockHeight >= TEST_START_SPOS_HEIGHT && self.tx.version == TX_VERSION_SPOS_NUMBER) {
                    txCell.lockHeightLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Unlock height:%ld", nil),(long)[self.tx.outputUnlockHeights[index] unsignedLongLongValue]];
                } else {
                    txCell.lockHeightLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Unlock height:%ld", nil),(long)([self.tx.outputUnlockHeights[index] unsignedLongLongValue] - TEST_START_SPOS_HEIGHT) * TEST_START_SPOS_BlockTimeRatio + TEST_START_SPOS_HEIGHT];
                }
            }
//            txCell.lockHeightLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Unlock height:%ld", nil),(long)[self.tx.outputUnlockHeights[index] unsignedLongLongValue]];
            return txCell;
        } else {
            BRCandyHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseID forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.assetNameLable.text = [self txAddreessContain:self.tx.outputReserves[index] address:self.tx.outputAddresses[index]];
            cell.addressLable.text = self.tx.outputAddresses[index];
            if(![BRSafeUtils isSafeTransaction:self.tx.outputReserves[index]]) { // [self.tx.outputReserves[index] length] > 42
                cell.amountLable.text = [BRSafeUtils amountForAssetAmount:[self.tx.outputAmounts[index] unsignedLongLongValue] decimals:[self returnDecimalBit:self.tx.outputReserves[index]]];
            } else {
                cell.amountLable.text = [NSString stringWithFormat:@"%@", [BRSafeUtils showSAFEAmount:[self.tx.outputAmounts[index] unsignedLongLongValue]]];
            }
            return cell;
        }
    } else {
        int index = 0;
        if([self isPushlishAsset]) {
            index = [self.publishTxIndex[indexPath.row] integerValue];
        } else {
            index = indexPath.row;
        }
        if([self.tx.outputUnlockHeights[index] unsignedLongLongValue] > 0) { // [BRPeerManager sharedInstance].lastBlockHeight
            BRTXHistoryListCell *txCell = [tableView dequeueReusableCellWithIdentifier:txHistoryListCellName];
            txCell.selectionStyle = UITableViewCellSelectionStyleNone;
            txCell.assetNameLable.text = [self txAddreessContain:self.tx.outputReserves[index] address:self.tx.outputAddresses[index]];
            txCell.addressLable.text = self.tx.outputAddresses[index];
            if(![BRSafeUtils isSafeTransaction:self.tx.outputReserves[index]]) { // [self.tx.outputReserves[indexPath.row] length] > 42
                txCell.amountLable.text = [BRSafeUtils amountForAssetAmount:[self.tx.outputAmounts[index] unsignedLongLongValue] decimals:[self returnDecimalBit:self.tx.outputReserves[index]]];
            } else {
                txCell.amountLable.text = [NSString stringWithFormat:@"%@", [BRSafeUtils showSAFEAmount:[self.tx.outputAmounts[index] unsignedLongLongValue]]];
            }
            txCell.lockImageView.hidden = YES;
            NSString *lockTime;
            if (self.tx.blockHeight == INT32_MAX) {
                lockTime = @"0";
            } else {
                long long unlockHeight = [self.tx.outputUnlockHeights[index] unsignedLongLongValue];
                if (unlockHeight > TEST_START_SPOS_HEIGHT) {
                    if (self.tx.blockHeight < TEST_START_SPOS_HEIGHT || self.tx.version == TX_VERSION_NUMBER) {
                        unlockHeight = (unlockHeight - TEST_START_SPOS_HEIGHT) * TEST_START_SPOS_BlockTimeRatio + TEST_START_SPOS_HEIGHT;
                        if(unlockHeight > [BRPeerManager sharedInstance].lastBlockHeight) {
                            lockTime = [NSString stringWithFormat:@"%d", (int)ceill(([self.tx.outputUnlockHeights[index] unsignedLongLongValue] - (uint64_t)self.tx.blockHeight) / (BLOCKS_PER_MONTH * 1.0))];
                            txCell.lockImageView.hidden = NO;
                        } else {
                            lockTime = @"-1";
                        }
                    } else {
                        if([self.tx.outputUnlockHeights[index] unsignedLongLongValue] > [BRPeerManager sharedInstance].lastBlockHeight) {
                            lockTime = [NSString stringWithFormat:@"%d", (int)ceill(([self.tx.outputUnlockHeights[index] unsignedLongLongValue] - (uint64_t)self.tx.blockHeight) / (BLOCKS_SPOS_PER_MONTH * 1.0))];
                            txCell.lockImageView.hidden = NO;
                        } else {
                            lockTime = @"-1";
                        }
                    }
                } else {
                    if([self.tx.outputUnlockHeights[index] unsignedLongLongValue] > [BRPeerManager sharedInstance].lastBlockHeight) {
                        lockTime = [NSString stringWithFormat:@"%d", (int)ceill(([self.tx.outputUnlockHeights[index] unsignedLongLongValue] - (uint64_t)self.tx.blockHeight) / (BLOCKS_PER_MONTH * 1.0))];
                        txCell.lockImageView.hidden = NO;
                    } else {
                        lockTime = @"-1";
                    }
                }
//                if([self.tx.outputUnlockHeights[index] unsignedLongLongValue] > [BRPeerManager sharedInstance].lastBlockHeight) {
//                    lockTime = [NSString stringWithFormat:@"%d", (int)ceill(([self.tx.outputUnlockHeights[index] unsignedLongLongValue] - (uint64_t)self.tx.blockHeight) / (BLOCKS_PER_MONTH * 1.0))];
//                    txCell.lockImageView.hidden = NO;
//                } else {
//                    lockTime = @"-1";
//                }
            }
            if([lockTime isEqualToString:@"0"]) {
                txCell.lockMonthLabel.text = NSLocalizedString(@"Confirming", nil);
            } else if ([lockTime isEqualToString:@"-1"]) {
                txCell.lockMonthLabel.text = NSLocalizedString(@"Unlocked", nil);
            } else {
                txCell.lockMonthLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Locked time:%@ (month)", nil),lockTime];
            }
            if ([self.tx.outputUnlockHeights[index] unsignedLongLongValue] < TEST_START_SPOS_HEIGHT) {
                txCell.lockHeightLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Unlock height:%ld", nil),(long)[self.tx.outputUnlockHeights[index] unsignedLongLongValue]];
            } else {
                if (self.tx.blockHeight >= TEST_START_SPOS_HEIGHT && self.tx.version == TX_VERSION_SPOS_NUMBER) {
                    txCell.lockHeightLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Unlock height:%ld", nil),(long)[self.tx.outputUnlockHeights[index] unsignedLongLongValue]];
                } else {
                    txCell.lockHeightLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Unlock height:%ld", nil),(long)([self.tx.outputUnlockHeights[index] unsignedLongLongValue] - TEST_START_SPOS_HEIGHT) * TEST_START_SPOS_BlockTimeRatio + TEST_START_SPOS_HEIGHT];
                }
            }
//            txCell.lockHeightLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Unlock height:%ld", nil),(long)[self.tx.outputUnlockHeights[index] unsignedLongLongValue]];
            return txCell;
        } else {
            BRCandyHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseID forIndexPath:indexPath];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.assetNameLable.text = [self txAddreessContain:self.tx.outputReserves[index] address:self.tx.outputAddresses[index]];
            cell.addressLable.text = self.tx.outputAddresses[index];
            if(![BRSafeUtils isSafeTransaction:self.tx.outputReserves[index]]) { // [ length] > 42
                cell.amountLable.text = [BRSafeUtils amountForAssetAmount:[self.tx.outputAmounts[index] unsignedLongLongValue] decimals:self.balanceModel.multiple];
            } else {
                cell.amountLable.text = [NSString stringWithFormat:@"%@", [BRSafeUtils showSAFEAmount:[self.tx.outputAmounts[index] unsignedLongLongValue]]];
            }
            return cell;
        }
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if((![self isSend] && ![self isPushlishAsset] && ![self isPushlishCandy])) {
        int index = [self.isMeTx[indexPath.row] integerValue];
        if([self.tx.outputUnlockHeights[index] unsignedLongLongValue] > 0) { // [BRPeerManager sharedInstance].lastBlockHeight
            return 90;
        } else {
            return 66;
        }
    } else {
        int index = 0;
        if([self isPushlishAsset]) {
            index = [self.publishTxIndex[indexPath.row] integerValue];
        } else {
            index = indexPath.row;
        }
        if([self.tx.outputUnlockHeights[index] unsignedLongLongValue] > 0) { // [BRPeerManager sharedInstance].lastBlockHeight
            return 90;
        } else {
            return 66;
        }
    }
}

- (int) returnDecimalBit:(NSData *) data {
    if(![BRSafeUtils isSafeTransaction:data]) { // data.length > 42
        return self.balanceModel.multiple;
    } else {
        return 8;
    }
}

- (NSString *) txAddreessContain:(NSData *) data address:(NSString *) address {
    if([self isPushlishAsset]) { // 资产发行
        if(![BRSafeUtils isSafeTransaction:data]) { //  data.length > 42
            NSNumber * l = 0;
            NSUInteger off = 0;
            NSData *d = [data dataAtOffset:off length:&l];
            if ([d UInt16AtOffset:38] == 200) { // 发行资产
                return NSLocalizedString(@"Issue assets", nil);
            } else if([d UInt16AtOffset:38] == 205) { // 发放糖果
                return NSLocalizedString(@"Issuing candy", nil);
            }
        } else {
            if (![[BRWalletManager sharedInstance].wallet containsAddress:address]) {
                return NSLocalizedString(@"Expenditure", nil);
            } else {
                return NSLocalizedString(@"SAFE change output", nil);
            }
        }
    } else if ([self isPushlishCandy]) { // 发放糖果
        if(![BRSafeUtils isSafeTransaction:data]) { // data.length > 42
            NSNumber * l = 0;
            NSUInteger off = 0;
            NSData *d = [data dataAtOffset:off length:&l];
            if ([d UInt16AtOffset:38] == 204) { // 发行资产
                return NSLocalizedString(@"Asset change output", nil);
            } else if([d UInt16AtOffset:38] == 205) { // 发放糖果
                return NSLocalizedString(@"Issuing candy", nil);
            }
        } else {
            return NSLocalizedString(@"SAFE change output", nil);
        }
    } else if (![self isSend]) { // 接收
        return NSLocalizedString(@"receive", nil);
    } else { // 转账
        if(![BRSafeUtils isSafeTransaction:data]) { // data.length > 42
            NSNumber * l = 0;
            NSUInteger off = 0;
            NSData *d = [data dataAtOffset:off length:&l];
            if ([d UInt16AtOffset:38] == 204) { // 资产找零
                return NSLocalizedString(@"Asset change output", nil);
            } else if([d UInt16AtOffset:38] == 202) { // 转让
                return NSLocalizedString(@"Expenditure", nil);
            }
        } else {
            if (![[BRWalletManager sharedInstance].wallet containsAddress:address]) {
                return NSLocalizedString(@"Expenditure", nil);
            } else {
                return NSLocalizedString(@"SAFE change output", nil);
            }
        }
    }
    return @"";
}

// 发送
- (BOOL) isSend {
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    
    uint64_t received = [manager.wallet amountReceivedFromTransaction:self.tx balanceModel:self.balanceModel],
    sent = [manager.wallet amountSentByTransaction:self.tx balanceModel:self.balanceModel];
    
    if (received > 0 && sent == 0) { // 进账
        return NO;
    } else { // 出账
        return YES;
    }
}

// 是否资产发行
- (BOOL) isPushlishAsset {
    for(NSData *reserves in self.tx.outputReserves) {
        if([reserves isEqual:[NSNull null]]) continue;
        NSNumber * l = 0;
        NSUInteger off = 0;
        NSData *d = [reserves dataAtOffset:off length:&l];
        if ([d UInt16AtOffset:38] == 200) {
            return YES;
        }
    }
    return NO;
}

// 是否是发放糖果
- (BOOL) isPushlishCandy {
    for(NSData *reserves in self.tx.outputReserves) {
        if([reserves isEqual:[NSNull null]]) continue;
        NSNumber * l = 0;
        NSUInteger off = 0;
        NSData *d = [reserves dataAtOffset:off length:&l];
        if ([d UInt16AtOffset:38] == 205) {
            return YES;
        }
    }
    return NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
