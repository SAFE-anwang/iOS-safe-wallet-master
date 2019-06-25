//
//  BRCommonModel.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/4.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRCommonDataModel : NSObject

@property (nonatomic,copy) NSString *assetName;

@property (nonatomic,assign) uint64_t assetAmount;

@property (nonatomic,strong) NSData *version;             // uint16_t

@property (nonatomic,strong) NSData *assetId;             // uint256

@property (nonatomic,copy) NSString *amount;              // int64_t

@property (nonatomic,copy) NSString *remarks;

@property (nonatomic,assign) int decimals;

@property (nonatomic,copy) NSString *address;

-(NSData *) toCommonData;

@end
