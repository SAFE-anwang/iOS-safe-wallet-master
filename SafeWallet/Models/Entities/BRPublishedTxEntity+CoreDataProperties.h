//
//  BRPublishedTxEntity+CoreDataProperties.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/8/1.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRPublishedTxEntity+CoreDataClass.h"

@class BRTransaction;
@class BRPublishedTxInputEntity;
@class BRPublishedTxOutputEntity;

NS_ASSUME_NONNULL_BEGIN

@interface BRPublishedTxEntity (CoreDataProperties)

+ (NSFetchRequest<BRPublishedTxEntity *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *txHash;
@property (nullable, nonatomic, retain) NSOrderedSet<BRPublishedTxInputEntity *> *txInputs;
@property (nullable, nonatomic, retain) NSOrderedSet<BRPublishedTxOutputEntity *> *txOutputs;

- (instancetype)setAttributesFromTx:(BRTransaction *)tx;
- (BRTransaction *)transaction;

@end

@interface BRPublishedTxEntity (CoreDataGeneratedAccessors)

- (void)insertObject:(BRPublishedTxInputEntity *)value inTxInputsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTxInputsAtIndex:(NSUInteger)idx;
- (void)insertTxInputs:(NSArray<BRPublishedTxInputEntity *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTxInputsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTxInputsAtIndex:(NSUInteger)idx withObject:(BRPublishedTxInputEntity *)value;
- (void)replaceTxInputsAtIndexes:(NSIndexSet *)indexes withTxInputs:(NSArray<BRPublishedTxInputEntity *> *)values;
- (void)addTxInputsObject:(BRPublishedTxInputEntity *)value;
- (void)removeTxInputsObject:(BRPublishedTxInputEntity *)value;
- (void)addTxInputs:(NSOrderedSet<BRPublishedTxInputEntity *> *)values;
- (void)removeTxInputs:(NSOrderedSet<BRPublishedTxInputEntity *> *)values;

- (void)insertObject:(BRPublishedTxOutputEntity *)value inTxOutputsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTxOutputsAtIndex:(NSUInteger)idx;
- (void)insertTxOutputs:(NSArray<BRPublishedTxOutputEntity *> *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTxOutputsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTxOutputsAtIndex:(NSUInteger)idx withObject:(BRPublishedTxOutputEntity *)value;
- (void)replaceTxOutputsAtIndexes:(NSIndexSet *)indexes withTxOutputs:(NSArray<BRPublishedTxOutputEntity *> *)values;
- (void)addTxOutputsObject:(BRPublishedTxOutputEntity *)value;
- (void)removeTxOutputsObject:(BRPublishedTxOutputEntity *)value;
- (void)addTxOutputs:(NSOrderedSet<BRPublishedTxOutputEntity *> *)values;
- (void)removeTxOutputs:(NSOrderedSet<BRPublishedTxOutputEntity *> *)values;

@end

NS_ASSUME_NONNULL_END
