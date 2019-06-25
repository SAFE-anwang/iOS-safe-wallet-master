//
//  BRDetailTxHeaderView.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/21.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRDetailTxHeaderView.h"
#import "BRWalletManager.h"
#import "BRPeerManager.h"
#import "BRSafeUtils.h"
#import "BRIssueDataEnity+CoreDataProperties.h"
#import "BRCoreDataManager.h"

@interface BRDetailTxHeaderView ()

@property (nonatomic,strong) UILabel *assetLable;
@property (nonatomic,strong) UILabel *lockStatusLable;
@property (nonatomic,strong) UILabel *lockTimeLable;
@property (nonatomic,strong) UILabel *unlockHeightLable;
@property (nonatomic,strong) NSArray *issueArray;
@end

@implementation BRDetailTxHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    imageView.frame = self.frame;
    [self addSubview:imageView];
    
    UILabel *totalMoneyLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, 20)];
    totalMoneyLable.text = NSLocalizedString(@"Locking", nil);
    totalMoneyLable.textColor = [UIColor whiteColor];
    totalMoneyLable.font = [UIFont systemFontOfSize:16.f];
    totalMoneyLable.textAlignment = NSTextAlignmentCenter;
    [self addSubview:totalMoneyLable];
    self.lockStatusLable = totalMoneyLable;
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(totalMoneyLable.frame) + 5, SCREEN_WIDTH - 20, 25)];
    lable.text = @"+ 6000000";
    lable.textColor = [UIColor whiteColor];
    lable.font = [UIFont systemFontOfSize:18.f];
    lable.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lable];
    self.assetLable = lable;
    
    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(lable.frame) + 20, SCREEN_WIDTH, 20)];
    bottomView.backgroundColor = [UIColor clearColor];
    [self addSubview:bottomView];
    
    CGFloat moneyLabWidth = (SCREEN_WIDTH - 40) * 0.5;
    CGFloat moneyLabHeight = 20;
    
    UILabel *useMoneyLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, moneyLabWidth, moneyLabHeight)];
    useMoneyLable.text = @"锁定时长:12个月";
    useMoneyLable.textColor = [UIColor whiteColor];
    useMoneyLable.font = [UIFont systemFontOfSize:15.f];
    useMoneyLable.textAlignment = NSTextAlignmentCenter;
    useMoneyLable.numberOfLines = 0;
    [bottomView addSubview:useMoneyLable];
    self.lockTimeLable = useMoneyLable;
    
    UILabel *waitMoneyLable = [[UILabel alloc] initWithFrame:CGRectMake(20 + moneyLabWidth, 0, moneyLabWidth, moneyLabHeight)];
    waitMoneyLable.text = @"解锁高度:9999999";
    waitMoneyLable.textColor = [UIColor whiteColor];
    waitMoneyLable.font = [UIFont systemFontOfSize:15.f];
    waitMoneyLable.textAlignment = NSTextAlignmentCenter;
    waitMoneyLable.numberOfLines = 0;
    [bottomView addSubview:waitMoneyLable];
    self.unlockHeightLable = waitMoneyLable;
}

- (void)setTransaction:(BRTransaction *)transaction {
    _transaction = transaction;
}

