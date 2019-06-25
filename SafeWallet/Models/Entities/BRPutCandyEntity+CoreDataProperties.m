//
//  BRPutCandyEntity+CoreDataProperties.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/9.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRPutCandyEntity+CoreDataProperties.h"
#import "NSData+Bitcoin.h"

@implementation BRPutCandyEntity (CoreDataProperties)

+ (NSFetchRequest<BRPutCandyEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"BRPutCandyEntity"];
}

@dynamic assetId;
@dynamic candyAmount;
@dynamic candyExpired;
@dynamic remarks;
@dynamic txId;
@dynamic txTime;
@dynamic decimals;
@dynamic assetName;
@dynamic blockHeight;
@dynamic isGetState;
@dynamic index;
@dynamic outputScript;

- (instancetype)setAttributesFromPutCandyData:(PutCandyData *) putCandyData txHash:(NSData *) txId txTime:(NSNumber *) txTime decimals:(NSNumber *) decimals assetName:(NSString *) assetName blockHeight:(NSInteger) blockHeight index:(NSInteger)index outputScript:(NSData *) outputScript{
    [self.managedObjectContext performBlockAndWait:^{
        self.assetId = putCandyData.assetId;
        self.candyAmount = @(putCandyData.amount);
        self.candyExpired = @([putCandyData.expired UInt16AtOffset:0]);
        self.remarks = [[NSString alloc] initWithData:putCandyData.remarks encoding:NSUTF8StringEncoding];
        self.txId = txId;
        self.txTime = txTime;
        self.decimals = decimals;
        self.assetName = assetName;
        self.blockHeight = @(blockHeight);
        self.isGetState = @(0);
        self.isCount = @(0);
        self.index = @(index);
        self.outputScript = outputScript;
    }];
    
    return self;
}

@end
