//
//  BRMasternodeEntiy+CoreDataProperties.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/8.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRMasternodeEntiy+CoreDataProperties.h"

@implementation BRMasternodeEntiy (CoreDataProperties)

+ (NSFetchRequest<BRMasternodeEntiy *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"BRMasternodeEntiy"];
}

@dynamic ip;
@dynamic address;
@dynamic status;

- (instancetype)setAttributesFromMasternodeModel:(BRMasternodeModel *) masternodeModel {
    [self.managedObjectContext performBlockAndWait:^{
        self.ip = masternodeModel.ip;
        self.address = masternodeModel.address;
        self.status = masternodeModel.status;
    }];
    
    return self;
}

@end
