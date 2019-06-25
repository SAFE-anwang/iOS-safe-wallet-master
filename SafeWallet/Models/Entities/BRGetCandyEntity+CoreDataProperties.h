//
//  BRGetCandyEntity+CoreDataProperties.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/14.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRGetCandyEntity+CoreDataClass.h"
#import "Safe.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRGetCandyEntity (CoreDataProperties)

+ (NSFetchRequest<BRGetCandyEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *address;
@property (nullable, nonatomic, retain) NSData *assetId;
@property (nullable, nonatomic, copy) NSNumber *candyAmount;
@property (nullable, nonatomic, copy) NSString *remarks;
@property (nullable, nonatomic, retain) NSData *txId;
@property (nullable, nonatomic, retain) NSData *inTxId;
@property (nullable, nonatomic, retain) NSData *version;
@property (nullable, nonatomic, copy) NSString *assetName;
@property (nullable, nonatomic, copy) NSNumber *decimals;
@property (nullable, nonatomic, copy) NSNumber *blockTime;
@property (nullable, nonatomic, copy) NSNumber *blockHeight;

- (instancetype)setAttributesFromGetCandyData:(GetCandyData *) getCandyData txId:(NSData *) txId address:(NSString *) address inTxId:(NSData *) inTxId version:(NSData *) version assetName:(NSString *) assetName blockTime:(NSNumber *) blockTime decimals:(NSNumber *) decimals blockHeight:(NSNumber *) blockHeight;

@end

NS_ASSUME_NONNULL_END
