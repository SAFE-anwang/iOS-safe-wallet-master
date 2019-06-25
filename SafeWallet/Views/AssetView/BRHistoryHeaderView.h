//
//  BRHistoryHeaderView.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/21.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRBalanceModel.h"

@interface BRHistoryHeaderView : UIView

@property (nonatomic,strong) UIImageView *headerImageView;
@property (nonatomic,strong) UILabel *totalAssetLable;//总资产
@property (nonatomic,strong) UILabel *useAssetLable;//可用资产
@property (nonatomic,strong) UILabel *waitAssetLable;//等待资产
@property (nonatomic,strong) UILabel *lockAssetLable;//锁定资产

@property (nonatomic,strong) BRBalanceModel *balanceModel;

- (instancetype)initWithFrame:(CGRect)frame;

- (void) reloadBalanceShow;
@end
