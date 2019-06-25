//
//  BRPublishedTxOutputEntity+CoreDataProperties.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/8/1.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRPublishedTxOutputEntity+CoreDataProperties.h"
#import "BRTransaction.h"
#import "NSData+Bitcoin.h"

@implementation BRPublishedTxOutputEntity (CoreDataProperties)

+ (NSFetchRequest<BRPublishedTxOutputEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"BRPublishedTxOutputEntity"];
}

@dynamic address;
@dynamic n;
@dynamic reserve;
@dynamic script;
@dynamic shapeshiftOutboundAddress;
@dynamic spent;
@dynamic txHash;
@dynamic unlockHeight;
@dynamic value;
@dynamic publishedTxOutputs;

- (instancetype)setAttributesFromTx:(BRTransaction *)tx outputIndex:(NSUInteger)index
{
    [self.managedObjectContext performBlockAndWait:^{
        UInt256 txHash = tx.txHash;
        
        self.txHash = [NSData dataWithBytes:&txHash length:sizeof(txHash)];
        self.n = @((int32_t)index);
        self.address = (tx.outputAddresses[index] == [NSNull null]) ? nil : tx.outputAddresses[index];
        self.script = tx.outputScripts[index];
        self.value = @([tx.outputAmounts[index] longLongValue]);
        self.shapeshiftOutboundAddress = [BRTransaction shapeshiftOutboundAddressForScript:self.script];
        self.unlockHeight = @([tx.outputUnlockHeights[index] longLongValue]);
        self.reserve = tx.outputReserves[index];
    }];
    
    return self;
}

@end
