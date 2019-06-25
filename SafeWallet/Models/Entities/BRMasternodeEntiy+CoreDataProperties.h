//
//  BRMasternodeEntiy+CoreDataProperties.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/8.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRMasternodeEntiy+CoreDataClass.h"
#import "BRMasternodeModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface BRMasternodeEntiy (CoreDataProperties)

+ (NSFetchRequest<BRMasternodeEntiy *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *ip;
@property (nullable, nonatomic, copy) NSString *status;
@property (nullable, nonatomic, copy) NSString *address;

- (instancetype)setAttributesFromMasternodeModel:(BRMasternodeModel *) masternodeModel;

@end

NS_ASSUME_NONNULL_END
