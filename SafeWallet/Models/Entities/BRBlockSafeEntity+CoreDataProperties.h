//
//  BRBlockSafeEntity+CoreDataProperties.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/11.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRBlockSafeEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BRBlockSafeEntity (CoreDataProperties)

+ (NSFetchRequest<BRBlockSafeEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *blockHeight;
@property (nullable, nonatomic, copy) NSNumber *totalAmount;

- (instancetype)setAttributesFromBlockHeight:(NSUInteger) blockHeight totalAmout:(uint64_t) totalAmout;

@end

NS_ASSUME_NONNULL_END
