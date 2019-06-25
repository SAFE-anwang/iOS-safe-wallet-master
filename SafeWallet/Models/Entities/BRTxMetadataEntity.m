//
//  BRTxMetadataEntity.m
//  BreadWallet
//
//  Created by Aaron Voisine on 10/22/15.
//  Copyright (c) 2015 Aaron Voisine <voisine@gmail.com>
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

#import "BRTxMetadataEntity.h"
#import "BRTransaction.h"
#import "NSManagedObject+Sugar.h"
#import "NSData+Bitcoin.h"
#import "NSMutableData+Bitcoin.h"
#import "BRSafeUtils.h"
@implementation BRTxMetadataEntity

@dynamic blob;
@dynamic txHash;
@dynamic type;

- (instancetype)setAttributesFromTx:(BRTransaction *)tx
{
//    NSMutableData *data = [NSMutableData dataWithData:tx.data];
    uint32_t blockheight = tx.blockHeight;
    if(blockheight == 0) blockheight = INT32_MAX;
    NSMutableData *data = [NSMutableData dataWithData:[tx toDataWithSubscriptIndex:NSNotFound blockHeight:blockheight]];

    [data appendUInt32:tx.blockHeight];
    [data appendUInt32:tx.timestamp];
//    BRLog(@"sssssssssssssssssssss %ld %d %@", data.length, tx.blockHeight, uint256_obj(tx.txHash));
    [self.managedObjectContext performBlockAndWait:^{
        self.blob = data;
        self.type = TX_MDTYPE_MSG;
        self.txHash = [NSData dataWithBytes:tx.txHash.u8 length:sizeof(UInt256)];
    }];
    
    return self;
}

- (BRTransaction *)transaction
{
    __block BRTransaction *tx = nil;
    
    [self.managedObjectContext performBlockAndWait:^{
        NSData *data = self.blob;
    
        if (data.length > sizeof(uint32_t)*2) {
//            tx = [BRTransaction transactionWithMessage:data];
//            tx.blockHeight = [data UInt32AtOffset:data.length - sizeof(uint32_t)*2];
//            tx.timestamp = [data UInt32AtOffset:data.length - sizeof(uint32_t)];
            
            // 修改
            tx = [BRTransaction transactionWithMessage:data blockHeight:[data UInt32AtOffset:data.length - sizeof(uint32_t)*2]];
            tx.blockHeight = [data UInt32AtOffset:data.length - sizeof(uint32_t)*2];
            tx.timestamp = [data UInt32AtOffset:data.length - sizeof(uint32_t)];
//            if(tx.blockHeight == 4017) {
//                BRLog(@"%lu", (unsigned long)data.length);
//                [BRSafeUtils logTransaction:tx];
//            }
        }
    }];
    
    return tx;
}

@end
