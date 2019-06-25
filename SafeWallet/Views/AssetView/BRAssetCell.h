//
//  BRAssetCell.h
//  dashwallet
//
//  Created by joker on 2018/6/19.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BRBalanceModel;

@interface BRAssetCell : UITableViewCell

@property (nonatomic, strong) BRBalanceModel *balance;

@end
