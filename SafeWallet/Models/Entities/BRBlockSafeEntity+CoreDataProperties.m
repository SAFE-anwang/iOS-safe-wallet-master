//
//  BRBlockSafeEntity+CoreDataProperties.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/11.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRBlockSafeEntity+CoreDataProperties.h"


@implementation BRBlockSafeEntity (CoreDataProperties)

+ (NSFetchRequest<BRBlockSafeEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"BRBlockSafeEntity"];
}

@dynamic blockHeight;
@dynamic totalAmount;

- (instancetype)setAttributesFromBlockHeight:(NSUInteger) blockHeight totalAmout:(uint64_t) totalAmout{
    [self.managedObjectContext performBlockAndWait:^{
        self.blockHeight = @(blockHeight);
        self.totalAmount = @(totalAmout);
    }];
    
    return self;
}


@end