- (void)setBalanceModel:(BRBalanceModel *)balanceModel {
    _balanceModel = balanceModel;
    if(self.issueArray == nil) {
        self.issueArray = [[BRCoreDataManager sharedInstance] entity:@"BRIssueDataEnity" objectsMatching:[NSPredicate predicateWithFormat:@"assetId = %@", self.balanceModel.assetId]];
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    BRTransaction *tx = self.transaction;
    // TODO: 修改
//    uint64_t received = [manager.wallet amountReceivedFromTransaction:tx] * self.multiple;
//    uint64_t sent = [manager.wallet amountSentByTransaction:tx] * self.multiple;
    uint64_t received;
    uint64_t sent;
    received = [manager.wallet amountReceivedFromTransaction:tx balanceModel:self.balanceModel];
    sent = [manager.wallet amountSentByTransaction:tx balanceModel:self.balanceModel];
   

    NSString *lockTime = @"0";
    
    static uint32_t height = 0;
    uint32_t h = [BRPeerManager sharedInstance].lastBlockHeight;
    if (h > height) height = h;
    
    uint64_t unlockHeight = 0;
    for (NSNumber *number in tx.outputUnlockHeights) {
        uint64_t h = [number longLongValue];
        if (h > height) {
            unlockHeight = h;
            break;
        }
    }
    
    if (sent > 0) {
        if (received == sent) {
            if (self.balanceModel.assetId.length == 0) {
                [NSString stringWithFormat:@"- %@", [self translateAssetWithAmount:received - sent]];
            } else {
                
                if(self.issueArray.count > 0) {
                    BRIssueDataEnity *issueModel = self.issueArray.firstObject;
                    self.assetLable.text = [NSString stringWithFormat:@"%@(%@)",[BRSafeUtils amountForAssetAmount:0 decimals:self.balanceModel.multiple], issueModel.assetUnit];
                }
                for(int i=0; i<tx.outputReserves.count; i++) {
                    uint64_t height = [tx.outputUnlockHeights[i] unsignedLongLongValue];
                    if(height > 0) {
//                    NSNumber * l = 0;
//                    NSUInteger off = 0;
//                    NSData *d = [tx.outputReserves[i] dataAtOffset:off length:&l];
//                    if([d UInt16AtOffset:38] == 202) {
                        if(self.issueArray.count > 0) {
                            BRIssueDataEnity *issueModel = self.issueArray.firstObject;
                            self.assetLable.text = [NSString stringWithFormat:@"+%@(%@)",[BRSafeUtils amountForAssetAmount:[tx.outputAmounts[i] unsignedLongLongValue] decimals:self.balanceModel.multiple], issueModel.assetUnit];
                        }
                        break;
                    }
                }
            }
        } else {
            if(self.balanceModel.assetId.length == 0) {
                if([self isPushlishAsset:tx]) {
                    for (int i=0; i<tx.outputAddresses.count; i++) {
                        NSString *outputAddress = tx.outputAddresses[i];
                        if([outputAddress isEqualToString:BLACK_HOLE_ADDRESS]) {
                            self.assetLable.text = [NSString stringWithFormat:@"-%@%@", [BRSafeUtils showSAFEAmount:([tx.outputAmounts[i] unsignedLongLongValue])], [BRSafeUtils showSAFEUint].length > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"];
                            break;
                        }
                    }
                } else {
                    self.assetLable.text = [NSString stringWithFormat:@"%@%@%@", (sent - received - [manager.wallet feeForTransaction:tx]) > 0 ? @"-" : @"", [BRSafeUtils showSAFEAmount:sent - received - [manager.wallet feeForTransaction:tx]], [[BRSafeUtils showSAFEUint] length] > 0 ? [NSString stringWithFormat:@"(%@)", [BRSafeUtils showSAFEUint]] : @"(SAFE)"];
                    if((sent - received - [manager.wallet feeForTransaction:tx]) == 0) {
                        for(int j=0; j<tx.outputUnlockHeights.count; j++) {
                            uint64_t height = [tx.outputUnlockHeights[j] unsignedLongLongValue];
                            if(height > 0) {
                                self.assetLable.text = [NSString stringWithFormat:@"+%@%@", [BRSafeUtils showSAFEAmount:[tx.outputAmounts[j] unsignedLongLongValue]], [[BRSafeUtils showSAFEUint] length] > 0 ? [NSString stringWithFormat:@"(%@)", [BRSafeUtils showSAFEUint]] : @"(SAFE)"];
                                break;
                            }
                        }
                    }
                }
            } else {
                if(self.issueArray.count > 0) {
                    BRIssueDataEnity *issueModel = self.issueArray.firstObject;
                    self.assetLable.text = [NSString stringWithFormat:@"%@(%@)", [BRSafeUtils amountForAssetAmount:received - sent decimals:self.balanceModel.multiple], issueModel.assetUnit];
                }
            }
        }
        
        if (unlockHeight > 0) {
            if (unlockHeight > height) {
                self.lockStatusLable.text = NSLocalizedString(@"Locking", nil);
                if (tx.blockHeight == INT32_MAX) {
                    lockTime = @"0";
                } else {
                    lockTime = [NSString stringWithFormat:@"%d", (int)ceill((unlockHeight - (uint64_t)tx.blockHeight) / (BLOCKS_PER_MONTH * 1.0))];
                }
                self.lockTimeLable.text = [NSString stringWithFormat:NSLocalizedString(@"Locked time:%@ month", nil),lockTime];
                self.unlockHeightLable.text = [NSString stringWithFormat:NSLocalizedString(@"Unlock height:%ld", nil),(long)unlockHeight];
            } else {
                self.lockStatusLable.text = NSLocalizedString(@"Unlocked", nil);
                self.lockTimeLable.text = NSLocalizedString(@"Locked time:0 month", nil);
                self.unlockHeightLable.text = [NSString stringWithFormat:NSLocalizedString(@"Unlock height:%ld", nil),(long)unlockHeight];
            }
            
        } else {
            self.lockStatusLable.text = NSLocalizedString(@"Sent", nil);
            self.lockTimeLable.text = NSLocalizedString(@"Locked time:0 month", nil);
            self.unlockHeightLable.text = NSLocalizedString(@"Unlock height:0", nil);
        }
//        self.lockStatusLable.text = NSLocalizedString(@"Sent", nil);
//        self.lockTimeLable.text = NSLocalizedString(@"Lock time:0 month", nil);
//        self.unlockHeightLable.text = NSLocalizedString(@"Unlock height:0", nil);
    }
    if (received > 0 && sent == 0) {
        
//        NSNumber *number = [tx.outputUnlockHeights firstObject];
        if(self.balanceModel.assetId.length == 0) {
            self.assetLable.text = [NSString stringWithFormat:@"+ %@%@", [BRSafeUtils showSAFEAmount:received], [[BRSafeUtils showSAFEUint] length] > 0 ? [NSString stringWithFormat:@"(%@)", [BRSafeUtils showSAFEUint]] : @"(SAFE)"];
        } else {
            if(self.issueArray.count > 0) {
                BRIssueDataEnity *issueModel = self.issueArray.firstObject;
                self.assetLable.text = [NSString stringWithFormat:@"+ %@(%@)", [BRSafeUtils amountForAssetAmount:received decimals:self.balanceModel.multiple], issueModel.assetUnit];
            }
        }
        if (unlockHeight > 0) {
            if (unlockHeight > height) {
                self.lockStatusLable.text = NSLocalizedString(@"Locking", nil);
                if (tx.blockHeight == INT32_MAX) {
                    lockTime = @"0";
                } else {
                    lockTime = [NSString stringWithFormat:@"%d", (int)ceill((unlockHeight - (uint64_t)tx.blockHeight) / (BLOCKS_PER_MONTH * 1.0))];
                }
                self.lockTimeLable.text = [NSString stringWithFormat:NSLocalizedString(@"Locked time:%@ month", nil),lockTime];
                self.unlockHeightLable.text = [NSString stringWithFormat:NSLocalizedString(@"Unlock height:%ld", nil),(long)unlockHeight];
            } else {
                self.lockStatusLable.text = NSLocalizedString(@"Unlocked", nil);
                self.lockTimeLable.text = NSLocalizedString(@"Locked time:0 month", nil);
                self.unlockHeightLable.text = [NSString stringWithFormat:NSLocalizedString(@"Unlock height:%ld", nil),(long)unlockHeight];
            }
        } else {
            self.lockStatusLable.text = NSLocalizedString(@"Available", nil);
            self.lockTimeLable.text = NSLocalizedString(@"Locked time:0 month", nil);
            self.unlockHeightLable.text = NSLocalizedString(@"Unlock height:0", nil);
        }
    }
    
//    if ([lockTime isEqualToString:@"0"]) {
        self.lockTimeLable.hidden = YES;
        self.unlockHeightLable.hidden = YES;
//    }
    
    self.lockStatusLable.text = NSLocalizedString(@"Amount of the transaction", nil);
}

// 是否资产发行
- (BOOL) isPushlishAsset:(BRTransaction *) tx {
    for(int i=0; i<tx.outputReserves.count; i++) {
        NSNumber * l = 0;
        NSUInteger off = 0;
        NSData *d = [tx.outputReserves[i] dataAtOffset:off length:&l];
        if ([d UInt16AtOffset:38] == 200) {
            return YES;
        }
    }
    return NO;
}

- (NSDecimalNumber *)translateAssetWithAmount:(uint64_t)amount {
    uint64_t tempBalance = amount;
    NSString *stringA = [NSString stringWithFormat:@"%ld",(long)tempBalance];
    NSString *stringB = [NSString stringWithFormat:@"100000000.0000"];
    NSDecimalNumber *totalBalance = [NSDecimalNumber decimalNumberWithString:stringA];
    NSDecimalNumber *actualBalance = [NSDecimalNumber decimalNumberWithString:stringB];
    NSDecimalNumber *finalBalance = [totalBalance decimalNumberByDividingBy:actualBalance];
    return finalBalance;
}

@end
