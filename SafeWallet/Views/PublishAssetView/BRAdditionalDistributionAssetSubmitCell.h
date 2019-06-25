//
//  BRAdditionalDistributionAssetSubmitCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/11.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRAdditionalDistributionAssetSubmitCellDelegate <NSObject>

@optional

- (void) additionalDistributionAssetSubmitCellLoadSubmintClick;

- (void) additionalDistributionAssetSubmitCellLoadSelectContentClick;

@end

@interface BRAdditionalDistributionAssetSubmitCell : UITableViewCell

@property (nonatomic, weak) id<BRAdditionalDistributionAssetSubmitCellDelegate>delegate;

@property (nonatomic,strong) UIButton *submitBtn;

@end
