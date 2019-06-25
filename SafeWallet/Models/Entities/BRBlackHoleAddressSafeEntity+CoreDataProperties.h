//
//  BRBlackHoleAddressSafeEntity+CoreDataProperties.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/11.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRBlackHoleAddressSafeEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BRBlackHoleAddressSafeEntity (CoreDataProperties)

+ (NSFetchRequest<BRBlackHoleAddressSafeEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *height;
@property (nullable, nonatomic, copy) NSNumber *totalAmount;
@property (nullable, nonatomic, retain) NSData *txId;

- (instancetype)setAttributesFromBlockHeight:(NSUInteger) blockHeight totalAmout:(uint64_t) totalAmout txId:(NSData *) txId;

@end

NS_ASSUME_NONNULL_END
