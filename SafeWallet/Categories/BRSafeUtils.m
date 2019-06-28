//
//  BRSafeUtils.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/23.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRSafeUtils.h"
#import "NSData+Bitcoin.h"
#import "NSMutableData+Bitcoin.h"
#import "BRPeerManager.h"
#import "NSManagedObject+Sugar.h"
#import "BRWalletManager.h"

#import "BRAddressEntity.h"
#import "BRBlackHoleAddressSafeEntity+CoreDataProperties.h"
#import "BRBlockAvailableSafeEntity+CoreDataProperties.h"
#import "BRBlockSafeEntity+CoreDataProperties.h"
#import "BRGetCandyEntity+CoreDataProperties.h"
#import "BRIssueDataEnity+CoreDataProperties.h"
#import "BRMasternodeEntiy+CoreDataProperties.h"
#import "BRMerkleBlockEntity.h"
#import "BRPeerEntity.h"
#import "BRPublishIssueDataEnity+CoreDataProperties.h"
#import "BRPutCandyEntity+CoreDataProperties.h"
#import "BRTransactionEntity.h"
#import "BRTxInputEntity.h"
#import "BRTxMetadataEntity.h"
#import "BRTxOutputEntity.h"
#import "DSShapeshiftEntity+CoreDataProperties.h"
#import "BRPublishedTxEntity+CoreDataProperties.h"
#import "BRPublishedTxInputEntity+CoreDataProperties.h"
#import "BRPublishedTxOutputEntity+CoreDataProperties.h"
#import "BRCandyNumberEntity+CoreDataProperties.h"
#import "BRKey.h"
#import "NSString+Utils.h"

#import "BRCoreDataManager.h"
#import "BRPeer.h"
#include <math.h>

@implementation BRSafeUtils

// TODO: 生成资产ID，小乐要按照C++的生成规则来
+ (NSData *) generateIssueAssetID:(IssueData *) issueData {
    NSMutableData *issueStream = [NSMutableData data];
    long long totalAmount = issueData.totalAmount;
    long long firstIssueAmount = issueData.firstIssueAmount;
    long long firstActualAmount = issueData.firstActualAmount;
    long long decimals = [issueData.decimals UInt8AtOffset:0];
    bool destory = issueData.destory;
    bool payCandy = issueData.payCandy;
    long long candyAmout = issueData.candyAmount;
    long long candyExpired = [issueData.candyExpired UInt16AtOffset:0];
    [issueStream appendData:[self writeSerializeSize:issueData.shortName.length]];
    [issueStream appendData:issueData.shortName];
    [issueStream appendData:[self writeSerializeSize:issueData.assetName.length]];
    [issueStream appendData:issueData.assetName];
    [issueStream appendData:[self writeSerializeSize:issueData.assetDesc.length]];
    [issueStream appendData:issueData.assetDesc];
    [issueStream appendData:[self writeSerializeSize:issueData.assetUnit.length]];
    [issueStream appendData:issueData.assetUnit];
    [issueStream appendUInt64:totalAmount];
    [issueStream appendUInt64:firstIssueAmount];
    [issueStream appendUInt64:firstActualAmount];
    [issueStream appendUInt8:decimals];
    if (destory) {
        [issueStream appendUInt8:1];
    } else {
        [issueStream appendUInt8:0];
    }
    if (payCandy) {
        [issueStream appendUInt8:1];
    } else {
        [issueStream appendUInt8:0];
    }
    [issueStream appendUInt64:candyAmout];
    [issueStream appendUInt16:candyExpired];
    [issueStream appendData:[self writeSerializeSize:issueData.remarks.length]];
    [issueStream appendData:issueData.remarks];
    return [NSData dataWithUInt256:issueStream.SHA256_2];
}

+ (NSData *) writeSerializeSize:(NSInteger )  nSize {
    NSMutableData *data = [NSMutableData data];
    if (nSize < 253) {
        [data appendUInt8:nSize];
    } else if (nSize <= 0xFFFF) {
        [data appendUInt8:253];
        [data appendUInt16:nSize];
    } else if (nSize <= 0xFFFFFFFF) {
        [data appendUInt8:254];
        [data appendUInt32:nSize];
    } else {
        [data appendUInt8:255];
        [data appendUInt64:nSize];
    }
    return data;
}

// TODO: 生成资产转让 reserve 数据
+ (NSData *) generateTransferredAssetData:(BRBalanceModel *) balanceModel {
    NSMutableData *reserveData = [NSMutableData data];
    NSMutableData *sendReservesData = [NSMutableData data];
    [sendReservesData appendData:[@"safe" dataUsingEncoding:NSUTF8StringEncoding]];
    [sendReservesData appendData:balanceModel.version];
    [sendReservesData appendData:[self generateSAFEAppIDData]];
    [sendReservesData appendUInt32:202];
    [sendReservesData appendData:[balanceModel.common data]];
    [reserveData appendVarInt:sendReservesData.length];
    [reserveData appendData:sendReservesData];
    return  reserveData;
}

// TODO: 生成资产找零 reserve 数据
+ (NSData *) generateGiveChangeAssetData:(BRBalanceModel *) balanceModel {
    NSMutableData *sendReserveData = [NSMutableData data];
    NSMutableData *reserveData = [NSMutableData data];
    [sendReserveData appendData:[@"safe" dataUsingEncoding:NSUTF8StringEncoding]];
    [sendReserveData appendData:balanceModel.version];
    [sendReserveData appendData:[self generateSAFEAppIDData]];
    [sendReserveData appendUInt32:204];
    [sendReserveData appendData:[balanceModel.common data]];
    [reserveData appendVarInt:sendReserveData.length];
    [reserveData appendData:sendReserveData];
    return reserveData;
}

// TODO: 生成发行资产 reserve 数据
+ (NSData *)  generatePublishAseetData:(NSData *) issueProtoBufData {
    NSMutableData *sendReserveData = [NSMutableData data];
    NSMutableData *reserveData = [NSMutableData data];
    [sendReserveData appendData:[@"safe" dataUsingEncoding:NSUTF8StringEncoding]];
    [sendReserveData appendUInt16:RESERVE_VERSION_NUMBER];
    [sendReserveData appendData:[self generateSAFEAppIDData]];
    [sendReserveData appendUInt32:200];
    [sendReserveData appendData:issueProtoBufData];
    [reserveData appendVarInt:sendReserveData.length];
    [reserveData appendData:sendReserveData];
    return reserveData;
}

// TODO: 生产发放糖果 reserve 数据
+ (NSData *) generatePutCandyData:(NSData *) putCandyData {
    NSMutableData *sendReserveData = [NSMutableData data];
    NSMutableData *reserveData = [NSMutableData data];
    [sendReserveData appendData:[@"safe" dataUsingEncoding:NSUTF8StringEncoding]];
    [sendReserveData appendUInt16:RESERVE_VERSION_NUMBER];
    [sendReserveData appendData:[self generateSAFEAppIDData]];
    [sendReserveData appendUInt32:205];
    [sendReserveData appendData:putCandyData];
    [reserveData appendVarInt:sendReserveData.length];
    [reserveData appendData:sendReserveData];
    return reserveData;
}

// TODO: 生成追加发行资产 reserve 数据
+ (NSData *) generateAdditionalPublishAsset:(NSData *) commonData {
    NSMutableData *sendReserveData = [NSMutableData data];
    NSMutableData *reserveData = [NSMutableData data];
    [sendReserveData appendData:[@"safe" dataUsingEncoding:NSUTF8StringEncoding]];
    [sendReserveData appendUInt16:RESERVE_VERSION_NUMBER];
    [sendReserveData appendData:[self generateSAFEAppIDData]];
    [sendReserveData appendUInt32:201];
    [sendReserveData appendData:commonData];
    [reserveData appendVarInt:sendReserveData.length];
    [reserveData appendData:sendReserveData];
    return reserveData;
}

