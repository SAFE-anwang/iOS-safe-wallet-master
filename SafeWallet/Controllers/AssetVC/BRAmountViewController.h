//
//  BRAmountViewController.h
//  BreadWallet
//
//  Created by Aaron Voisine on 6/4/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <UIKit/UIKit.h>

@class BRAmountViewController;

@protocol BRAmountViewControllerDelegate <NSObject>
@required

- (void)amountViewController:(BRAmountViewController *)amountViewController selectedAmount:(uint64_t)amount;
@optional
- (void)amountViewController:(BRAmountViewController *)amountViewController shapeshiftBitcoinAmount:(uint64_t)amount approximateDashAmount:(uint64_t)dashAmount;
- (void)amountViewController:(BRAmountViewController *)amountViewController shapeshiftDashAmount:(uint64_t)amount;
- (void)amountViewController:(BRAmountViewController *)amountViewController selectedAmount:(uint64_t)amount unlockBlockHeight:(uint64_t)blockHeight;

@end

@interface BRAmountViewController : UIViewController<UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, assign) id<BRAmountViewControllerDelegate> delegate;
@property (nonatomic, strong) NSString *to;
@property (nonatomic, assign) BOOL usingShapeshift;
@property (nonatomic, strong) NSString * payeeCurrency;
@property (nonatomic,assign) BOOL isFromReceiveVc;

/// 即时支付
@property (nonatomic, assign) BOOL isInstant;

//  小数位数
@property (nonatomic, assign) int maximumFractionDigits;

@end
