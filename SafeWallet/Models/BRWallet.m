//
//  BRWallet.m
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

#import "BRWallet.h"
#import "BRKey.h"
#import "BRAddressEntity.h"
#import "BRTransaction.h"
#import "BRTransactionEntity.h"
#import "BRTxInputEntity.h"
#import "BRTxOutputEntity.h"
#import "BRTxMetadataEntity.h"
#import "BRPeerManager.h"
#import "BRKeySequence.h"
#import "NSData+Bitcoin.h"
#import "NSMutableData+Bitcoin.h"
#import "NSManagedObject+Sugar.h"
#import "Safe.pbobjc.h"
#import "BRIssueDataEnity+CoreDataClass.h"
#import "BRSafeUtils.h"
#import "NSString+Dash.h"
#import "BRPublishIssueDataEnity+CoreDataProperties.h"
#import "BRBlockAvailableSafeEntity+CoreDataProperties.h"
#import "NSString+Bitcoin.h"
#import "BRCoreDataManager.h"

// chain position of first tx output address that appears in chain
static NSUInteger txAddressIndex(BRTransaction *tx, NSArray *chain) {
    for (NSString *addr in tx.outputAddresses) {
        NSUInteger i = [chain indexOfObject:addr];
        
        if (i != NSNotFound) return i;
    }
    
    return NSNotFound;
}

@interface BRWallet ()

@property (nonatomic, strong) id<BRKeySequence> sequence;
@property (nonatomic, strong) NSData *masterPublicKey,*masterBIP32PublicKey;
@property (nonatomic, strong) NSMutableArray *internalBIP44Addresses,*internalBIP32Addresses, *externalBIP44Addresses,*externalBIP32Addresses;
@property (nonatomic, strong) NSMutableSet *allAddresses, *usedAddresses;
@property (nonatomic, strong) NSSet *spentOutputs, *invalidTx, *pendingTx;
@property (nonatomic, strong) NSMutableOrderedSet *transactions;
@property (nonatomic, strong) NSOrderedSet *utxos;
@property (nonatomic, strong) NSMutableDictionary *allTx;
@property (nonatomic, strong) NSArray *balanceHistory;
@property (nonatomic, assign) uint32_t bestBlockHeight;
@property (nonatomic, strong) SeedRequestBlock seed;
@property (nonatomic, strong) NSManagedObjectContext *moc;

@end

@implementation BRWallet

- (instancetype)initWithContext:(NSManagedObjectContext *)context sequence:(id<BRKeySequence>)sequence
                masterBIP44PublicKey:(NSData *)masterPublicKey masterBIP32PublicKey:(NSData *)masterBIP32PublicKey requestSeedBlock:(SeedRequestBlock)seed
{
    if (! (self = [super init])) return nil;

    self.moc = context;
    self.sequence = sequence;
    self.masterPublicKey = masterPublicKey;
    self.masterBIP32PublicKey = masterBIP32PublicKey;
    self.seed = seed;

    [self InitializationOfData];
    
    return self;
}

- (void) InitializationOfData {
    NSMutableSet *updateTx = [NSMutableSet set];
    self.allTx = [NSMutableDictionary dictionary];
    self.transactions = [NSMutableOrderedSet orderedSet];
    self.internalBIP32Addresses = [NSMutableArray array];
    self.internalBIP44Addresses = [NSMutableArray array];
    self.externalBIP32Addresses = [NSMutableArray array];
    self.externalBIP44Addresses = [NSMutableArray array];
    self.allAddresses = [NSMutableSet set];
    self.usedAddresses = [NSMutableSet set];
    // 添加线程计算金额
//    dispatch_async(dispatch_queue_create("InitializationOfData", nil), ^{
        [self.moc performBlockAndWait:^{
            [BRAddressEntity setContext:self.moc];
            [BRTransactionEntity setContext:self.moc];
            [BRTxMetadataEntity setContext:self.moc];
            
            for (BRAddressEntity *e in [BRAddressEntity allObjects]) {
                @autoreleasepool {
                    NSMutableArray *a = (e.purpose == 44)?((e.internal) ? self.internalBIP44Addresses : self.externalBIP44Addresses) : ((e.internal) ? self.internalBIP32Addresses : self.externalBIP32Addresses);
                    
                    while (e.index >= a.count) [a addObject:[NSNull null]];
                    a[e.index] = e.address;
                    [self.allAddresses addObject:e.address];
                }
            }
            
            for (BRTxMetadataEntity *e in [BRTxMetadataEntity allObjects]) {
                @autoreleasepool {
                    if (e.type != TX_MDTYPE_MSG) continue;
                    
                    BRTransaction *tx = e.transaction;
                    
                    NSValue *hash = (tx) ? uint256_obj(tx.txHash) : nil;
                    
                    if (! tx) continue;
                    self.allTx[hash] = tx;
                    [self.transactions addObject:tx];
                    [self.usedAddresses addObjectsFromArray:tx.inputAddresses];
                    [self.usedAddresses addObjectsFromArray:tx.outputAddresses];
                }
            }
            
            if ([BRTransactionEntity countAllObjects] > self.allTx.count) {

                // pre-fetch transaction inputs and outputs
                [BRTxInputEntity allObjects];
                [BRTxOutputEntity allObjects];
                
                for (BRTransactionEntity *e in [BRTransactionEntity allObjects]) {
                    @autoreleasepool {
                        BRTransaction *tx = e.transaction;
                        NSValue *hash = (tx) ? uint256_obj(tx.txHash) : nil;
                        
                        if (! tx || self.allTx[hash] != nil) continue;
                        
                        [updateTx addObject:tx];
                        self.allTx[hash] = tx;
                        [self.transactions addObject:tx];
                        [self.usedAddresses addObjectsFromArray:tx.inputAddresses];
                        [self.usedAddresses addObjectsFromArray:tx.outputAddresses];
                    }
                }
            }
        }];
        
        if (updateTx.count > 0) {
            [self.moc performBlock:^{
                for (BRTransaction *tx in updateTx) {
                    [[BRTxMetadataEntity managedObject] setAttributesFromTx:tx];
                }
                
                [BRTxMetadataEntity saveContext];
            }];
        }
        
        [self sortTransactions];
        _balance = UINT64_MAX; // trigger balance changed notification even if balance is zero
        _balanceArray = [NSArray array];
        [self updateBalance];
//    });
}

// TODO: 清空缓存数据
- (void) cleanWalletCacheData {
    [self InitializationOfData];
}

// TODO: 判断自己交易是否有未认证的交易
- (BOOL) getTransactionIsUnverified {
    for (BRTransaction *tx in [self.transactions reverseObjectEnumerator]) {
        if(tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) return YES;
    }
    return NO;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(NSArray*)internalAddresses {
    return [self.internalBIP32Addresses arrayByAddingObjectsFromArray:self.internalBIP44Addresses];
}

-(NSArray*)externalAddresses {
    return [self.externalBIP32Addresses arrayByAddingObjectsFromArray:self.externalBIP44Addresses];
}

// Wallets are composed of chains of addresses. Each chain is traversed until a gap of a certain number of addresses is
// found that haven't been used in any transactions. This method returns an array of <gapLimit> unused addresses
// following the last used address in the chain. The internal chain is used for change addresses and the external chain
// for receive addresses.
- (NSArray *)addressesWithGapLimit:(NSUInteger)gapLimit internal:(BOOL)internal
{
    NSMutableArray *a = [NSMutableArray arrayWithArray:(internal) ? self.internalBIP44Addresses : self.externalBIP44Addresses];
    NSUInteger i = a.count;
    
    // keep only the trailing contiguous block of addresses with no transactions
    while (i > 0 && ! [self.usedAddresses containsObject:a[i - 1]]) {
        i--;
    }
    
    if (i > 0) [a removeObjectsInRange:NSMakeRange(0, i)];
    if (a.count >= gapLimit) return [a subarrayWithRange:NSMakeRange(0, gapLimit)];
    
    if (gapLimit > 1) { // get receiveAddress and changeAddress first to avoid blocking
        [self receiveAddress];
        [self changeAddress];
    }
    
    @synchronized(self) {
        [a setArray:(internal) ? self.internalBIP44Addresses : self.externalBIP44Addresses];
        i = a.count;
        
        unsigned n = (unsigned)i;
        
        // keep only the trailing contiguous block of addresses with no transactions
        while (i > 0 && ! [self.usedAddresses containsObject:a[i - 1]]) {
            i--;
        }
        
        if (i > 0) [a removeObjectsInRange:NSMakeRange(0, i)];
        if (a.count >= gapLimit) return [a subarrayWithRange:NSMakeRange(0, gapLimit)];
        
        while (a.count < gapLimit) { // generate new addresses up to gapLimit
            NSData *pubKey = [self.sequence publicKey:n internal:internal masterPublicKey:self.masterPublicKey];
            NSString *addr = [BRKey keyWithPublicKey:pubKey].address;
            
            if (! addr) {
                //BRLog(@"error generating keys");
                return nil;
            }
            
            [self.moc performBlock:^{ // store new address in core data
                BRAddressEntity *e = [BRAddressEntity managedObject];
                e.purpose = 44;
                e.account = 0;
                e.address = addr;
                e.index = n;
                e.internal = internal;
            }];
            
            [self.allAddresses addObject:addr];
            [(internal) ? self.internalBIP44Addresses : self.externalBIP44Addresses addObject:addr];
            [a addObject:addr];
            n++;
        }
        
        return a;
    }
}

- (NSArray *)addressesBIP32NoPurposeWithGapLimit:(NSUInteger)gapLimit internal:(BOOL)internal
{
    @synchronized(self) {
        NSMutableArray *a = [NSMutableArray arrayWithArray:(internal) ? self.internalBIP32Addresses : self.externalBIP32Addresses];
        NSUInteger i = a.count;
        
        unsigned n = (unsigned)i;
        
        // keep only the trailing contiguous block of addresses with no transactions
        while (i > 0 && ! [self.usedAddresses containsObject:a[i - 1]]) {
            i--;
        }
        
        if (i > 0) [a removeObjectsInRange:NSMakeRange(0, i)];
        if (a.count >= gapLimit) return [a subarrayWithRange:NSMakeRange(0, gapLimit)];
        
        while (a.count < gapLimit) { // generate new addresses up to gapLimit
            NSData *pubKey = [self.sequence publicKey:n internal:internal masterPublicKey:self.masterBIP32PublicKey];
            NSString *addr = [BRKey keyWithPublicKey:pubKey].address;
            
            if (! addr) {
                //BRLog(@"error generating keys");
                return nil;
            }
            
            [self.moc performBlock:^{ // store new address in core data
                BRAddressEntity *e = [BRAddressEntity managedObject];
                e.purpose = 0;
                e.account = 0;
                e.address = addr;
                e.index = n;
                e.internal = internal;
            }];
            
            [self.allAddresses addObject:addr];
            [(internal) ? self.internalBIP32Addresses : self.externalBIP32Addresses addObject:addr];
            [a addObject:addr];
            n++;
        }
        
        return a;
    }
}

// this sorts transactions by block height in descending order, and makes a best attempt at ordering transactions within
// each block, however correct transaction ordering cannot be relied upon for determining wallet balance or UTXO set
- (void)sortTransactions
{
    BOOL (^isAscending)(id, id);
    __block __weak BOOL (^_isAscending)(id, id) = isAscending = ^BOOL(BRTransaction *tx1, BRTransaction *tx2) {
        if (! tx1 || ! tx2) return NO;
        if (tx1.blockHeight > tx2.blockHeight) return YES;
        if (tx1.blockHeight < tx2.blockHeight) return NO;
        
        NSValue *hash1 = uint256_obj(tx1.txHash), *hash2 = uint256_obj(tx2.txHash);
        
        if ([tx1.inputHashes containsObject:hash2]) return YES;
        if ([tx2.inputHashes containsObject:hash1]) return NO;
        if ([self.invalidTx containsObject:hash1] && ! [self.invalidTx containsObject:hash2]) return YES;
        if ([self.pendingTx containsObject:hash1] && ! [self.pendingTx containsObject:hash2]) return YES;
        
        for (NSValue *hash in tx1.inputHashes) {
            if (_isAscending(self.allTx[hash], tx2)) return YES;
        }
        
        return NO;
    };
    
    [self.transactions sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id tx1, id tx2) {
        if (isAscending(tx1, tx2)) return NSOrderedAscending;
        if (isAscending(tx2, tx1)) return NSOrderedDescending;
        
        NSUInteger i = txAddressIndex(tx1, self.internalAddresses),
        j = txAddressIndex(tx2, (i == NSNotFound) ? self.externalAddresses : self.internalAddresses);
        
        if (i == NSNotFound && j != NSNotFound) i = txAddressIndex(tx1, self.externalAddresses);
        if (i == NSNotFound || j == NSNotFound || i == j) return NSOrderedSame;
        return (i > j) ? NSOrderedAscending : NSOrderedDescending;
    }];
}

- (void) sortTimeTransaction {
    [self.transactions sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(BRTransaction *tx1, BRTransaction *tx2) {
        return tx1.blockHeight < tx2.blockHeight;
    }];
}

