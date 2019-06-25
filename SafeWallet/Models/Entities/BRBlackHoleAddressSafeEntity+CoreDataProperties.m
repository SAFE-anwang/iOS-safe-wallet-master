//
//  BRBlackHoleAddressSafeEntity+CoreDataProperties.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/11.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRBlackHoleAddressSafeEntity+CoreDataProperties.h"

@implementation BRBlackHoleAddressSafeEntity (CoreDataProperties)

+ (NSFetchRequest<BRBlackHoleAddressSafeEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"BRBlackHoleAddressSafeEntity"];
}

@dynamic height;
@dynamic totalAmount;
@dynamic txId;

- (instancetype)setAttributesFromBlockHeight:(NSUInteger) blockHeight totalAmout:(uint64_t) totalAmout txId:(NSData *) txId{
    [self.managedObjectContext performBlockAndWait:^{
        self.height = @(blockHeight);
        self.totalAmount = @(totalAmout);
        self.txId = txId;
    }];
    
    return self;
}

@end
