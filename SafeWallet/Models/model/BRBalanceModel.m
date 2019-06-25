//
//  BRBalanceModel.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/23.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRBalanceModel.h"

@implementation BRBalanceModel

- (NSMutableArray *)txArray {
    if(_txArray == nil) {
        _txArray = [NSMutableArray array];
    }
    return _txArray;
}

- (NSMutableOrderedSet *)utxos {
    if(_utxos == nil) {
        _utxos = [NSMutableOrderedSet orderedSet];
    }
    return _utxos;
}

@end