- (void)updateBalance
{
    uint64_t balance = 0, prevBalance = 0, totalSent = 0, totalReceived = 0;
    NSMutableOrderedSet *utxos = [NSMutableOrderedSet orderedSet];
    NSMutableSet *spentOutputs = [NSMutableSet set], *invalidTx = [NSMutableSet set], *pendingTx = [NSMutableSet set];
    NSMutableArray *balanceHistory = [NSMutableArray array];
    uint32_t now = [NSDate timeIntervalSinceReferenceDate] + NSTimeIntervalSince1970;
    
    NSMutableArray *balanceArray = [NSMutableArray array];
    BRBalanceModel *balanceModel = [[BRBalanceModel alloc] init];
    balanceModel.balance = 0;
    balanceModel.nameString = @"SAFE";
    balanceModel.assetId = [NSData data];
    balanceModel.prevBalance = 0;
    balanceModel.multiple = 8;
    [balanceArray addObject:balanceModel];
    [self sortTimeTransaction];
    for (BRTransaction *tx in [self.transactions reverseObjectEnumerator]) {
        @autoreleasepool {
            NSMutableSet *spent = [NSMutableSet set];
            NSSet *inputs;
            uint32_t i = 0, n = 0;
            BOOL pending = NO;
            UInt256 h;
  
            for (NSValue *hash in tx.inputHashes) {
                n = [tx.inputIndexes[i++] unsignedIntValue];
                [hash getValue:&h];
                [spent addObject:brutxo_obj(((BRUTXO) { h, n }))];
            }
            
            inputs = [NSSet setWithArray:tx.inputHashes];
            
            // check if any inputs are invalid or already spent
            if (tx.blockHeight == TX_UNCONFIRMED &&
                ([spent intersectsSet:spentOutputs] || [inputs intersectsSet:invalidTx])) {
                [invalidTx addObject:uint256_obj(tx.txHash)];
                [balanceHistory insertObject:@(balance) atIndex:0];
                continue;
            }
            
            [spentOutputs unionSet:spent]; // add inputs to spent output set
            n = 0;
            
            // check if any inputs are pending
            if (tx.blockHeight == TX_UNCONFIRMED) {
                if (tx.size > TX_MAX_SIZE) pending = YES; // check transaction size is under TX_MAX_SIZE
                
                for (NSNumber *sequence in tx.inputSequences) {
                    if (sequence.unsignedIntValue < UINT32_MAX - 1) pending = YES; // check for replace-by-fee
                    if (sequence.unsignedIntValue < UINT32_MAX && tx.lockTime < TX_MAX_LOCK_HEIGHT &&
                        tx.lockTime > self.bestBlockHeight + 1) pending = YES; // future lockTime
                    if (sequence.unsignedIntValue < UINT32_MAX && tx.lockTime >= TX_MAX_LOCK_HEIGHT &&
                        tx.lockTime > now) pending = YES; // future locktime
                }
                // TODO: 修改
//                for (NSNumber *amount in tx.outputAmounts) { // check that no outputs are dust
//                    if (amount.unsignedLongLongValue < TX_MIN_OUTPUT_AMOUNT) pending = YES;
//                }
                
                //TODO ZCZCZC
                if (pending || [inputs intersectsSet:pendingTx]) {
                    [pendingTx addObject:uint256_obj(tx.txHash)];
                    [balanceHistory insertObject:@(balance) atIndex:0];
                    continue;
                }
            }
            
            //TODO: don't add outputs below TX_MIN_OUTPUT_AMOUNT
            //TODO: don't add coin generation outputs < 100 blocks deep
            //NOTE: balance/UTXOs will then need to be recalculated when last block changes
            for (NSString *address in tx.outputAddresses) { // add outputs to UTXO set
                if ([self containsAddress:address]) {
                    [utxos addObject:brutxo_obj(((BRUTXO) { tx.txHash, n }))];
//                    balance += [tx.outputAmounts[n] unsignedLongLongValue];
                    // TODO: 修改资产分组
//                    if([tx.outputReserves[n] isEqual:[NSNull null]]) continue;
                    if(![BRSafeUtils isSafeTransaction:tx.outputReserves[n]]) { // [tx.outputReserves[n] length] > 42
                            NSNumber * l = 0;
                            NSUInteger off = 0;
                            NSData *d = [tx.outputReserves[n] dataAtOffset:off length:&l];
                            NSData *data = [d subdataWithRange:NSMakeRange(42, d.length-42)];
                        if([d UInt16AtOffset:38] == 204 || [d UInt16AtOffset:38] == 202 || [d UInt16AtOffset:38] == 201 || [d UInt16AtOffset:38] == 203){
                            // 追加发行201  转让202 销毁203 找零204
                            CommonData *commonData = [BRSafeUtils analysisCommonData:data];
                            NSArray *issueDataArray = [[BRCoreDataManager sharedInstance] entity:@"BRIssueDataEnity" objectsMatching:[NSPredicate predicateWithFormat:@"assetId = %@", commonData.assetId]];
                            if(issueDataArray.count != 0) {
                                BOOL islookUp = NO;
                                BRIssueDataEnity *issueDataEnity = issueDataArray.firstObject;
                                for(int i=1; i<balanceArray.count; i++) {
                                    BRBalanceModel *balanceModel = balanceArray[i];
                                    if([balanceModel.assetId isEqual:commonData.assetId]) {
                                        balanceModel.balance += [tx.outputAmounts[n] unsignedLongLongValue];
                                        [balanceModel.utxos addObject:brutxo_obj(((BRUTXO) { tx.txHash, n }))];
                                        islookUp = YES;
                                        break;
                                    }
                                }
                                if(!islookUp) {
                                    BRBalanceModel *balanceModel = [[BRBalanceModel alloc] init];
                                    balanceModel.multiple = [issueDataEnity.decimals integerValue];
                                    balanceModel.balance = [tx.outputAmounts[n] unsignedLongLongValue];
                                    balanceModel.assetId = commonData.assetId;
                                    balanceModel.nameString = issueDataEnity.assetName;
                                    balanceModel.common = commonData;
                                    balanceModel.version = [d subdataWithRange:NSMakeRange(4, 2)];
                                    balanceModel.applicationID = [d subdataWithRange:NSMakeRange(6, 32)];
                                    balanceModel.prevBalance = 0;
                                    [balanceArray addObject:balanceModel];
                                    [balanceModel.utxos addObject:brutxo_obj(((BRUTXO) { tx.txHash, n }))];
                                }
                                balance += [tx.outputAmounts[n] unsignedLongLongValue] * pow(10, 8 - [issueDataEnity.decimals integerValue]);
                            } else {
                                BRLog(@"无此资产");
                                balance += [tx.outputAmounts[n] unsignedLongLongValue];
                            }
                        }else if ([d UInt16AtOffset:38] == 206) {
                            // 领取糖果 206
                            GetCandyData *getCandyData = [BRSafeUtils analysisGetCandyData:data];
                            NSArray *issueDataArray = [[BRCoreDataManager sharedInstance] entity:@"BRIssueDataEnity" objectsMatching:[NSPredicate predicateWithFormat:@"assetId = %@", getCandyData.assetId]];
                            if(issueDataArray.count != 0) {
                                BOOL islookUp = NO;
                                BRIssueDataEnity *issueDataEnity = issueDataArray.firstObject;
                                for(int i=1; i<balanceArray.count; i++) {
                                    BRBalanceModel *balanceModel = balanceArray[i];
                                    if([balanceModel.assetId isEqual:getCandyData.assetId]) {
                                        balanceModel.balance += [tx.outputAmounts[n] unsignedLongLongValue];
                                        [balanceModel.utxos addObject:brutxo_obj(((BRUTXO) { tx.txHash, n }))];
                                        islookUp = YES;
                                        break;
                                    }
                                }
                                if(!islookUp) {
                                    BRBalanceModel *balanceModel = [[BRBalanceModel alloc] init];
                                    balanceModel.multiple = [issueDataEnity.decimals integerValue];
                                    balanceModel.balance = [tx.outputAmounts[n] unsignedLongLongValue];
                                    balanceModel.assetId = getCandyData.assetId;
                                    balanceModel.nameString = issueDataEnity.assetName;
                                    balanceModel.prevBalance = 0;
                                    CommonData *commonData = [[CommonData alloc] init];
                                    commonData.version = getCandyData.version;
                                    commonData.assetId = getCandyData.assetId;
                                    commonData.amount =  getCandyData.amount;
                                    commonData.remarks = getCandyData.remarks;
                                    balanceModel.common = commonData;
                                    balanceModel.version = [d subdataWithRange:NSMakeRange(4, 2)];
                                    balanceModel.applicationID = [d subdataWithRange:NSMakeRange(6, 32)];
                                    [balanceModel.utxos addObject:brutxo_obj(((BRUTXO) { tx.txHash, n }))];
                                    [balanceArray addObject:balanceModel];
                                }
                                balance += [tx.outputAmounts[n] unsignedLongLongValue] * pow(10, 8 - [issueDataEnity.decimals integerValue]);
                            } else {
                                BRLog(@"无此资产");
                                balance += [tx.outputAmounts[n] unsignedLongLongValue];
                            }
                        } else if([d UInt16AtOffset:38] == 205){
                            // 发放糖果 205
                            PutCandyData *putCandyData = [BRSafeUtils analysisPutCandyData:data];
                            NSArray *issueDataArray = [[BRCoreDataManager sharedInstance] entity:@"BRIssueDataEnity" objectsMatching:[NSPredicate predicateWithFormat:@"assetId = %@", putCandyData.assetId]];
                            if(issueDataArray.count != 0) {
                                BOOL islookUp = NO;
                                BRIssueDataEnity *issueDataEnity = issueDataArray.firstObject;
                                for(int i=1; i<balanceArray.count; i++) {
                                    BRBalanceModel *balanceModel = balanceArray[i];
                                    if([balanceModel.assetId isEqual:putCandyData.assetId]) {
                                        balanceModel.balance += [tx.outputAmounts[n] unsignedLongLongValue];
                                        [balanceModel.utxos addObject:brutxo_obj(((BRUTXO) { tx.txHash, n }))];
                                        islookUp = YES;
                                        break;
                                    }
                                }
                                if(!islookUp) {
                                    BRBalanceModel *balanceModel = [[BRBalanceModel alloc] init];
                                    balanceModel.multiple = [issueDataEnity.decimals integerValue];
                                    balanceModel.balance = [tx.outputAmounts[n] unsignedLongLongValue];
                                    balanceModel.assetId = putCandyData.assetId;
                                    balanceModel.nameString = issueDataEnity.assetName;
                                    balanceModel.prevBalance = 0;
                                    [balanceModel.utxos addObject:brutxo_obj(((BRUTXO) { tx.txHash, n }))];
                                    [balanceArray addObject:balanceModel];
                                }
                                balance += [tx.outputAmounts[n] unsignedLongLongValue] * pow(10, 8 - [issueDataEnity.decimals integerValue]);
                            } else {
                                BRLog(@"无此资产");
                                balance += [tx.outputAmounts[n] unsignedLongLongValue];
                            }
                        }else if([d UInt16AtOffset:38] == 200){
                            // 发行 200
                            IssueData *issueData = [BRSafeUtils analysisIssueData:data];
                            BOOL islookUp = NO;
                            for(int i=1; i<balanceArray.count; i++) {
                                BRBalanceModel *balanceModel = balanceArray[i];
                                if([balanceModel.assetId isEqual:[BRSafeUtils generateIssueAssetID:issueData]]) {
                                    balanceModel.balance += [tx.outputAmounts[n] unsignedLongLongValue];
                                    [balanceModel.utxos addObject:brutxo_obj(((BRUTXO) { tx.txHash, n }))];
                                    islookUp = YES;
                                    break;
                                }
                            }
                            if(!islookUp) {
                                BRBalanceModel *balanceModel = [[BRBalanceModel alloc] init];
                                balanceModel.multiple = [issueData.decimals UInt8AtOffset:0];
                                balanceModel.balance = [tx.outputAmounts[n] unsignedLongLongValue];
                                balanceModel.assetId = [BRSafeUtils generateIssueAssetID:issueData];
                                balanceModel.nameString = [[NSString alloc] initWithData:issueData.assetName encoding:NSUTF8StringEncoding];
                                CommonData *commonData = [[CommonData alloc] init];
                                commonData.version = issueData.version;
                                commonData.assetId = [BRSafeUtils generateIssueAssetID:issueData];
                                commonData.amount = issueData.firstActualAmount;
                                commonData.remarks = issueData.remarks;
                                balanceModel.common = commonData;
                                balanceModel.version = [d subdataWithRange:NSMakeRange(4, 2)];
                                balanceModel.applicationID = [d subdataWithRange:NSMakeRange(6, 32)];
                                balanceModel.prevBalance = 0;
                                [balanceArray addObject:balanceModel];
                                [balanceModel.utxos addObject:brutxo_obj(((BRUTXO) { tx.txHash, n }))];
                            }
                            balance += [tx.outputAmounts[n] unsignedLongLongValue] * pow(10, 8 - [issueData.decimals UInt8AtOffset:0]);
                        }else if([d UInt16AtOffset:38] == 103) {
                            // 创建外带数据交易 103
                            ExtendData *extendData = [BRSafeUtils analysisExtendData:data];
                            balance += [tx.outputAmounts[n] unsignedLongLongValue];
                        } else if([d UInt16AtOffset:38] == 101 || [d UInt16AtOffset:38] == 102) {
                            // 添加权限 101 删除权限 102
                            AuthData *authData = [BRSafeUtils analysisAuthData:data];
                            balance += [tx.outputAmounts[n] unsignedLongLongValue];
                        }
                    } else {
                        balance += [tx.outputAmounts[n] unsignedLongLongValue];
                        balanceModel.balance += [tx.outputAmounts[n] unsignedLongLongValue];
                        [balanceModel.utxos addObject:brutxo_obj(((BRUTXO) { tx.txHash, n }))];
                    }
                }
//                BRLog(@"+++++++++++%@ %llu", tx.outputAmounts[n], balance);
                n++;
            }

            // transaction ordering is not guaranteed, so check the entire UTXO set against the entire spent output set
            [spent setSet:utxos.set];
            [spent intersectSet:spentOutputs];
            
            for (NSValue *output in spent) { // remove any spent outputs from UTXO set
                BRTransaction *transaction;
                BRUTXO o;
                
                [output getValue:&o];
                transaction = self.allTx[uint256_obj(o.hash)];
                [utxos removeObject:output];
//                balance -= [transaction.outputAmounts[o.n] unsignedLongLongValue];
                
                // TODO: 修改资产分组
//                if([transaction.outputReserves[o.n] isEqual:[NSNull null]]) continue;
                if(![BRSafeUtils isSafeTransaction:transaction.outputReserves[o.n]]) { // [transaction.outputReserves[o.n] length] > 42
                    NSNumber * l = 0;
                    NSUInteger off = 0;
                    NSData *d = [transaction.outputReserves[o.n] dataAtOffset:off length:&l];
                    NSData *data = [d subdataWithRange:NSMakeRange(42, d.length-42)];
                    if([d UInt16AtOffset:38] == 204 || [d UInt16AtOffset:38] == 202 || [d UInt16AtOffset:38] == 201 || [d UInt16AtOffset:38] == 203){
                        // 追加发行201  转让202 销毁203 找零204
                        CommonData *commonData = [BRSafeUtils analysisCommonData:data];
                        NSArray *issueDataArray = [[BRCoreDataManager sharedInstance] entity:@"BRIssueDataEnity" objectsMatching:[NSPredicate predicateWithFormat:@"assetId = %@", commonData.assetId]];
                        if(issueDataArray.count != 0) {
                            BOOL islookUp = NO;
                            BRIssueDataEnity *issueDataEnity = issueDataArray.firstObject;
                            for(int i=1; i<balanceArray.count; i++) {
                                BRBalanceModel *balanceModel = balanceArray[i];
                                if([balanceModel.assetId isEqual:commonData.assetId]) {
                                    balanceModel.balance -= [transaction.outputAmounts[o.n] unsignedLongLongValue];
                                    [balanceModel.utxos removeObject:output];
                                    islookUp = YES;
                                    break;
                                }
                            }
                            if(!islookUp) {
                                BRBalanceModel *balanceModel = [[BRBalanceModel alloc] init];
                                balanceModel.multiple = [issueDataEnity.decimals integerValue];
                                balanceModel.balance = -[transaction.outputAmounts[o.n] unsignedLongLongValue];
                                balanceModel.assetId = commonData.assetId;
                                balanceModel.nameString = issueDataEnity.assetName;
                                balanceModel.common = commonData;
                                balanceModel.version = [d subdataWithRange:NSMakeRange(4, 2)];
                                balanceModel.applicationID = [d subdataWithRange:NSMakeRange(6, 32)];
                                balanceModel.prevBalance = 0;
                                [balanceModel.utxos removeObject:output];
                                [balanceArray addObject:balanceModel];
                            }
                            balance -= [transaction.outputAmounts[o.n] unsignedLongLongValue] * pow(10, 8 - [issueDataEnity.decimals integerValue]);
                        } else {
                            BRLog(@"无此资产");
                            balance -= [transaction.outputAmounts[o.n] unsignedLongLongValue];
                        }
                    }else if ([d UInt16AtOffset:38] == 206) {
                        // 领取糖果 206
                        GetCandyData *getCandyData = [BRSafeUtils analysisGetCandyData:data];
                        NSArray *issueDataArray = [[BRCoreDataManager sharedInstance] entity:@"BRIssueDataEnity" objectsMatching:[NSPredicate predicateWithFormat:@"assetId = %@", getCandyData.assetId]];
                        if(issueDataArray.count != 0) {
                            BOOL islookUp = NO;
                            BRIssueDataEnity *issueDataEnity = issueDataArray.firstObject;
                            for(int i=1; i<balanceArray.count; i++) {
                                BRBalanceModel *balanceModel = balanceArray[i];
                                if([balanceModel.assetId isEqual:getCandyData.assetId]) {
                                    balanceModel.balance -= [transaction.outputAmounts[o.n] unsignedLongLongValue];
                                    [balanceModel.utxos removeObject:output];
                                    islookUp = YES;
                                    break;
                                }
                            }
                            if(!islookUp) {
                                BRBalanceModel *balanceModel = [[BRBalanceModel alloc] init];
                                balanceModel.multiple = [issueDataEnity.decimals integerValue];
                                balanceModel.balance = -[transaction.outputAmounts[o.n] unsignedLongLongValue];
                                balanceModel.assetId = getCandyData.assetId;
                                balanceModel.nameString = issueDataEnity.assetName;
                                balanceModel.prevBalance = 0;
                                CommonData *commonData = [[CommonData alloc] init];
                                commonData.version = getCandyData.version;
                                commonData.assetId = getCandyData.assetId;
                                commonData.amount =  -getCandyData.amount;
                                commonData.remarks = getCandyData.remarks;
                                balanceModel.common = commonData;
                                balanceModel.version = [d subdataWithRange:NSMakeRange(4, 2)];
                                balanceModel.applicationID = [d subdataWithRange:NSMakeRange(6, 32)];
                                [balanceModel.utxos removeObject:output];
                                [balanceArray addObject:balanceModel];
                            }
                            balance -= [transaction.outputAmounts[o.n] unsignedLongLongValue] * pow(10, 8 - [issueDataEnity.decimals integerValue]);
                        } else {
                            BRLog(@"无此资产");
                            balance -= [transaction.outputAmounts[o.n] unsignedLongLongValue];
                        }
                    } else if([d UInt16AtOffset:38] == 205){
                        // 发放糖果 205
                        PutCandyData *putCandyData = [BRSafeUtils analysisPutCandyData:data];
                        NSArray *issueDataArray = [[BRCoreDataManager sharedInstance] entity:@"BRIssueDataEnity" objectsMatching:[NSPredicate predicateWithFormat:@"assetId = %@", putCandyData.assetId]];
                        if(issueDataArray.count != 0) {
                            BOOL islookUp = NO;
                            BRIssueDataEnity *issueDataEnity = issueDataArray.firstObject;
                            for(int i=1; i<balanceArray.count; i++) {
                                BRBalanceModel *balanceModel = balanceArray[i];
                                if([balanceModel.assetId isEqual:putCandyData.assetId]) {
                                    balanceModel.balance -= [transaction.outputAmounts[o.n] unsignedLongLongValue];
                                    [balanceModel.utxos removeObject:output];
                                    islookUp = YES;
                                    break;
                                }
                            }
                            if(!islookUp) {
                                BRBalanceModel *balanceModel = [[BRBalanceModel alloc] init];
                                balanceModel.multiple = [issueDataEnity.decimals integerValue];
                                balanceModel.balance = -[transaction.outputAmounts[o.n] unsignedLongLongValue];
                                balanceModel.assetId = putCandyData.assetId;
                                balanceModel.nameString = issueDataEnity.assetName;
                                balanceModel.prevBalance = 0;
                                [balanceModel.utxos removeObject:output];
                                [balanceArray addObject:balanceModel];
                            }
                            balance -= [transaction.outputAmounts[o.n] unsignedLongLongValue] * pow(10, 8 - [issueDataEnity.decimals integerValue]);
                        } else {
                            BRLog(@"无此资产");
                            balance -= [transaction.outputAmounts[o.n] unsignedLongLongValue];
                        }
                    }else if([d UInt16AtOffset:38] == 200){
                        // 发行 200
                        IssueData *issueData = [BRSafeUtils analysisIssueData:data];
                        BOOL islookUp = NO;
                        for(int i=1; i<balanceArray.count; i++) {
                            BRBalanceModel *balanceModel = balanceArray[i];
                            if([balanceModel.assetId isEqual:[BRSafeUtils generateIssueAssetID:issueData]]) {
                                balanceModel.balance -= [transaction.outputAmounts[o.n] unsignedLongLongValue];
                                [balanceModel.utxos removeObject:output];
                                islookUp = YES;
                                break;
                            }
                        }
                        if(!islookUp) {
                            BRBalanceModel *balanceModel = [[BRBalanceModel alloc] init];
                            balanceModel.multiple = [issueData.decimals UInt8AtOffset:0];
                            balanceModel.balance = -[transaction.outputAmounts[o.n] unsignedLongLongValue];
                            balanceModel.assetId = [BRSafeUtils generateIssueAssetID:issueData];
                            balanceModel.nameString = [[NSString alloc] initWithData:issueData.assetName encoding:NSUTF8StringEncoding];
                            CommonData *commonData = [[CommonData alloc] init];
                            commonData.version = issueData.version;
                            commonData.assetId = [BRSafeUtils generateIssueAssetID:issueData];
                            commonData.amount = -issueData.firstActualAmount;
                            commonData.remarks = issueData.remarks;
                            balanceModel.common = commonData;
                            balanceModel.version = [d subdataWithRange:NSMakeRange(4, 2)];
                            balanceModel.applicationID = [d subdataWithRange:NSMakeRange(6, 32)];
                            balanceModel.prevBalance = 0;
                            [balanceArray addObject:balanceModel];
                            [balanceModel.utxos removeObject:output];
                        }
                        balance -= [transaction.outputAmounts[o.n] unsignedLongLongValue] * pow(10, 8 - [issueData.decimals UInt8AtOffset:0]);
                    }else if([d UInt16AtOffset:38] == 103) {
                        // 创建外带数据交易 103
                        ExtendData *extendData = [BRSafeUtils analysisExtendData:data];
                    } else if([d UInt16AtOffset:38] == 101 || [d UInt16AtOffset:38] == 102) {
                        // 添加权限 101 删除权限 102
                        AuthData *authData = [BRSafeUtils analysisAuthData:data];
                        balance -= [transaction.outputAmounts[o.n] unsignedLongLongValue];
                    }
                } else {
                    balance -= [transaction.outputAmounts[o.n] unsignedLongLongValue];
                    balanceModel.balance -= [transaction.outputAmounts[o.n] unsignedLongLongValue];
                    [balanceModel.utxos removeObject:output];
                }
//                BRLog(@"----------%@ %llu", transaction.outputAmounts[o.n], balance);
            }
            for(int index=balanceArray.count-1; index>=0; index--) {
                BRBalanceModel *balanceModel = balanceArray[index];
                if(balanceModel.prevBalance != balanceModel.balance) {
                    if(balanceModel.assetId.length != 0) {
                        [balanceModel.txArray insertObject:tx atIndex:0];
                        if(balanceModel.balance < balanceModel.prevBalance) {
                            balanceModel.totalSent += balanceModel.prevBalance - balanceModel.balance;
                        }
                        balanceModel.prevBalance = balanceModel.balance;
                        for(NSData *reserve in tx.outputReserves) {
                            if(![BRSafeUtils isSafeTransaction:reserve]) { // reserve.length > 42
                                NSNumber * l = 0;
                                NSUInteger off = 0;
                                NSData *d = [reserve dataAtOffset:off length:&l];
                                NSData *data = [d subdataWithRange:NSMakeRange(42, d.length-42)];
                                if([d UInt16AtOffset:38] == 200) {
                                    for(BRBalanceModel *model in balanceArray) {
                                        if(model.assetId.length == 0) {
                                            [model.txArray insertObject:tx atIndex:0];
                                            model.prevBalance = model.balance;
                                            break;
                                        }
                                    }
                                }
                            }
                        }
                        break;
                    } else {
                        BOOL isSafe = YES;
                        for(NSData *reserve in tx.outputReserves) {
                            if(![BRSafeUtils isSafeTransaction:reserve]) { // reserve.length > 42
                                NSNumber * l = 0;
                                NSUInteger off = 0;
                                NSData *d = [reserve dataAtOffset:off length:&l];
                                NSData *data = [d subdataWithRange:NSMakeRange(42, d.length-42)];
                                if([d UInt16AtOffset:38] == 202) {
                                    CommonData *commonData = [BRSafeUtils analysisCommonData:data];
                                    for(BRBalanceModel *model in balanceArray) {
                                        if([commonData.assetId isEqual:model.assetId]) {
                                            [model.txArray insertObject:tx atIndex:0];
                                            model.prevBalance = model.balance;
                                            break;
                                        }
                                    }
                                }
                                isSafe = NO;
                            }
                        }
                        if(!isSafe) continue;
                        [balanceModel.txArray insertObject:tx atIndex:0];
                        if(balanceModel.prevBalance > balanceModel.balance) {
                            balanceModel.totalSent += balanceModel.prevBalance - balanceModel.balance;
                        }
                        balanceModel.prevBalance = balanceModel.balance;
                        break;
                    }
                }
            }
            BRBalanceModel *safeBalanceModel = balanceArray.firstObject;
            if(safeBalanceModel.prevBalance > safeBalanceModel.balance) {
                safeBalanceModel.totalSent += safeBalanceModel.prevBalance - safeBalanceModel.balance;
                safeBalanceModel.prevBalance = safeBalanceModel.balance;
            }
            if (prevBalance < balance) totalReceived += balance - prevBalance;
            if (balance < prevBalance) totalSent += prevBalance - balance;
            [balanceHistory insertObject:@(balance) atIndex:0];
            prevBalance = balance;
        }
    }
    
    self.invalidTx = invalidTx;
    self.pendingTx = pendingTx;
    self.spentOutputs = spentOutputs;
    self.utxos = utxos;
    self.balanceHistory = balanceHistory;
    _totalSent = totalSent;
    _totalReceived = totalReceived;
    BOOL isSendNotification = NO;
    if(_balanceArray.count != balanceArray.count) {
        isSendNotification = YES;
    } else {
        for(int i=0; i<balanceArray.count; i++) {
            BRBalanceModel *modelOne = balanceArray[i];
            BRBalanceModel *modelTwo = _balanceArray[i];
            if(modelOne.balance != modelTwo.balance) {
                isSendNotification = YES;
                break;
            }
        }
    }
    // 封存dash
    BRUTXO o;
    if([BRPeerManager sharedInstance].lastBlockHeight >= DisableDash_TX_HEIGHT) {
        BRBalanceModel *model = balanceArray.firstObject;
        for(NSValue *output in model.utxos) {
            [output getValue:&o];
            BRTransaction *tx = self.allTx[uint256_obj(o.hash)];
            if([tx.outputReserves[o.n] isEqual:[NSNull null]]) {
                model.balance -= [tx.outputAmounts[o.n] unsignedLongLongValue];
                isSendNotification = YES;
            }
        }
    }
//    int index = 1;
//    for(BRTransaction *tx in [self.transactions reverseObjectEnumerator]) {
//        BRLog(@"%@ %d %@", uint256_obj(tx.txHash), index++, tx);
//    }
    BRLog(@"==========XXXXXXXXXXX=========== %d %lu %lu", isSendNotification,(unsigned long) self.transactions.count,(unsigned long) (unsigned long)self.allAddresses.count);
   
    if (isSendNotification) {
        _balance = balance;
        _balanceArray = [NSArray arrayWithArray:balanceArray];
        dispatch_async(dispatch_get_main_queue(), ^{
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(balanceNotification) object:nil];
            [self performSelector:@selector(balanceNotification) withObject:nil afterDelay:0.1];
        });
    }
}

