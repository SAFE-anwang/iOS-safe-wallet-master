//
//  BRWallet.h
//  BreadWallet
//
//  Created by Aaron Voisine on 5/12/13.
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
#import <CoreData/CoreData.h>
#import "BRTransaction.h"
#import "BRKeySequence.h"
#import "NSData+Bitcoin.h"
#import "BRBalanceModel.h"
#import "BRPutCandyModel.h"
#import "BRPutCandyEntity+CoreDataProperties.h"

FOUNDATION_EXPORT NSString* _Nonnull const BRWalletBalanceChangedNotification;

#define DUFFS           100000000LL
#define MAX_MONEY          (21000000LL*DUFFS)
#define DEFAULT_FEE_PER_KB ((5000ULL*100 + 99)/100) // bitcoind 0.11 min relay fee on 100bytes
#define MIN_FEE_PER_KB     ((TX_FEE_PER_KB*1000 + 190)/191) // minimum relay fee on a 191byte tx
#define MAX_FEE_PER_KB     ((100100ULL*1000 + 190)/191) // slightly higher than a 1000bit fee on a 191byte tx

typedef void (^TransactionValidityCompletionBlock)(BOOL signedTransaction);
typedef void (^SeedCompletionBlock)(NSData * _Nullable seed);
typedef void (^SeedRequestBlock)(NSString * _Nullable authprompt, uint64_t amount, _Nullable SeedCompletionBlock seedCompletion);

typedef struct _BRUTXO {
    UInt256 hash;
    unsigned long n; // use unsigned long instead of uint32_t to avoid trailing struct padding (for NSValue comparisons)
} BRUTXO;

#define brutxo_obj(o) [NSValue value:&(o) withObjCType:@encode(BRUTXO)]
#define brutxo_data(o) [NSData dataWithBytes:&((struct { uint32_t u[256/32 + 1]; }) {\
    o.hash.u32[0], o.hash.u32[1], o.hash.u32[2], o.hash.u32[3],\
    o.hash.u32[4], o.hash.u32[5], o.hash.u32[6], o.hash.u32[7],\
    CFSwapInt32HostToLittle((uint32_t)o.n) }) length:sizeof(UInt256) + sizeof(uint32_t)]

@class BRTransaction;
@protocol BRKeySequence;

@interface BRWallet : NSObject

// current wallet balance excluding transactions known to be invalid
@property (nonatomic, readonly) uint64_t balance;

// returns the first unused external address
@property (nonatomic, readonly) NSString * _Nullable receiveAddress;

// returns the first unused internal address
@property (nonatomic, readonly) NSString * _Nullable changeAddress;

@property (nonatomic, readonly) NSString * _Nullable newReceiveAddress;

// all previously generated external addresses
@property (nonatomic, readonly) NSSet * _Nonnull allReceiveAddresses;

// all previously generated internal addresses
@property (nonatomic, readonly) NSSet * _Nonnull allChangeAddresses;

// NSValue objects containing UTXO structs
@property (nonatomic, readonly) NSArray * _Nonnull unspentOutputs;

// latest 100 transactions sorted by date, most recent first
@property (nonatomic, readonly) NSArray * _Nonnull recentTransactions;

// all wallet transactions sorted by date, most recent first
@property (nonatomic, readonly) NSArray * _Nonnull allTransactions;

// the total amount spent from the wallet (excluding change)
@property (nonatomic, readonly) uint64_t totalSent;

// the total amount received by the wallet (excluding change)
@property (nonatomic, readonly) uint64_t totalReceived;

// fee per kb of transaction size to use when including tx fee
@property (nonatomic, assign) uint64_t feePerKb;

// outputs below this amount are uneconomical due to fees
@property (nonatomic, readonly) uint64_t minOutputAmount;

// TODO:  添加不同资产
@property (nonatomic, strong, readonly) NSArray <BRBalanceModel *> * _Nullable balanceArray;
// 交易未确认的层数
@property (nonatomic, assign) int maxlayers;

// largest amount that can be sent from the wallet after fees
- (uint64_t)maxOutputAmountUsingInstantSend:(BOOL)instantSend;

