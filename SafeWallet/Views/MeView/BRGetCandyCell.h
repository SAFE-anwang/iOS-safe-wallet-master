//
//  BRGetCandyCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/24.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRGetCandyCellDelegate <NSObject>

@optional

- (void) getCandyCellIndex:(NSIndexPath *) indexPath;

@end


@interface BRGetCandyCell : UITableViewCell

@property (nonatomic, weak) id<BRGetCandyCellDelegate>delegate;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic,strong) UILabel *assetNameLable;

@property (nonatomic,strong) UILabel *timeLable;

@property (nonatomic,strong) UILabel *amountLable;

@property (nonatomic,strong) UIButton *getButton;

@end