#pragma mark 计算可用的金额
- (uint64_t) useBalance:(NSData *) assetId {
    uint64_t usebalance = 0;
    BRBalanceModel *balanceModel;
    for(int i=0; i<self.balanceArray.count; i++) {
        balanceModel = self.balanceArray[i];
        if([balanceModel.assetId isEqual:assetId]) {
            break;
        } else {
            balanceModel = nil;
        }
    }
    if(balanceModel == nil) return usebalance;
    BRTransaction *tx;
    BRUTXO o;
    for (NSValue *output in balanceModel.utxos) {
        [output getValue:&o];
        tx = self.allTx[uint256_obj(o.hash)];
        
        if (!tx) continue;
//        if (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) continue;
//        if ([tx.outputUnlockHeights[o.n] unsignedLongLongValue] > 0 && [tx.outputUnlockHeights[o.n] unsignedLongLongValue] > [BRPeerManager sharedInstance].lastBlockHeight) continue;
        if([self sposLockTxOut:tx index:o.n]) continue;
        if (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) { // continue;
            BOOL isAdd = YES;
            for(int i=0; i<tx.inputHashes.count; i++) {
                BRTransaction *parentTx = self.allTx[tx.inputHashes[i]];
                if(parentTx) {
                    if(parentTx.inputHashes.count == 1 && [parentTx.inputHashes.firstObject isEqual:uint256_obj(UINT256_ZERO)]) {
                        if(parentTx.blockHeight == 0 || parentTx.blockHeight == INT32_MAX || parentTx.blockHeight - [BRPeerManager sharedInstance].lastBlockHeight < 100) {
                            isAdd = NO;
                        }
                    }
                }
            }
            if(isAdd) isAdd = [self isMeTransactionSend:tx];
            if(!isAdd) continue;
        }
        if([tx.outputReserves[o.n] isEqual:[NSNull null]] && [BRPeerManager sharedInstance].lastBlockHeight >= DisableDash_TX_HEIGHT) {
            continue;
        }
        usebalance += [tx.outputAmounts[o.n] unsignedLongLongValue];
    }
    return usebalance;
}
// 判断是否是自己发送的交易
- (BOOL) isMeTransactionSend:(BRTransaction *) tx {
    int index = 0;
    for(int i=0; i<tx.inputAddresses.count; i++) {
        if(![self.allAddresses containsObject:tx.inputAddresses[i]]) {
            index ++;
        }
    }
    if(index == tx.inputAddresses.count) return NO;
    return YES;
}

#pragma mark  计算是否为锁定交易
-(BOOL) sposLockTxOut:(BRTransaction *) tx index:(NSInteger) index {
    if ([tx.outputUnlockHeights[index] unsignedLongLongValue] > 0) {
        if ([tx.outputUnlockHeights[index] unsignedLongLongValue] <= TEST_START_SPOS_HEIGHT) {
            if ([tx.outputUnlockHeights[index] unsignedLongLongValue] > [BRPeerManager sharedInstance].lastBlockHeight) {
                return YES;
            }
        } else {
            if (tx.blockHeight >= TEST_START_SPOS_HEIGHT && tx.version == TX_VERSION_SPOS_NUMBER) {
                if ([tx.outputUnlockHeights[index] unsignedLongLongValue] > [BRPeerManager sharedInstance].lastBlockHeight) {
                    return YES;
                }
            } else {
                long long unlockHeight = ([tx.outputUnlockHeights[index] unsignedLongLongValue] - TEST_START_SPOS_HEIGHT) * TEST_START_SPOS_BlockTimeRatio + TEST_START_SPOS_HEIGHT;
                if(unlockHeight > [BRPeerManager sharedInstance].lastBlockHeight) {
                    return YES;
                }
            }
        }
    }
    return NO;
}

#pragma mark 支付计算可用的金额
- (uint64_t) payUIUseBalance:(NSData *) assetId {
    uint64_t usebalance = 0;
    BRBalanceModel *balanceModel;
    for(int i=0; i<self.balanceArray.count; i++) {
        balanceModel = self.balanceArray[i];
        if([balanceModel.assetId isEqual:assetId]) {
            break;
        } else {
            balanceModel = nil;
        }
    }
    if(balanceModel == nil) return usebalance;
    BRTransaction *tx;
    BRUTXO o;
    for (NSValue *output in balanceModel.utxos) {
        [output getValue:&o];
        tx = self.allTx[uint256_obj(o.hash)];
        
        if (!tx) continue;
        //        if (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) continue;
//        if ([tx.outputUnlockHeights[o.n] unsignedLongLongValue] > 0 && [tx.outputUnlockHeights[o.n] unsignedLongLongValue] > [BRPeerManager sharedInstance].lastBlockHeight) continue;
        if([self sposLockTxOut:tx index:o.n]) continue;
        if (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) { // continue;
            BOOL isAdd = YES;
            for(int i=0; i<tx.inputHashes.count; i++) {
                BRTransaction *parentTx = self.allTx[tx.inputHashes[i]];
                if(parentTx) {
                    if(parentTx.inputHashes.count == 1 && [parentTx.inputHashes.firstObject isEqual:uint256_obj(UINT256_ZERO)]) {
                        if(parentTx.blockHeight == 0 || parentTx.blockHeight == INT32_MAX || parentTx.blockHeight - [BRPeerManager sharedInstance].lastBlockHeight < 100) {
                            isAdd = NO;
                        }
                    }
                }
            }
            if(isAdd) isAdd = [self isMeTransactionSend:tx];
            if(!isAdd) continue;
        }
        if([tx.outputReserves[o.n] isEqual:[NSNull null]] && [BRPeerManager sharedInstance].lastBlockHeight + 1 >= DisableDash_TX_HEIGHT) {
            continue;
        }
        usebalance += [tx.outputAmounts[o.n] unsignedLongLongValue];
    }
    return usebalance;
}

#pragma mark 计算可用的金额
- (NSInteger) countUtxosNumber:(NSData *) assetId {
    NSInteger usebalance = 0;
    BRBalanceModel *balanceModel;
    for(int i=0; i<self.balanceArray.count; i++) {
        balanceModel = self.balanceArray[i];
        if([balanceModel.assetId isEqual:assetId]) {
            break;
        } else {
            balanceModel = nil;
        }
    }
    if(balanceModel == nil) return 1;
    BRTransaction *tx;
    BRUTXO o;
    for (NSValue *output in balanceModel.utxos) {
        [output getValue:&o];
        tx = self.allTx[uint256_obj(o.hash)];
        
        if (!tx) continue;
//        if ([tx.outputUnlockHeights[o.n] unsignedLongLongValue] > 0 && [tx.outputUnlockHeights[o.n] unsignedLongLongValue] > [BRPeerManager sharedInstance].lastBlockHeight) continue;
        if([self sposLockTxOut:tx index:o.n]) continue;
        if (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) { // continue;
            BOOL isAdd = YES;
            for(int i=0; i<tx.inputHashes.count; i++) {
                BRTransaction *parentTx = self.allTx[tx.inputHashes[i]];
                if(parentTx) {
                    if(parentTx.inputHashes.count == 1 && [parentTx.inputHashes.firstObject isEqual:uint256_obj(UINT256_ZERO)]) {
                        if(parentTx.blockHeight == 0 || parentTx.blockHeight == INT32_MAX || parentTx.blockHeight - [BRPeerManager sharedInstance].lastBlockHeight < 100) {
                            isAdd = NO;
                        }
                    }
                }
            }
            if(isAdd) isAdd = [self isMeTransactionSend:tx];
            if(!isAdd) continue;
        }
        
        usebalance += 1;
    }
    return usebalance;
}

#pragma mark 计算是否可以发送即使交易
- (BOOL) useisInstantTxBalance {
    BRBalanceModel *balanceModel;
    for(int i=0; i<self.balanceArray.count; i++) {
        balanceModel = self.balanceArray[i];
        if(balanceModel.assetId.length == 0) {
            break;
        } else {
            balanceModel = nil;
        }
    }
    if(balanceModel == nil) return 0;
    BRTransaction *tx;
    BRUTXO o;
    for (NSValue *output in balanceModel.utxos) {
        [output getValue:&o];
        tx = self.allTx[uint256_obj(o.hash)];
        
        if (!tx) continue;
        if (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX || [BRPeerManager sharedInstance].lastBlockHeight - tx.blockHeight < [self isInstantConfirmHeight] - 1)  return NO; // 5
    }
    return YES;
}

#pragma mark 计算未花费的金额
- (uint64_t) useUtxosBalance:(NSData *) assetId {
    uint64_t usebalance = 0;
    BRBalanceModel *balanceModel;
    for(int i=0; i<self.balanceArray.count; i++) {
        balanceModel = self.balanceArray[i];
        if([balanceModel.assetId isEqual:assetId]) {
            break;
        } else {
            balanceModel = nil;
        }
    }
    if(balanceModel == nil) return usebalance;
    BRTransaction *tx;
    BRUTXO o;
    for (NSValue *output in balanceModel.utxos) {
        [output getValue:&o];
        tx = self.allTx[uint256_obj(o.hash)];
        
        if (!tx) continue;
//        if (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) continue;
//        if ([tx.outputUnlockHeights[o.n] unsignedLongLongValue] > 0 && [tx.outputUnlockHeights[o.n] unsignedLongLongValue] > [BRPeerManager sharedInstance].lastBlockHeight) continue;
        if([self sposLockTxOut:tx index:o.n]) continue;
        usebalance += [tx.outputAmounts[o.n] unsignedLongLongValue];
    }
    return usebalance;
}

#pragma mark 计算锁定的金额
- (uint64_t) lockBalance:(NSData *) assetId {
    uint64_t lockalance = 0;
    BRBalanceModel *balanceModel;
    for(int i=0; i<self.balanceArray.count; i++) {
        balanceModel = self.balanceArray[i];
        if([balanceModel.assetId isEqual:assetId]) {
            break;
        } else {
            balanceModel = nil;
        }
    }
    if(balanceModel == nil) return lockalance;
    BRTransaction *tx;
    BRUTXO o;
    for (NSValue *output in balanceModel.utxos) {
        [output getValue:&o];
        tx = self.allTx[uint256_obj(o.hash)];
        
        if (!tx) continue;

//        if ([tx.outputUnlockHeights[o.n] unsignedLongLongValue] > 0 && [tx.outputUnlockHeights[o.n] unsignedLongLongValue] > [BRPeerManager sharedInstance].lastBlockHeight) {
//            lockalance += [tx.outputAmounts[o.n] unsignedLongLongValue];
//        }
        if([self sposLockTxOut:tx index:o.n]) {
            lockalance += [tx.outputAmounts[o.n] unsignedLongLongValue];
        }
    }
    return lockalance;
}

#pragma mark 添加区块高度之前所拥有的safe
- (void) getBlockHeightSafe:(NSInteger) blockHeight {
    uint64_t balance = 0;
    BRUTXO x, y;
//    BRBalanceModel *safeBalanceModel = self.balanceArray.firstObject;
    NSMutableOrderedSet *utxos = [self countHeightAvailableSafe:blockHeight];
    for (int i=0; i<utxos.count; i++) {
        NSValue *outputOne = utxos[i];
        [outputOne getValue:&x];
        BRTransaction *txOne = self.allTx[uint256_obj(x.hash)];
        if (!txOne) continue;
        if (txOne.blockHeight > blockHeight || txOne.blockHeight < CriticalHeight) continue;
        if (![BRSafeUtils isSafeTransaction:txOne.outputReserves[x.n]]) continue; // [txOne.outputReserves[x.n] length] > 42
        NSArray *blockAvailableSafeArray = [[BRCoreDataManager sharedInstance] entity:@"BRBlockAvailableSafeEntity" objectsMatching:[NSPredicate predicateWithFormat:@"address = %@ AND height = %@", txOne.outputAddresses[x.n], @(blockHeight)]];
        if(blockAvailableSafeArray.count > 0) continue;
        balance = [txOne.outputAmounts[x.n] unsignedLongLongValue];;
        for(int j=i+1; j<utxos.count; j++) {
            NSValue *outputTwo = utxos[j];
            [outputTwo getValue:&y];
            BRTransaction *txTwo = self.allTx[uint256_obj(y.hash)];
            if (!txTwo) continue;
            if (txTwo.blockHeight > blockHeight || txTwo.blockHeight < CriticalHeight) continue;
            if (![BRSafeUtils isSafeTransaction:txTwo.outputReserves[y.n]]) continue; // [txTwo.outputReserves[y.n] length] > 42
            if (![txOne.outputAddresses[x.n] isEqualToString:txTwo.outputAddresses[y.n]]) continue;
            balance += [txTwo.outputAmounts[y.n] unsignedLongLongValue];
        }
        // 过滤小于1
        if(balance < 1 * (uint64_t)pow(10, 8)) continue;
        [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlockAndWait:^{
            BRBlockAvailableSafeEntity *blockAvailableSafeEntity = (BRBlockAvailableSafeEntity *)[[BRCoreDataManager sharedInstance] createEntityNamedWith:@"BRBlockAvailableSafeEntity"];
            [blockAvailableSafeEntity setAttributesFromBlockHeight:blockHeight amout:balance address:txOne.outputAddresses[x.n]];
            [[BRCoreDataManager sharedInstance] saveContext:[BRCoreDataManager sharedInstance].contextForCurrentThread];
        }];
    }
//    for (NSValue *output in self.utxos) {
//        [output getValue:&o];
//        tx = self.allTx[uint256_obj(o.hash)];
//        if (!tx) continue;
//        if (tx.blockHeight > blockHeight) continue;
//        if([tx.outputReserves[o.n] length] < 42) {
//            uint64_t balance = [tx.outputAmounts[o.n] unsignedLongLongValue];
//            NSArray *blockAvailableSafeArray = [BRBlockAvailableSafeEntity objectsMatching:@"txId = %@ AND address = %@ AND height = %@", [NSData dataWithUInt256:tx.txHash], tx.outputAddresses[o.n], @(blockHeight)];
//            if(blockAvailableSafeArray.count > 0) continue;
//            [[BRBlockAvailableSafeEntity context] performBlock:^{
//                @autoreleasepool {
//                    [[BRBlockAvailableSafeEntity managedObject] setAttributesFromBlockHeight:blockHeight amout:balance txId:[NSData dataWithUInt256:tx.txHash] address:tx.outputAddresses[o.n]];
//                }
//                [BRBlockAvailableSafeEntity saveContext];
//            }];
//        }
//    }
}

// TODO: SPOS 即时交易数 扩大 TEST_START_SPOS_BlockTimeRatio 倍
- (NSInteger) isInstantConfirmHeight{
    if([BRPeerManager sharedInstance].lastBlockHeight >= TEST_START_SPOS_HEIGHT) {
        return IX_PREVIOUS_CONFIRMATIONS_NEEDED * TEST_START_SPOS_BlockTimeRatio;
    } else {
        return IX_PREVIOUS_CONFIRMATIONS_NEEDED;
    }
}

- (NSMutableOrderedSet *) countHeightAvailableSafe:(uint32_t) height {
    uint64_t balance = 0;
    NSMutableOrderedSet *utxos = [NSMutableOrderedSet orderedSet];
    NSMutableSet *spentOutputs = [NSMutableSet set], *invalidTx = [NSMutableSet set], *pendingTx = [NSMutableSet set];
    NSMutableArray *balanceHistory = [NSMutableArray array];
    uint32_t now = [NSDate timeIntervalSinceReferenceDate] + NSTimeIntervalSince1970;
    for (BRTransaction *tx in [self.transactions reverseObjectEnumerator]) {
        @autoreleasepool {
            if(tx.blockHeight == 0 || tx.blockHeight == INT32_MAX || tx.blockHeight > height) continue;
            NSMutableSet *spent = [NSMutableSet set];
            NSSet *inputs;
            uint32_t i = 0, n = 0;
            BOOL pending = NO;
            UInt256 h;
            
            for (NSValue *hash in tx.inputHashes) {
                n = [tx.inputIndexes[i++] unsignedIntValue];
                [hash getValue:&h];
                [spent addObject:brutxo_obj(((BRUTXO) { h, n }))];
            }
            
            inputs = [NSSet setWithArray:tx.inputHashes];
            
            // check if any inputs are invalid or already spent
            if (tx.blockHeight == TX_UNCONFIRMED &&
                ([spent intersectsSet:spentOutputs] || [inputs intersectsSet:invalidTx])) {
                [invalidTx addObject:uint256_obj(tx.txHash)];
                [balanceHistory insertObject:@(balance) atIndex:0];
                continue;
            }
            
            [spentOutputs unionSet:spent]; // add inputs to spent output set
            n = 0;
            
            // check if any inputs are pending
            if (tx.blockHeight == TX_UNCONFIRMED) {
                if (tx.size > TX_MAX_SIZE) pending = YES; // check transaction size is under TX_MAX_SIZE
                
                for (NSNumber *sequence in tx.inputSequences) {
                    if (sequence.unsignedIntValue < UINT32_MAX - 1) pending = YES; // check for replace-by-fee
                    if (sequence.unsignedIntValue < UINT32_MAX && tx.lockTime < TX_MAX_LOCK_HEIGHT &&
                        tx.lockTime > self.bestBlockHeight + 1) pending = YES; // future lockTime
                    if (sequence.unsignedIntValue < UINT32_MAX && tx.lockTime >= TX_MAX_LOCK_HEIGHT &&
                        tx.lockTime > now) pending = YES; // future locktime
                }
                
//                for (NSNumber *amount in tx.outputAmounts) { // check that no outputs are dust
//                    if (amount.unsignedLongLongValue < TX_MIN_OUTPUT_AMOUNT) pending = YES;
//                }
//
                //TODO ZCZCZC
                if (pending || [inputs intersectsSet:pendingTx]) {
                    [pendingTx addObject:uint256_obj(tx.txHash)];
                    [balanceHistory insertObject:@(balance) atIndex:0];
                    continue;
                }
            }
            
            //TODO: don't add outputs below TX_MIN_OUTPUT_AMOUNT
            //TODO: don't add coin generation outputs < 100 blocks deep
            //NOTE: balance/UTXOs will then need to be recalculated when last block changes
            for (NSString *address in tx.outputAddresses) { // add outputs to UTXO set
                if ([self containsAddress:address]) {
                    if([tx.outputReserves[n] isEqual:[NSNull null]]) continue;
                    if([BRSafeUtils isSafeTransaction:tx.outputReserves[n]]) { // [tx.outputReserves[n] length] < 42
                        balance += [tx.outputAmounts[n] unsignedLongLongValue];
                        [utxos addObject:brutxo_obj(((BRUTXO) { tx.txHash, n }))];
                    }
                }
                n++;
            }
            
            // transaction ordering is not guaranteed, so check the entire UTXO set against the entire spent output set
            [spent setSet:utxos.set];
            [spent intersectSet:spentOutputs];
            
            for (NSValue *output in spent) { // remove any spent outputs from UTXO set
                BRTransaction *transaction;
                BRUTXO o;
                
                [output getValue:&o];
                transaction = self.allTx[uint256_obj(o.hash)];
                
                if([transaction.outputReserves[o.n] isEqual:[NSNull null]]) continue;
                if([BRSafeUtils isSafeTransaction:transaction.outputReserves[o.n]]){ // [transaction.outputReserves[o.n] length] < 42
                    [utxos removeObject:output];
                }
            }
        }
    }
    return utxos;
}