- (uint64_t)maxOutputAmountWithConfirmationCount:(uint64_t)confirmationCount usingInstantSend:(BOOL)instantSend;

- (instancetype _Nullable)initWithContext:(NSManagedObjectContext * _Nullable)context
                                 sequence:(id<BRKeySequence> _Nonnull)sequence
                          masterBIP44PublicKey:(NSData * _Nonnull)masterPublicKey
                            masterBIP32PublicKey:(NSData * _Nonnull)masterBIP32PublicKey
                            requestSeedBlock:(_Nullable SeedRequestBlock)seed;

-(NSUInteger)addressPurpose:(NSString * _Nonnull)address;

// true if the address is controlled by the wallet
- (BOOL)containsAddress:(NSString * _Nonnull)address;

// true if the address was previously used as an input or output in any wallet transaction
- (BOOL)addressIsUsed:(NSString * _Nonnull)address;

// Wallets are composed of chains of addresses. Each chain is traversed until a gap of a certain number of addresses is
// found that haven't been used in any transactions. This method returns an array of <gapLimit> unused addresses
// following the last used address in the chain. The internal chain is used for change addresses and the external chain
// for receive addresses.  These have a hardened purpose scheme of 44 as compliant with BIP 43 and 44
- (NSArray * _Nullable)addressesWithGapLimit:(NSUInteger)gapLimit internal:(BOOL)internal;

// For the sake of backwards compatibility we need to register addresses that aren't compliant with BIP 43 and 44.
- (NSArray * _Nullable)addressesBIP32NoPurposeWithGapLimit:(NSUInteger)gapLimit internal:(BOOL)internal;

// returns an unsigned transaction that sends the specified amount from the wallet to the given address
- (BRTransaction * _Nullable)transactionFor:(uint64_t)amount to:(NSString * _Nonnull)address withFee:(BOOL)fee;

// returns an unsigned transaction that sends the specified amounts from the wallet to the specified output scripts
- (BRTransaction * _Nullable)transactionForAmounts:(NSArray * _Nonnull)amounts toOutputScripts:(NSArray * _Nonnull)scripts withUnlockHeights:(NSArray * _Nonnull)unlockHeights withReserves:(NSArray * _Nonnull)reserves withFee:(BOOL)fee;

// returns an unsigned transaction that sends the specified amounts from the wallet to the specified output scripts
- (BRTransaction * _Nullable)transactionForAmounts:(NSArray * _Nonnull)amounts toOutputScripts:(NSArray * _Nonnull)scripts withUnlockHeights:(NSArray * _Nonnull)unlockHeights withReserves:(NSArray * _Nonnull)reserves withFee:(BOOL)fee  isInstant:(BOOL)isInstant;

// returns an unsigned transaction that sends the specified amounts from the wallet to the specified output scripts
//- (BRTransaction * _Nullable)transactionForAmounts:(NSArray * _Nonnull)amounts toOutputScripts:(NSArray * _Nonnull)scripts withFee:(BOOL)fee isInstant:(BOOL)isInstant toShapeshiftAddress:(NSString* _Nullable)shapeshiftAddress;
- (BRTransaction * _Nullable)transactionForAmounts:(NSArray * _Nonnull)amounts toOutputScripts:(NSArray * _Nonnull)scripts withUnlockHeights:(NSArray * _Nonnull)unlockHeights withReserves:(NSArray * _Nonnull)reserves withFee:(BOOL)fee isInstant:(BOOL)isInstant toShapeshiftAddress:(NSString* _Nullable)shapeshiftAddress;
// TODO: 生成交易添加BRTransaction
- (BRTransaction * _Nullable)transactionForAmounts:(NSArray * _Nonnull)amounts toOutputScripts:(NSArray * _Nonnull)scripts withUnlockHeights:(NSArray * _Nonnull)unlockHeights withReserves:(NSArray * _Nonnull)reserves withFee:(BOOL)fee isInstant:(BOOL)isInstant toShapeshiftAddress:(NSString* _Nullable)shapeshiftAddress BalanceModel:(BRBalanceModel *_Nullable) balanceModel;

