//
//  BRTXHistoryListCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/27.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BRTXHistoryListCell : UITableViewCell

@property (nonatomic,strong) UILabel *assetNameLable;

@property (nonatomic,strong) UILabel *amountLable;

@property (nonatomic,strong) UILabel *addressLable;

@property (nonatomic,strong) UILabel *lockMonthLabel;

@property (nonatomic,strong) UILabel *lockHeightLabel;

@property (nonatomic,strong) UIImageView *lockImageView;

@end