- (void)balanceNotification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:BRWalletBalanceChangedNotification object:nil];
}

// MARK: - wallet info

// returns the first unused external address
- (NSString *)receiveAddress
{
    //TODO: limit to 10,000 total addresses and utxos for practical usability with bloom filters
#if ADDRESS_DEFAULT == BIP32_PURPOSE
    NSString *addr = [self addressesBIP32NoPurposeWithGapLimit:1 internal:NO].lastObject;
    return (addr) ? addr : self.externalBIP32Addresses.lastObject;
#else
    NSString *addr = [self addressesWithGapLimit:1 internal:NO].lastObject;
    return (addr) ? addr : self.externalBIP44Addresses.lastObject;
#endif
}

- (NSString *)newReceiveAddress {
    NSString *addr = [self receiveAddress];
    [self.usedAddresses addObject:addr];
    return [self receiveAddress];
}

// returns the first unused internal address
- (NSString *)changeAddress
{
    //TODO: limit to 10,000 total addresses and utxos for practical usability with bloom filters
#if ADDRESS_DEFAULT == BIP32_PURPOSE
    return [self addressesBIP32NoPurposeWithGapLimit:1 internal:YES].lastObject;
#else
    return [self addressesWithGapLimit:1 internal:YES].lastObject;
#endif
}

// all previously generated external addresses
- (NSSet *)allReceiveAddresses
{
    return [NSSet setWithArray:[self.externalBIP32Addresses arrayByAddingObjectsFromArray:self.externalBIP44Addresses]];
}

// all previously generated external addresses
- (NSSet *)allChangeAddresses
{
    return [NSSet setWithArray:[self.internalBIP32Addresses arrayByAddingObjectsFromArray:self.internalBIP44Addresses]];
}

// NSData objects containing serialized UTXOs
- (NSArray *)unspentOutputs
{
    return self.utxos.array;
}

// last 100 transactions sorted by date, most recent first
- (NSArray *)recentTransactions
{
    //TODO: don't include receive transactions that don't have at least one wallet output >= TX_MIN_OUTPUT_AMOUNT
    return [self.transactions.array subarrayWithRange:NSMakeRange(0, (self.transactions.count > 100) ? 100 :
                                                                  self.transactions.count)];
}

// all wallet transactions sorted by date, most recent first
- (NSArray *)allTransactions
{
    return self.transactions.array;
}

// true if the address is controlled by the wallet
- (BOOL)containsAddress:(NSString *)address
{
    return (address && [self.allAddresses containsObject:address]) ? YES : NO;
}

// gives the purpose of the address (either 0 or 44 for now)
-(NSUInteger)addressPurpose:(NSString *)address
{
    if ([self.internalBIP44Addresses containsObject:address] || [self.externalBIP44Addresses containsObject:address]) return BIP44_PURPOSE;
    if ([self.internalBIP32Addresses containsObject:address] || [self.externalBIP32Addresses containsObject:address]) return BIP32_PURPOSE;
    return NSIntegerMax;
}

// true if the address was previously used as an input or output in any wallet transaction
- (BOOL)addressIsUsed:(NSString *)address
{
    return (address && [self.usedAddresses containsObject:address]) ? YES : NO;
}

// MARK: - transactions

// returns an unsigned transaction that sends the specified amount from the wallet to the given address
- (BRTransaction *)transactionFor:(uint64_t)amount to:(NSString *)address withFee:(BOOL)fee
{
    NSMutableArray *unlockHeights = [NSMutableArray array];
    [unlockHeights addObject:@(0)];
    NSMutableArray *reserves = [NSMutableArray array];
    [reserves addObject:@"safe"];
    
    NSMutableData *script = [NSMutableData data];
    
    [script appendScriptPubKeyForAddress:address];
    
    return [self transactionForAmounts:@[@(amount)] toOutputScripts:@[script] withUnlockHeights:unlockHeights withReserves:reserves withFee:fee];
}

// returns an unsigned transaction that sends the specified amounts from the wallet to the specified output scripts
- (BRTransaction *)transactionForAmounts:(NSArray *)amounts toOutputScripts:(NSArray *)scripts withUnlockHeights:(NSArray *)unlockHeights withReserves:(NSArray *)reserves withFee:(BOOL)fee {
    return [self transactionForAmounts:amounts toOutputScripts:scripts withUnlockHeights:unlockHeights withReserves:reserves withFee:fee isInstant:FALSE toShapeshiftAddress:nil];
}

// returns an unsigned transaction that sends the specified amounts from the wallet to the specified output scripts
- (BRTransaction *)transactionForAmounts:(NSArray *)amounts toOutputScripts:(NSArray *)scripts withUnlockHeights:(NSArray *)unlockHeights withReserves:(NSArray *)reserves withFee:(BOOL)fee isInstant:(BOOL)isInstant {
    return [self transactionForAmounts:amounts toOutputScripts:scripts withUnlockHeights:unlockHeights withReserves:reserves withFee:fee isInstant:isInstant toShapeshiftAddress:nil];
}

// returns an unsigned transaction that sends the specified amounts from the wallet to the specified output scripts
- (BRTransaction *)transactionForAmounts:(NSArray *)amounts toOutputScripts:(NSArray *)scripts withUnlockHeights:(NSArray *)unlockHeights withReserves:(NSArray *)reserves withFee:(BOOL)fee isInstant:(BOOL)isInstant toShapeshiftAddress:(NSString *)shapeshiftAddress
{
    
    uint64_t amount = 0, balance = 0, feeAmount = 0;
    BRTransaction *transaction = [BRTransaction new], *tx;
    NSUInteger i = 0, cpfpSize = 0;
    BRUTXO o;
    
    if (amounts.count != scripts.count || amounts.count < 1) return nil; // sanity check

    for (NSData *script in scripts) {
        if (script.length == 0) return nil;
        [transaction addOutputScript:script amount:[amounts[i] unsignedLongLongValue] unlockHeight:[unlockHeights[i] longLongValue] reserve:reserves[i]];
        amount += [amounts[i++] unsignedLongLongValue];
    }
    
    //TODO: use up all UTXOs for all used addresses to avoid leaving funds in addresses whose public key is revealed
    //TODO: avoid combining addresses in a single transaction when possible to reduce information leakage
    //TODO: use up UTXOs received from any of the output scripts that this transaction sends funds to, to mitigate an
    //      attacker double spending and requesting a refund
    
    //当前区块高度
    uint64_t blockHeight = [BRPeerManager sharedInstance].lastBlockHeight;

    for (NSValue *output in self.utxos) {
        [output getValue:&o];
        tx = self.allTx[uint256_obj(o.hash)];
        if (!tx) continue;
        
        //TODO ZC ADD  判断解锁高度是否大于0
//        for (NSInteger i = 0; i < tx.outputUnlockHeights.count; i ++) {
//            uint64_t unlockheight = [tx.outputUnlockHeights[i] unsignedLongLongValue];
//            if (unlockheight > 0 && unlockheight > blockHeight) {
//                continue;
//            }
//        }
//        uint64_t unlockheight = [tx.outputUnlockHeights[o.n] unsignedLongLongValue];
//        if(unlockheight > 0 && unlockheight > blockHeight) {
//            continue;
//        }
        if ([self sposLockTxOut:tx index:o.n]) continue;
        
        //for example the tx block height is 25, can only send after the chain block height is 31 for previous confirmations needed of 6
        if (isInstant && (tx.blockHeight >= (self.blockHeight - [self isInstantConfirmHeight]))) continue;
        [transaction addInputHash:tx.txHash index:o.n script:tx.outputScripts[o.n]];
        
        if (transaction.size + 34 > TX_MAX_SIZE) { // transaction size-in-bytes too large
            NSUInteger txSize = 10 + self.utxos.count*148 + (scripts.count + 1)*34;
            
            // check for sufficient total funds before building a smaller transaction
            if (self.balance < amount + [self feeForTxSize:txSize + cpfpSize isInstant:isInstant inputCount:transaction.inputHashes.count]) {
                //BRLog(@"Insufficient funds. %llu is less than transaction amount:%llu", self.balance,
                      //amount + [self feeForTxSize:txSize + cpfpSize isInstant:isInstant inputCount:transaction.inputHashes.count]);
                return nil;
            }
            
            uint64_t lastAmount = [amounts.lastObject unsignedLongLongValue];
            NSArray *newAmounts = [amounts subarrayWithRange:NSMakeRange(0, amounts.count - 1)],
            *newScripts = [scripts subarrayWithRange:NSMakeRange(0, scripts.count - 1)];
            
            if (lastAmount > amount + feeAmount + self.minOutputAmount - balance) { // reduce final output amount
                newAmounts = [newAmounts arrayByAddingObject:@(lastAmount - (amount + feeAmount - balance))];
                newScripts = [newScripts arrayByAddingObject:scripts.lastObject];
            }
            return [self transactionForAmounts:newAmounts toOutputScripts:newScripts withUnlockHeights:unlockHeights withReserves:reserves withFee:fee];
        }
        
        balance += [tx.outputAmounts[o.n] unsignedLongLongValue];
        
        // add up size of unconfirmed, non-change inputs for child-pays-for-parent fee calculation
        // don't include parent tx with more than 10 inputs or 10 outputs
        if (tx.blockHeight == TX_UNCONFIRMED && tx.inputHashes.count <= 10 && tx.outputAmounts.count <= 10 &&
            [self amountSentByTransaction:tx] == 0) cpfpSize += tx.size;
        
        if (fee) {
            feeAmount = [self feeForTxSize:transaction.size + 34 + cpfpSize isInstant:isInstant inputCount:transaction.inputHashes.count]; // assume we will add a change output
            if (self.balance > amount) feeAmount += (self.balance - amount) % 100; // round off balance to 100 satoshi
        }
        
        if (balance == amount + feeAmount || balance >= amount + feeAmount + self.minOutputAmount) break;
    }
    
    transaction.isInstant = isInstant;
    
    if (balance < amount + feeAmount) { // insufficient funds
        //BRLog(@"Insufficient funds. %llu is less than transaction amount:%llu", balance, amount + feeAmount);
        return nil;
    }
    
    if (shapeshiftAddress) {
        [transaction addOutputShapeshiftAddress:shapeshiftAddress];
    }
    
    if (balance - (amount + feeAmount) >= self.minOutputAmount) {
        [transaction addOutputAddress:self.changeAddress amount:balance - (amount + feeAmount)];
        [transaction shuffleOutputOrder];
    }
   
    return transaction;
}

//// TODO: 在所有交易中找未确认的交易
//- (NSMutableOrderedSet *) lookupUnconfirmedTx {
//    NSMutableOrderedSet * unconfirmedTxSet = [NSMutableOrderedSet orderedSet];
//    for (BRTransaction *tx in [self.transactions reverseObjectEnumerator]) {
//        @autoreleasepool {
//            if(tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) {
//                [unconfirmedTxSet addObject:tx];
//            }
//        }
//    }
//    return unconfirmedTxSet;
//}

// TODO: 判断交易是否可以发送
- (BOOL) isSendTransaction:(BRTransaction *) tx {
    self.maxlayers = 25;
    [self recursionTxlookupUnconfirmed:25 transaction:tx];
    if(self.maxlayers < 0) return NO;
    return YES;
}

// TODO: 递归找到一个交易的输入是否前25个都有确认
- (void) recursionTxlookupUnconfirmed:(NSInteger) layerNumber transaction:(BRTransaction *) tx{
    if(self.maxlayers < 0) return;
    BOOL isConfirmed = YES;
    for(NSValue *hash in tx.inputHashes) {
        BRTransaction *newTx = self.allTx[hash];
        if(newTx.blockHeight == 0 || newTx.blockHeight == INT32_MAX) {
            [self recursionTxlookupUnconfirmed:layerNumber - 1 transaction:newTx];
            isConfirmed = NO;
        }
    }
    if(isConfirmed) {
        if(layerNumber < self.maxlayers) {
            self.maxlayers = layerNumber;
        }
    }
}