// TODO: 生成资产发行Transaction
- (BRTransaction *_Nullable) transactionForAssetAmount:(NSNumber *_Nonnull) assetAmount assetReserve:(NSData *_Nonnull) assetReserve candyAmount:(NSNumber *_Nullable) candyAmount candyReserve:(NSData *_Nullable) candyReserve safeAmount:(NSNumber *_Nullable) safeAmount;

// TODO: 生成追加资产发行Transaction
- (BRTransaction *_Nullable) transactionForAssetAmount:(NSNumber *_Nullable) assetAmount assetReserve:(NSData *_Nullable) assetReserve assetId:(NSData *_Nonnull) assetId address:(NSString *_Nonnull) address;

// TODO: 生成发放糖果Transaction
- (BRTransaction *_Nullable) transactionForCandyAmount:(BRPutCandyModel *_Nullable) putCandyModel balanceModel:(BRBalanceModel *_Nullable) balanceModel;
// 获取发放糖果旷工费
- (uint64_t) getFeeAmountTransactionForCandyAmount:(BRPutCandyModel *_Nullable)putCandyModel balanceModel:(BRBalanceModel *_Nullable) balanceModel;

// TODO: 生成领取糖果Transaction
- (BRTransaction *_Nullable) transactionForSafeTotalAmount:(uint64_t) totalAmount address:(NSArray *_Nullable) addressArray putCandyEntity:(BRPutCandyEntity *_Nonnull) putCandyEntity;
//获取领取糖果交易费
- (uint64_t) getFeeAmountTransactionForSafeTotalAmount:(uint64_t) totalAmount address:(NSArray *_Nullable) addressArray putCandyEntity:(BRPutCandyEntity *_Nonnull) putCandyEntity;

// TODO: 返回发行资产管理员地址上的金额
- (uint64_t) assetManagerAddressAmount:(NSData *_Nullable) assetId address:(NSString *_Nonnull) address;

// TODO: 添加区块高度之前所拥有的safe
- (void) getBlockHeightSafe:(NSInteger) blockHeight;

// sign any inputs in the given transaction that can be signed using private keys from the wallet
- (void)signTransaction:(BRTransaction * _Nonnull)transaction withPrompt:(NSString * _Nonnull)authprompt completion:(_Nonnull TransactionValidityCompletionBlock)completion;
// TODO: 添加提交交易方法
- (void)signTransaction:(BRTransaction *_Nonnull)transaction withPrompt:(NSString * _Nonnull)authprompt amount:(uint64_t) amount completion:(TransactionValidityCompletionBlock _Nonnull )completion;

- (void)signBIP32Transaction:(BRTransaction * _Nonnull)transaction withPrompt:(NSString * _Nonnull)authprompt completion:(_Nonnull TransactionValidityCompletionBlock)completion;

// true if the given transaction is associated with the wallet (even if it hasn't been registered), false otherwise
- (BOOL)containsTransaction:(BRTransaction * _Nonnull)transaction;

// adds a transaction to the wallet, or returns false if it isn't associated with the wallet
- (BOOL)registerTransaction:(BRTransaction * _Nonnull)transaction;

// removes a transaction from the wallet along with any transactions that depend on its outputs
- (void)removeTransaction:(UInt256)txHash;

// returns the transaction with the given hash if it's been registered in the wallet (might also return non-registered)
- (BRTransaction * _Nullable)transactionForHash:(UInt256)txHash;

// true if no previous wallet transaction spends any of the given transaction's inputs, and no inputs are invalid
- (BOOL)transactionIsValid:(BRTransaction * _Nonnull)transaction;

// true if transaction cannot be immediately spent (i.e. if it or an input tx can be replaced-by-fee, via BIP125)
- (BOOL)transactionIsPending:(BRTransaction * _Nonnull)transaction;

// true if tx is considered 0-conf safe (valid and not pending, timestamp is greater than 0, and no unverified inputs)
- (BOOL)transactionIsVerified:(BRTransaction * _Nonnull)transaction;

