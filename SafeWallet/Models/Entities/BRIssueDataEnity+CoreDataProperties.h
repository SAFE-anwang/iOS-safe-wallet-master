//
//  BRIssueDataEnity+CoreDataProperties.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/22.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRIssueDataEnity+CoreDataClass.h"
#import "Safe.pbobjc.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRIssueDataEnity (CoreDataProperties)

+ (NSFetchRequest<BRIssueDataEnity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *version;
@property (nullable, nonatomic, copy) NSString *shortName;
@property (nullable, nonatomic, copy) NSString *assetName;
@property (nullable, nonatomic, copy) NSString *assetDesc;
@property (nullable, nonatomic, copy) NSString *assetUnit;
@property (nullable, nonatomic, copy) NSNumber *totalAmount;
@property (nullable, nonatomic, copy) NSNumber *firstIssueAmount;
@property (nullable, nonatomic, copy) NSNumber *firstActualAmount;
@property (nullable, nonatomic, copy) NSNumber *decimals;
@property (nullable, nonatomic, copy) NSNumber *destory;
@property (nullable, nonatomic, copy) NSNumber *payCandy;
@property (nullable, nonatomic, copy) NSNumber *candyAmount;
@property (nullable, nonatomic, copy) NSNumber *candyExpired;
@property (nullable, nonatomic, copy) NSString *remarks;
@property (nullable, nonatomic, retain) NSData *assetId;
@property (nullable, nonatomic, retain) NSData *txId;

- (instancetype)setAttributesFromIssueData:(IssueData *) issueData txHash:(NSData *) txHash;

@end

NS_ASSUME_NONNULL_END
