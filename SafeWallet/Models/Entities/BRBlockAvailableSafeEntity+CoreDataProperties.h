//
//  BRBlockAvailableSafeEntity+CoreDataProperties.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/12.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRBlockAvailableSafeEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BRBlockAvailableSafeEntity (CoreDataProperties)

+ (NSFetchRequest<BRBlockAvailableSafeEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *height;
@property (nullable, nonatomic, copy) NSString *address;
@property (nullable, nonatomic, copy) NSNumber *amount;

- (instancetype)setAttributesFromBlockHeight:(NSUInteger) blockHeight amout:(uint64_t) amout address:(NSString *) address;

@end

NS_ASSUME_NONNULL_END
