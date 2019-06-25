//
//  BRPublishedTxInputEntity+CoreDataProperties.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/8/1.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRPublishedTxInputEntity+CoreDataProperties.h"
#import "BRTransaction.h"
#import "NSData+Bitcoin.h"

@implementation BRPublishedTxInputEntity (CoreDataProperties)

+ (NSFetchRequest<BRPublishedTxInputEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"BRPublishedTxInputEntity"];
}

@dynamic n;
@dynamic sequence;
@dynamic signature;
@dynamic txHash;
@dynamic publishedTx;

- (instancetype)setAttributesFromTx:(BRTransaction *)tx inputIndex:(NSUInteger)index
{
    [self.managedObjectContext performBlockAndWait:^{
        UInt256 hash = UINT256_ZERO;
        
        [tx.inputHashes[index] getValue:&hash];
        self.txHash = [NSData dataWithBytes:&hash length:sizeof(hash)];
        self.n = @([tx.inputIndexes[index] intValue]);
        self.signature = (tx.inputSignatures[index] != [NSNull null]) ? tx.inputSignatures[index] : nil;
        self.sequence = @([tx.inputSequences[index] intValue]);
    }];
    
    return self;
}

@end
