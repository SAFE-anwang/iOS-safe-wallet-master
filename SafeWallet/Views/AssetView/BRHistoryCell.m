//
//  BRHistoryCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/21.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRHistoryCell.h"
#import "UIView+Extension.h"
#import "BRTransaction.h"
#import "BRWalletManager.h"
#import "BRSafeUtils.h"
#import "BRPeerManager.h"
/**
 交易状态
 
 
 - TXStatusInvalid:
 - TXStatusWaiting:
 - TXStatusUnverified:
 - TXStatusSent:
 - TXStatusReceived: 已收到
 */
typedef NS_ENUM(NSUInteger, TXStatus) {
    ///  确认中
    TXStatusConfirming,
    ///  无效
    TXStatusInvalid,
    ///  等待中
    TXStatusWaiting,
    ///  未验证
    TXStatusUnverified,
    ///  已发送
    TXStatusSent,
    ///  已收到
    TXStatusReceived
};


@interface BRHistoryCell()

@property (nonatomic,strong) UIImageView *arrowImageView;
@property (nonatomic,strong) UILabel *addressLable;
@property (nonatomic,strong) UILabel *statusLable;
@property (nonatomic,strong) UILabel *timeLable;
@property (nonatomic,strong) UILabel *loseOrGetAssetLable;
@property (nonatomic,strong) UILabel *amoutLable;
@property (nonatomic,strong) UIImageView *lockImageView;

@property (nonatomic, assign) TXStatus txStatus;


@end

@implementation BRHistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    // 箭头
    UIImageView *arrowImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"right"]];
    self.arrowImageView = arrowImgView;
    [self addSubview:arrowImgView];
    [arrowImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(10);
        make.centerY.equalTo(self);
        make.width.height.mas_equalTo(@20);
    }];
    
    // 地址
    UILabel *addressLabel = [[UILabel alloc] init];
    self.addressLable = addressLabel;
    addressLabel.text = @"Xs1yjUshwYzsQf8t6t6u1t2NuuCKW7PXkW";
    addressLabel.font = kFont(12);
    [self addSubview:addressLabel];
    [addressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(arrowImgView.mas_right).offset(10);
        make.top.mas_equalTo(self.mas_top).offset(15);
        make.height.equalTo(@30);
    }];
    
    // 状态
    UILabel *statusLabel = [[UILabel alloc] init];
    self.statusLable = statusLabel;
    statusLabel.font = kFont(12);
    statusLabel.text = @"未验证";
    statusLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:statusLabel];
    [statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self.mas_right).offset(-10);
        make.height.equalTo(@30);
        make.top.mas_equalTo(self).offset(15);
        make.width.equalTo(@106);
        make.left.mas_equalTo(addressLabel.mas_right).offset(4);
    }];
//    self.timeLable = [[UILabel alloc] init];
//    self.timeLable.textColor = [UIColor darkGrayColor];
//    self.timeLable.font = kFont(12);
//    self.timeLable.text = @"88/88/88 88:88";
//    [self addSubview:self.timeLable];
//
//    self.loseOrGetAssetLable = [[UILabel alloc] init];
//    self.loseOrGetAssetLable.textAlignment = NSTextAlignmentRight;
//    self.loseOrGetAssetLable.font = kBlodFont(12);
//    self.loseOrGetAssetLable.text = @"888,888,888,888,888,888,8";
//    [self addSubview:self.loseOrGetAssetLable];
//
//    self.lockImageView = [[UIImageView alloc] init];
//    self.lockImageView.image = [UIImage imageNamed:@"assetLock"];
//    [self addSubview:self.lockImageView];
//
//    [self.timeLable mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.mas_left).offset(40);
//        make.right.equalTo(self.loseOrGetAssetLable.mas_left).offset(-20);
//        make.height.equalTo(@(20));
//        make.bottom.equalTo(self.mas_bottom).offset(-10);
//    }];
//
//    [self.loseOrGetAssetLable mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.timeLable.mas_right).offset(20);
//        make.right.equalTo(self.mas_right).offset(-10);
//        make.height.equalTo(@(20));
//        make.bottom.equalTo(self.mas_bottom).offset(-10);
//    }];
//    [self.loseOrGetAssetLable setContentCompressionResistancePriority:(UILayoutPriorityRequired) forAxis:(UILayoutConstraintAxisHorizontal)];
//
//    [self.lockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.width.height.equalTo(@(20));
//        make.centerY.equalTo(self.loseOrGetAssetLable.mas_centerY);
//        make.right.equalTo(self.loseOrGetAssetLable.mas_left);
//    }];
    
    // 时间
    UILabel *timeLabel = [[UILabel alloc] init];
    self.timeLable = timeLabel;
    timeLabel.textColor = [UIColor darkGrayColor];
    timeLabel.font = kFont(12);
    timeLabel.text = @"88/88/88 88:88";
    [self addSubview:timeLabel];
    [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(arrowImgView.mas_right).offset(10);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-10);
        make.height.equalTo(@20);
    }];
    [timeLabel setContentCompressionResistancePriority:(UILayoutPriorityDefaultLow) forAxis:(UILayoutConstraintAxisHorizontal)];
    // 钱数
    UILabel *moneyLabel = [[UILabel alloc] init];
    self.loseOrGetAssetLable = moneyLabel;
    moneyLabel.textAlignment = NSTextAlignmentRight;
    moneyLabel.font = kBlodFont(12);
    moneyLabel.text = @"888,888,888,888,888,888,8";
    moneyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    [self addSubview:moneyLabel];
    [moneyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-10);
        make.bottom.mas_equalTo(self).offset(-10);
        make.height.equalTo(@20);
    }];
    [moneyLabel setContentCompressionResistancePriority:(UILayoutPriorityRequired) forAxis:(UILayoutConstraintAxisHorizontal)];
    UIImageView *lockImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"assetLock"]];
    self.lockImageView = lockImgView;
    [self addSubview:lockImgView];
    [lockImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@20);
        make.right.mas_equalTo(moneyLabel.mas_left).offset(0);
        make.centerY.mas_equalTo(moneyLabel);
        make.left.mas_greaterThanOrEqualTo(timeLabel.mas_right).offset(5);// mas_equalTo(timeLabel.mas_right).offset(5);
    }];

    
    
}