// TODO: 生成交易添加BalanceModel
- (BRTransaction * _Nullable)transactionForAmounts:(NSArray * _Nonnull)amounts toOutputScripts:(NSArray * _Nonnull)scripts withUnlockHeights:(NSArray * _Nonnull)unlockHeights withReserves:(NSArray * _Nonnull)reserves withFee:(BOOL)fee isInstant:(BOOL)isInstant toShapeshiftAddress:(NSString* _Nullable)shapeshiftAddress BalanceModel:(BRBalanceModel *_Nullable) balanceModel {
    
    // TODO: 修改生成交易块  不同资产扣除费用
    uint64_t amount = 0, balance = 0, safeBalance = 0, feeAmount = 0;
    BRTransaction *transaction = [BRTransaction new], *tx;
    NSUInteger i = 0, cpfpSize = 0;
    BRUTXO o;
    BRBalanceModel *safeBalanceModel = self.balanceArray.firstObject;

    if (amounts.count != scripts.count || amounts.count < 1) return nil; // sanity check
    
    for (NSData *script in scripts) {
        if (script.length == 0) return nil;
        [transaction addOutputScript:script amount:[amounts[i] unsignedLongLongValue] unlockHeight:[unlockHeights[i] longLongValue] reserve:reserves[i]];
        amount += [amounts[i++] unsignedLongLongValue];
    }
    
    //TODO: use up all UTXOs for all used addresses to avoid leaving funds in addresses whose public key is revealed
    //TODO: avoid combining addresses in a single transaction when possible to reduce information leakage
    //TODO: use up UTXOs received from any of the output scripts that this transaction sends funds to, to mitigate an
    //      attacker double spending and requesting a refund
    
    //当前区块高度
    uint64_t blockHeight = [BRPeerManager sharedInstance].lastBlockHeight;
//    NSArray *sortUtxos = [self.utxos sortedArrayUsingComparator:^NSComparisonResult(NSValue *obj1, NSValue *obj2) {
//        BRUTXO x, y;
//        [obj1 getValue:&x];
//        [obj2 getValue:&y];
//        BRTransaction *tx1 = self.allTx[uint256_obj(x.hash)];
//        BRTransaction *tx2 = self.allTx[uint256_obj(y.hash)];
//        return [tx1.outputAmounts[x.n] unsignedLongLongValue] > [tx2.outputAmounts[y.n] unsignedLongLongValue];
//    }];
    for(BRBalanceModel *model in self.balanceArray) {
        if([model.assetId isEqual:balanceModel.assetId]) {
            balanceModel = model;
            break;
        }
    }
    int z = 0;
    for (NSValue *output in self.utxos) {
        if(balanceModel.assetId.length != 0) {
            if(![balanceModel.utxos containsObject:output] && ![safeBalanceModel.utxos containsObject:output]) {
                continue;
            }
        } else {
            if(![balanceModel.utxos containsObject:output]) {
                continue;
            }
        }
        [output getValue:&o];
        tx = self.allTx[uint256_obj(o.hash)];
    
        if (!tx) continue;

        // TODO: 未验证的资产
//        if (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) continue;
        
        //TODO ZC ADD  判断解锁高度是否大于0
//        for (NSInteger i = 0; i < tx.outputUnlockHeights.count; i ++) {
//            uint64_t unlockheight = [tx.outputUnlockHeights[i] unsignedLongLongValue];
//            if (unlockheight > 0 && unlockheight > blockHeight) {
//                continue;
//            }
//        }
//        uint64_t unlockheight = [tx.outputUnlockHeights[o.n] unsignedLongLongValue];
//        if(unlockheight > 0 && unlockheight > blockHeight) {
//            continue;
//        }
        if ([self sposLockTxOut:tx index:o.n]) continue;
//        BRLog(@"============== %llu", [tx.outputAmounts[o.n] unsignedLongLongValue]);
        //for example the tx block height is 25, can only send after the chain block height is 31 for previous confirmations needed of 6
        if (isInstant && (tx.blockHeight - 1 > (self.blockHeight - [self isInstantConfirmHeight]))) continue;
        if (isInstant && [tx.outputAmounts[o.n] unsignedLongLongValue] >= 1000 * pow(10, ![BRSafeUtils isSafeTransaction:tx.outputReserves[o.n]] ? balanceModel.multiple : safeBalanceModel.multiple)) continue; // 修改即时交易条件 [tx.outputReserves[o.n] length] > 42
        if (balanceModel.assetId.length != 0 && (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX )) {
            NSNumber * l = 0;
            NSUInteger off = 0;
            NSData *d = [tx.outputReserves[o.n] dataAtOffset:off length:&l];
            if([d UInt16AtOffset:38] == 200) {
                continue;
            }
        }
    
        // TODO: 判断输入是否可用
        if ((tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) && ![self isMeTransactionSend:tx]) continue;
        
        // 封存dash
        if([tx.outputReserves[o.n] isEqual:[NSNull null]] && [BRPeerManager sharedInstance].lastBlockHeight + 1 >= DisableDash_TX_HEIGHT) {
            continue;
        }
        [transaction addInputHash:tx.txHash index:o.n script:tx.outputScripts[o.n]];
        
        if (transaction.size + 34 > TX_MAX_SIZE) { // transaction size-in-bytes too large
            NSUInteger txSize = 10 + self.utxos.count*148 + (scripts.count + 1)*34;
            
            // 资产矿工费扣除的是safe
            if(balanceModel.assetId.length != 0) {
                if(balanceModel.balance < amount || safeBalanceModel.balance < [self feeForTxSize:txSize + cpfpSize isInstant:isInstant inputCount:transaction.inputHashes.count]) {
                    return nil;
                }
            } else {
                if (balanceModel.balance < amount + [self feeForTxSize:txSize + cpfpSize isInstant:isInstant inputCount:transaction.inputHashes.count]) {
                    //BRLog(@"Insufficient funds. %llu is less than transaction amount:%llu", self.balance,
                    //amount + [self feeForTxSize:txSize + cpfpSize isInstant:isInstant inputCount:transaction.inputHashes.count]);
                    return nil;
                }
            }
            
            // check for sufficient total funds before building a smaller transaction
//            if (self.balance < amount + [self feeForTxSize:txSize + cpfpSize isInstant:isInstant inputCount:transaction.inputHashes.count]) {
//                //BRLog(@"Insufficient funds. %llu is less than transaction amount:%llu", self.balance,
//                //amount + [self feeForTxSize:txSize + cpfpSize isInstant:isInstant inputCount:transaction.inputHashes.count]);
//                return nil;
//            }
            
            uint64_t lastAmount = [amounts.lastObject unsignedLongLongValue];
            NSArray *newAmounts = [amounts subarrayWithRange:NSMakeRange(0, amounts.count - 1)],
            *newScripts = [scripts subarrayWithRange:NSMakeRange(0, scripts.count - 1)];
            
//            if (lastAmount > amount + feeAmount + self.minOutputAmount - balance) { // reduce final output amount
//                newAmounts = [newAmounts arrayByAddingObject:@(lastAmount - (amount + feeAmount - balance))];
//                newScripts = [newScripts arrayByAddingObject:scripts.lastObject];
//            }
            
            if(balanceModel.assetId.length != 0) {
                if (lastAmount > amount + self.minOutputAmount - balance && safeBalanceModel.balance > feeAmount) { // reduce final output amount
                    newAmounts = [newAmounts arrayByAddingObject:@(lastAmount - (amount - balance))];
                    newScripts = [newScripts arrayByAddingObject:scripts.lastObject];
                }
            } else {
                if (lastAmount > amount + feeAmount + self.minOutputAmount - balance) { // reduce final output amount
                    newAmounts = [newAmounts arrayByAddingObject:@(lastAmount - (amount + feeAmount - balance))];
                    newScripts = [newScripts arrayByAddingObject:scripts.lastObject];
                }
            }
            return  [self transactionForAmounts:newAmounts toOutputScripts:newScripts withUnlockHeights:unlockHeights withReserves:reserves withFee:fee isInstant:FALSE toShapeshiftAddress:nil BalanceModel:balanceModel];
        }
        if([balanceModel.utxos containsObject:output]) {
            balance += [tx.outputAmounts[o.n] unsignedLongLongValue];
        } else if ([safeBalanceModel.utxos containsObject:output]) {
            safeBalance += [tx.outputAmounts[o.n] unsignedLongLongValue];
        }
 
        // add up size of unconfirmed, non-change inputs for child-pays-for-parent fee calculation
        // don't include parent tx with more than 10 inputs or 10 outputs
        if (tx.blockHeight == TX_UNCONFIRMED && tx.inputHashes.count <= 10 && tx.outputAmounts.count <= 10 &&
            [self amountSentByTransaction:tx] == 0)  cpfpSize += tx.size;
        
        if (fee) {
            if(balanceModel.assetId.length != 0) {
                feeAmount = [self statisticalMinerfee:balance amount:amount safeBalance:safeBalance balanceModel:balanceModel transaction:transaction isInstant:isInstant];
//                if(balanceModel.balance > amount) feeAmount += safeBalanceModel.balance % 100;
            } else {
//                feeAmount = [self feeForTxSize:transaction.size + 34 + cpfpSize isInstant:isInstant inputCount:transaction.inputHashes.count]; // assume we will add a change output
                feeAmount = [self statisticalMinerfee:0 amount:0 safeBalance:balance balanceModel:balanceModel transaction:transaction isInstant:isInstant];
//                if (balanceModel.balance > amount) feeAmount += (balanceModel.balance - amount) % 100; // round off balance to 100 satoshi
            }
//            if (self.balance > amount) feeAmount += (self.balance - amount) % 100; // round off balance to 100 satoshi
        }
        
        if(balanceModel.assetId.length != 0) {
            // TODO: 待优化
            if(balance >= amount  && (safeBalance == feeAmount || safeBalance >= feeAmount + self.minOutputAmount)) break;
        } else {
            if (balance == amount + feeAmount || balance >= amount + feeAmount + self.minOutputAmount) break;
        }
    }
    
    transaction.isInstant = isInstant;
    if(balanceModel.assetId.length != 0) {
        if(balance < amount || feeAmount == 0 || safeBalance < feeAmount ) {
            return nil;
        }
    } else {
        if (isInstant && balance >= 1000 * (uint64_t)pow(10, 8)) {
            return nil;
        }
        if (amount == [self useBalance:safeBalanceModel.assetId] && balance == amount) {
            if(amount - feeAmount >= self.minOutputAmount) {
                return [self transactionForAmounts:@[@(amount - feeAmount)] toOutputScripts:scripts withUnlockHeights:unlockHeights withReserves:reserves withFee:fee isInstant:isInstant toShapeshiftAddress:nil BalanceModel:balanceModel];
            } else {
                return nil;
            }
        } else if (balance < amount + feeAmount) { // insufficient funds
            return nil;
        }
        
    }

    if (shapeshiftAddress) {
        [transaction addOutputShapeshiftAddress:shapeshiftAddress];
    }
    
    if(balanceModel.assetId.length != 0) {
        // TODO: 待修改
        if(balance - amount > 0) {
            balanceModel.common.amount = balance - amount;
            NSMutableData *reserveData = [NSMutableData dataWithData:[BRSafeUtils generateGiveChangeAssetData:balanceModel]];
            NSArray *publishIssueDataArray = [[BRCoreDataManager sharedInstance] entity:@"BRPublishIssueDataEnity" objectsMatching:[NSPredicate predicateWithFormat:@"assetId = %@", balanceModel.assetId]];
            if(publishIssueDataArray.count >= 1) {
                BRPublishIssueDataEnity *publishIssueDataEnity = publishIssueDataArray.firstObject;
                [transaction addOutputAddress:publishIssueDataEnity.assetAddress amount:balance - amount reserve:reserveData];
            } else {
                [transaction addOutputAddress:[self addressesWithGapLimit:2 internal:YES].firstObject amount:balance - amount reserve:reserveData];
            }
        }
        // 计算资产转让旷工费需要做修改 临时处理方案 字节数计算需要修改
//        long long sizeBtye = 0;
//        for(int i=0; i<transaction.outputReserves.count; i++) {
//            sizeBtye += [transaction.outputReserves[i] length];
//        }
//        sizeBtye += sizeof(uint64_t) * 3 + transaction.size + 34 + 4;
//        if(isInstant) {
//            feeAmount = (transaction.outputReserves.count + 1) * 100000;
//        } else {
//            feeAmount = sizeBtye > 1000 ? sizeBtye * 10 : 10000;
//        }
//        // 计算额外的矿工费 规则按文档执行
//        for(int i=0; i<transaction.outputReserves.count; i++) {
//            NSInteger reserveLength = [transaction.outputReserves[i] length];
//            if(reserveLength > 42) {
//                feeAmount += [BRSafeUtils feeReserve:reserveLength];
//            }
//        }
        if(feeAmount == 0 || feeAmount > safeBalance) {
            return nil;
        }
        if(safeBalance - feeAmount >= self.minOutputAmount) {
            [transaction addOutputAddress:[self addressesWithGapLimit:2 internal:YES].lastObject amount:safeBalance - feeAmount];
        }
        [transaction shuffleOutputOrder];
    } else {
        if (balance - (amount + feeAmount) >= self.minOutputAmount) {
            [transaction addOutputAddress:self.changeAddress amount:balance - (amount + feeAmount)];
            [transaction shuffleOutputOrder];
        }
    }
    
    return transaction;
}

// 转账矿工费计算
- (uint64_t) statisticalMinerfee:(uint64_t) balance amount:(uint64_t) amount safeBalance:(uint64_t) safeBalance balanceModel:(BRBalanceModel *) balanceModel transaction:(BRTransaction *) tx isInstant:(BOOL) isInstant {
    long long sizeBtye = tx.inputHashes.count * 20;
    uint64_t feeAmount = 0;
    if(balance - amount > 0) {
        balanceModel.common.amount = balance - amount;
        NSMutableData *reserveData = [NSMutableData dataWithData:[BRSafeUtils generateGiveChangeAssetData:balanceModel]];
        sizeBtye = reserveData.length + sizeof(uint64_t) + 34;
        feeAmount = [BRSafeUtils feeReserve:reserveData.length];
    }
    // 计算额外的矿工费 规则按文档执行
    for(int i=0; i<tx.outputReserves.count; i++) {
        NSInteger reserveLength = [tx.outputReserves[i] length];
        if(![BRSafeUtils isSafeTransaction:tx.outputReserves[i]]) { // reserveLength > 42
            feeAmount += [BRSafeUtils feeReserve:reserveLength];
        }
    }
    for(int i=0; i<tx.outputReserves.count; i++) {
        sizeBtye += [tx.outputReserves[i] length];
    }
    if(isInstant) {
        feeAmount = tx.inputHashes.count * 100000;
    } else {
        sizeBtye = sizeBtye + sizeof(uint64_t) + tx.size + 10;
        uint64_t sizeFee = (sizeBtye > 1000 ? sizeBtye * 10 : 10000);
        if(safeBalance - (sizeFee + feeAmount) == 0) {
            feeAmount = sizeFee + feeAmount;
        } else {
            sizeBtye = sizeBtye + TX_OUTPUT_SIZE + sizeof(uint64_t);
            sizeFee = (sizeBtye > 1000 ? sizeBtye * 10 : 10000);
            feeAmount = sizeFee + feeAmount;
        }
    }
    return feeAmount;
}

