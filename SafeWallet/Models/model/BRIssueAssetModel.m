//
//  BRIssueAssetModel.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/30.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRIssueAssetModel.h"
#import "NSMutableData+Bitcoin.h"
#import "BRSafeUtils.h"
#import "NSString+Utils.h"

@implementation BRIssueAssetModel

- (NSData *) toIssueAssetData {
    return [BRSafeUtils generatePublishAseetData:[[self getIssueData] data]];
}

- (IssueData *) getIssueData {
    IssueData *issueData = [[IssueData alloc] init];
    NSMutableData *versionData = [NSMutableData data];
    [versionData appendUInt16:RESERVE_VERSION_NUMBER];
    issueData.version = [NSData dataWithData:versionData];
    issueData.shortName = [self.shortName.removeFirstAndEndSpace dataUsingEncoding:NSUTF8StringEncoding];
    issueData.assetName = [self.assetName.removeFirstAndEndSpace dataUsingEncoding:NSUTF8StringEncoding];
    issueData.assetDesc = [self.assetDesc.removeFirstAndEndSpace dataUsingEncoding:NSUTF8StringEncoding];
    issueData.assetUnit = [self.assetUnit.removeFirstAndEndSpace dataUsingEncoding:NSUTF8StringEncoding];
    issueData.totalAmount = [self.totalAmount stringToUint64:self.decimals.integerValue];
    issueData.firstIssueAmount = [self.firstIssueAmount stringToUint64:self.decimals.integerValue];
    NSMutableData *decimalsData = [NSMutableData data];
    [decimalsData appendUInt8:[self.decimals integerValue]];
    issueData.decimals = [NSData dataWithData:decimalsData];
    issueData.destory = self.destory;
    issueData.payCandy = self.payCandy;
    NSMutableData *candyExpiredData = [NSMutableData data];
    if(self.payCandy) {
        [candyExpiredData appendUInt16:[self.candyExpired integerValue]];
        issueData.candyAmount = [self getCandyAmount];
        issueData.firstActualAmount = [self getFirstActualAmount];
    } else {
        [candyExpiredData appendUInt16:0];
        issueData.candyAmount = 0;
        issueData.firstActualAmount = [self getFirstActualAmount];
    }
    issueData.candyExpired = [NSData dataWithData:candyExpiredData];
    if(self.remarks.removeFirstAndEndSpace.length == 0) {
        issueData.remarks = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        issueData.remarks = [self.remarks.removeFirstAndEndSpace dataUsingEncoding:NSUTF8StringEncoding];
    }
    BRLog(@"%@", issueData);
    return issueData;
}

- (NSData *) toCandyAssetData {
    PutCandyData *putCandyData = [[PutCandyData alloc] init];
    NSMutableData *versionData = [NSMutableData data];
    [versionData appendUInt16:RESERVE_VERSION_NUMBER];
    putCandyData.version = [NSData dataWithData:versionData];
    putCandyData.assetId = [BRSafeUtils generateIssueAssetID:[self getIssueData]];
    putCandyData.amount = [self getCandyAmount];
    NSMutableData *candyExpiredData = [NSMutableData data];
    [candyExpiredData appendUInt16:[self.candyExpired integerValue]];
    putCandyData.expired = [NSData dataWithData:candyExpiredData];
    if(self.remarks.length == 0) {
        putCandyData.remarks = [@"" dataUsingEncoding:NSUTF8StringEncoding];
    } else {
        putCandyData.remarks = [self.remarks.removeFirstAndEndSpace dataUsingEncoding:NSUTF8StringEncoding];
    }
    return [BRSafeUtils generatePutCandyData:[putCandyData data]];
}

- (uint64_t) getCandyAmount {
    if(self.payCandy) {
//        return (uint64_t)([self.totalAmount stringToUint64:self.decimals.integerValue] * (0.001 +  (int)(self.candyAmount) / 100.0 * (0.1 - 0.001)));
        if(self.candyAmount == 0) self.candyAmount = 1;
        int currentCandy = (int)(self.candyAmount);
        if(currentCandy == 0) currentCandy = 1;
        NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%d", currentCandy]];
        
        
        NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                           decimalNumberHandlerWithRoundingMode:NSRoundDown
                                           scale:0
                                           raiseOnExactness:NO
                                           raiseOnOverflow:NO
                                           raiseOnUnderflow:NO
                                           raiseOnDivideByZero:NO];
        NSString *totalAmountStr = self.totalAmount;
        int decimalsBit = [self.totalAmount getDecimal];
        if(decimalsBit <= self.decimals.integerValue) {
            for(int i=0; i<self.decimals.integerValue - decimalsBit; i++) {
                totalAmountStr = [NSString stringWithFormat:@"%@0", totalAmountStr];
            }
        } else {
            totalAmountStr = [totalAmountStr substringToIndex:totalAmountStr.length - (decimalsBit - self.decimals.integerValue)];
        }
        if(totalAmountStr.length == 0) totalAmountStr = @"0";
        totalAmountStr = [totalAmountStr stringByReplacingOccurrencesOfString:@"." withString:@""];
        NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:totalAmountStr];
        number = [number decimalNumberByMultiplyingBy:num1 withBehavior:roundUp];
        number = [number decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"] withBehavior:roundUp];
//        BRLog(@"%@ %llu", [NSString stringWithFormat:@"%@", number], number.unsignedLongLongValue);
        return number.unsignedLongLongValue;
//        return (uint64_t)([self.totalAmount stringToUint64:self.decimals.integerValue] * ((int)(self.candyAmount)) / 1000);
    } else {
        return 0;
    }
}

- (uint64_t) getFirstActualAmount {
    return (uint64_t)[self.firstIssueAmount stringToUint64:self.decimals.integerValue] - [self getCandyAmount];
}



@end
