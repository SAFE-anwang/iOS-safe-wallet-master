//
//  BRBalanceModel.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/23.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Safe.pbobjc.h"

@interface BRBalanceModel : NSObject

/**
 前一个资产
 */
@property (nonatomic, assign) uint64_t prevBalance;

/**
 总资产
 */
@property (nonatomic, assign) uint64_t balance;

/**
 总共发送的
 */
@property (nonatomic, assign) uint64_t totalSent;

@property (nonatomic, copy) NSString *nameString;

@property (nonatomic, strong) NSData *assetId;

@property (nonatomic, strong) NSData *version;

@property (nonatomic,strong) NSData *applicationID;

@property (nonatomic, strong) CommonData *common;

@property (nonatomic, strong) NSMutableArray *txArray;

@property (nonatomic, assign) int multiple;

@property (nonatomic, strong) NSMutableOrderedSet *utxos;

@property (nonatomic, assign) uint64_t notificationBalance;

@end
