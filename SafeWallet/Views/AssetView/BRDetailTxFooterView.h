//
//  BRDetailTxFooterView.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/21.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRBalanceModel.h"
@class BRDetailTxFooterView,BRTransaction;

@protocol BRDetailTxFooterViewDelegate <NSObject>

- (void)qrcodeLongpress:(UIImage *)longpressImage;

- (void)footerView:(BRDetailTxFooterView *)footerView moreBtnDidTapped:(UIButton *)btn;

- (void)footerView:(BRDetailTxFooterView *)footerView browserBtnDidTapped:(UIButton *)btn;
@end

@interface BRDetailTxFooterView : UIView

@property (nonatomic, weak) id<BRDetailTxFooterViewDelegate> delegate;
@property (nonatomic,strong) BRTransaction *transaction;
- (instancetype)initWithFrame:(CGRect)frame;
@property (nonatomic,strong) BRBalanceModel *balanceModel;

@end
