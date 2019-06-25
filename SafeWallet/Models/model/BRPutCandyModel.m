//
//  BRPutCandyModel.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/6.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPutCandyModel.h"
#import "Safe.pbobjc.h"
#import "BRSafeUtils.h"
#import "NSMutableData+Bitcoin.h"
#import "NSString+Utils.h"

@implementation BRPutCandyModel

- (NSData *) toPutCandyData {
    PutCandyData *putCandyData = [[PutCandyData alloc] init];
    NSMutableData *versionData = [NSMutableData data];
    [versionData appendUInt16:RESERVE_VERSION_NUMBER];
    putCandyData.version = [NSData dataWithData:versionData];
    putCandyData.assetId = self.assetId;
    putCandyData.amount = [self getCandy];
    NSMutableData *candyExpiredData = [NSMutableData data];
    [candyExpiredData appendUInt16:[self.expired integerValue]];
    putCandyData.expired = [NSData dataWithData:candyExpiredData];
    if(self.remarks.removeFirstAndEndSpace.length == 0) {
        putCandyData.remarks = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        putCandyData.remarks = [self.remarks.removeFirstAndEndSpace dataUsingEncoding:NSUTF8StringEncoding];
    }
    return [BRSafeUtils generatePutCandyData:[putCandyData data]];
}

- (uint64_t) getCandy {
//    return (uint64_t)(self.totalAmount * (0.001 +  (int)(self.sliderValue) / 100.0 * (0.1 - 0.001)));
    if(self.sliderValue == 0) self.sliderValue = 1;
    int currentCandy = (int)(self.sliderValue);
    if(currentCandy == 0) currentCandy = 1;
    NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%d", currentCandy]];
    
    
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                       decimalNumberHandlerWithRoundingMode:NSRoundDown
                                       scale:0
                                       raiseOnExactness:NO
                                       raiseOnOverflow:NO
                                       raiseOnUnderflow:NO
                                       raiseOnDivideByZero:NO];
    NSString *totalAmountStr = [NSString stringWithFormat:@"%llu", self.totalAmount];
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:totalAmountStr];
    number = [number decimalNumberByMultiplyingBy:num1 withBehavior:roundUp];
    number = [number decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"] withBehavior:roundUp];
    return number.unsignedLongLongValue;
//    return (uint64_t)(self.totalAmount * ((int)self.sliderValue) / 1000);
}

@end
