//
//  BRPutCandyEntity+CoreDataProperties.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/9.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRPutCandyEntity+CoreDataClass.h"
#import "Safe.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRPutCandyEntity (CoreDataProperties)

+ (NSFetchRequest<BRPutCandyEntity *> *)fetchRequest;

@property (nullable, nonatomic, retain) NSData *assetId;
@property (nullable, nonatomic, copy) NSNumber *candyAmount;
@property (nullable, nonatomic, copy) NSNumber *candyExpired;
@property (nullable, nonatomic, copy) NSString *remarks;
@property (nullable, nonatomic, retain) NSData *txId;
@property (nullable, nonatomic, copy) NSNumber *txTime;
@property (nullable, nonatomic, copy) NSNumber *decimals;
@property (nullable, nonatomic, copy) NSString *assetName;
@property (nullable, nonatomic, copy) NSNumber *blockHeight;
/**
  0 不可领取 1 可领取 2 已领取 3 已过期  4 已领完
 */
@property (nullable, nonatomic, copy) NSNumber *isGetState;

/**
 0 没有计算 1 有计算
 */
@property (nullable, nonatomic, copy) NSNumber *isCount;
@property (nullable, nonatomic, copy) NSNumber *index;
@property (nullable, nonatomic, retain) NSData *outputScript;


- (instancetype)setAttributesFromPutCandyData:(PutCandyData *) putCandyData txHash:(NSData *) txId txTime:(NSNumber *) txTime decimals:(NSNumber *) decimals assetName:(NSString *) assetName blockHeight:(NSInteger) blockHeight index:(NSInteger) index outputScript:(NSData *) outputScript;

@end

NS_ASSUME_NONNULL_END
