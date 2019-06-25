//
//  BRPaySendCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/17.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRPaySendCellDelegate <NSObject>

@optional

- (void) BRPaySendCellLoadSendClick;

@end

@interface BRPaySendCell : UITableViewCell

@property (nonatomic, weak) id<BRPaySendCellDelegate>delegate;

@property (nonatomic, strong) UIButton *sendBtn;

@end