// TODO: 生成领取糖果 reserve 数据
+ (NSData *) generateGetCandy:(uint64_t) amount assetId:(NSData *) assetId  remarks:(NSData *) remarks {
    NSMutableData *sendReserveData = [NSMutableData data];
    NSMutableData *reserveData = [NSMutableData data];
    [sendReserveData appendData:[@"safe" dataUsingEncoding:NSUTF8StringEncoding]];
    [sendReserveData appendUInt16:RESERVE_VERSION_NUMBER];
    [sendReserveData appendData:[self generateSAFEAppIDData]];
    [sendReserveData appendUInt32:206];
    GetCandyData *getCandyData = [[GetCandyData alloc] init];
    NSMutableData *versionData = [NSMutableData data];
    [versionData appendUInt16:RESERVE_VERSION_NUMBER];
    getCandyData.version = [NSData dataWithData:versionData];
    getCandyData.amount = amount;
    getCandyData.assetId = assetId;
    getCandyData.remarks = remarks;
    [sendReserveData appendData:[getCandyData data]];
    [reserveData appendVarInt:sendReserveData.length];
    [reserveData appendData:sendReserveData];
    return reserveData;
}

// TODO: 获取安资应用ID
+ (NSData *) generateSAFEAppIDData {
    return [self convertHexStrToData:SAFE_APP_ID];
}

