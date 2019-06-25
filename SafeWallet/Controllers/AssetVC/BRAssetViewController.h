//
//  BRAssetViewController.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/21.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BRAmountViewController.h"

@class BRPaymentRequest;

@interface BRAssetViewController : UIViewController

@property (nonatomic, strong) BRPaymentRequest *paymentRequest;
- (void)updateAddress;

@end
