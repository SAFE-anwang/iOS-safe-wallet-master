//
//  BRPublishedTxEntity+CoreDataClass.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/8/1.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class BRPublishedTxInputEntity, BRPublishedTxOutputEntity;

NS_ASSUME_NONNULL_BEGIN

@interface BRPublishedTxEntity : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "BRPublishedTxEntity+CoreDataProperties.h"