+ (NSMutableData *)convertHexStrToData:(NSString *)str {
    
    if (!str || [str length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    
    if ([str length] %2 == 0) {
        range = NSMakeRange(0,2);
    } else {
        range = NSMakeRange(0,1);
    }
    
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

// TODO: 添加解析数据方法
+ (AuthData *) analysisAuthData:(NSData *) originalData {
    NSError *error;
    AuthData *authData = [[AuthData alloc] initWithData:originalData error:&error];
    if(!error) {
//        BRLog(@"authData -------- %@", authData);
        return authData;
    } else {
        return nil;
    }
}

+ (ExtendData *) analysisExtendData:(NSData *) originalData {
    NSError *error;
    ExtendData *extendData = [[ExtendData alloc] initWithData:originalData error:&error];
    if(!error) {
//        BRLog(@"extendData -------- %@", extendData);
        return extendData;
    } else {
        return nil;
    }
}

// TODO: 解析资产pubbuf
+ (IssueData *) analysisIssueData:(NSData *) originalData {
    NSError *error;
    IssueData *issueData = [[IssueData alloc] initWithData:originalData error:&error];
    if(!error) {
//        BRLog(@"issueData -------- %@", issueData);
        return issueData;
    } else {
        return nil;
    }
}

// TODO: 解析资产找零pubbuf
+ (CommonData *) analysisCommonData:(NSData *) originalData {
    NSError *error;
    CommonData *commonData = [[CommonData alloc] initWithData:originalData error:&error];
    if(!error) {
//        BRLog(@"commonData --------- %@", commonData);
        return commonData;
    } else {
        return nil;
    }
}

// TODO: 解析发放糖果pubbuf
+ (PutCandyData *) analysisPutCandyData:(NSData *) originalData {
    NSError *error;
    PutCandyData *putCandyData = [[PutCandyData alloc] initWithData:originalData error:&error];
    if(!error) {
//        BRLog(@"putCandyData --------- %@", putCandyData);
        return putCandyData;
    } else {
        return nil;
    }
}

// TODO: 解析领取糖果pubbuf
+ (GetCandyData *) analysisGetCandyData:(NSData *) originalData {
    NSError *error;
    GetCandyData *getCandyData = [[GetCandyData alloc] initWithData:originalData error:&error];
    if(!error) {
//        BRLog(@"getCandyData --------- %@", getCandyData);
        return getCandyData;
    } else {
        return nil;
    }
}

// TODO: 计算发行资产消耗safe
+ (uint64_t) publishAssetConsumeSafe {
//    int nOffset = [BRPeerManager sharedInstance].lastBlockHeight - APP_START_HEIGHT;
//    if(nOffset < 0)
//        return 0;
//    int nMonth = nOffset / BLOCKS_PER_MONTH;
//    if (nMonth == 0)
//        return (uint64_t)(50000000000);
//    double nLeft = 500.00;
//    for(int i = 1; i <= nMonth; i++) {
//        nLeft *=  0.95;
//        uint32_t thirddata = 0;
//        thirddata = (uint32_t)(nLeft * 1000) % 100 % 10;
//        if (thirddata > 4) {
//            nLeft = (double)((uint32_t)(nLeft * 100) + 1) / 100;
//        } else {
//            if (thirddata == 4) {
//                uint32_t fouthdata =0;
//                fouthdata = (uint32_t)(nLeft * 10000) % 1000 % 100 %10;
//                if (fouthdata > 4)
//                    nLeft = (double)((uint32_t)(nLeft * 100) + 1) / 100;
//                else
//                    nLeft = (double)((uint32_t)(nLeft * 100)) / 100;
//            } else {
//                nLeft = (double)((uint32_t)(nLeft * 100)) / 100;
//            }
//        }
//        if (nLeft < 50)
//            nLeft = 50.00;
//    }
//    uint64_t value = nLeft * 100000000;
//    if (value % 1000000 == 999999)
//        value += 1;
//    return value;
    
    if ([BRPeerManager sharedInstance].lastBlockHeight >= TEST_START_SPOS_HEIGHT) {
//        int nOffset = [BRPeerManager sharedInstance].lastBlockHeight - TEST_START_SPOS_HEIGHT;
//        if (nOffset < 0)
//            return 0;
//        int nprevMonth = (TEST_START_SPOS_HEIGHT - DisableDash_TX_HEIGHT) / BLOCKS_PER_MONTH;
//        int nMonth = nOffset / BLOCKS_SPOS_PER_MONTH + nprevMonth;

        int nOffset = [BRPeerManager sharedInstance].lastBlockHeight - TEST_START_SPOS_HEIGHT;
        if (nOffset < 0)
            return 0;
        int nprevDay = (TEST_START_SPOS_HEIGHT - DisableDash_TX_HEIGHT) / 576;
        int currentDay = nOffset / BLOCKS_SPOS_PER_DAY;
        int nMonth = (currentDay + nprevDay) / 30;

        if (nMonth == 0)
            return (uint64_t)(50000000000);
        double nLeft = 500.00;
//        for (int i = 1; i <= nMonth; i++) {
//            nLeft *= 0.95;
//            nLeft =  (int) (nLeft * 100 + 0.5) / 100.0;
//            BRLog(@"%f", nLeft);
//        }
//        if (nLeft < 50)
//            nLeft = 50.00;
//        return (uint64_t)(nLeft * 100000000);
        for(int i = 1; i <= nMonth; i++) {
            nLeft *=  0.95;
            uint32_t thirddata = 0;
            thirddata = (uint32_t)(nLeft * 1000) % 100 % 10;
            if (thirddata > 4) {
                nLeft = (double)((uint32_t)(nLeft * 100) + 1) / 100;
            } else {
                if (thirddata == 4) {
                    uint32_t fouthdata = 0;
                    fouthdata = (uint32_t)(nLeft * 10000) % 1000 % 100 %10;
                    if (fouthdata > 4)
                        nLeft = (double)((uint32_t)(nLeft * 100) + 1) / 100;
                    else
                        nLeft = (double)((uint32_t)(nLeft * 100)) / 100;
                } else {
                    nLeft = (double)((uint32_t)(nLeft * 100)) / 100;
                }
            }
            if (nLeft < 50)
                nLeft = 50.00;
        }
        uint64_t value = nLeft * 100000000;
        if (value % 1000000 == 999999)
            value += 1;
        return value;
    } else {
        int nOffset = [BRPeerManager sharedInstance].lastBlockHeight - DisableDash_TX_HEIGHT;
        if (nOffset < 0)
            return 0;
        int nMonth = nOffset / BLOCKS_PER_MONTH;
        if (nMonth == 0)
            return (uint64_t)(50000000000);
        double nLeft = 500.00;
//        for (int i = 1; i <= nMonth; i++) {
//            nLeft *= 0.95;
//            nLeft =  ((int) ((nLeft + 0.005) * 100)) / 100.0;
//        }
//        if (nLeft < 50)
//            nLeft = 50.00;
//        return (uint64_t)(nLeft * 100000000);
        for(int i = 1; i <= nMonth; i++) {
            nLeft *=  0.95;
            uint32_t thirddata = 0;
            thirddata = (uint32_t)(nLeft * 1000) % 100 % 10;
            if (thirddata > 4) {
                nLeft = (double)((uint32_t)(nLeft * 100) + 1) / 100;
            } else {
                if (thirddata == 4) {
                    uint32_t fouthdata = 0;
                    fouthdata = (uint32_t)(nLeft * 10000) % 1000 % 100 %10;
                    if (fouthdata > 4)
                        nLeft = (double)((uint32_t)(nLeft * 100) + 1) / 100;
                    else
                        nLeft = (double)((uint32_t)(nLeft * 100)) / 100;
                } else {
                    nLeft = (double)((uint32_t)(nLeft * 100)) / 100;
                }
            }
            if (nLeft < 50)
                nLeft = 50.00;
        }
        uint64_t value = nLeft * 100000000;
        if (value % 1000000 == 999999)
            value += 1;
        return value;
    }
}

// TODO: safe显示格式
+ (NSDecimalNumber *)translateAssetWithAmount:(uint64_t)amount {
    
    uint64_t tempBalance = amount;
    NSString *stringA = [NSString stringWithFormat:@"%ld",(long)tempBalance];
    NSString *stringB = [NSString stringWithFormat:@"100000000.0000"];
    NSDecimalNumber *totalBalance = [NSDecimalNumber decimalNumberWithString:stringA];
    NSDecimalNumber *actualBalance = [NSDecimalNumber decimalNumberWithString:stringB];
    NSDecimalNumber *finalBalance = [totalBalance decimalNumberByDividingBy:actualBalance];
    return finalBalance;
}

// TODO: 计算reserve字段旷工费
+ (uint64_t) feeReserve:(NSInteger) reserveLength {
    uint64_t reserveFee = 10000;
    if (reserveLength > 300) {
        int count = reserveLength / 300;
        if (reserveLength % 300 > 0) {
            count++;
        }
        reserveFee = reserveFee * count;
    }
    return reserveFee;
}

// TODO: 过滤 安网、银链、安網、銀鏈    （模糊匹配)
+ (NSString *) fuzzyMatchingPublishAssetWithText:(NSString *)text {
    NSArray *array = [[NSArray alloc]initWithObjects:@"安网", @"银链", @"安網", @"銀鏈", @"銀链", @"银鏈", nil];
    NSMutableString *showString = [NSMutableString string];
    for(int i=0; i<array.count; i++) {
        if([text containsString:array[i]]) {
            if(showString.length == 0) {
                [showString appendString:array[i]];
            } else {
                [showString appendString:[NSString stringWithFormat:@"、%@", array[i]]];
            }
        }
    }
    return showString;
}

// TODO: 过滤关键字
+ (NSString *) matchingPublishAssetWithText:(NSString *) text {
    NSArray *array = [[NSArray alloc]initWithObjects:@"安资", @"安聊", @"安投", @"安付", @"安資", @"SafeAsset", @"SafeChat", @"SafeVote", @"SafePay", @"anwang", @"bankledger", @"electionchain", @"safenetspace", @"darknetspace", @"SAFE", @"ELT", @"DNC", @"DNC2", @"BTC", @"ETH", @"EOS", @"LTC", @"DASH", @"ETC", @"bitcoin", @"ethereum", @"LiteCoin", @"Ethereum Classic", @"人民币", @"港元", @"港币", @"澳门元", @"澳门币", @"新台币", @"RMB", @"CNY", @"HKD", @"MOP", @"TWD", @"人民幣", @"港幣", @"澳門元", @"澳門币", @"澳門幣", @"澳门幣", @"新台幣", @"mSAFE", @"μSAFE", @"duffs", @"tSAFE", @"mtSAFE", @"μtSAFE", @"tduffs", nil];
    for(int i=0; i<array.count; i++) {
        if([[text lowercaseString] isEqualToString:[array[i] lowercaseString]]) {
            return array[i];
            break;
        }
    }
    return nil;
}

// TODO: 保存资产 发放糖果 领取糖果信息
+ (void) saveIssueData:(BRTransaction *)tx isMe:(BOOL) isMe blockTime:(int) blockTime blockHeight:(NSInteger) blockHeight {
    @synchronized(self) {
//        BRLog(@"保存数据线程 %@", [NSThread currentThread]);
        uint64_t getCandyAmount = 0;
        NSManagedObjectContext *currentContext = [[BRCoreDataManager sharedInstance] contextForCurrentThread];
        for(int i=0; i<tx.outputReserves.count; i++) {
            if([tx.outputReserves[i] isEqual:[NSNull null]]) continue;
            if(![BRSafeUtils isSafeTransaction:tx.outputReserves[i]]) { // [tx.outputReserves[i] length] > 42
                NSNumber * l = 0;
                NSUInteger off = 0;
                NSData *d = [tx.outputReserves[i] dataAtOffset:off length:&l];
                if([d UInt16AtOffset:38] == 200) { // 资产处理
                    NSError *error;
                    NSData *data = [d subdataWithRange:NSMakeRange(42, d.length-42)];
                    IssueData *issueData = [[IssueData alloc] initWithData:data error:&error];
                    if(!error) {
                        if(isMe && !(blockHeight == 0 || blockHeight == INT32_MAX)) {
                            NSArray *publishIssueData = [[BRCoreDataManager sharedInstance] entity:@"BRPublishIssueDataEnity" objectsMatching:[NSPredicate predicateWithFormat:@"assetId = %@", [self generateIssueAssetID:issueData]]];
                            if(publishIssueData.count != 0) continue;
                            [currentContext performBlockAndWait:^{
                                BRPublishIssueDataEnity *publishIssueEntity = (BRPublishIssueDataEnity *)[[BRCoreDataManager sharedInstance] createEntityNamedWith:@"BRPublishIssueDataEnity"];
                                [publishIssueEntity setAttributesFromIssueData:issueData txHash:[NSData dataWithUInt256:tx.txHash] address:tx.outputAddresses[i]];
                                [[BRCoreDataManager sharedInstance] saveContext:currentContext];
                            }];
                        }
                        NSArray *publishIssueData = [[BRCoreDataManager sharedInstance] entity:@"BRIssueDataEnity" objectsMatching:[NSPredicate predicateWithFormat:@"assetId = %@", [self generateIssueAssetID:issueData]]];
                        if(publishIssueData.count != 0) continue;
                        [currentContext performBlockAndWait:^{
                            BRIssueDataEnity *issueDataEntity = (BRIssueDataEnity *)[[BRCoreDataManager sharedInstance] createEntityNamedWith:@"BRIssueDataEnity"];
                            [issueDataEntity setAttributesFromIssueData:issueData txHash:[NSData dataWithUInt256:tx.txHash]];
                            [[BRCoreDataManager sharedInstance] saveContext:currentContext];
                        }];
                    }
                } else if ([d UInt16AtOffset:38] == 205 && !(blockHeight == 0 || blockHeight == INT32_MAX)) { // 发放糖果处理
                    NSError *error;
                    NSData *data = [d subdataWithRange:NSMakeRange(42, d.length-42)];
                    PutCandyData *putCandyData = [[PutCandyData alloc] initWithData:data error:&error];
                    if(!error) {
                        NSArray *putCandyEntiyArray = [[BRCoreDataManager sharedInstance] entity:@"BRPutCandyEntity" objectsMatching:[NSPredicate predicateWithFormat:@"txId = %@", [NSData dataWithUInt256:tx.txHash]]];
                        if(putCandyEntiyArray.count > 0) continue;
                        NSNumber *decimals;
                        NSString *assetName;
                        NSArray *publishIssueData = [[BRCoreDataManager sharedInstance] entity:@"BRIssueDataEnity" objectsMatching:[NSPredicate predicateWithFormat:@"assetId = %@", putCandyData.assetId]];
                        if(publishIssueData.count >= 1) {
                            BRIssueDataEnity *issueDataEnity = publishIssueData.firstObject;
                            decimals = issueDataEnity.decimals;
                            assetName = issueDataEnity.assetName;
                        } else {
                            for(int j=0; j<tx.outputReserves.count; j++) {
                                if([tx.outputReserves[j] isEqual:[NSNull null]]) continue;
                                if(![BRSafeUtils isSafeTransaction:tx.outputReserves[j]]) { // [tx.outputReserves[j] length] > 42
                                    NSNumber * length = 0;
                                    NSUInteger offlength = 0;
                                    NSData *reserveData = [tx.outputReserves[j] dataAtOffset:offlength length:&length];
                                    if([reserveData UInt16AtOffset:38] == 200) {
                                        NSError *error;
                                        NSData *messageData = [reserveData subdataWithRange:NSMakeRange(42, reserveData.length-42)];
                                        IssueData *issueData = [[IssueData alloc] initWithData:messageData error:&error];
                                        decimals = [NSNumber numberWithInt:[issueData.decimals UInt8AtOffset:0]];
                                        assetName = [[NSString alloc] initWithData:issueData.assetName encoding:NSUTF8StringEncoding];
                                        break;
                                    }
                                }
                            }
                        }
                        [currentContext performBlockAndWait:^{
                            BRPutCandyEntity *putCandyEntity = (BRPutCandyEntity *)[[BRCoreDataManager sharedInstance] createEntityNamedWith:@"BRPutCandyEntity"];
                            [putCandyEntity setAttributesFromPutCandyData:putCandyData txHash:[NSData dataWithUInt256:tx.txHash] txTime:@(blockTime) decimals:decimals assetName:assetName blockHeight:blockHeight index:i outputScript:tx.outputScripts[i]];
                            [[BRCoreDataManager sharedInstance] saveContext:currentContext];
                        }];
                    }
                } else if (isMe && [d UInt16AtOffset:38] == 206) { // 领取糖果处理
//                    if(blockHeight == 0 || blockHeight == INT32_MAX) { // 糖果本地验证通过 改变领取状态。
//                        UInt256 h;
//                        [tx.inputHashes.lastObject getValue:&h];
//                        NSArray *putCandyArray = [BRPutCandyEntity objectsMatching:@"txId = %@", [NSData dataWithUInt256:h]];
//                        if(putCandyArray.count == 0) continue;
//                        if(putCandyArray.count > 0) {
//                            [[BRPutCandyEntity context] performBlockAndWait:^{
//                                for(BRPutCandyEntity *putCandyEntity in putCandyArray) {
//                                    putCandyEntity.isGetCandy = @(1);
//                                }
//                                [BRPutCandyEntity saveContext];
//                            }];
//                        }
//                        continue;
//                    }
                    NSError *error;
                    NSData *data = [d subdataWithRange:NSMakeRange(42, d.length-42)];
                    GetCandyData *getCandyData = [[GetCandyData alloc] initWithData:data error:&error];
                    if(!error) {
                        NSArray *getCandyArray = [[BRCoreDataManager sharedInstance] entity:@"BRGetCandyEntity" objectsMatching:[NSPredicate predicateWithFormat:@"txId = %@ AND address = %@", [NSData dataWithUInt256:tx.txHash], tx.outputAddresses[i]]];//[BRGetCandyEntity objectsMatching:@"txId = %@", [NSData dataWithUInt256:tx.txHash]];
                        if(getCandyArray.count > 0) {
                            if(blockHeight != 0 && blockHeight != INT32_MAX) {
                                [currentContext performBlockAndWait:^{
                                    for(BRGetCandyEntity *e in getCandyArray) {
                                        e.blockTime = @(blockTime);
                                        e.blockHeight = @(blockHeight);
                                    }
                                    [[BRCoreDataManager sharedInstance] saveContext:currentContext];
                                }];
                            }
                            continue;
                        }
                        UInt256 h;
                        [tx.inputHashes.lastObject getValue:&h];
                        NSArray *putCandyArray = [[BRCoreDataManager sharedInstance] entity:@"BRPutCandyEntity" objectsMatching:[NSPredicate predicateWithFormat:@"txId = %@", [NSData dataWithUInt256:h]]];
                        if(putCandyArray.count == 0) continue;
                        BRPutCandyEntity *putCandyEntity = putCandyArray.firstObject;
                        [currentContext performBlockAndWait:^{
                            BRGetCandyEntity *getCandyEntity = (BRGetCandyEntity *)[[BRCoreDataManager sharedInstance] createEntityNamedWith:@"BRGetCandyEntity"];
                            [getCandyEntity setAttributesFromGetCandyData:getCandyData txId:[NSData dataWithUInt256:tx.txHash] address:tx.outputAddresses[i] inTxId:[NSData dataWithUInt256:h] version:[d subdataWithRange:NSMakeRange(4, 2)] assetName:putCandyEntity.assetName blockTime:@(blockTime) decimals:putCandyEntity.decimals blockHeight:@(blockHeight)];
                            [[BRCoreDataManager sharedInstance] saveContext:currentContext];
                            BRLog(@"block ======== %ld", (long)blockHeight);
                        }];
                        if(putCandyArray.count > 0) {
                            [currentContext performBlockAndWait:^{
                                for(BRPutCandyEntity *putCandyEntity in putCandyArray) {
                                    putCandyEntity.isGetState = @(2);
                                }
                                [[BRCoreDataManager sharedInstance] saveContext:currentContext];
                            }];
                        }
                        BRLog(@"xxxxxxxxx = %ld", (long)blockHeight);
                    }
                }
                if ([d UInt16AtOffset:38] == 206 && !(blockHeight == 0 || blockHeight == INT32_MAX)) { // 处理已领取糖果数量
                    getCandyAmount += [tx.outputAmounts[i] unsignedLongLongValue];
                }
            }
        }
        // 领取的糖果大于0 存入已领取的数量
        if (getCandyAmount > 0) {
            NSArray *CandyNumberArray = [[BRCoreDataManager sharedInstance] entity:@"BRCandyNumberEntity" objectsMatching:[NSPredicate predicateWithFormat:@"txId = %@", [NSData dataWithUInt256:tx.txHash]]];
            if(CandyNumberArray.count == 0) {
                UInt256 hash;
                [tx.inputHashes[tx.inputHashes.count - 1] getValue:&hash];
                NSData *publishCandyTxId = [NSData dataWithUInt256:hash];
                [currentContext performBlockAndWait:^{
                    BRCandyNumberEntity *candyNumberEntity = (BRCandyNumberEntity *)[[BRCoreDataManager sharedInstance] createEntityNamedWith:@"BRCandyNumberEntity"];
                    [candyNumberEntity setAttributesFromCandyNumber:getCandyAmount txId:[NSData dataWithUInt256:tx.txHash] publishCandyTxId:publishCandyTxId];
                    [[BRCoreDataManager sharedInstance] saveContext:currentContext];
                }];
            }
        }
    }
}

// TODO: 输出资产金额
+ (NSString *) amountForAssetAmount:(uint64_t) amount decimals:(NSInteger) decimals {
    NSNumberFormatter *dashFormat = [[NSNumberFormatter alloc] init];
    dashFormat.lenient = YES;
    dashFormat.numberStyle = NSNumberFormatterCurrencyStyle;
    dashFormat.generatesDecimalNumbers = YES;
    dashFormat.negativeFormat = [dashFormat.positiveFormat
                                 stringByReplacingCharactersInRange:[dashFormat.positiveFormat rangeOfString:@"#"]
                                 withString:@"-#"];
    dashFormat.currencyCode = @"";
    dashFormat.currencySymbol = @"";
    dashFormat.maximumFractionDigits = decimals;
    dashFormat.minimumFractionDigits = decimals;
    return [dashFormat stringFromNumber:[(id)[NSDecimalNumber numberWithLongLong:amount]
                                         decimalNumberByMultiplyingByPowerOf10:-dashFormat.maximumFractionDigits]];
}
// TODO: 输出发送资产金额
+ (NSString *) amountForSendAssetAmount:(uint64_t) amount decimals:(NSInteger) decimals {
    NSNumberFormatter *dashFormat = [[NSNumberFormatter alloc] init];
    dashFormat.lenient = YES;
    dashFormat.numberStyle = NSNumberFormatterCurrencyStyle;
    dashFormat.generatesDecimalNumbers = YES;
    dashFormat.negativeFormat = [dashFormat.positiveFormat
                                 stringByReplacingCharactersInRange:[dashFormat.positiveFormat rangeOfString:@"#"]
                                 withString:@"-#"];
    dashFormat.currencyCode = @"";
    dashFormat.currencySymbol = @"";
    dashFormat.maximumFractionDigits = decimals;
    dashFormat.minimumFractionDigits = 0;
    
    return [dashFormat stringFromNumber:[(id)[NSDecimalNumber numberWithLongLong:amount]
                                         decimalNumberByMultiplyingByPowerOf10:-dashFormat.maximumFractionDigits]];
}

+ (NSString *) amountForAssetAmount:(uint64_t) amount decimals:(NSInteger) decimals name:(NSString *) name {
    NSNumberFormatter *dashFormat = [[NSNumberFormatter alloc] init];
    dashFormat.lenient = YES;
    dashFormat.numberStyle = NSNumberFormatterCurrencyStyle;
    dashFormat.generatesDecimalNumbers = YES;
    dashFormat.negativeFormat = [dashFormat.positiveFormat
                                 stringByReplacingCharactersInRange:[dashFormat.positiveFormat rangeOfString:@"#"]
                                 withString:@"-#"];
    dashFormat.currencyCode = name;
    dashFormat.currencySymbol = [name stringByAppendingString:NARROW_NBSP];;
    dashFormat.maximumFractionDigits = decimals;
    dashFormat.minimumFractionDigits = decimals;
    return [dashFormat stringFromNumber:[(id)[NSDecimalNumber numberWithLongLong:amount]
                                         decimalNumberByMultiplyingByPowerOf10:-dashFormat.maximumFractionDigits]];
}

// TODO: 删除本地数据库所有数据
+ (void) deleteCoreDataData:(BOOL) isReExecution {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    [defs setBool:false forKey:USER_REJECTED_TRANSACTION];
    BRLog(@"24142134124214214214");
    
//    [[NSManagedObject context] performBlockAndWait:^{
//        [BRAddressEntity deleteObjects:[BRAddressEntity allObjects]];
//        [BRTransactionEntity deleteObjects:[BRTransactionEntity allObjects]];
//        [BRTxMetadataEntity deleteObjects:[BRTxMetadataEntity allObjects]];
//
//        [BRPeerEntity deleteObjects:[BRPeerEntity allObjects]];
//        [BRMerkleBlockEntity deleteObjects:[BRMerkleBlockEntity allObjects]];
//        [DSShapeshiftEntity deleteObjects:[DSShapeshiftEntity allObjects]];
//        [BRTxInputEntity deleteObjects:[BRTxInputEntity allObjects]];
//        [BRTxOutputEntity deleteObjects:[BRTxOutputEntity allObjects]];
//        [NSManagedObject saveContext];
//    }];

    [[NSManagedObject context] performBlockAndWait:^{
        [NSManagedObject saveContext];
        [BRAddressEntity deleteEntityAllData:@"BRAddressEntity"];
        [BRTransactionEntity deleteEntityAllData:@"BRTransactionEntity"];
        [BRTxMetadataEntity deleteEntityAllData:@"BRTxMetadataEntity"];
        
        [BRPeerEntity deleteEntityAllData:@"BRPeerEntity"];
        [BRMerkleBlockEntity deleteEntityAllData:@"BRMerkleBlockEntity"];
        [DSShapeshiftEntity deleteEntityAllData:@"DSShapeshiftEntity"];
        [BRTxInputEntity deleteEntityAllData:@"BRTxInputEntity"];
        [BRTxOutputEntity deleteEntityAllData:@"BRTxOutputEntity"];
        
    }];
    // TODO:添加删除数据库表
    [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlockAndWait:^{
        [[BRCoreDataManager sharedInstance] deleteEntityAllData:@"BRBlackHoleAddressSafeEntity"];
        [[BRCoreDataManager sharedInstance] deleteEntityAllData:@"BRBlockAvailableSafeEntity"];
        [[BRCoreDataManager sharedInstance] deleteEntityAllData:@"BRBlockSafeEntity"];
        [[BRCoreDataManager sharedInstance] deleteEntityAllData:@"BRGetCandyEntity"];
        [[BRCoreDataManager sharedInstance] deleteEntityAllData:@"BRIssueDataEnity"];

        [[BRCoreDataManager sharedInstance] deleteEntityAllData:@"BRPublishIssueDataEnity"];
        [[BRCoreDataManager sharedInstance] deleteEntityAllData:@"BRPutCandyEntity"];
        [[BRCoreDataManager sharedInstance] deleteEntityAllData:@"BRPublishedTxEntity"];
        [[BRCoreDataManager sharedInstance] deleteEntityAllData:@"BRPublishedTxInputEntity"];
        [[BRCoreDataManager sharedInstance] deleteEntityAllData:@"BRPublishedTxOutputEntity"];
        
        [[BRCoreDataManager sharedInstance] deleteEntityAllData:@"BRCandyNumberEntity"];
    }];
    
    [[BRWalletManager sharedInstance].wallet cleanWalletCacheData];
    [[BRPeerManager sharedInstance] initializationData];
    if(isReExecution) {
        [self deleteCoreDataData:NO];
    }
    BRLog(@"=24142134124214214214");
}
// TODO: 计算CoinBase交易的金额来统计区块生产的金额  此方案不可行 交易中的金额包含矿工费
+ (void) saveBlockSafeAmountTx:(BRTransaction *) tx Height:(int) height {
    @synchronized(self) {
        if(height == 0 || height == INT32_MAX) return;
#if SAFEWallet_TESTNET // 测试
        if(height < CriticalHeight) return;
#else // 正式
        if(height < CriticalHeight) return;
#endif
        NSArray *safeAmountData = [[BRCoreDataManager sharedInstance] entity:@"BRBlockSafeEntity" objectsMatching:[NSPredicate predicateWithFormat:@"blockHeight = %@", @(height)]];
        if(safeAmountData.count > 0) return;
        uint64_t safeAmount = 0;
        for(NSNumber *amounts in tx.outputAmounts) {
            safeAmount += [amounts unsignedLongLongValue];
        }
#if SAFEWallet_TESTNET // 测试
        if(height == CriticalHeight) {
            safeAmount = (uint64_t)21000000 * 100000000;
        }
#else // 正式
        if(height == CriticalHeight) {
            safeAmount = (uint64_t)21000000 * 100000000;
        }
#endif
        [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlockAndWait:^{
            BRBlockSafeEntity *blockSafeEntity = (BRBlockSafeEntity *)[[BRCoreDataManager sharedInstance] createEntityNamedWith:@"BRBlockSafeEntity"];
            [blockSafeEntity setAttributesFromBlockHeight:height totalAmout:safeAmount];
            [[BRCoreDataManager sharedInstance] saveContext:[BRCoreDataManager sharedInstance].contextForCurrentThread];
        }];
    }

    
}

// TODO: 计算区块中Safe总量
+ (void) saveBlockSafeAmount:(int) height nPrevTarget:(long) nPrevTarget {
    @synchronized(self) {
       
#if SAFEWallet_TESTNET // 测试
         if(height < CriticalHeight) return;
#else // 正式
         if(height < SafeBlock_Amount_HEIGHT) return;
#endif
        NSArray *safeAmountData = [[BRCoreDataManager sharedInstance] entity:@"BRBlockSafeEntity" objectsMatching:[NSPredicate predicateWithFormat:@"blockHeight = %@", @(height)]];
        if(safeAmountData.count > 0) return;
        uint64_t safeAmount = [self getBlockInflation:height nPrevTarget:nPrevTarget fSuperblockPartOnly:NO];
        [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlockAndWait:^{
            BRBlockSafeEntity *blockSafeEntity = (BRBlockSafeEntity *)[[BRCoreDataManager sharedInstance] createEntityNamedWith:@"BRBlockSafeEntity"];
            [blockSafeEntity setAttributesFromBlockHeight:height totalAmout:safeAmount];
            [[BRCoreDataManager sharedInstance] saveContext:[BRCoreDataManager sharedInstance].contextForCurrentThread];
        }];
    }
}
// TODO: 计算区块中safe数量 改用SPOS算法
+ (uint64_t) getSposBlockInflation:(int) height nPrevTarget:(long) nPrevTarget fSuperblockPartOnly:(BOOL) fSuperblockPartOnly
{
    
    int nPrevHeight = height - 1;
#if SAFEWallet_TESTNET // 测试
    uint64_t nSubsidy = 0;
    if(nPrevHeight >= ADJUST_MIN_REWARD_HEIGHT) {
        nSubsidy = 500000000;
    } else {
        nSubsidy = 450000000;
    }
#else // 正式
    uint64_t nSubsidy = 0;
    if(nPrevHeight >= ADJUST_MIN_REWARD_HEIGHT) {
        nSubsidy = 345180768;
    } else {
        nSubsidy = 310662692;
    }
#endif
    
    int nNextDecrementHeight = 1261441;
    int nOffset = nNextDecrementHeight - TEST_START_SPOS_HEIGHT;
    long long nStartDecrementHeight = TEST_START_SPOS_HEIGHT + nOffset * TEST_START_SPOS_BlockTimeRatio;
    
    long long newSubsidyDecreaseBlockCount = SubsidyDecreaseBlockCount * TEST_START_SPOS_BlockTimeRatio;
    for (int i = nStartDecrementHeight; i <= nPrevHeight; i += newSubsidyDecreaseBlockCount) {
        nSubsidy = nSubsidy - nSubsidy / 14;
    }
    
    nSubsidy = nSubsidy / TEST_START_SPOS_BlockTimeRatio;
    
    uint64_t nSuperblockPart = (nPrevHeight > BudgetPaymentsStartBlock) ? nSubsidy / 10 : 0;
    
    return fSuperblockPartOnly ? nSuperblockPart : nSubsidy - nSuperblockPart;
}


//1 ～ 2101  金额 500             total = 1050500
//2102 ～ 5465 金额 450      total = 2564300
//5466  ～ 5872  金额 137.7
// TODO: 计算区块中safe数量
+ (uint64_t) getBlockInflation:(int) height nPrevTarget:(long) nPrevTarget fSuperblockPartOnly:(BOOL) fSuperblockPartOnly {
    
    if (height >= TEST_START_SPOS_HEIGHT) {
        return [self getSposBlockInflation:height nPrevTarget:nPrevTarget fSuperblockPartOnly:fSuperblockPartOnly];
    }
    
    #if SAFEWallet_TESTNET // 测试
        if(height == CriticalHeight) {
            return (uint64_t)21000000 * 100000000;
        }
    #else // 正式
        if(height == SafeBlock_Amount_HEIGHT) {
            return (uint64_t)1846514477084975;
        }
    #endif

    
    
    double dDiff;
    uint64_t nSubsidyBase;
    int nPrevHeight = height - 1;
    
    if(nPrevHeight <= 4500) {
        dDiff = (double) 0x0000ffff / (double) (nPrevTarget & 0x00ffffff);
    } else {
        dDiff = [self convertTargetToDouble:nPrevTarget];
    }
    
    if (nPrevHeight < 5465) {
        // 1111/((x+1)^2)
        nSubsidyBase = (long) (1111.0 / pow((dDiff + 1.0), 2));
        if(nSubsidyBase > 500) {
            nSubsidyBase = 500;
        } else if (nSubsidyBase < 1) {
            nSubsidyBase = 1;
        }
    } else if (nPrevHeight < 17000 || (dDiff <= 75 && nPrevHeight < 24000)) {
        // 11111/(((x+51)/6)^2)
        nSubsidyBase = (long) (11111.0 / pow((dDiff + 51.0) / 6.0, 2.0));
        if (nSubsidyBase > 500) {
            nSubsidyBase = 500;
        } else if (nSubsidyBase < 25) {
            nSubsidyBase = 25;
        }
    } else {
        // 2222222/(((x+2600)/9)^2)
        nSubsidyBase = (long) (2222222.0 / pow((dDiff + 2600.0) / 9.0, 2.0));
        if (nPrevHeight > CriticalHeight) {
            if (nSubsidyBase > 5) {
                nSubsidyBase = 5;
            } else if (nSubsidyBase < 5) {
                nSubsidyBase = 5;
            }
        } else {
            if (nSubsidyBase > 25) {
                nSubsidyBase = 25;
            } else if (nSubsidyBase < 5) {
                nSubsidyBase = 5;
            }
        }
    }
    
    int nSubsidyBaseInt = (int) nSubsidyBase;
    nSubsidyBase = nSubsidyBaseInt * 1.0;
    
    uint64_t nSubsidy = nSubsidyBase * 100000000;
    
    for (int i = SubsidyDecreaseBlockCount; i <= nPrevHeight; i += SubsidyDecreaseBlockCount) {
        nSubsidy = nSubsidy - nSubsidy / 14;
    }
    
    uint64_t nSuperblockPart = (nPrevHeight > BudgetPaymentsStartBlock) ? nSubsidy / 10 : 0;
    
    return fSuperblockPartOnly ? nSuperblockPart : nSubsidy - nSuperblockPart;
}

+ (double) convertTargetToDouble:(long) targer {
    long nShift = (targer >> 24) * 0xff;
    double dDiff = (double) 0x0000ffff / (double)(targer & 0x00ffffff);
    
    while (nShift < 29) {
        dDiff *= 256.0;
        nShift ++;
    }
    
    while (nShift > 29) {
        dDiff /= 256.0;
        nShift --;
    }
    
    return dDiff;
}

// TODO: 计算区块中黑洞地址中的safe
+ (void) saveBlackHoleAddressSafe:(int) height transaction:(BRTransaction *) tx {
    @synchronized(self) {
        
#if SAFEWallet_TESTNET // 测试
if(height == 0 || height == INT32_MAX || height < CriticalHeight) return;
#else // 正式
if(height == 0 || height == INT32_MAX || height <= SafeBlock_Amount_HEIGHT) return;
#endif
        if(tx.outputReserves.count == 0) return;
        uint64_t amount = 0;
        for(int i=0; i<tx.outputAddresses.count; i++) {
            if(tx.outputReserves[i] == [NSNull null]) continue;
            NSData *d = [tx.outputReserves[i] dataAtOffset:0 length:0];
            NSString *reserve = [[NSString alloc] initWithData:d encoding:NSUTF8StringEncoding];
            if([FILTER_BLACK_HOLE_ADDRESS containsObject:tx.outputAddresses[i]] && [reserve isEqualToString:@"safe"]) {
                amount += [tx.outputAmounts[i] unsignedLongLongValue];
    //            BRLog(@"dafasfasfasfasf %@ %llu %d", tx.outputAddresses[i], [tx.outputAmounts[i] unsignedLongLongValue], height);
            }
        }
        if(amount == 0) {
            return;
        }
        NSArray *blackHoleSafeAmountArray = [[BRCoreDataManager sharedInstance] entity:@"BRBlackHoleAddressSafeEntity" objectsMatching:[NSPredicate predicateWithFormat:@"txId = %@", [NSData dataWithUInt256:tx.txHash]]];
        if(blackHoleSafeAmountArray.count > 0) return;
        [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlockAndWait:^{
            BRBlackHoleAddressSafeEntity *blackHoleAddressSafeEntity = (BRBlackHoleAddressSafeEntity *)[[BRCoreDataManager sharedInstance] createEntityNamedWith:@"BRBlackHoleAddressSafeEntity"];
            [blackHoleAddressSafeEntity setAttributesFromBlockHeight:height totalAmout:amount txId:[NSData dataWithUInt256:tx.txHash]];
            [[BRCoreDataManager sharedInstance] saveContext:[BRCoreDataManager sharedInstance].contextForCurrentThread];
        }];
    }
}
// 的挡土墙 41350631112 0.000017 2368801840000000 getCandyAmount = 17 ********** putCandyEntity = 100
// TODO: 保存某个区块以前所有可用address的safe
+ (void) saveBlockAvailableSafeAddress:(int) height {
    @synchronized(self) {
        [[BRWalletManager sharedInstance].wallet getBlockHeightSafe:height];
        NSArray *putCandyArray = [[BRCoreDataManager sharedInstance] entity:@"BRPutCandyEntity" objectsMatching:[NSPredicate predicateWithFormat:@"blockHeight = %@", @(height)]];
        if(putCandyArray.count <= 0) return;
        NSArray *blockAvailableSafeArray = [[BRCoreDataManager sharedInstance] entity:@"BRBlockAvailableSafeEntity" objectsMatching:[NSPredicate predicateWithFormat:@"height = %@", @(height)]];
        if(blockAvailableSafeArray.count <= 0) return;
        uint64_t safeTotalAmount = [self returnBRBlockSafeEntityTotalAmountSumToHeight:height] - [self returnBRBlackHoleAddressSafeEntityTotalAmountSumToHeight:height];
//        NSArray *blockSafeArray = [NSArray arrayWithArray:[BRBlockSafeEntity objectsMatching:@"blockHeight <= %@", @(height)]];
//        for(BRBlockSafeEntity *blockSafeEntity in blockSafeArray) {
//            safeTotalAmount += [blockSafeEntity.totalAmount unsignedLongLongValue];
//        }
//        NSArray *blackHoleAddressSafeList = [NSArray arrayWithArray:[BRBlackHoleAddressSafeEntity objectsMatching:@"height <= %@", @(height)]];
//        for(BRBlackHoleAddressSafeEntity *blackHoleAddressSafeEntity in blackHoleAddressSafeList) {
//            safeTotalAmount -= [blackHoleAddressSafeEntity.totalAmount unsignedLongLongValue];
//        }
        [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlockAndWait:^{
            for(BRPutCandyEntity *putCandyEntity in putCandyArray) {
                putCandyEntity.isCount = @(1);
                for(BRBlockAvailableSafeEntity *blockAvailableSafeEntity in blockAvailableSafeArray) {
                     uint64_t getCandyAmount = (uint64_t)([blockAvailableSafeEntity.amount unsignedLongLongValue] * 1.0 / safeTotalAmount * [putCandyEntity.candyAmount unsignedLongLongValue]);
//                    if(height == 12172 || height == 12174) {
//                        BRLog(@"%d %@ %@ %llu %f %llu getCandyAmount = %llu ********** putCandyEntity = %llu", height, blockAvailableSafeEntity.address,  putCandyEntity.assetName, [blockAvailableSafeEntity.amount unsignedLongLongValue], [blockAvailableSafeEntity.amount unsignedLongLongValue] * 1.0 / safeTotalAmount, safeTotalAmount, getCandyAmount, (uint64_t)(0.0001 * pow(10, putCandyEntity.decimals.integerValue)));
//                    }
                    if(getCandyAmount != 0 && getCandyAmount >= (0.0001 * pow(10, putCandyEntity.decimals.integerValue))) {
                        putCandyEntity.isGetState = @(1);
                        break;
                    }
                }
            }
            [[BRCoreDataManager sharedInstance] saveContext:[BRCoreDataManager sharedInstance].contextForCurrentThread];
        }];
    }
}

// App启动计算本地为计算的糖果
+ (void) AppStartUpCountCandyIsGet {
    dispatch_async(dispatch_queue_create("Candy_Count_Height_APPStartUp", nil), ^{
        uint32_t height = [BRPeerManager sharedInstance].lastBlockHeight - Candy_Count_Height;
        if(height == 0) return;
        NSArray *CandyList = [[BRCoreDataManager sharedInstance] entity:@"BRPutCandyEntity" objectsMatching:[NSPredicate predicateWithFormat:@"blockHeight <= %@ AND isCount = %@", @(height), @(0)]];
        if(CandyList.count == 0) return;
        [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlockAndWait:^{
            for(BRPutCandyEntity *putCandyEntity in CandyList) {
                putCandyEntity.isCount = @(1);
                uint64_t safeTotalAmount = [self returnBRBlockSafeEntityTotalAmountSumToHeight:[putCandyEntity.blockHeight unsignedIntValue]] - [self returnBRBlackHoleAddressSafeEntityTotalAmountSumToHeight:[putCandyEntity.blockHeight unsignedIntValue]];
                NSArray *blockAvailableSafeArray = [[BRCoreDataManager sharedInstance] entity:@"BRBlockAvailableSafeEntity" objectsMatching:[NSPredicate predicateWithFormat:@"height = %@", @([putCandyEntity.blockHeight unsignedIntValue])]];
                if(blockAvailableSafeArray.count <= 0) continue;
                for(BRBlockAvailableSafeEntity *blockAvailableSafeEntity in blockAvailableSafeArray) {
                    uint64_t getCandyAmount = (uint64_t)([blockAvailableSafeEntity.amount unsignedLongLongValue] * 1.0 / safeTotalAmount * [putCandyEntity.candyAmount unsignedLongLongValue]);
                    if(getCandyAmount != 0 && getCandyAmount >= (0.0001 * pow(10, putCandyEntity.decimals.integerValue))) {
                        putCandyEntity.isGetState = @(1);
                        break;
                    }
                }
            }
            [[BRCoreDataManager sharedInstance] saveContext:[BRCoreDataManager sharedInstance].contextForCurrentThread];
        }];
    });
}

// 统计某个高度下黑洞地址的safe总和
+ (uint64_t) returnBRBlackHoleAddressSafeEntityTotalAmountSumToHeight:(uint32_t) height{
    NSArray *sumArray = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] fetchObjects:[self buildingNSFetchRequestForEntity:@"BRBlackHoleAddressSafeEntity" predicate:[NSPredicate predicateWithFormat:@"height <= %@", @(height)]]]];
    if(sumArray.count == 0) return 0;
    NSDictionary *dict = sumArray.firstObject;
    return [[dict objectForKey:@"sumTotalAmount"] unsignedLongLongValue];
}

