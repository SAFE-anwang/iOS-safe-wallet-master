//
//  BRIssueAssetModel.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/30.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Safe.pbobjc.h"

@interface BRIssueAssetModel : NSObject

@property (nonatomic,copy) NSString *shortName;             // string

@property (nonatomic,copy) NSString *assetName;           // string

@property (nonatomic,copy) NSString *assetDesc ;           // string

@property (nonatomic,copy) NSString *assetUnit;           // string

@property (nonatomic,copy) NSString *totalAmount;         // int64_t

@property (nonatomic,copy) NSString *firstIssueAmount;    // int64_t

@property (nonatomic,copy) NSString *firstActualAmount;   // int64_t

@property (nonatomic,copy) NSString *decimals;            // uint8_t

@property (nonatomic,assign) BOOL destory;             // bool

@property (nonatomic,assign) BOOL payCandy;            // bool

@property (nonatomic,assign) double candyAmount;     // int64_t

@property (nonatomic,copy) NSString *candyExpired;       // uint16_t

@property (nonatomic,copy) NSString *remarks ;            // string

@property (nonatomic, assign) BOOL isTesting;

@property (nonatomic,assign) BOOL isPublishAsset;

// 构建资产发行reserve数据
- (NSData *) toIssueAssetData;

// 构建糖果reserve数据
- (NSData *) toCandyAssetData;

- (uint64_t) getCandyAmount;

- (uint64_t) getFirstActualAmount;

@end
