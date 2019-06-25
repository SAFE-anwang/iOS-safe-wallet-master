//
//  BRMasternodeModel.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/9.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BRMasternodeModel : NSObject

@property (nonatomic,copy) NSString *ip;

@property (nonatomic,copy) NSString *status;

@property (nonatomic,copy) NSString *address;

- (NSDictionary *) toDictionary;

@end
