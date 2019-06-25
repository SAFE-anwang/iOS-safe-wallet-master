//
//  BRMasternodeModel.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/9.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRMasternodeModel.h"
#import "BRMasternodeEntiy+CoreDataProperties.h"
#import "BRCoreDataManager.h"

@implementation BRMasternodeModel

- (NSArray *) toDictionary {
    NSArray *masternodeEntiyArray =  [[BRCoreDataManager sharedInstance] fetchEntity:@"BRMasternodeEntiy" withPredicate:nil];
    NSMutableArray *jsonArray = [NSMutableArray array];
    for(BRMasternodeEntiy *masternodeEntiy in masternodeEntiyArray) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:masternodeEntiy.ip forKey:@"ip"];
        [dict setValue:masternodeEntiy.address forKey:@"address"];
        [dict setValue:masternodeEntiy.status forKey:@"status"];
        [jsonArray addObject:dict];
    }
    return [NSArray arrayWithArray:jsonArray];
}

@end
