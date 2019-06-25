//
//  BRPutCandyModel.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/6.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRPutCandyModel : NSObject

@property (nonatomic,strong) NSData *assetId;

@property (nonatomic, assign) double sliderValue;

@property (nonatomic,copy) NSString *expired;

@property (nonatomic,copy) NSString *remarks;

@property (nonatomic,copy) NSString *assetName;

@property (nonatomic,copy) NSString *amount;

@property (nonatomic,copy) NSString *address;

@property (nonatomic,copy) NSString *assetUnit;

@property (nonatomic,assign) uint64_t actualAmount;

@property (nonatomic, assign) uint64_t totalAmount;

@property (nonatomic,assign) int decimals;

@property (nonatomic,assign) int publishCandyNumber;

- (NSData *) toPutCandyData;

- (uint64_t) getCandy;

@end