// 统计某个高度下safe总和
+ (uint64_t) returnBRBlockSafeEntityTotalAmountSumToHeight:(uint32_t) height{
    
    NSArray *sumArray = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] fetchObjects:[self buildingNSFetchRequestForEntity:@"BRBlockSafeEntity" predicate:[NSPredicate predicateWithFormat:@"blockHeight <= %@", @(height)]]]];
    if(sumArray.count == 0) return 0;
    NSDictionary *dict = sumArray.firstObject;
    return [[dict objectForKey:@"sumTotalAmount"] unsignedLongLongValue];
}

+ (NSFetchRequest *) buildingNSFetchRequestForEntity:(NSString *) entityName predicate:(NSPredicate *) newPredicate{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    fetchRequest.predicate = newPredicate;
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"totalAmount"];
    NSExpression *sumSalaryExpression = [NSExpression expressionForFunction:@"sum:" arguments:@[keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"sumTotalAmount"];
    [expressionDescription setExpression:sumSalaryExpression];
    [expressionDescription setExpressionResultType:NSInteger64AttributeType];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    return fetchRequest;
}

// TODO: 返回已领取糖果总数
+ (uint64_t) returnCandyNumberEntityGetCandyTotalAmount:(NSData *) publishCandyTxId {
    NSArray *sumArray = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] fetchObjects:[self CandyNumberForEntity:@"BRCandyNumberEntity" predicate:[NSPredicate predicateWithFormat:@"publishCandyTxId = %@", publishCandyTxId]]]];
    if(sumArray.count == 0) return 0;
    NSDictionary *dict = sumArray.firstObject;
    return [[dict objectForKey:@"sumTotalAmount"] unsignedLongLongValue];
}

