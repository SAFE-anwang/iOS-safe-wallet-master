//
//  BRTXHistoryListViewController.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/17.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRTransaction.h"
#import "BRBalanceModel.h"

@interface BRTXHistoryListViewController : UIViewController

@property (nonatomic, strong) BRTransaction *tx;

@property (nonatomic, strong) BRBalanceModel *balanceModel;

@end
