//
//  BRPayAddressMoneyCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/17.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRBalanceModel.h"
#import "BRAmountTextField.h"

#define payAddressMoneyCellNotification @"BRPayAddressMoneyCellNotification"

@protocol BRPayAddressMoneyCellDelegate <NSObject>

@optional

- (void) payAddressMoneyCellAmount:(NSString *) amount;

@end

@interface BRPayAddressMoneyCell : UITableViewCell

@property (nonatomic, weak) id<BRPayAddressMoneyCellDelegate>delegate;

@property (nonatomic, strong) BRBalanceModel *balanceModel;

@property (nonatomic,strong) BRAmountTextField *textField;

@property (nonatomic,strong) UILabel *titleLabel;

@property (nonatomic,strong) NSArray *issueList;

@end
