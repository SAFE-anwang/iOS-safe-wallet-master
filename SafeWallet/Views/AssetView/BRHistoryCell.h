//
//  BRHistoryCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/21.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BRTransaction, BRBalanceModel;

@interface BRHistoryCell : UITableViewCell

@property (nonatomic, strong) BRTransaction *tx;
@property (nonatomic, strong) BRBalanceModel *balanceModel;
@property (nonatomic, copy) NSString *timeStr;
@property (nonatomic, assign) uint32_t blockHeight;

@end
