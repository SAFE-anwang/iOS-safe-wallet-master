//
//  BRGetCandyEntity+CoreDataProperties.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/14.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRGetCandyEntity+CoreDataProperties.h"

@implementation BRGetCandyEntity (CoreDataProperties)

+ (NSFetchRequest<BRGetCandyEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"BRGetCandyEntity"];
}

@dynamic address;
@dynamic assetId;
@dynamic candyAmount;
@dynamic remarks;
@dynamic txId;
@dynamic inTxId;
@dynamic version;
@dynamic assetName;
@dynamic blockHeight;
@dynamic blockTime;
@dynamic decimals;

- (instancetype)setAttributesFromGetCandyData:(GetCandyData *) getCandyData txId:(NSData *) txId address:(NSString *) address inTxId:(NSData *) inTxId version:(NSData *) version assetName:(NSString *) assetName blockTime:(NSNumber *) blockTime decimals:(NSNumber *) decimals blockHeight:(NSNumber *) blockHeight {
    [self.managedObjectContext performBlockAndWait:^{
        self.address = address;
        self.assetId = getCandyData.assetId;
        self.candyAmount = @(getCandyData.amount);
        self.remarks = [[NSString alloc] initWithData:getCandyData.remarks encoding:NSUTF8StringEncoding];
        self.txId = txId;
        self.inTxId = inTxId;
        self.version = version;
        self.assetName = assetName;
        self.decimals = decimals;
        self.blockTime = blockTime;
        self.blockHeight = blockHeight;
    }];
    
    return self;
}

@end
