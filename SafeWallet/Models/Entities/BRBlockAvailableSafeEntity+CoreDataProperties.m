//
//  BRBlockAvailableSafeEntity+CoreDataProperties.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/12.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRBlockAvailableSafeEntity+CoreDataProperties.h"

@implementation BRBlockAvailableSafeEntity (CoreDataProperties)

+ (NSFetchRequest<BRBlockAvailableSafeEntity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"BRBlockAvailableSafeEntity"];
}

@dynamic height;
@dynamic address;
@dynamic amount;

- (instancetype)setAttributesFromBlockHeight:(NSUInteger) blockHeight amout:(uint64_t) amout address:(NSString *) address {
    [self.managedObjectContext performBlockAndWait:^{
        self.height = @(blockHeight);
        self.amount = @(amout);
        self.address = address;
    }];
    
    return self;
}


@end
