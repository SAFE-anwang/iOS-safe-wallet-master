//
//  BRPublishAssetEditCheckboxCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/9.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRPublishAssetEditCheckboxCellDelegate <NSObject>

@optional

- (void) publishAssetEditCheckboxCellWithIsCandy: (BOOL) isCandy;

- (void) publishAssetEditCheckboxCellWithIsDestroy: (BOOL) isDestroy;

@end

@interface BRPublishAssetEditCheckboxCell : UITableViewCell

@property (nonatomic,weak) id<BRPublishAssetEditCheckboxCellDelegate> delegate;

@property (nonatomic,assign) BOOL isDestroy;

@property (nonatomic,assign) BOOL isCandy;

@end
