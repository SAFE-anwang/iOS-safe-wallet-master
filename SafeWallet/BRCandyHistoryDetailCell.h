//
//  BRCandyHistoryDetailCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/24.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRCandyHistoryDetailCellDelegate <NSObject>

- (void)qrcodeLongpress:(UIImage *)longpressImage;

@end

@interface BRCandyHistoryDetailCell : UITableViewCell

@property (nonatomic, weak) id<BRCandyHistoryDetailCellDelegate>delegate;

@end
