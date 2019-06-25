//
//  BRReceivablesCodeCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/19.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRReceivablesCodeCellDelegate <NSObject>

@optional

- (void) receivablesCodeCellLoadCopyURLClick;

- (void) receivablesCodeCellLoadCopyAddressClick;

@end

@interface BRReceivablesCodeCell : UITableViewCell

@property (nonatomic, weak) id<BRReceivablesCodeCellDelegate>delegate;

@property (nonatomic,strong) UIImageView *showCodeImageView;

@end
