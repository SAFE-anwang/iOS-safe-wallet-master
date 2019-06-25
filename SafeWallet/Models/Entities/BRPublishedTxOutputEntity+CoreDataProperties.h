//
//  BRPublishedTxOutputEntity+CoreDataProperties.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/8/1.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRPublishedTxOutputEntity+CoreDataClass.h"

@class BRTransaction;
NS_ASSUME_NONNULL_BEGIN

@interface BRPublishedTxOutputEntity (CoreDataProperties)

+ (NSFetchRequest<BRPublishedTxOutputEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *address;
@property (nullable, nonatomic, copy) NSNumber *n;
@property (nullable, nonatomic, retain) NSData *reserve;
@property (nullable, nonatomic, retain) NSData *script;
@property (nullable, nonatomic, copy) NSString *shapeshiftOutboundAddress;
@property (nullable, nonatomic, copy) NSNumber *spent;
@property (nullable, nonatomic, retain) NSData *txHash;
@property (nullable, nonatomic, copy) NSNumber *unlockHeight;
@property (nullable, nonatomic, copy) NSNumber *value;
@property (nullable, nonatomic, retain) BRPublishedTxEntity *publishedTxOutputs;

- (instancetype)setAttributesFromTx:(BRTransaction *)tx outputIndex:(NSUInteger)index;

@end

NS_ASSUME_NONNULL_END
