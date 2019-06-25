//
//  BRDetaiTransantionViewController.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/21.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BRTransaction;

@interface BRDetaiTransantionViewController : UIViewController

@property (nonatomic, strong) BRTransaction *transaction;
@property (nonatomic, strong) NSString *txDateString;

@end
