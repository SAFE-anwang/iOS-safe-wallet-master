//
//  BRApplyNameCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/8.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRTextField.h"

#define applyNameCellNotification @"applyNameCellNotification"

@protocol BRApplyNameCellDelegate <NSObject>

@optional

- (void) applyNameCellWithString:(NSString *) title;

- (void) applyNameCellLoadTestingRequest:(NSString *) title;

@end

@interface BRApplyNameCell : UITableViewCell

@property (nonatomic, weak) id<BRApplyNameCellDelegate> delegate;

@property (nonatomic, strong) BRTextField *textField;

@property (nonatomic, strong) UILabel *title;

@property (nonatomic, copy) NSString *holderText;

@property (nonatomic, strong) UIButton *testingBtn;

@end