// 判断发行的资产是否被确认
- (BOOL) PublishAssetIsConfirm:(BRBalanceModel *) model {
    if (model.utxos.count == 1) {
        BRUTXO o;
        NSValue *output = model.utxos.firstObject;
        [output getValue:&o];
        BRTransaction *tx = self.allTx[uint256_obj(o.hash)];
        NSNumber * l = 0;
        NSUInteger off = 0;
        NSData *d = [tx.outputReserves[o.n] dataAtOffset:off length:&l];
        if([d UInt16AtOffset:38] == 200 && (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX)) {
            return YES;
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

// TODO: 构建发行资产交易
- (BRTransaction *) transactionForAssetAmount:(NSNumber *) assetAmount assetReserve:(NSData *) assetReserve candyAmount:(NSNumber *) candyAmount candyReserve:(NSData *) candyReserve safeAmount:(NSNumber *) safeAmount {
    
    uint64_t balance = 0, feeAmount = 0;
    BRTransaction *transaction = [BRTransaction new], *tx;
    NSUInteger i = 0, cpfpSize = 0;
    BRUTXO o;
    
    BRBalanceModel *safeBalanceModel;
    for(int i=0; i<self.balanceArray.count; i++) {
        safeBalanceModel = self.balanceArray[i];
        if(safeBalanceModel.assetId.length == 0) {
            break;
        }
    }
    
    //当前区块高度
    uint64_t blockHeight = [BRPeerManager sharedInstance].lastBlockHeight;
    
    for (NSValue *output in safeBalanceModel.utxos) {
        [output getValue:&o];
        tx = self.allTx[uint256_obj(o.hash)];
        if (!tx) continue;
        
        // TODO: 未验证的资产
//        if (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) continue;
        
        //TODO ZC ADD  判断解锁高度是否大于0
//        for (NSInteger i = 0; i < tx.outputUnlockHeights.count; i ++) {
//            uint64_t unlockheight = [tx.outputUnlockHeights[i] unsignedLongLongValue];
//            if (unlockheight > 0 && unlockheight > blockHeight) {
//                continue;
//            }
//        }
//        uint64_t unlockheight = [tx.outputUnlockHeights[o.n] unsignedLongLongValue];
//        if(unlockheight > 0 && unlockheight > blockHeight) {
//            continue;
//        }
        if ([self sposLockTxOut:tx index:o.n]) continue;
        // TODO: 判断输入是否可用
        if ((tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) && ![self isMeTransactionSend:tx]) continue;
        
        // 封存dash
        if([tx.outputReserves[o.n] isEqual:[NSNull null]] && [BRPeerManager sharedInstance].lastBlockHeight >= DisableDash_TX_HEIGHT) {
            continue;
        }
        [transaction addInputHash:tx.txHash index:o.n script:tx.outputScripts[o.n]];
        
        balance += [tx.outputAmounts[o.n] unsignedLongLongValue];
        
        // add up size of unconfirmed, non-change inputs for child-pays-for-parent fee calculation
        // don't include parent tx with more than 10 inputs or 10 outputs
        if (tx.blockHeight == TX_UNCONFIRMED && tx.inputHashes.count <= 10 && tx.outputAmounts.count <= 10 &&
            [self amountSentByTransaction:tx] == 0) cpfpSize += tx.size;
        
        feeAmount = [self publishAssetFee:balance safeAmount:[safeAmount unsignedLongLongValue] transaction:transaction assetReserve:assetReserve candyReserve:candyReserve candyAmount:[candyAmount unsignedLongLongValue]]; // assume we will add a change output
        
        // TODO: 待优化
        if (balance == [safeAmount unsignedLongLongValue] + feeAmount || balance >= [safeAmount unsignedLongLongValue] + feeAmount + self.minOutputAmount) break;
    }
    
    transaction.isInstant = NO; // 是否是即使支付
    if (balance < [safeAmount unsignedLongLongValue] + feeAmount) {
        return nil;
    }
    if(transaction.inputAddresses.count == 0) {
        return nil;
    }
    
    [transaction addOutputAddress:transaction.inputAddresses.firstObject amount:[assetAmount unsignedLongLongValue] reserve:assetReserve];
    [transaction addOutputAddress:BLACK_HOLE_ADDRESS amount:[safeAmount unsignedLongLongValue]];
    if([candyAmount unsignedLongLongValue] != 0) {
        [transaction addOutputAddress:CANDY_BLACK_HOLE_ADDRESS amount:[candyAmount unsignedLongLongValue] reserve:candyReserve];
    }
    
    // 计算资产转让旷工费需要做修改 临时处理方案 字节数计算需要修改
//    long long sizeBtye = 0;
//    for(int i=0; i<transaction.outputReserves.count; i++) {
//        sizeBtye += [transaction.outputReserves[i] length];
//    }
//
//    sizeBtye += sizeof(uint64_t) * (transaction.outputAddresses.count + 1) + transaction.size + 34 + 8;
//    feeAmount = sizeBtye > 1000 ? sizeBtye * 10 : 10000;
//    feeAmount += [BRSafeUtils feeReserve:assetReserve.length];
//    if(candyReserve.length != 0) {
//        feeAmount += [BRSafeUtils feeReserve:candyReserve.length];
//    }
    
    if(feeAmount == 0 || balance < [safeAmount unsignedLongLongValue] + feeAmount) {
        return nil;
    }
    
    if (balance - ([safeAmount unsignedLongLongValue] + feeAmount) >= self.minOutputAmount) {
        [transaction addOutputAddress:self.changeAddress amount:balance - ([safeAmount unsignedLongLongValue] + feeAmount)];
    }
    [transaction shuffleOutputOrder];
    return transaction;
}

// 发行资产矿工费计算
- (uint64_t) publishAssetFee:(uint64_t) balance safeAmount:(uint64_t) safeAmount transaction:(BRTransaction *) tx assetReserve:(NSData *) assetReserve candyReserve:(NSData *) candyReserve candyAmount:(uint64_t) candyAmount {
    long long sizeBtye = tx.inputHashes.count * 20;
    uint64_t feeAmount = 0;
    
    sizeBtye += [assetReserve length] + 5;
    feeAmount += [BRSafeUtils feeReserve:assetReserve.length];
 
    if(candyAmount != 0) {
        sizeBtye += [candyReserve length];
        feeAmount += [BRSafeUtils feeReserve:candyReserve.length];
        sizeBtye += [NSMutableData sizeOfVarInt:3] + TX_OUTPUT_SIZE * 3 + sizeof(uint64_t) * 3;
    } else {
        sizeBtye += [NSMutableData sizeOfVarInt:2] + TX_OUTPUT_SIZE * 2 + sizeof(uint64_t) * 2;
    }
    
    sizeBtye = sizeBtye + tx.size + 18;
    uint64_t sizeFee = (sizeBtye > 1000 ? sizeBtye * 10 : 10000);
    if(balance - (sizeFee + safeAmount + feeAmount) == 0) {
        feeAmount = sizeFee + feeAmount;
    } else {
        sizeBtye = sizeBtye + TX_OUTPUT_SIZE + sizeof(uint64_t);
        sizeFee = (sizeBtye > 1000 ? sizeBtye * 10 : 10000);
        feeAmount = sizeFee + feeAmount;
    }
    
    return feeAmount;
}

// TODO: 构建追加发行交易
- (BRTransaction *_Nullable) transactionForAssetAmount:(NSNumber *_Nullable) assetAmount assetReserve:(NSData *_Nullable) assetReserve assetId:(NSData *_Nonnull) assetId address:(NSString *_Nonnull) address {
    
    uint64_t balance = 0, feeAmount = 0;
    BRTransaction *transaction = [BRTransaction new], *tx;
    NSUInteger i = 0, cpfpSize = 0;
    BRUTXO o;
    
    BRBalanceModel *safeBalanceModel;
    for(int i=0; i<self.balanceArray.count; i++) {
        safeBalanceModel = self.balanceArray[i];
        if(safeBalanceModel.assetId.length == 0) {
            break;
        } else {
            safeBalanceModel = nil;
        }
    }
    
    [transaction addOutputAddress:address amount:[assetAmount unsignedLongLongValue] reserve:assetReserve];
    
    //当前区块高度
    uint64_t blockHeight = [BRPeerManager sharedInstance].lastBlockHeight;

    for (NSValue *output in safeBalanceModel.utxos) {
        [output getValue:&o];
        tx = self.allTx[uint256_obj(o.hash)];
        if (!tx) continue;

        // TODO: 未验证的资产
//        if (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) continue;
        
        //TODO ZC ADD  判断解锁高度是否大于0
//        for (NSInteger i = 0; i < tx.outputUnlockHeights.count; i ++) {
//            uint64_t unlockheight = [tx.outputUnlockHeights[i] unsignedLongLongValue];
//            if (unlockheight > 0 && unlockheight > blockHeight) {
//                continue;
//            }
//        }
//        uint64_t unlockheight = [tx.outputUnlockHeights[o.n] unsignedLongLongValue];
//        if(unlockheight > 0 && unlockheight > blockHeight) {
//            continue;
//        }
        if ([self sposLockTxOut:tx index:o.n]) continue;
        // 加判断是不是管理圆地址
        if(![address isEqualToString:[NSString addressWithScriptPubKey:tx.outputScripts[o.n]]]) continue;
        // TODO: 判断输入是否可用
        if ([tx.outputReserves[o.n] isEqual:[NSNull null]] && (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) && ![self isMeTransactionSend:tx]) continue;
        // 封存dash
        if([tx.outputReserves[o.n] isEqual:[NSNull null]] && [BRPeerManager sharedInstance].lastBlockHeight >= DisableDash_TX_HEIGHT) {
            continue;
        }
        [transaction addInputHash:tx.txHash index:o.n script:tx.outputScripts[o.n]];

        balance += [tx.outputAmounts[o.n] unsignedLongLongValue];

        // add up size of unconfirmed, non-change inputs for child-pays-for-parent fee calculation
        // don't include parent tx with more than 10 inputs or 10 outputs
//        if (tx.blockHeight == TX_UNCONFIRMED && tx.inputHashes.count <= 10 && tx.outputAmounts.count <= 10 &&
//            [self amountSentByTransaction:tx] == 0) cpfpSize += tx.size;

        feeAmount = [self addPublishAssetFee:balance assetReserve:assetReserve transaction:transaction]; // assume we will add a change output
        // TODO: 待优化
        if (balance ==  feeAmount || balance >= feeAmount + self.minOutputAmount) break;
    }
    
    transaction.isInstant = NO; // 是否是即使支付

    
    
    // 计算资产转让旷工费需要做修改 临时处理方案 字节数计算需要修改
//    long long sizeBtye = 0;
//    for(int i=0; i<transaction.outputReserves.count; i++) {
//        sizeBtye += [transaction.outputReserves[i] length];
//    }
//    sizeBtye += sizeof(uint64_t) * (transaction.outputAddresses.count + 1) + transaction.size + 34 + 8;
//    feeAmount = ((sizeBtye + 999 ) / 1000) * 10000;
//    feeAmount += [BRSafeUtils feeReserve:assetReserve.length];
    
    if(feeAmount == 0 || balance < feeAmount) {
        return nil;
    }
    
    if(balance - feeAmount >= self.minOutputAmount) {
        [transaction addOutputAddress:address amount:balance - feeAmount];
    }
    [transaction shuffleOutputOrder];
    return transaction;
}

// 追加发行矿工费计算
- (uint64_t) addPublishAssetFee:(uint64_t) balance assetReserve:(NSData *) assetReserve transaction:(BRTransaction *) transaction {
    uint64_t feeAmount = [BRSafeUtils feeReserve:assetReserve.length];
    long long sizeBtye = [assetReserve length] + transaction.inputHashes.count * 20;
    sizeBtye += sizeof(uint64_t) * transaction.outputAddresses.count + transaction.size + 16;
    uint64_t sizeFee = sizeBtye > 1000 ? sizeBtye * 10 : 10000;
    if(balance - (sizeFee + feeAmount) == 0) {
        feeAmount = sizeFee + feeAmount;
    } else {
        sizeBtye = sizeBtye + 34 + sizeof(uint64_t);
        sizeFee = sizeBtye > 1000 ? sizeBtye * 10 : 10000;
        feeAmount = sizeFee + feeAmount;
    }
    return feeAmount;
}

// TODO: 构建发放糖果交易
- (BRTransaction *_Nullable) transactionForCandyAmount:(BRPutCandyModel *)putCandyModel balanceModel:(BRBalanceModel *_Nullable) balanceModel {
    
    uint64_t balance = 0, safeBalance = 0, feeAmount = 0;
    BRTransaction *transaction = [BRTransaction new], *tx;
    NSUInteger i = 0, cpfpSize = 0;
    BRUTXO o;
    
    BRBalanceModel *safeBalanceModel;
    for(int i=0; i<self.balanceArray.count; i++) {
        safeBalanceModel = self.balanceArray[i];
        if(safeBalanceModel.assetId.length == 0) {
            break;
        } else {
            safeBalanceModel = nil;
        }
    }
    [transaction addOutputAddress:CANDY_BLACK_HOLE_ADDRESS amount:[putCandyModel getCandy] reserve:putCandyModel.toPutCandyData];
    //当前区块高度
    uint64_t blockHeight = [BRPeerManager sharedInstance].lastBlockHeight;
    
    for (NSValue *output in self.utxos) {
        if(![balanceModel.utxos containsObject:output] && ![safeBalanceModel.utxos containsObject:output]) {
            continue;
        }
     
        [output getValue:&o];
        tx = self.allTx[uint256_obj(o.hash)];
        
        if (!tx) continue;
        
        // TODO: 未验证的资产
//        if (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) continue;
        
        //TODO ZC ADD  判断解锁高度是否大于0
//        for (NSInteger i = 0; i < tx.outputUnlockHeights.count; i ++) {
//            uint64_t unlockheight = [tx.outputUnlockHeights[i] unsignedLongLongValue];
//            if (unlockheight > 0 && unlockheight > blockHeight) {
//                continue;
//            }
//        }
//        uint64_t unlockheight = [tx.outputUnlockHeights[o.n] unsignedLongLongValue];
//        if(unlockheight > 0 && unlockheight > blockHeight) {
//            continue;
//        }
        if ([self sposLockTxOut:tx index:o.n]) continue;

        if([balanceModel.utxos containsObject:output] && ![putCandyModel.address isEqualToString:tx.outputAddresses[o.n]]) continue;
        
        // TODO: 判断输入是否可用
        if ((tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) && ![self isMeTransactionSend:tx]) continue;
        
        // 封存dash
        if([tx.outputReserves[o.n] isEqual:[NSNull null]] && [BRPeerManager sharedInstance].lastBlockHeight >= DisableDash_TX_HEIGHT) {
            continue;
        }
        [transaction addInputHash:tx.txHash index:o.n script:tx.outputScripts[o.n]];
        

        if([balanceModel.utxos containsObject:output]) {
            balance += [tx.outputAmounts[o.n] unsignedLongLongValue];
        } else if ([safeBalanceModel.utxos containsObject:output]) {
            safeBalance += [tx.outputAmounts[o.n] unsignedLongLongValue];
        }
        
        // add up size of unconfirmed, non-change inputs for child-pays-for-parent fee calculation
        // don't include parent tx with more than 10 inputs or 10 outputs
//        if (tx.blockHeight == TX_UNCONFIRMED && tx.inputHashes.count <= 10 && tx.outputAmounts.count <= 10 &&
//            [self amountSentByTransaction:tx] == 0)  cpfpSize += tx.size;
        
        feeAmount = [self putCandyFee:balance amount:[putCandyModel getCandy] safeBalance:safeBalance balanceModel:balanceModel transaction:transaction]; // assume we will add a change output
//        if(balanceModel.balance > [putCandyModel getCandy]) feeAmount += safeBalanceModel.balance % 100;
        
        // TODO: 结束条件待优化
        if(balance >= [putCandyModel getCandy]  && (safeBalance == feeAmount || safeBalance >= feeAmount + self.minOutputAmount)) break;
    }

    if(balance <  [putCandyModel getCandy]) {
        return nil;
    }
    
    balanceModel.common.amount = balance - [putCandyModel getCandy];
    if(balance != [putCandyModel getCandy]) {
        [transaction addOutputAddress:putCandyModel.address amount:balance - [putCandyModel getCandy] reserve:[BRSafeUtils generateGiveChangeAssetData:balanceModel]];
    }
    // 计算资产转让旷工费需要做修改 临时处理方案 字节数计算需要修改
//    long long sizeBtye = 0;
//    for(int i=0; i<transaction.outputReserves.count; i++) {
//        sizeBtye += [transaction.outputReserves[i] length];
//    }
//    sizeBtye += sizeof(uint64_t) * (transaction.outputAddresses.count + 1) + transaction.size + 34 + 8;
//    feeAmount = ((sizeBtye + 999 ) / 1000) * 10000;
//    for(int i=0; i<transaction.outputReserves.count; i++) {
//        feeAmount += [BRSafeUtils feeReserve:[transaction.outputReserves[i] length]];
//    }

    if(feeAmount == 0 || safeBalance < feeAmount) {
        return nil;
    }
    
    if(safeBalance - feeAmount >= self.minOutputAmount)  {
        [transaction addOutputAddress:self.changeAddress amount:safeBalance - feeAmount];
    }
    [transaction shuffleOutputOrder];
    return transaction;
}

// 发放糖果矿工费计算
- (uint64_t) putCandyFee:(uint64_t)balance amount:(uint64_t) amount safeBalance:(uint64_t) safebalance balanceModel:(BRBalanceModel *) balanceModel transaction:(BRTransaction *) transaction {
    long long sizeBtye = transaction.inputHashes.count * 20;
    uint64_t feeAmount = 0;
    for(int i=0; i<transaction.outputReserves.count; i++) {
        sizeBtye += [transaction.outputReserves[i] length];
        feeAmount += [BRSafeUtils feeReserve:[transaction.outputReserves[i] length]];
    }
    if(balance - amount > 0) {
        balanceModel.common.amount = balance - amount;
        NSMutableData *reserveData = [NSMutableData dataWithData:[BRSafeUtils generateGiveChangeAssetData:balanceModel]];
        sizeBtye += reserveData.length + sizeof(uint64_t) + 34;
        feeAmount += [BRSafeUtils feeReserve:reserveData.length];
    }
    sizeBtye = sizeBtye + sizeof(uint64_t) * transaction.outputAddresses.count + transaction.size + 16;
    uint64_t sizeFee = (sizeBtye > 1000 ? sizeBtye * 10 : 10000);
    if(safebalance - (sizeFee + feeAmount) == 0) {
        feeAmount = sizeFee + feeAmount;
    } else {
        sizeBtye = sizeBtye + TX_OUTPUT_SIZE + sizeof(uint64_t);
        sizeFee = (sizeBtye > 1000 ? sizeBtye * 10 : 10000);
        feeAmount = sizeFee + feeAmount;
    }
   
    return feeAmount;
}

// 获取发放糖果旷工费
- (uint64_t) getFeeAmountTransactionForCandyAmount:(BRPutCandyModel *)putCandyModel balanceModel:(BRBalanceModel *_Nullable) balanceModel {
    
    uint64_t balance = 0, safeBalance = 0, feeAmount = 0;
    BRTransaction *transaction = [BRTransaction new], *tx;
    NSUInteger i = 0, cpfpSize = 0;
    BRUTXO o;
    
    BRBalanceModel *safeBalanceModel;
    for(int i=0; i<self.balanceArray.count; i++) {
        safeBalanceModel = self.balanceArray[i];
        if(safeBalanceModel.assetId.length == 0) {
            break;
        } else {
            safeBalanceModel = nil;
        }
    }
    [transaction addOutputAddress:CANDY_BLACK_HOLE_ADDRESS amount:[putCandyModel getCandy] reserve:putCandyModel.toPutCandyData];
    //当前区块高度
    uint64_t blockHeight = [BRPeerManager sharedInstance].lastBlockHeight;
    
    for (NSValue *output in self.utxos) {
        if(![balanceModel.utxos containsObject:output] && ![safeBalanceModel.utxos containsObject:output]) {
            continue;
        }
        
        [output getValue:&o];
        tx = self.allTx[uint256_obj(o.hash)];
        
        if (!tx) continue;
        
        // TODO: 未验证的资产
        //        if (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) continue;
        
        //TODO ZC ADD  判断解锁高度是否大于0
        //        for (NSInteger i = 0; i < tx.outputUnlockHeights.count; i ++) {
        //            uint64_t unlockheight = [tx.outputUnlockHeights[i] unsignedLongLongValue];
        //            if (unlockheight > 0 && unlockheight > blockHeight) {
        //                continue;
        //            }
        //        }
//        uint64_t unlockheight = [tx.outputUnlockHeights[o.n] unsignedLongLongValue];
//        if(unlockheight > 0 && unlockheight > blockHeight) {
//            continue;
//        }
        if ([self sposLockTxOut:tx index:o.n]) continue;
        
        if([balanceModel.utxos containsObject:output] && ![putCandyModel.address isEqualToString:tx.outputAddresses[o.n]]) continue;
        
        // TODO: 判断输入是否可用
        if ((tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) && ![self isMeTransactionSend:tx]) continue;
        [transaction addInputHash:tx.txHash index:o.n script:tx.outputScripts[o.n]];
        
        
        if([balanceModel.utxos containsObject:output]) {
            balance += [tx.outputAmounts[o.n] unsignedLongLongValue];
        } else if ([safeBalanceModel.utxos containsObject:output]) {
            safeBalance += [tx.outputAmounts[o.n] unsignedLongLongValue];
        }
        
        // add up size of unconfirmed, non-change inputs for child-pays-for-parent fee calculation
        // don't include parent tx with more than 10 inputs or 10 outputs
        //        if (tx.blockHeight == TX_UNCONFIRMED && tx.inputHashes.count <= 10 && tx.outputAmounts.count <= 10 &&
        //            [self amountSentByTransaction:tx] == 0)  cpfpSize += tx.size;
        
        feeAmount = [self putCandyFee:balance amount:[putCandyModel getCandy] safeBalance:safeBalance balanceModel:balanceModel transaction:transaction]; // assume we will add a change output
        //        if(balanceModel.balance > [putCandyModel getCandy]) feeAmount += safeBalanceModel.balance % 100;
        
        // TODO: 结束条件待优化
        if(balance >= [putCandyModel getCandy]  && (safeBalance == feeAmount || safeBalance >= feeAmount + self.minOutputAmount)) break;
    }
    
    balanceModel.common.amount = balance - [putCandyModel getCandy];
    if(balance != [putCandyModel getCandy]) {
        [transaction addOutputAddress:putCandyModel.address amount:balance - [putCandyModel getCandy] reserve:[BRSafeUtils generateGiveChangeAssetData:balanceModel]];
    }
    if(feeAmount == 0) feeAmount = [self putCandyFee:balance amount:[putCandyModel getCandy] safeBalance:safeBalance balanceModel:balanceModel transaction:transaction];
    return feeAmount;
}

// TODO: 构建领取糖果BRTransaction
- (BRTransaction *_Nullable) transactionForSafeTotalAmount:(uint64_t) totalAmount address:(NSArray *_Nullable) addressArray putCandyEntity:(BRPutCandyEntity *_Nonnull) putCandyEntity{
    uint64_t balance = 0, feeAmount = 0;
    BRTransaction *transaction = [BRTransaction new], *tx;
    NSUInteger i = 0, cpfpSize = 0;
    BRUTXO o;
    
    BRBalanceModel *safeBalanceModel;
    for(int i=0; i<self.balanceArray.count; i++) {
        safeBalanceModel = self.balanceArray[i];
        if(safeBalanceModel.assetId.length == 0) {
            break;
        } else {
            safeBalanceModel = nil;
        }
    }
    
    for(BRBlockAvailableSafeEntity *blockAvailableSafeEntity in addressArray) {
        uint64_t candyAmount = (uint64_t)([blockAvailableSafeEntity.amount unsignedLongLongValue] * 1.0 / totalAmount * [putCandyEntity.candyAmount unsignedLongLongValue]);
        if(candyAmount == 0 || candyAmount < (0.0001 * pow(10, putCandyEntity.decimals.integerValue))) continue;
        [transaction addOutputAddress:blockAvailableSafeEntity.address amount:candyAmount reserve:[BRSafeUtils generateGetCandy:candyAmount assetId:putCandyEntity.assetId remarks:[putCandyEntity.remarks dataUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    if(transaction.outputAmounts.count == 0) {
        return nil;
    }

    //当前区块高度
    uint64_t blockHeight = [BRPeerManager sharedInstance].lastBlockHeight;
//    NSMutableOrderedSet *safeUtxos = [self getAvailableSafePublishCandy];
    for (NSValue *output in safeBalanceModel.utxos) {
        
        [output getValue:&o];
        tx = self.allTx[uint256_obj(o.hash)];
        
        if (!tx) continue;
        
        // TODO: 未验证的资产
//        if (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) continue;
        
        //TODO ZC ADD  判断解锁高度是否大于0
//        for (NSInteger i = 0; i < tx.outputUnlockHeights.count; i ++) {
//            uint64_t unlockheight = [tx.outputUnlockHeights[i] unsignedLongLongValue];
//            if (unlockheight > 0 && unlockheight > blockHeight) {
//                continue;
//            }
//        }
//        uint64_t unlockheight = [tx.outputUnlockHeights[o.n] unsignedLongLongValue];
//        if(unlockheight > 0 && unlockheight > blockHeight) {
//            continue;
//        }
        if ([self sposLockTxOut:tx index:o.n]) continue;

        // TODO: 判断输入是否可用
        if ((tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) && ![self isMeTransactionSend:tx]) continue;
        
        // 封存dash
        if([tx.outputReserves[o.n] isEqual:[NSNull null]] && [BRPeerManager sharedInstance].lastBlockHeight >= DisableDash_TX_HEIGHT) {
            continue;
        }
        [transaction addInputHash:tx.txHash index:o.n script:tx.outputScripts[o.n]];
        
        balance += [tx.outputAmounts[o.n] unsignedLongLongValue];
        
        feeAmount = [self getCandyFee:balance transaction:transaction];
        
        // TODO: 结束条件待优化
        if(balance == feeAmount || balance >= feeAmount + self.minOutputAmount) break;
    }
    // 黑洞地址必须放在输入的最后一个 不可修改
    [transaction addInputHash:[putCandyEntity.txId hashAtOffset:0] index:[putCandyEntity.index integerValue] script:putCandyEntity.outputScript];

    // 计算资产转让旷工费需要做修改 临时处理方案 字节数计算需要修改
//    long long sizeBtye = 0;
//    for(int i=0; i<transaction.outputReserves.count; i++) {
//        sizeBtye += [transaction.outputReserves[i] length];
//    }
//    sizeBtye += sizeof(uint64_t) * (transaction.outputAddresses.count + 1) + transaction.size + 34 + 8;
//    feeAmount = ((sizeBtye + 999 ) / 1000) * 10000;
//    for(int i=0; i<transaction.outputReserves.count; i++) {
//        feeAmount += [BRSafeUtils feeReserve:[transaction.outputReserves[i] length]];
//    }
  
    if(feeAmount == 0 || balance < feeAmount) {
        return nil;
    }
    
    if(balance - feeAmount >= self.minOutputAmount) {
        [transaction addOutputAddress:self.changeAddress amount:balance - feeAmount];
    }
    
    [transaction shuffleOutputOrder];
    
    return transaction;
}

// 领取糖果矿工费计算
- (uint64_t) getCandyFee:(uint64_t) balance transaction:(BRTransaction *) transaction  {
    long long sizeBtye = transaction.inputHashes.count * 20;
    uint64_t feeAmount = 0;
    for(int i=0; i<transaction.outputReserves.count; i++) {
        sizeBtye += [transaction.outputReserves[i] length];
        feeAmount += [BRSafeUtils feeReserve:[transaction.outputReserves[i] length]];
    }
    sizeBtye = sizeBtye + sizeof(uint64_t) * transaction.outputAddresses.count + TX_INPUT_SIZE + transaction.size + 16;
    uint64_t sizeFee = sizeBtye > 1000 ? sizeBtye * 10 : 10000;
    if(balance - (feeAmount + sizeFee) == 0) {
        feeAmount = feeAmount + sizeFee;
    } else {
        sizeBtye = sizeBtye + TX_OUTPUT_SIZE + sizeof(uint64_t);
        sizeFee = sizeBtye > 1000 ? sizeBtye * 10 : 10000;
        feeAmount = feeAmount + sizeFee;
    }

    return feeAmount;
}

//获取领取糖果交易费
- (uint64_t) getFeeAmountTransactionForSafeTotalAmount:(uint64_t) totalAmount address:(NSArray *_Nullable) addressArray putCandyEntity:(BRPutCandyEntity *_Nonnull) putCandyEntity{
    uint64_t balance = 0, feeAmount = 0;
    BRTransaction *transaction = [BRTransaction new], *tx;
    NSUInteger i = 0, cpfpSize = 0;
    BRUTXO o;
    
    BRBalanceModel *safeBalanceModel;
    for(int i=0; i<self.balanceArray.count; i++) {
        safeBalanceModel = self.balanceArray[i];
        if(safeBalanceModel.assetId.length == 0) {
            break;
        } else {
            safeBalanceModel = nil;
        }
    }
    
    for(BRBlockAvailableSafeEntity *blockAvailableSafeEntity in addressArray) {
        uint64_t candyAmount = (uint64_t)([blockAvailableSafeEntity.amount unsignedLongLongValue] * 1.0 / totalAmount * [putCandyEntity.candyAmount unsignedLongLongValue]);
        if(candyAmount == 0 || candyAmount < (0.0001 * pow(10, putCandyEntity.decimals.integerValue))) continue;
        [transaction addOutputAddress:blockAvailableSafeEntity.address amount:candyAmount reserve:[BRSafeUtils generateGetCandy:candyAmount assetId:putCandyEntity.assetId remarks:[putCandyEntity.remarks dataUsingEncoding:NSUTF8StringEncoding]]];
    }
    
    if(transaction.outputAmounts.count == 0) {
        return 0;
    }
    
    //当前区块高度
    uint64_t blockHeight = [BRPeerManager sharedInstance].lastBlockHeight;
    //    NSMutableOrderedSet *safeUtxos = [self getAvailableSafePublishCandy];
    for (NSValue *output in safeBalanceModel.utxos) {
        
        [output getValue:&o];
        tx = self.allTx[uint256_obj(o.hash)];
        
        if (!tx) continue;
        
        // TODO: 未验证的资产
        //        if (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) continue;
        
        //TODO ZC ADD  判断解锁高度是否大于0
        //        for (NSInteger i = 0; i < tx.outputUnlockHeights.count; i ++) {
        //            uint64_t unlockheight = [tx.outputUnlockHeights[i] unsignedLongLongValue];
        //            if (unlockheight > 0 && unlockheight > blockHeight) {
        //                continue;
        //            }
        //        }
//        uint64_t unlockheight = [tx.outputUnlockHeights[o.n] unsignedLongLongValue];
//        if(unlockheight > 0 && unlockheight > blockHeight) {
//            continue;
//        }
        if ([self sposLockTxOut:tx index:o.n]) continue;
        
        // TODO: 判断输入是否可用
        if ((tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) && ![self isMeTransactionSend:tx]) continue;
        [transaction addInputHash:tx.txHash index:o.n script:tx.outputScripts[o.n]];
        
        balance += [tx.outputAmounts[o.n] unsignedLongLongValue];
        
        feeAmount = [self getCandyFee:balance transaction:transaction];
        // TODO: 结束条件待优化
        if(balance == feeAmount || balance >= feeAmount + self.minOutputAmount) break;
    }
    // 黑洞地址必须放在输入的最后一个 不可修改
    [transaction addInputHash:[putCandyEntity.txId hashAtOffset:0] index:[putCandyEntity.index integerValue] script:putCandyEntity.outputScript];
    
    if(feeAmount == 0)  feeAmount = [self getCandyFee:balance transaction:transaction];
    return feeAmount;
}
// 计算当前可用safe
- (NSMutableOrderedSet *) getAvailableSafePublishCandy {
    uint64_t balance = 0;
    NSMutableOrderedSet *utxos = [NSMutableOrderedSet orderedSet];
    NSMutableSet *spentOutputs = [NSMutableSet set], *invalidTx = [NSMutableSet set], *pendingTx = [NSMutableSet set];
    NSMutableArray *balanceHistory = [NSMutableArray array];
    uint32_t now = [NSDate timeIntervalSinceReferenceDate] + NSTimeIntervalSince1970;
    for (BRTransaction *tx in [self.transactions reverseObjectEnumerator]) {
        @autoreleasepool {
            NSMutableSet *spent = [NSMutableSet set];
            NSSet *inputs;
            uint32_t i = 0, n = 0;
            BOOL pending = NO;
            UInt256 h;
            
            for (NSValue *hash in tx.inputHashes) {
                n = [tx.inputIndexes[i++] unsignedIntValue];
                [hash getValue:&h];
                [spent addObject:brutxo_obj(((BRUTXO) { h, n }))];
            }
            
            inputs = [NSSet setWithArray:tx.inputHashes];
            
            // check if any inputs are invalid or already spent
            if (tx.blockHeight == TX_UNCONFIRMED &&
                ([spent intersectsSet:spentOutputs] || [inputs intersectsSet:invalidTx])) {
                [invalidTx addObject:uint256_obj(tx.txHash)];
                [balanceHistory insertObject:@(balance) atIndex:0];
                continue;
            }
            
            [spentOutputs unionSet:spent]; // add inputs to spent output set
            n = 0;
            
            // check if any inputs are pending
            if (tx.blockHeight == TX_UNCONFIRMED) {
                if (tx.size > TX_MAX_SIZE) { BRLog(@"1 ============= pending"); pending = YES;} // check transaction size is under TX_MAX_SIZE
                
                for (NSNumber *sequence in tx.inputSequences) {
                    if (sequence.unsignedIntValue < UINT32_MAX - 1) { BRLog(@"2 ============= pending"); pending = YES;} // check for replace-by-fee
                    if (sequence.unsignedIntValue < UINT32_MAX && tx.lockTime < TX_MAX_LOCK_HEIGHT &&
                        tx.lockTime > self.bestBlockHeight + 1)  { BRLog(@"3 ============= pending %u %u", tx.lockTime, self.bestBlockHeight + 1); pending = YES; }// future lockTime
                    if (sequence.unsignedIntValue < UINT32_MAX && tx.lockTime >= TX_MAX_LOCK_HEIGHT &&
                        tx.lockTime > now){ BRLog(@"4 ============= pending %u %u", tx.lockTime, now); pending = YES;} // future locktime
                }
                
                for (NSNumber *amount in tx.outputAmounts) { // check that no outputs are dust
                    if (amount.unsignedLongLongValue < TX_MIN_OUTPUT_AMOUNT) { BRLog(@"5 ============= pending %u %llu %llu", tx.lockTime, amount.unsignedLongLongValue, TX_MIN_OUTPUT_AMOUNT); pending = YES;}
                }
                
                //TODO ZCZCZC
                if (pending || [inputs intersectsSet:pendingTx]) {
                    [pendingTx addObject:uint256_obj(tx.txHash)];
                    [balanceHistory insertObject:@(balance) atIndex:0];
                    BRLog(@"送中的交易不计算 2 ===== %@", uint256_obj(tx.txHash));
                    continue;
                }
            }
            
            //TODO: don't add outputs below TX_MIN_OUTPUT_AMOUNT
            //TODO: don't add coin generation outputs < 100 blocks deep
            //NOTE: balance/UTXOs will then need to be recalculated when last block changes
            for (NSString *address in tx.outputAddresses) { // add outputs to UTXO set
                if ([self containsAddress:address]) {
                    if([tx.outputReserves[n] isEqual:[NSNull null]]) continue;
                    if([BRSafeUtils isSafeTransaction:tx.outputReserves[n]]) { // [tx.outputReserves[n] length] < 42
                        balance += [tx.outputAmounts[n] unsignedLongLongValue];
                        [utxos addObject:brutxo_obj(((BRUTXO) { tx.txHash, n }))];
                    }
                }
                n++;
            }
            
            // transaction ordering is not guaranteed, so check the entire UTXO set against the entire spent output set
            [spent setSet:utxos.set];
            [spent intersectSet:spentOutputs];
            
            for (NSValue *output in spent) { // remove any spent outputs from UTXO set
                BRTransaction *transaction;
                BRUTXO o;
                
                [output getValue:&o];
                transaction = self.allTx[uint256_obj(o.hash)];
                
                if([transaction.outputReserves[o.n] isEqual:[NSNull null]]) continue;
                if([BRSafeUtils isSafeTransaction:transaction.outputReserves[o.n]]){ // [transaction.outputReserves[o.n] length] < 42
                    [utxos removeObject:output];
                }
            }
        }
    }
    BRLog(@"结束计算交易的总数 %ld", self.transactions.count);
    return utxos;
}

// TODO: 返回发行资产管理员地址上的金额
- (uint64_t) assetManagerAddressAmount:(NSData *_Nullable) assetId address:(NSString *_Nonnull) address {
    uint64_t amount = 0;
    
    for(int i=0; i<self.balanceArray.count; i++) {
        BRBalanceModel *balanceModel = self.balanceArray[i];
        if([balanceModel.assetId isEqual:assetId]) {
            BRUTXO o;
            for(NSValue *output in balanceModel.utxos) {
                [output getValue:&o];
                BRTransaction *tx = self.allTx[uint256_obj(o.hash)];
//                if (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) continue;
                if([address isEqualToString:tx.outputAddresses[o.n]]) {
                    amount += [tx.outputAmounts[o.n] unsignedLongLongValue];
                }
            }
            break;
        }
    }
    
    return amount;
}

// sign any inputs in the given transaction that can be signed using private keys from the wallet
- (void)signTransaction:(BRTransaction *)transaction withPrompt:(NSString *)authprompt completion:(TransactionValidityCompletionBlock)completion;
{
    int64_t amount = [self amountSentByTransaction:transaction] - [self amountReceivedFromTransaction:transaction];

    NSMutableOrderedSet *externalIndexesPurpose44 = [NSMutableOrderedSet orderedSet],
    *internalIndexesPurpose44 = [NSMutableOrderedSet orderedSet],
    *externalIndexesNoPurpose = [NSMutableOrderedSet orderedSet],
    *internalIndexesNoPurpose = [NSMutableOrderedSet orderedSet];
    
    for (NSString *addr in transaction.inputAddresses) {
        NSInteger index = [self.internalBIP44Addresses indexOfObject:addr];
        if (index != NSNotFound) {
            [internalIndexesPurpose44 addObject:@(index)];
            continue;
        }
        index = [self.externalBIP44Addresses indexOfObject:addr];
        if (index != NSNotFound) {
            [externalIndexesPurpose44 addObject:@(index)];
            continue;
        }
        index = [self.internalBIP32Addresses indexOfObject:addr];
        if (index != NSNotFound) {
            [internalIndexesNoPurpose addObject:@(index)];
            continue;
        }
        index = [self.externalBIP32Addresses indexOfObject:addr];
        if (index != NSNotFound) {
            [externalIndexesNoPurpose addObject:@(index)];
            continue;
        }
    }
    
    @autoreleasepool { // @autoreleasepool ensures sensitive data will be dealocated immediately
        self.seed(authprompt, (amount > 0) ? amount : 0,^void (NSData * _Nullable seed) {
            if (! seed) {
                if (completion) completion(YES);
            } else {
                NSMutableArray *privkeys = [NSMutableArray array];
                [privkeys addObjectsFromArray:[self.sequence privateKeys:externalIndexesPurpose44.array purpose:BIP44_PURPOSE internal:NO fromSeed:seed]];
                [privkeys addObjectsFromArray:[self.sequence privateKeys:internalIndexesPurpose44.array purpose:BIP44_PURPOSE internal:YES fromSeed:seed]];
                [privkeys addObjectsFromArray:[self.sequence privateKeys:externalIndexesNoPurpose.array purpose:BIP32_PURPOSE internal:NO fromSeed:seed]];
                [privkeys addObjectsFromArray:[self.sequence privateKeys:internalIndexesNoPurpose.array purpose:BIP32_PURPOSE internal:YES fromSeed:seed]];
                BOOL signedSuccessfully = [transaction signWithPrivateKeys:privkeys];
                if (completion) completion(signedSuccessfully);
            }
        });
    }
}

// TODO: 添加提交交易方法
// sign any inputs in the given transaction that can be signed using private keys from the wallet
- (void)signTransaction:(BRTransaction *)transaction withPrompt:(NSString *)authprompt amount:(uint64_t) amount completion:(TransactionValidityCompletionBlock)completion;
{
    NSMutableOrderedSet *externalIndexesPurpose44 = [NSMutableOrderedSet orderedSet],
    *internalIndexesPurpose44 = [NSMutableOrderedSet orderedSet],
    *externalIndexesNoPurpose = [NSMutableOrderedSet orderedSet],
    *internalIndexesNoPurpose = [NSMutableOrderedSet orderedSet];
    
    for (NSString *addr in transaction.inputAddresses) {
        NSInteger index = [self.internalBIP44Addresses indexOfObject:addr];
        if (index != NSNotFound) {
            [internalIndexesPurpose44 addObject:@(index)];
            continue;
        }
        index = [self.externalBIP44Addresses indexOfObject:addr];
        if (index != NSNotFound) {
            [externalIndexesPurpose44 addObject:@(index)];
            continue;
        }
        index = [self.internalBIP32Addresses indexOfObject:addr];
        if (index != NSNotFound) {
            [internalIndexesNoPurpose addObject:@(index)];
            continue;
        }
        index = [self.externalBIP32Addresses indexOfObject:addr];
        if (index != NSNotFound) {
            [externalIndexesNoPurpose addObject:@(index)];
            continue;
        }
    }
    
    @autoreleasepool { // @autoreleasepool ensures sensitive data will be dealocated immediately
        self.seed(authprompt, (amount > 0) ? amount : 0,^void (NSData * _Nullable seed) {
            if (! seed) {
                if (completion) completion(YES);
            } else {
                NSMutableArray *privkeys = [NSMutableArray array];
                [privkeys addObjectsFromArray:[self.sequence privateKeys:externalIndexesPurpose44.array purpose:BIP44_PURPOSE internal:NO fromSeed:seed]];
                [privkeys addObjectsFromArray:[self.sequence privateKeys:internalIndexesPurpose44.array purpose:BIP44_PURPOSE internal:YES fromSeed:seed]];
                [privkeys addObjectsFromArray:[self.sequence privateKeys:externalIndexesNoPurpose.array purpose:BIP32_PURPOSE internal:NO fromSeed:seed]];
                [privkeys addObjectsFromArray:[self.sequence privateKeys:internalIndexesNoPurpose.array purpose:BIP32_PURPOSE internal:YES fromSeed:seed]];
                BOOL signedSuccessfully = [transaction signWithPrivateKeys:privkeys];
                if (completion) completion(signedSuccessfully);
            }
        });
    }
}

// sign any inputs in the given transaction that can be signed using private keys from the wallet
- (void)signBIP32Transaction:(BRTransaction *)transaction withPrompt:(NSString *)authprompt completion:(TransactionValidityCompletionBlock)completion;
{
    int64_t amount = [self amountSentByTransaction:transaction] - [self amountReceivedFromTransaction:transaction];
    NSMutableOrderedSet *externalIndexes = [NSMutableOrderedSet orderedSet],
    *internalIndexes = [NSMutableOrderedSet orderedSet];
    
    for (NSString *addr in transaction.inputAddresses) {
        [internalIndexes addObject:@([self.internalBIP32Addresses indexOfObject:addr])];
        [externalIndexes addObject:@([self.externalBIP32Addresses indexOfObject:addr])];
    }
    
    [internalIndexes removeObject:@(NSNotFound)];
    [externalIndexes removeObject:@(NSNotFound)];
    
    @autoreleasepool { // @autoreleasepool ensures sensitive data will be dealocated immediately
        self.seed(authprompt, (amount > 0) ? amount : 0,^void (NSData * _Nullable seed) {
            if (! seed) {
                completion(YES);
            } else {
                NSMutableArray *privkeys = [NSMutableArray array];
                [privkeys addObjectsFromArray:[self.sequence privateKeys:externalIndexes.array purpose:BIP32_PURPOSE internal:NO fromSeed:seed]];
                [privkeys addObjectsFromArray:[self.sequence privateKeys:internalIndexes.array purpose:BIP32_PURPOSE internal:YES fromSeed:seed]];
                
                BOOL signedSuccessfully = [transaction signWithPrivateKeys:privkeys];
                completion(signedSuccessfully);
            }
        });
    }
}

// true if the given transaction is associated with the wallet (even if it hasn't been registered), false otherwise
- (BOOL)containsTransaction:(BRTransaction *)transaction
{
    if ([[NSSet setWithArray:transaction.outputAddresses] intersectsSet:self.allAddresses]) return YES;
    
    NSInteger i = 0;
    
    for (NSValue *txHash in transaction.inputHashes) {
        BRTransaction *tx = self.allTx[txHash];
        uint32_t n = [transaction.inputIndexes[i++] unsignedIntValue];
        
        if (n < tx.outputAddresses.count && [self containsAddress:tx.outputAddresses[n]]) return YES;
    }
    
    return NO;
}

// records the transaction in the wallet, or returns false if it isn't associated with the wallet
- (BOOL)registerTransaction:(BRTransaction *)transaction
{
    UInt256 txHash = transaction.txHash;
    NSValue *hash = uint256_obj(txHash);
    
    if (uint256_is_zero(txHash)) return NO;
    
    if (! [self containsTransaction:transaction]) {
        if (transaction.blockHeight == TX_UNCONFIRMED) self.allTx[hash] = transaction;
        return NO;
    }
    
    if (self.allTx[hash] != nil) return YES;
    
    //TODO: handle tx replacement with input sequence numbers (now replacements appear invalid until confirmation)
    BRLog(@"[BRWallet] received unseen transaction %@", transaction);

    self.allTx[hash] = transaction;
    [self.transactions insertObject:transaction atIndex:0];
    [self.usedAddresses addObjectsFromArray:transaction.inputAddresses];
    [self.usedAddresses addObjectsFromArray:transaction.outputAddresses];
    [self updateBalance];
    
    // when a wallet address is used in a transaction, generate a new address to replace it
    [self addressesWithGapLimit:SEQUENCE_GAP_LIMIT_EXTERNAL internal:NO];
    [self addressesWithGapLimit:SEQUENCE_GAP_LIMIT_INTERNAL internal:YES];
    
    [self.moc performBlock:^{ // add the transaction to core data
        if ([BRTransactionEntity countObjectsMatching:@"txHash == %@",
             [NSData dataWithBytes:&txHash length:sizeof(txHash)]] == 0) {
            [[BRTransactionEntity managedObject] setAttributesFromTx:transaction];
        }
        
        if ([BRTxMetadataEntity countObjectsMatching:@"txHash == %@ && type == %d",
             [NSData dataWithBytes:&txHash length:sizeof(txHash)], TX_MDTYPE_MSG] == 0) {
            [[BRTxMetadataEntity managedObject] setAttributesFromTx:transaction];
        }
    }];
    
    return YES;
}

// removes a transaction from the wallet along with any transactions that depend on its outputs
- (void)removeTransaction:(UInt256)txHash
{
    BRTransaction *transaction = self.allTx[uint256_obj(txHash)];
    NSMutableSet *hashes = [NSMutableSet set];
    
    for (BRTransaction *tx in self.transactions) { // remove dependent transactions
        if (tx.blockHeight < transaction.blockHeight) break;
        
        if (! uint256_eq(txHash, tx.txHash) && [tx.inputHashes containsObject:uint256_obj(txHash)]) {
            [hashes addObject:uint256_obj(tx.txHash)];
        }
    }
    
    for (NSValue *hash in hashes) {
        UInt256 h;
        
        [hash getValue:&h];
        [self removeTransaction:h];
    }
    
    [self.allTx removeObjectForKey:uint256_obj(txHash)];
    if (transaction) [self.transactions removeObject:transaction];
    [self updateBalance];
    
    [self.moc performBlock:^{ // remove transaction from core data
        [BRTransactionEntity deleteObjects:[BRTransactionEntity objectsMatching:@"txHash == %@",
                                            [NSData dataWithBytes:&txHash length:sizeof(txHash)]]];
        [BRTxMetadataEntity deleteObjects:[BRTxMetadataEntity objectsMatching:@"txHash == %@",
                                           [NSData dataWithBytes:&txHash length:sizeof(txHash)]]];
    }];
}

// returns the transaction with the given hash if it's been registered in the wallet (might also return non-registered)
- (BRTransaction *)transactionForHash:(UInt256)txHash
{
    return self.allTx[uint256_obj(txHash)];
}

// true if no previous wallet transactions spend any of the given transaction's inputs, and no input tx is invalid
- (BOOL)transactionIsValid:(BRTransaction *)transaction
{
    //TODO: XXX attempted double spends should cause conflicted tx to remain unverified until they're confirmed
    //TODO: XXX verify signatures for spends

    if (transaction.blockHeight != TX_UNCONFIRMED) return YES;
    
    if (self.allTx[uint256_obj(transaction.txHash)] != nil) {
        return ([self.invalidTx containsObject:uint256_obj(transaction.txHash)]) ? NO : YES;
    }
    
    uint32_t i = 0;
    
    for (NSValue *hash in transaction.inputHashes) {
        BRTransaction *tx = self.allTx[hash];
        uint32_t n = [transaction.inputIndexes[i++] unsignedIntValue];
        UInt256 h;
        
        [hash getValue:&h];
        if ((tx && ! [self transactionIsValid:tx]) ||
            [self.spentOutputs containsObject:brutxo_obj(((BRUTXO) { h, n }))]) return NO;
    }
    
    return YES;
}

// true if transaction cannot be immediately spent (i.e. if it or an input tx can be replaced-by-fee)
- (BOOL)transactionIsPending:(BRTransaction *)transaction
{
    if (transaction.blockHeight != TX_UNCONFIRMED) return NO; // confirmed transactions are not pending
    if (transaction.size > TX_MAX_SIZE) return YES; // check transaction size is under TX_MAX_SIZE
    
    // check for future lockTime or replace-by-fee: https://github.com/bitcoin/bips/blob/master/bip-0125.mediawiki
    for (NSNumber *sequence in transaction.inputSequences) {
        if (sequence.unsignedIntValue < UINT32_MAX - 1) return YES;
        if (sequence.unsignedIntValue < UINT32_MAX && transaction.lockTime < TX_MAX_LOCK_HEIGHT &&
            transaction.lockTime > self.bestBlockHeight + 1) return YES;
        if (sequence.unsignedIntValue < UINT32_MAX && transaction.lockTime >= TX_MAX_LOCK_HEIGHT &&
            transaction.lockTime > [NSDate timeIntervalSinceReferenceDate] + NSTimeIntervalSince1970) return YES;
    }
    
//    for (NSNumber *amount in transaction.outputAmounts) { // check that no outputs are dust
//        if (amount.unsignedLongLongValue < TX_MIN_OUTPUT_AMOUNT) return YES;
//    }
    
    for (NSValue *txHash in transaction.inputHashes) { // check if any inputs are known to be pending
        if ([self transactionIsPending:self.allTx[txHash]]) return YES;
    }
    
    return NO;
}

// true if tx is considered 0-conf safe (valid and not pending, timestamp is greater than 0, and no unverified inputs)
- (BOOL)transactionIsVerified:(BRTransaction *)transaction
{
    if (transaction.blockHeight != TX_UNCONFIRMED) return YES; // confirmed transactions are always verified
//    if (transaction.timestamp == 0) return NO; // a timestamp of 0 indicates transaction is to remain unverified
    if (! [self transactionIsValid:transaction] || [self transactionIsPending:transaction]) return NO;
    
    for (NSValue *txHash in transaction.inputHashes) { // check if any inputs are known to be unverfied
        if (! self.allTx[txHash]) continue;
        if (! [self transactionIsVerified:self.allTx[txHash]]) return NO;
    }
    
    return YES;
}

// set the block heights and timestamps for the given transactions, use a height of TX_UNCONFIRMED and timestamp of 0 to
// indicate a transaction and it's dependents should remain marked as unverified (not 0-conf safe)
- (NSArray *)setBlockHeight:(int32_t)height andTimestamp:(NSTimeInterval)timestamp forTxHashes:(NSArray *)txHashes
{
    NSMutableArray *hashes = [NSMutableArray array], *updated = [NSMutableArray array];
    BOOL needsUpdate = NO;
    
    if (height != TX_UNCONFIRMED && height > self.bestBlockHeight) self.bestBlockHeight = height;
    
    for (NSValue *hash in txHashes) {
        BRTransaction *tx = self.allTx[hash];
        UInt256 h;
        
        if (! tx || (tx.blockHeight == height && tx.timestamp == timestamp)) continue;
        tx.blockHeight = height;
        tx.timestamp = timestamp;
        
        if ([self containsTransaction:tx]) {
            [hash getValue:&h];
            [hashes addObject:[NSData dataWithBytes:&h length:sizeof(h)]];
            [updated addObject:hash];
            if ([self.pendingTx containsObject:hash] || [self.invalidTx containsObject:hash]) needsUpdate = YES;
        }
        else if (height != TX_UNCONFIRMED) [self.allTx removeObjectForKey:hash]; // remove confirmed non-wallet tx
    }
    
    if (hashes.count > 0) {
        if (needsUpdate) {
            [self sortTransactions];
            [self updateBalance];
        }
        
        [self.moc performBlockAndWait:^{
            @autoreleasepool {
                NSMutableSet *entities = [NSMutableSet set];
                
                for (BRTransactionEntity *e in [BRTransactionEntity objectsMatching:@"txHash in %@", hashes]) {
                    e.blockHeight = height;
                    e.timestamp = timestamp;
                    [entities addObject:e];
                }
                
                for (BRTxMetadataEntity *e in [BRTxMetadataEntity objectsMatching:@"txHash in %@ && type == %d", hashes,
                                               TX_MDTYPE_MSG]) {
                    @autoreleasepool {
                        BRTransaction *tx = e.transaction;
                        
                        tx.blockHeight = height;
                        tx.timestamp = timestamp;
                        [e setAttributesFromTx:tx];
                        [entities addObject:e];
                    }
                }
                
                if (height != TX_UNCONFIRMED) {
                    // BUG: XXX saving the tx.blockHeight and the block it's contained in both need to happen together
                    // as an atomic db operation. If the tx.blockHeight is saved but the block isn't when the app exits,
                    // then a re-org that happens afterward can potentially result in an invalid tx showing as confirmed
                    [BRTxMetadataEntity saveContext];
                    
                    for (NSManagedObject *e in entities) {
                        [self.moc refreshObject:e mergeChanges:NO];
                    }
                }
            }
        }];
    }
    
    return updated;
}

// returns the amount received by the wallet from the transaction (total outputs to change and/or receive addresses)
- (uint64_t)amountReceivedFromTransaction:(BRTransaction *)transaction
{
    uint64_t amount = 0;
    NSUInteger n = 0;
    
    //TODO: don't include outputs below TX_MIN_OUTPUT_AMOUNT
    for (NSString *address in transaction.outputAddresses) {
        if ([self containsAddress:address]) amount += [transaction.outputAmounts[n] unsignedLongLongValue];
        n++;
    }
    
    return amount;
}

// TODO: 添加方法
- (uint64_t)amountReceivedFromPublishAssetTransaction:(BRTransaction *)transaction
{
    uint64_t amount = 0;
    NSUInteger n = 0;
    //TODO: don't include outputs below TX_MIN_OUTPUT_AMOUNT
    for (NSString *address in transaction.outputAddresses) {
        if ([self containsAddress:address] && [BRSafeUtils isSafeTransaction:transaction.outputReserves[n]]) { // [transaction.outputReserves[n] length] < 42
            amount += [transaction.outputAmounts[n] unsignedLongLongValue];
        }
        n++;
    }
    
    return amount;
}

// TODO: 添加方法
- (uint64_t)amountReceivedFromTransaction:(BRTransaction *)transaction balanceModel:(BRBalanceModel *) balanceModel
{
    uint64_t amount = 0;
    NSUInteger n = 0;
    //TODO: don't include outputs below TX_MIN_OUTPUT_AMOUNT
    for (NSString *address in transaction.outputAddresses) {
        if ([self containsAddress:address]) {
            if(balanceModel.assetId.length != 0 && ![BRSafeUtils isSafeTransaction:transaction.outputReserves[n]]) { // [transaction.outputReserves[n] length] > 42
                amount += [transaction.outputAmounts[n] unsignedLongLongValue];
            } else if (balanceModel.assetId.length == 0 && [BRSafeUtils isSafeTransaction:transaction.outputReserves[n]]) { // [transaction.outputReserves[n] length] < 42
                amount += [transaction.outputAmounts[n] unsignedLongLongValue];
            }
        }
        n++;
    }
    
    return amount;
}

// retuns the amount sent from the wallet by the trasaction (total wallet outputs consumed, change and fee included)
- (uint64_t)amountSentByTransaction:(BRTransaction *)transaction
{
    uint64_t amount = 0;
    NSUInteger i = 0;
    
    for (NSValue *hash in transaction.inputHashes) {
        BRTransaction *tx = self.allTx[hash];
        uint32_t n = [transaction.inputIndexes[i++] unsignedIntValue];
        
        if (n < tx.outputAddresses.count && [self containsAddress:tx.outputAddresses[n]]) {
            amount += [tx.outputAmounts[n] unsignedLongLongValue];
        }
    }
    return amount;
}


// TODO: 添加计算sent金额
- (uint64_t)amountSentByTransaction:(BRTransaction *)transaction balanceModel:(BRBalanceModel *) balanceModel
{
    uint64_t amount = 0;
    NSUInteger i = 0;
    for (NSValue *hash in transaction.inputHashes) {
        BRTransaction *tx = self.allTx[hash];
        uint32_t n = [transaction.inputIndexes[i++] unsignedIntValue];
//        BRLog(@"sssssssss %d %d %@", n < tx.outputAddresses.count, [self containsAddress:tx.outputAddresses[n]], tx.outputAddresses[n]);
        if (n < tx.outputAddresses.count && [self containsAddress:tx.outputAddresses[n]]) {
            if(balanceModel.assetId.length != 0 && ![BRSafeUtils isSafeTransaction:tx.outputReserves[n]]) { // [tx.outputReserves[n] length] > 42
                amount += [tx.outputAmounts[n] unsignedLongLongValue];
            } else if(balanceModel.assetId.length == 0 && [BRSafeUtils isSafeTransaction:tx.outputReserves[n]]) { // [tx.outputReserves[n] length] < 42
                amount += [tx.outputAmounts[n] unsignedLongLongValue];
            }
        }
    }
    return amount;
}

// TODO: 添加计算资产发行sent金额
- (uint64_t)amountSentByPublishAssetTransaction:(BRTransaction *)transaction
{
    uint64_t amount = 0;
    NSUInteger i = 0;
    for (NSValue *hash in transaction.inputHashes) {
        BRTransaction *tx = self.allTx[hash];
        uint32_t n = [transaction.inputIndexes[i++] unsignedIntValue];
        
        if (n < tx.outputAddresses.count && [self containsAddress:tx.outputAddresses[n]] && [BRSafeUtils isSafeTransaction:tx.outputReserves[n]]) { // [tx.outputReserves[n] length] < 42
            amount += [tx.outputAmounts[n] unsignedLongLongValue];
        }
    }
    return amount;
}


// returns the fee for the given transaction if all its inputs are from wallet transactions, UINT64_MAX otherwise
- (uint64_t)feeForTransaction:(BRTransaction *)transaction
{
    uint64_t amount = 0;
    NSUInteger i = 0;
    
    for (NSValue *hash in transaction.inputHashes) {
        BRTransaction *tx = self.allTx[hash];
        uint32_t n = [transaction.inputIndexes[i++] unsignedIntValue];
        if (n >= tx.outputAmounts.count) return UINT64_MAX;
        amount += [tx.outputAmounts[n] unsignedLongLongValue];
    }

    for (NSNumber *amt in transaction.outputAmounts) {
        amount -= amt.unsignedLongLongValue;
    }

    return amount;
}

// TODO: 添加计算
- (uint64_t)feeForPublishAssetTransaction:(BRTransaction *)transaction
{
    uint64_t amount = 0;
    NSUInteger i = 0;
    
    for (NSValue *hash in transaction.inputHashes) {
        BRTransaction *tx = self.allTx[hash];
        uint32_t n = [transaction.inputIndexes[i++] unsignedIntValue];
        
        if (n >= tx.outputAmounts.count) return UINT64_MAX;
        amount += [tx.outputAmounts[n] unsignedLongLongValue];
    }
    i = 0;
    for (NSNumber *amt in transaction.outputAmounts) {
        if([BRSafeUtils isSafeTransaction:transaction.outputReserves[i++]]) { // [transaction.outputReserves[i++] length] < 42
            amount -= amt.unsignedLongLongValue;
        }
    }
    
    return amount;
}

// TODO: 添加计算糖果的fee
- (uint64_t)feeForCandyTransaction:(BRTransaction *)transaction
{
    uint64_t amount = 0;
    NSUInteger i = 0;
    
    for (NSValue *hash in transaction.inputHashes) {
        BRTransaction *tx = self.allTx[hash];
        uint32_t n = [transaction.inputIndexes[i++] unsignedIntValue];
        
        if ([BRSafeUtils isSafeTransaction:tx.outputReserves[n]]) { // [tx.outputReserves[n] length] < 42
            amount += [tx.outputAmounts[n] unsignedLongLongValue];
        }
    }

    i = 0;
    for (NSNumber *amt in transaction.outputAmounts) {
        if([BRSafeUtils isSafeTransaction:transaction.outputReserves[i++]]) { // [transaction.outputReserves[i++] length] < 42
            amount -= amt.unsignedLongLongValue;
        }
    }

    return amount;
}

// historical wallet balance after the given transaction, or current balance if transaction is not registered in wallet
- (uint64_t)balanceAfterTransaction:(BRTransaction *)transaction
{
    NSUInteger i = [self.transactions indexOfObject:transaction];
    
    return (i < self.balanceHistory.count) ? [self.balanceHistory[i] unsignedLongLongValue] : self.balance;
}

// Returns the block height after which the transaction is likely to be processed without including a fee. This is based
// on the default satoshi client settings, but on the real network it's way off. In testing, a 0.01btc transaction that
// was expected to take an additional 90 days worth of blocks to confirm was confirmed in under an hour by Eligius pool.
- (uint32_t)blockHeightUntilFree:(BRTransaction *)transaction
{
    // TODO: calculate estimated time based on the median priority of free transactions in last 144 blocks (24hrs)
    NSMutableArray *amounts = [NSMutableArray array], *heights = [NSMutableArray array];
    NSUInteger i = 0;
    
    for (NSValue *hash in transaction.inputHashes) { // get the amounts and block heights of all the transaction inputs
        BRTransaction *tx = self.allTx[hash];
        uint32_t n = [transaction.inputIndexes[i++] unsignedIntValue];
        
        if (n >= tx.outputAmounts.count) break;
        [amounts addObject:tx.outputAmounts[n]];
        [heights addObject:@(tx.blockHeight)];
    };
    
    return [transaction blockHeightUntilFreeForAmounts:amounts withBlockHeights:heights];
}

// fee that will be added for a transaction of the given size in bytes
- (uint64_t)feeForTxSize:(NSUInteger)size isInstant:(BOOL)isInstant inputCount:(NSInteger)inputCount
{
    if (isInstant) {
        return TX_FEE_PER_INPUT*inputCount;
    } else {
        uint64_t standardFee = ((size + 999)/1000)*TX_FEE_PER_KB; // standard fee based on tx size rounded up to nearest kb
#if (!!FEE_PER_KB_URL)
        uint64_t fee = (((size*self.feePerKb/1000) + 99)/100)*100; // fee using feePerKb, rounded up to nearest 100 satoshi
        return (fee > standardFee) ? fee : standardFee;
#else
        return standardFee;
#endif
        
    }
}

// outputs below this amount are uneconomical due to fees
- (uint64_t)minOutputAmount
{
    uint64_t amount = (TX_MIN_OUTPUT_AMOUNT*self.feePerKb + MIN_FEE_PER_KB - 1)/MIN_FEE_PER_KB;
    
    return (amount > TX_MIN_OUTPUT_AMOUNT) ? amount : TX_MIN_OUTPUT_AMOUNT * 10;
}

- (uint64_t)maxOutputAmountUsingInstantSend:(BOOL)instantSend
{
    return [self maxOutputAmountWithConfirmationCount:0 usingInstantSend:instantSend];
}

- (uint32_t)blockHeight
{
    static uint32_t height = 0;
    uint32_t h = [BRPeerManager sharedInstance].lastBlockHeight;
    
    if (h > height) height = h;
    return height;
}

- (uint64_t)maxOutputAmountWithConfirmationCount:(uint64_t)confirmationCount usingInstantSend:(BOOL)instantSend
{
    BRUTXO o;
    BRTransaction *tx;
    NSUInteger inputCount = 0;
    uint64_t amount = 0, fee;
    size_t cpfpSize = 0, txSize;
    
    for (NSValue *output in self.utxos) {
        [output getValue:&o];
        tx = self.allTx[uint256_obj(o.hash)];
        if (o.n >= tx.outputAmounts.count) continue;
        if (confirmationCount && (tx.blockHeight >= (self.blockHeight - confirmationCount))) continue;
        inputCount++;
        amount += [tx.outputAmounts[o.n] unsignedLongLongValue];
        
        // size of unconfirmed, non-change inputs for child-pays-for-parent fee
        // don't include parent tx with more than 10 inputs or 10 outputs
        if (tx.blockHeight == TX_UNCONFIRMED && tx.inputHashes.count <= 10 && tx.outputAmounts.count <= 10 &&
            [self amountSentByTransaction:tx] == 0) cpfpSize += tx.size;
    }
    
    txSize = 8 + [NSMutableData sizeOfVarInt:inputCount] + TX_INPUT_SIZE*inputCount +
    [NSMutableData sizeOfVarInt:2] + TX_OUTPUT_SIZE*2;
    fee = [self feeForTxSize:txSize + cpfpSize isInstant:instantSend inputCount:inputCount];
    return (amount > fee) ? amount - fee : 0;
}

// 获取钱包所有未花费的地址
- (NSArray *) getAllUtxosAddress {
    NSMutableSet *addRddressSet = [NSMutableSet set];
    for(BRBalanceModel *balanceModel in self.balanceArray) {
        BRUTXO o;
        BRTransaction *tx;
        for (NSValue *output in balanceModel.utxos) {
            [output getValue:&o];
            tx = self.allTx[uint256_obj(o.hash)];
            [addRddressSet addObject:tx.outputAddresses[o.n]];
        }
    }
    return [addRddressSet allObjects];
}

// 获取未花费地址私钥
- (void) getWalltePrivate:(NSArray *) addressArr Seed:(NSData *) seed {
    NSMutableOrderedSet *externalIndexesPurpose44 = [NSMutableOrderedSet orderedSet],
    *internalIndexesPurpose44 = [NSMutableOrderedSet orderedSet],
    *externalIndexesNoPurpose = [NSMutableOrderedSet orderedSet],
    *internalIndexesNoPurpose = [NSMutableOrderedSet orderedSet];
    for (NSString *addr in addressArr) {
        NSInteger index = [self.internalBIP44Addresses indexOfObject:addr];
        if (index != NSNotFound) {
            [internalIndexesPurpose44 addObject:@(index)];
            continue;
        }
        index = [self.externalBIP44Addresses indexOfObject:addr];
        if (index != NSNotFound) {
            [externalIndexesPurpose44 addObject:@(index)];
            continue;
        }
        index = [self.internalBIP32Addresses indexOfObject:addr];
        if (index != NSNotFound) {
            [internalIndexesNoPurpose addObject:@(index)];
            continue;
        }
        index = [self.externalBIP32Addresses indexOfObject:addr];
        if (index != NSNotFound) {
            [externalIndexesNoPurpose addObject:@(index)];
            continue;
        }
    }
    
    NSMutableArray *privkeys = [NSMutableArray array];
    [privkeys addObjectsFromArray:[self.sequence privateKeys:externalIndexesPurpose44.array purpose:BIP44_PURPOSE internal:NO fromSeed:seed]];
    [privkeys addObjectsFromArray:[self.sequence privateKeys:internalIndexesPurpose44.array purpose:BIP44_PURPOSE internal:YES fromSeed:seed]];
    [privkeys addObjectsFromArray:[self.sequence privateKeys:externalIndexesNoPurpose.array purpose:BIP32_PURPOSE internal:NO fromSeed:seed]];
    [privkeys addObjectsFromArray:[self.sequence privateKeys:internalIndexesNoPurpose.array purpose:BIP32_PURPOSE internal:YES fromSeed:seed]];
    for(NSString *pri in privkeys) {
        BRLog(@"privateKey = %@ %@", pri, pri.base58ToData);
    }
}

@end
