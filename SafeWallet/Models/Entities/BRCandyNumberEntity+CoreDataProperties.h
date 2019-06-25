//
//  BRCandyNumberEntity+CoreDataProperties.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/11/21.
//  Copyright © 2018 Aaron Voisine. All rights reserved.
//
//

#import "BRCandyNumberEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface BRCandyNumberEntity (CoreDataProperties)

+ (NSFetchRequest<BRCandyNumberEntity *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *txId;
@property (nullable, nonatomic, retain) NSData *publishCandyTxId;
@property (nullable, nonatomic, copy) NSNumber *candyNumber;

- (instancetype)setAttributesFromCandyNumber:(int64_t) candyNumber txId:(NSData *) txId publishCandyTxId:(NSData *) publishCandyTxId;

@end

NS_ASSUME_NONNULL_END
