//
//  BRPayAddressFunctionCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/17.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRPayAddressFunctionCellDelegate <NSObject>

@optional

- (void) payAddressFunctionCellLoadPasteClick;

- (void) payAddressFunctionCellLoadCodeClick;

@end

@interface BRPayAddressFunctionCell : UITableViewCell

@property (nonatomic, weak) id<BRPayAddressFunctionCellDelegate>delegate;

@end
