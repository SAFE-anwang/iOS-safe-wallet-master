//
//  BRCandyHistoryCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/24.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BRGetCandyEntity;

@interface BRCandyHistoryCell : UITableViewCell

@property (nonatomic,strong) UILabel *assetNameLable;

@property (nonatomic,strong) UILabel *amountLable;

@property (nonatomic,strong) UILabel *addressLable;

@property (nonatomic, strong) BRGetCandyEntity *candy;

@end
