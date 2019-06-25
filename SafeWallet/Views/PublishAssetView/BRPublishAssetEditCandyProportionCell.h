//
//  BRPublishAssetEditCandyProportionCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/9.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRPublishAssetEditCandyProportionCellDelegate <NSObject>

@optional

- (void) publishAssetEditCandyProportionCellLoadSubmintClick;

@end

@interface BRPublishAssetEditCandyProportionCell : UITableViewCell

@property (nonatomic,weak) id<BRPublishAssetEditCandyProportionCellDelegate> delegate;

@property (nonatomic,strong) UIButton *confirmBtn;

@end
