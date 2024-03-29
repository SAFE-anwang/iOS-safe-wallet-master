//
//  BRPaymentRequest.h
//  BreadWallet
//
//  Created by Aaron Voisine on 5/9/13.
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

#import <Foundation/Foundation.h>
#import "BRBalanceModel.h"

@class BRPaymentProtocolRequest, BRPaymentProtocolPayment, BRPaymentProtocolACK;

// BIP21 bitcoin payment request URI https://github.com/bitcoin/bips/blob/master/bip-0021.mediawiki
@interface BRPaymentRequest : NSObject

@property (nonatomic, strong) NSString *scheme;
@property (nonatomic, strong) NSString *paymentAddress;
@property (nonatomic, strong) NSString *label;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, assign) uint64_t amount;
@property (nonatomic, strong) NSString *r; // BIP72 URI: https://github.com/bitcoin/bips/blob/master/bip-0072.mediawiki
@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSString *callbackScheme;
@property (nonatomic, strong) NSData *data;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, readonly) BOOL isValid;
@property (nonatomic, readonly) BOOL wantsInstant;
@property (nonatomic, readonly) BOOL instantValueRequired;
@property (nonatomic, readonly) BOOL amountValueImmutable;
@property (nonatomic, readonly) BRPaymentProtocolRequest *protocolRequest; // receiver converted to BIP70 request object

@property (nonatomic,strong) BRBalanceModel *balanceModel;

/** 增加资产名称 */
@property (nonatomic, strong) NSString *assetName;
/** 增加及时交易标签 */
@property (nonatomic, strong) NSString *IS;
/** 解锁高度 */
@property (nonatomic, assign) uint64_t unlockBlockHeight;

+ (instancetype)requestWithString:(NSString *)string;
+ (instancetype)requestWithData:(NSData *)data;
+ (instancetype)requestWithURL:(NSURL *)url;

- (instancetype)initWithString:(NSString *)string;
- (instancetype)initWithData:(NSData *)data;
- (instancetype)initWithURL:(NSURL *)url;

// fetches a BIP70 request over HTTP and calls completion block
// https://github.com/bitcoin/bips/blob/master/bip-0070.mediawiki
+ (void)fetch:(NSString *)url scheme:(NSString*)scheme timeout:(NSTimeInterval)timeout
completion:(void (^)(BRPaymentProtocolRequest *req, NSError *error))completion;

// posts a BIP70 payment object to the specified URL
+ (void)postPayment:(BRPaymentProtocolPayment *)payment scheme:(NSString*)scheme to:(NSString *)paymentURL
timeout:(NSTimeInterval)timeout completion:(void (^)(BRPaymentProtocolACK *ack, NSError *error))completion;

@end
