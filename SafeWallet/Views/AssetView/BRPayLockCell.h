//
//  BRPayLockCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/17.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRPayLockCellDelegate <NSObject>

@optional

- (void) payLockCellForSelectLock:(BOOL) isLock;

- (void) payLockCellForSelectInstantPayment:(BOOL) isPay;

- (void) payLockCellForSelectLockMonth:(NSString *) month;

@end

@interface BRPayLockCell : UITableViewCell

@property (nonatomic, weak) id<BRPayLockCellDelegate>delegate;

@property (nonatomic,strong) UIButton *payBtn;

@property (nonatomic,strong) UILabel *payLabel;

@property (nonatomic,strong) UIView *payView;

- (void)settingIsPay:(BOOL)isPay;

- (void)settingIsLock:(BOOL)isLock;

@end
