//
//  BRPublishedTxEntity+CoreDataProperties.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/8/1.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRPublishedTxEntity+CoreDataProperties.h"
#import "BRPublishedTxInputEntity+CoreDataProperties.h"
#import "BRPublishedTxOutputEntity+CoreDataProperties.h"
#import "BRTransaction.h"
#import "BRCoreDataManager.h"
#import "NSData+Bitcoin.h"
#import "NSMutableData+Bitcoin.h"

@implementation BRPublishedTxEntity (CoreDataProperties)

+ (NSFetchRequest<BRPublishedTxEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"BRPublishedTxEntity"];
}

@dynamic txHash;
@dynamic txInputs;
@dynamic txOutputs;

- (instancetype)setAttributesFromTx:(BRTransaction *)tx
{
    [self.managedObjectContext performBlockAndWait:^{
        NSMutableOrderedSet *inputs = [self mutableOrderedSetValueForKey:@"txInputs"];
        NSMutableOrderedSet *outputs = [self mutableOrderedSetValueForKey:@"txOutputs"];
        UInt256 txHash = tx.txHash;
        NSUInteger idx = 0;
        
        self.txHash = [NSData dataWithBytes:&txHash length:sizeof(txHash)];
        
        while (inputs.count < tx.inputHashes.count) {
            [inputs addObject:(BRPublishedTxInputEntity *)[[BRCoreDataManager sharedInstance] createEntityNamedWith:@"BRPublishedTxInputEntity"]];
        }
        
        while (inputs.count > tx.inputHashes.count) {
            [inputs removeObjectAtIndex:inputs.count - 1];
        }
        
        for (BRPublishedTxInputEntity *e in inputs) {
            [e setAttributesFromTx:tx inputIndex:idx++];
        }
        
        while (outputs.count < tx.outputAddresses.count) {
            [outputs addObject:(BRPublishedTxOutputEntity *)[[BRCoreDataManager sharedInstance] createEntityNamedWith:@"BRPublishedTxOutputEntity"]];
        }
        
        while (outputs.count > tx.outputAddresses.count) {
            [self removeObjectFromTxOutputsAtIndex:outputs.count - 1];
        }
        
        idx = 0;
        
        for (BRPublishedTxOutputEntity *e in outputs) {
            [e setAttributesFromTx:tx outputIndex:idx++];
        }
        
    }];
    
    return self;
}

- (BRTransaction *)transaction
{
    BRTransaction *tx = [BRTransaction new];
    
    [self.managedObjectContext performBlockAndWait:^{
        NSData *txHash = self.txHash;
        
        if (txHash.length == sizeof(UInt256)) tx.txHash = *(const UInt256 *)txHash.bytes;
        
        for (BRPublishedTxInputEntity *e in self.txInputs) {
            txHash = e.txHash;
            if (txHash.length != sizeof(UInt256)) continue;
            [tx addInputHash:*(const UInt256 *)txHash.bytes index:[e.n integerValue] script:nil signature:e.signature
                    sequence:[e.sequence integerValue]];
        }
        
        for (BRPublishedTxOutputEntity *e in self.txOutputs) {
            [tx addOutputScript:e.script amount:[e.value unsignedLongLongValue] unlockHeight:[e.unlockHeight unsignedLongLongValue] reserve:e.reserve];
        }
    }];
    
    return tx;
}

@end