// sets the block heights and timestamps for the given transactions, and returns an array of hashes of the updated tx
// use a height of TX_UNCONFIRMED and timestamp of 0 to indicate a transaction and it's dependents should remain marked
// as unverified (not 0-conf safe)
- (NSArray * _Nonnull)setBlockHeight:(int32_t)height andTimestamp:(NSTimeInterval)timestamp
                         forTxHashes:(NSArray * _Nonnull)txHashes;

// returns the amount received by the wallet from the transaction (total outputs to change and/or receive addresses)
- (uint64_t)amountReceivedFromTransaction:(BRTransaction * _Nonnull)transaction;
// TODO: 添加方法
- (uint64_t)amountReceivedFromTransaction:(BRTransaction *_Nonnull)transaction balanceModel:(BRBalanceModel *_Nonnull) balanceModel;
- (uint64_t)amountReceivedFromPublishAssetTransaction:(BRTransaction *_Nonnull)transaction;

// retuns the amount sent from the wallet by the trasaction (total wallet outputs consumed, change and fee included)
- (uint64_t)amountSentByTransaction:(BRTransaction * _Nonnull)transaction;
// TODO: 添加方法
- (uint64_t)amountSentByTransaction:(BRTransaction *_Nullable)transaction balanceModel:(BRBalanceModel *_Nonnull) balanceModel;
// TODO: 添加计算资产发行sent金额
- (uint64_t)amountSentByPublishAssetTransaction:(BRTransaction *_Nullable)transaction;

// returns the fee for the given transaction if all its inputs are from wallet transactions, UINT64_MAX otherwise
- (uint64_t)feeForTransaction:(BRTransaction * _Nonnull)transaction;
// TODO: 添加方法
- (uint64_t)feeForPublishAssetTransaction:(BRTransaction *_Nullable)transaction;
// TODO: 添加计算糖果的fee
- (uint64_t)feeForCandyTransaction:(BRTransaction *_Nullable)transaction;

// historical wallet balance after the given transaction, or current balance if transaction is not registered in wallet
- (uint64_t)balanceAfterTransaction:(BRTransaction * _Nonnull)transaction;

// returns the block height after which the transaction is likely to be processed without including a fee
- (uint32_t)blockHeightUntilFree:(BRTransaction * _Nonnull)transaction;

// fee that will be added for a transaction of the given size in bytes
- (uint64_t)feeForTxSize:(NSUInteger)size isInstant:(BOOL)isInstant inputCount:(NSInteger)inputCount;

- (void)updateBalance;

// TODO: 清空缓存数据
- (void) cleanWalletCacheData;

// TODO: 判断自己交易是否有未认证的交易 
- (BOOL) getTransactionIsUnverified;

#pragma mark 计算可用的金额
- (uint64_t) useBalance:(NSData *_Nullable) assetId;
#pragma mark 计算可用的金额
- (NSInteger) countUtxosNumber:(NSData *_Nullable) assetId;
#pragma mark 计算是否可以发送即使交易
- (BOOL) useisInstantTxBalance;
#pragma mark 计算未花费的金额
- (uint64_t) useUtxosBalance:(NSData *_Nullable) assetId;
#pragma mark 支付计算可用的金额
- (uint64_t) payUIUseBalance:(NSData *_Nullable) assetId;
#pragma mark 计算锁定的金额
- (uint64_t) lockBalance:(NSData *_Nullable) assetId;

// TODO: 判断交易是否可以发送
- (BOOL) isSendTransaction:(BRTransaction *_Nonnull) tx;

// 判断发行的资产是否被确认
- (BOOL) PublishAssetIsConfirm:(BRBalanceModel *_Nonnull) model;

- (NSInteger) isInstantConfirmHeight;

// 获取未花费地址私钥
- (void) getWalltePrivate:(NSArray *_Nullable) addressArr Seed:(NSData *_Nullable) seed;

// 获取钱包所有未花费的地址
- (NSArray *_Nullable) getAllUtxosAddress;

@end