- (void)setTx:(BRTransaction *)tx {
    _tx = tx;
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    
    uint64_t received = [manager.wallet amountReceivedFromTransaction:tx balanceModel:self.balanceModel],
    sent = [manager.wallet amountSentByTransaction:tx balanceModel:self.balanceModel],
    balance = [manager.wallet balanceAfterTransaction:tx];
    
    NSString *sendAddress = @"";
    if (received > 0 && sent == 0) { // 进账
        sendAddress = [self isPushlishAsset];
        if(sendAddress.length == 0) {
            if([self isAddPushlishAsset]) {
                sendAddress = NSLocalizedString(@"Internal", nil);
            } else {
                for (NSString *outputAddress in tx.outputAddresses) {
                    if ([manager.wallet containsAddress:outputAddress]) {
                        sendAddress = outputAddress;
                    }
                }
            }
        }
    } else { // 出账
        for (NSString *outputAddress in tx.outputAddresses) {
            if([[self isPushlishAsset] length] > 0 && self.balanceModel.assetId.length == 0 && [outputAddress isEqualToString:BLACK_HOLE_ADDRESS]) {
                sendAddress = outputAddress;
                break;
            } else {
                if (![manager.wallet containsAddress:outputAddress]) {
                    sendAddress = outputAddress;
                }
            }
        }
    }
    
    uint32_t blockHeight = self.blockHeight;
    uint32_t confirms = (tx.blockHeight > blockHeight) ? 0 : (blockHeight - tx.blockHeight) + 1;
    BOOL showLock = NO;
    for (int i=0; i<tx.outputUnlockHeights.count; i++) {
        long long unlockheight = [tx.outputUnlockHeights[i] unsignedLongLongValue];
        if (unlockheight > TEST_START_SPOS_HEIGHT && (tx.blockHeight < TEST_START_SPOS_HEIGHT || tx.version == TX_VERSION_NUMBER)) {
            unlockheight = (unlockheight - TEST_START_SPOS_HEIGHT) * TEST_START_SPOS_BlockTimeRatio + TEST_START_SPOS_HEIGHT;
        }
        if (unlockheight > 0 && unlockheight > blockHeight) {
            if (received > 0 && sent == 0) {
                if([manager.wallet containsAddress:tx.outputAddresses[i]]) {
                    showLock = YES;
                    break;
                }
            } else {
                showLock = YES;
                break;
            }
        }
    }
    self.lockImageView.hidden = !showLock;
    

    if (received > 0 && sent == 0) {
        self.arrowImageView.image = [UIImage imageNamed:@"right"];
        if(self.balanceModel.assetId.length == 0) {
            self.loseOrGetAssetLable.text = [NSString stringWithFormat:@"+%@%@", [BRSafeUtils showSAFEAmount:received], [BRSafeUtils showSAFEUint].length > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"];
        } else {
            self.loseOrGetAssetLable.text = [NSString stringWithFormat:@"+%@", [BRSafeUtils amountForAssetAmount:received decimals:self.balanceModel.multiple]];
            [self.loseOrGetAssetLable setContentMode:UIViewContentModeLeft];
        }
    } else {
        self.arrowImageView.image = [UIImage imageNamed:@"left"];
        if(self.balanceModel.assetId.length == 0) {
            if(self.balanceModel.assetId.length == 0 && [self isPushlishAsset].length > 0) {
                for (int i=0; i<tx.outputAddresses.count; i++) {
                    NSString *outputAddress = tx.outputAddresses[i];
                    if([outputAddress isEqualToString:BLACK_HOLE_ADDRESS]) {
                        self.loseOrGetAssetLable.text = [NSString stringWithFormat:@"-%@%@", [BRSafeUtils showSAFEAmount:([tx.outputAmounts[i] unsignedLongLongValue])], [BRSafeUtils showSAFEUint].length > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"];
                        break;
                    }
                }
            } else {
                if((sent - received - [manager.wallet feeForTransaction:tx]) == 0) {
                    self.loseOrGetAssetLable.text = [NSString stringWithFormat:@"-%@%@", [BRSafeUtils showSAFEAmount:[manager.wallet feeForTransaction:tx]], [BRSafeUtils showSAFEUint].length > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"];
                } else {
                    self.loseOrGetAssetLable.text = [NSString stringWithFormat:@"%@%@%@", (sent - received - [manager.wallet feeForTransaction:tx]) > 0 ? @"-" : @"", [BRSafeUtils showSAFEAmount:(sent - received - [manager.wallet feeForTransaction:tx])], [BRSafeUtils showSAFEUint].length > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"];
                }
            }
        } else {
            self.loseOrGetAssetLable.text = [BRSafeUtils amountForAssetAmount:received - sent decimals:self.balanceModel.multiple];
//            if(received - sent == 0) {
//                for (int i=0; i<tx.outputReserves.count; i++) {
//                    NSNumber * l = 0;
//                    NSUInteger off = 0;
//                    NSData *d = [tx.outputReserves[i] dataAtOffset:off length:&l];
//                    if([d UInt16AtOffset:38] == 202) {
//                        self.loseOrGetAssetLable.text = [NSString stringWithFormat:@"+%@", [BRSafeUtils amountForAssetAmount:[tx.outputAmounts[i] unsignedLongLongValue] decimals:self.balanceModel.multiple]];
//                        break;
//                    }
//                }
//            }
        }
    }
    
    if (![sendAddress isEqual:[NSNull null]] && sendAddress.length == 0) {
#warning Language International
        sendAddress = NSLocalizedString(@"Internal", nil);
        for(int i=0; i<tx.outputUnlockHeights.count; i++) {
            uint64_t height = [tx.outputUnlockHeights[i] unsignedLongLongValue];
            if(height > 0) {
                if(self.balanceModel.assetId.length == 0) {
                    self.loseOrGetAssetLable.text = [NSString stringWithFormat:@"+%@%@", [BRSafeUtils showSAFEAmount:[tx.outputAmounts[i] unsignedLongLongValue]], [BRSafeUtils showSAFEUint].length > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"];
                } else {
                    self.loseOrGetAssetLable.text = [NSString stringWithFormat:@"+%@", [BRSafeUtils amountForAssetAmount:[tx.outputAmounts[i] unsignedLongLongValue] decimals:self.balanceModel.multiple]];
                }
                break;
            }
        }
    }
    self.addressLable.text = sendAddress;
    
    if (confirms == 0 && ! [manager.wallet transactionIsValid:tx]) {
        self.txStatus = TXStatusInvalid;
        self.statusLable.text = NSLocalizedString(@"INVALID", nil);
    }
    else if (confirms == 0 && [manager.wallet transactionIsPending:tx]) {
        self.txStatus = TXStatusWaiting;
        self.statusLable.text = NSLocalizedString(@"pending", nil);
    }
    else if (confirms == 0 && ! [manager.wallet transactionIsVerified:tx]) {
        self.txStatus = TXStatusUnverified;
        self.statusLable.text = NSLocalizedString(@"unverified", nil);
    }
    else if (confirms < 6) {
        self.txStatus = TXStatusConfirming;
        if (confirms == 0) self.statusLable.text = NSLocalizedString(@"0 confirmations", nil);
        else if (confirms == 1) self.statusLable.text = NSLocalizedString(@"1 confirmation", nil);
        else self.statusLable.text = [NSString stringWithFormat:NSLocalizedString(@"%d confirmations", nil),
                                      (int)confirms];
    } else {
        if (sent > 0) {
//            if (received == sent) {
//                self.statusLable.text = NSLocalizedString(@"moved", nil);
//            } else {
                self.statusLable.text = NSLocalizedString(@"sent", nil);
//            }
            self.txStatus = TXStatusSent;
        } else if (received > 0 && sent == 0) {
            self.txStatus = TXStatusReceived;
            self.statusLable.text = NSLocalizedString(@"received", nil);
        }
#warning Language International
        else if ([sendAddress isEqualToString:NSLocalizedString(@"Internal", nil)]) {
            self.statusLable.text = NSLocalizedString(@"moved", nil);
            self.txStatus = TXStatusSent;
        }
    }
    if([BRPeerManager sharedInstance].lastBlockHeight >= DisableDash_TX_HEIGHT) {
        for(int i=0; i<tx.outputReserves.count; i++) {
            if([tx.outputReserves[i] isEqual:[NSNull null]]) {
                self.statusLable.text = NSLocalizedString(@"Sealed", nil);
                self.txStatus = TXStatusSent;
                break;
            }
        }
    }

    self.statusLable.clipsToBounds = YES;
    [self configStatusLabel];
    if (self.lockImageView.hidden) {
        [self.lockImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(@20);
            make.right.mas_equalTo(self.loseOrGetAssetLable.mas_left).offset(0);
            make.centerY.mas_equalTo(self.loseOrGetAssetLable);
            make.left.mas_greaterThanOrEqualTo(self.timeLable.mas_right).offset(5);
        }];
    }
}

- (BOOL) isAddPushlishAsset {
    for(int i=0; i<self.tx.outputReserves.count; i++) {
        if([self.tx.outputReserves[i] isEqual:[NSNull null]]) continue;
        NSNumber * l = 0;
        NSUInteger off = 0;
        NSData *d = [self.tx.outputReserves[i] dataAtOffset:off length:&l];
        if ([d UInt16AtOffset:38] == 201) {
            return YES;
        }
    }
    return NO;
}

// 是否资产发行
- (NSString *) isPushlishAsset {
    for(int i=0; i<self.tx.outputReserves.count; i++) {
        if([self.tx.outputReserves[i] isEqual:[NSNull null]]) continue;
        NSNumber * l = 0;
        NSUInteger off = 0;
        NSData *d = [self.tx.outputReserves[i] dataAtOffset:off length:&l];
        if ([d UInt16AtOffset:38] == 200) {
            return self.tx.outputAddresses[i];
        }
    }
    return @"";
}

- (void)setTimeStr:(NSString *)timeStr {
    _timeStr = timeStr;
    self.timeLable.text = timeStr;
}

- (void)configStatusLabel {
    UIColor *borderColor;
    
    switch (self.txStatus) {
        case TXStatusConfirming:
            self.statusLable.backgroundColor = ColorFromRGB(0x999999);
            self.statusLable.textColor = [UIColor whiteColor];
            borderColor = ColorFromRGB(0x999999);
            break;
        case TXStatusInvalid:
            self.statusLable.backgroundColor = [UIColor redColor];
            self.statusLable.textColor = [UIColor whiteColor];
            borderColor = [UIColor grayColor];
            break;
        case TXStatusWaiting:
            self.statusLable.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
            self.statusLable.textColor = [UIColor grayColor];
            borderColor = [UIColor grayColor];
            break;
        case TXStatusUnverified:
            self.statusLable.backgroundColor = [UIColor redColor];
            self.statusLable.textColor = [UIColor whiteColor];
            borderColor = [UIColor redColor];
            break;
        case TXStatusSent: {
            UIColor *sentColor = [UIColor colorWithRed:1.0 green:0.33 blue:0.33 alpha:1.0];
            self.statusLable.backgroundColor = [UIColor clearColor];
            self.statusLable.textColor = sentColor;
            borderColor = sentColor;
        }
            break;
        case TXStatusReceived: {
            UIColor *receiveColor = [UIColor colorWithRed:0.0 green:0.75 blue:0.0 alpha:1.0];
            self.statusLable.backgroundColor = [UIColor clearColor];
            self.statusLable.textColor = receiveColor;
            borderColor = receiveColor;
        }
            break;
    }
//    [BRSafeUtils logTransaction:self.tx];
    [self layoutIfNeeded];
    self.statusLable.layer.cornerRadius = 3;
    self.statusLable.layer.borderColor = borderColor.CGColor;
    self.statusLable.layer.borderWidth = 1;
}

- (void)layoutSubviews {

    [super layoutSubviews];

}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
