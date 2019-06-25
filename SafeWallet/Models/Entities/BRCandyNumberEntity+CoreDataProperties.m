//
//  BRCandyNumberEntity+CoreDataProperties.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/11/21.
//  Copyright © 2018 Aaron Voisine. All rights reserved.
//
//

#import "BRCandyNumberEntity+CoreDataProperties.h"

@implementation BRCandyNumberEntity (CoreDataProperties)

+ (NSFetchRequest<BRCandyNumberEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"BRCandyNumberEntity"];
}

@dynamic txId;
@dynamic publishCandyTxId;
@dynamic candyNumber;

- (instancetype)setAttributesFromCandyNumber:(int64_t) candyNumber txId:(NSData *) txId publishCandyTxId:(NSData *) publishCandyTxId {
    [self.managedObjectContext performBlockAndWait:^{
        self.candyNumber = @(candyNumber);
        self.publishCandyTxId = publishCandyTxId;
        self.txId = txId;
    }];
    
    return self;
}


@end
