//
//  BRPayAddressCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/17.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRTextField.h"

#define payAddressCellNotification @"BRPayAddressCellNotification"

@protocol BRPayAddressCellDelegate <NSObject>

@optional

- (void) payAddressCellForText:(NSString *) text;

@end

@interface BRPayAddressCell : UITableViewCell

@property (nonatomic, weak) id<BRPayAddressCellDelegate>delegate;

@property (nonatomic,strong) BRTextField *textField;

@end
