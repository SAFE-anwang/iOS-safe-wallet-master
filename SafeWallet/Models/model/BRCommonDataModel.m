//
//  BRCommonModel.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/4.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRCommonDataModel.h"
#import "BRSafeUtils.h"
#import "Safe.pbobjc.h"
#import "NSMutableData+Bitcoin.h"
#import "NSString+Utils.h"

@implementation BRCommonDataModel

-(NSData *) toCommonData {
    CommonData *commonData = [[CommonData alloc] init];
    NSMutableData *versionData = [NSMutableData data];
    [versionData appendUInt16:RESERVE_VERSION_NUMBER];
    commonData.version = [NSData dataWithData:versionData];
    commonData.assetId = self.assetId;
    commonData.amount = [self.amount stringToUint64:self.decimals];
    if(self.remarks.removeFirstAndEndSpace.length == 0) {
        commonData.remarks = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        commonData.remarks = [self.remarks.removeFirstAndEndSpace dataUsingEncoding:NSUTF8StringEncoding];
    }
    return [BRSafeUtils generateAdditionalPublishAsset:[commonData data]];
}

@end