+ (NSFetchRequest *) CandyNumberForEntity:(NSString *) entityName predicate:(NSPredicate *) newPredicate{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];
    fetchRequest.predicate = newPredicate;
    NSExpression *keyPathExpression = [NSExpression expressionForKeyPath:@"candyNumber"];
    NSExpression *sumSalaryExpression = [NSExpression expressionForFunction:@"sum:" arguments:@[keyPathExpression]];
    NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
    [expressionDescription setName:@"sumTotalAmount"];
    [expressionDescription setExpression:sumSalaryExpression];
    [expressionDescription setExpressionResultType:NSInteger64AttributeType];
    [fetchRequest setResultType:NSDictionaryResultType];
    [fetchRequest setPropertiesToFetch:[NSArray arrayWithObject:expressionDescription]];
    return fetchRequest;
}

// 计算糖果可领取时间
+ (NSString *) getCandyTime:(NSInteger) blockHeight {
    NSString *showStr = @"";
    uint32_t diffHeight = 0;
    double minute = 0;
    if (blockHeight > TEST_START_SPOS_HEIGHT) {
        diffHeight = [BRPeerManager sharedInstance].lastBlockHeight - blockHeight;
        if (diffHeight < BLOCKS_SPOS_PER_DAY) {
            minute = (BLOCKS_SPOS_PER_DAY - diffHeight) / 2;
        }
    } else {
        if (blockHeight + BLOCKS_PER_DAY < TEST_START_SPOS_HEIGHT) {
            diffHeight = [BRPeerManager sharedInstance].lastBlockHeight - blockHeight;
            if (diffHeight < BLOCKS_PER_DAY) {
                diffHeight = BLOCKS_PER_DAY - diffHeight;
                #if SAFEWallet_TESTNET // 测试
//                        double minute = diffHeight * BLOCKS_PER_MIN;
                        minute = diffHeight / BLOCKS_PER_MIN;
                #else // 正式
                        minute = diffHeight / BLOCKS_PER_MIN;
                #endif
            }
        } else {
            diffHeight = (blockHeight + BLOCKS_PER_DAY - TEST_START_SPOS_HEIGHT) * TEST_START_SPOS_BlockTimeRatio + TEST_START_SPOS_HEIGHT;
            if ([BRPeerManager sharedInstance].lastBlockHeight < diffHeight) {
                diffHeight = diffHeight - [BRPeerManager sharedInstance].lastBlockHeight;
                minute = diffHeight / 2;
            }
        }
    }
//    uint32_t diffHeight = [BRPeerManager sharedInstance].lastBlockHeight - blockHeight;
//    if(diffHeight < BLOCKS_PER_DAY) {
//        uint32_t diffBlock = BLOCKS_PER_DAY - diffHeight;
//#if SAFEWallet_TESTNET // 测试
//        double minute = diffBlock * BLOCKS_PER_MIN;
////        double minute = diffBlock / BLOCKS_PER_MIN;
//#else // 正式
//        double minute = diffBlock / BLOCKS_PER_MIN;
//#endif
    if (minute != 0) {
        int hour = (int)minute / 60;
        int mine = (int)minute % 60;
        if(hour != 0) {
            if(mine != 0) {
                showStr = [NSString stringWithFormat:NSLocalizedString(@"%d hours %d minute from candy collection", nil), hour, mine];
            } else {
                showStr = [NSString stringWithFormat:NSLocalizedString(@"%d hours from candy collection", nil), hour];
            }
        } else {
            if(mine != 0) {
                showStr = [NSString stringWithFormat:NSLocalizedString(@"%d minutes from candy collection", nil), mine];
            }
        }
    }
    return showStr;
}

