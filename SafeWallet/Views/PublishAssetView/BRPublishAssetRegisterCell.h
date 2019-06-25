//
//  BRPublishAssetRegisterCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/8.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRPublishAssetRegisterCellDelegate <NSObject>

@optional

- (void) publishAssetRegisterCellLoadRegisterApplication;

- (void) publishAssetRegisterCellLoadIssueAsset;

@end

@interface BRPublishAssetRegisterCell : UITableViewCell

@property (nonatomic, weak) id<BRPublishAssetRegisterCellDelegate> delegate;

@end
