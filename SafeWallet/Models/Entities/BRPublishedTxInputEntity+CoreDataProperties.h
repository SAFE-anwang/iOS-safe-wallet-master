//
//  BRPublishedTxInputEntity+CoreDataProperties.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/8/1.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRPublishedTxInputEntity+CoreDataClass.h"

@class BRTransaction;

NS_ASSUME_NONNULL_BEGIN

@interface BRPublishedTxInputEntity (CoreDataProperties)

+ (NSFetchRequest<BRPublishedTxInputEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *n;
@property (nullable, nonatomic, copy) NSNumber *sequence;
@property (nullable, nonatomic, retain) NSData *signature;
@property (nullable, nonatomic, retain) NSData *txHash;
@property (nullable, nonatomic, retain) BRPublishedTxEntity *publishedTx;

- (instancetype)setAttributesFromTx:(BRTransaction *)tx inputIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