// TODO: 打印交易信息
+ (void) logTransaction:(BRTransaction *) transaction {
    BRLog(@"xxxxxxxxxxxxxxxxxxxxxxxxxxx %@ %u", uint256_obj(transaction.txHash), transaction.blockHeight);
    for(int i=0; i<transaction.inputHashes.count; i++) {
        BRLog(@"%@ inputHashes %@ inputAddresses %@ inputScripts %@ inputSignatures %@ inputSequences %@", transaction.inputIndexes[i], transaction.inputHashes[i], transaction.inputAddresses[i], transaction.inputScripts[i], transaction.inputSignatures[i], transaction.inputSequences[i]);
    }
    for(int i=0; i<transaction.outputAmounts.count; i++) {
        BRLog(@"outputAmounts %@ outputAddresses %@ outputScripts %@ outputUnlockHeights %@ outputReserves %@", transaction.outputAmounts[i], transaction.outputAddresses[i], transaction.outputScripts[i], transaction.outputUnlockHeights[i], transaction.outputReserves[i]);
    }
    BRLog(@"ssssssssssssssssssssssssss");
}

// 显示SAFE金额
+ (NSString *) showSAFEAmount:(uint64_t) amount {
    NSInteger index;
    if(![[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name]) {
        index = 2;
    } else {
        index = [[[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name] integerValue];
    }
    if(index == 0) {
        return [self amountForAssetAmount:amount decimals:8];
    } else if (index == 1) {
        if((amount % ((uint64_t)(pow(10, 2)))) >= 50) {
            return [self amountForAssetAmount:((uint64_t)(amount / pow(10, 2)) + 1) decimals:6];
        } else {
            return [self amountForAssetAmount:((uint64_t)(amount / pow(10, 2))) decimals:6];
        }
    } else if (index == 2) {
        if((amount % ((uint64_t)(pow(10, 4)))) >= 5000) {
            return [self amountForAssetAmount:((uint64_t)(amount / pow(10, 4)) + 1) decimals:4];
        } else {
            return [self amountForAssetAmount:((uint64_t)(amount / pow(10, 4))) decimals:4];
        }
    } else if (index == 3) {
        if((amount % ((uint64_t)(pow(10, 3)))) >= 500) {
            return [self amountForAssetAmount:((uint64_t)(amount / pow(10, 3)) + 1) decimals:2];
        } else {
            return [self amountForAssetAmount:((uint64_t)(amount / pow(10, 3))) decimals:2];
        }
    } else {
        if((amount % ((uint64_t)(pow(10, 2)))) >= 50) {
            return [self amountForAssetAmount:(uint64_t)((amount / pow(10, 2)) + 1) decimals:0];
        } else {
            return [self amountForAssetAmount:(uint64_t)(amount / pow(10, 2)) decimals:0];
        }
    }
}

+ (NSString *) showSAFEUint {
    NSInteger index;
    if(![[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name]) {
        index = 2;
    } else {
        index = [[[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name] integerValue];
    }
    if(index == 3) {
        return @"mSAFE";
    } else if (index == 4) {
        return @"μSAFE";
    }
    return @"";
}

// safe单位换算uint64
+ (uint64_t) safeUintAmount:(NSString *) amount {
    NSInteger index;
    if(![[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name]) {
        index = 2;
    } else {
        index = [[[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name] integerValue];
    }
    if(index == 3) {
        return [amount stringToUint64:5];
    } else if (index == 4) {
        return [amount stringToUint64:2];
    }
    return [amount stringToUint64:8];
}

// 返回safe小数位输入
+ (NSInteger) limitSafeDecimal {
    NSInteger index;
    if(![[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name]) {
        index = 2;
    } else {
        index = [[[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name] integerValue];
    }
    if (index == 3) {
        return 5;
    } else if (index == 4) {
        return 2;
    } else {
        return 8;
    }
}

// 判断是否是safe交易
+ (BOOL) isSafeTransaction:(NSData *) reserve {
    if([reserve isEqual:[NSNull null]] || reserve.length < 42) { // reserve.length < 42
        return YES;
    } else {
        NSNumber * l = 0;
        NSUInteger off = 0;
        NSData *d = [reserve dataAtOffset:off length:&l];
        if([d UInt16AtOffset:38] == 300) {
            return YES;
        } else {
            return NO;
        }
    }
}

// 删除发送中数据本地数据
+ (void) deletePublishedTx:(NSArray *) txHashes {
    [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlockAndWait:^{
        NSMutableArray *deleteArray = [NSMutableArray array];
        for(NSValue *hash in txHashes) {
            UInt256 hash256;
            [hash getValue:&hash256];
//            BRLog(@"删除发送中数据本地数据%@", uint256_obj(hash256));
            [deleteArray addObjectsFromArray:[NSMutableArray arrayWithArray:[[BRCoreDataManager sharedInstance] entity:@"BRPublishedTxEntity" objectsMatching:[NSPredicate predicateWithFormat:@"txHash = %@", [NSData dataWithUInt256:hash256]]]]];
        }
//        BRLog(@"=======删除safe=======%ld", deleteArray.count);
        [[BRCoreDataManager sharedInstance] deleteEntity:deleteArray];
    }];
}

// 保存发送中的数据
+ (void) savePublishedTx:(BRTransaction *) tx {
    [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlockAndWait:^{
        BRPublishedTxEntity *publishedTxEntity = (BRPublishedTxEntity *)[[BRCoreDataManager sharedInstance] createEntityNamedWith:@"BRPublishedTxEntity"];
        [publishedTxEntity setAttributesFromTx:tx];
        [[BRCoreDataManager sharedInstance] saveContext:[BRCoreDataManager sharedInstance].contextForCurrentThread];
    }];
}

// 获取正在发送中的交易
+ (NSDictionary *) getPublishedTx {
    NSMutableDictionary *txDict = [NSMutableDictionary dictionary];
    [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlockAndWait:^{
        NSArray *txList = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] fetchEntity:@"BRPublishedTxEntity" withPredicate:nil]];
        for(BRPublishedTxEntity *e in txList) {
            BRTransaction *tx = [e transaction];
            txDict[uint256_obj(tx.txHash)] = ^(NSError *error){};
        }
    }];
    return txDict;
}

// 删除正在发送中的所有数据
+ (void) deleteAllPublishedTx{
    [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlockAndWait:^{
        [[BRCoreDataManager sharedInstance] deleteEntityAllData:@"BRPublishedTxEntity"];
    }];
}

// 判断是否是dash交易
+ (BOOL) isDashTransaction:(BRTransaction *) tx {
    for(NSData *reserve in tx.outputReserves) {
        if([reserve isEqual:[NSNull null]]) {
            return YES;
        }
    }
    return NO;
}

// TODO: 获取交易版本
+ (NSInteger) getTxVersionNumber{
    if([BRPeerManager sharedInstance].lastBlockHeight < TEST_START_SPOS_HEIGHT) {
        return TX_VERSION_NUMBER;
    } else {
        // spos 交易版本
        return TX_VERSION_SPOS_NUMBER;
    }
}


@end
