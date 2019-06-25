//
//  BRPublishIssueDataEnity+CoreDataProperties.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/4.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRPublishIssueDataEnity+CoreDataProperties.h"
#import "BRSafeUtils.h"
#import "NSData+Bitcoin.h"

@implementation BRPublishIssueDataEnity (CoreDataProperties)

+ (NSFetchRequest<BRPublishIssueDataEnity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"BRPublishIssueDataEnity"];
}

@dynamic assetDesc;
@dynamic assetId;
@dynamic assetName;
@dynamic assetUnit;
@dynamic candyAmount;
@dynamic candyExpired;
@dynamic decimals;
@dynamic destory;
@dynamic firstActualAmount;
@dynamic firstIssueAmount;
@dynamic payCandy;
@dynamic remarks;
@dynamic shortName;
@dynamic totalAmount;
@dynamic txId;
@dynamic version;
@dynamic assetAddress;

- (instancetype)setAttributesFromIssueData:(IssueData *) issueData txHash:(NSData *) txHash address:(NSString *) address {
    [self.managedObjectContext performBlockAndWait:^{
        self.version = [NSNumber numberWithInt:[issueData.version UInt16AtOffset:0]];
        self.shortName = [[NSString alloc] initWithData:issueData.shortName encoding:NSUTF8StringEncoding];
        self.assetName = [[NSString alloc] initWithData:issueData.assetName encoding:NSUTF8StringEncoding];
        self.assetDesc = [[NSString alloc] initWithData:issueData.assetDesc encoding:NSUTF8StringEncoding];
        self.assetUnit = [[NSString alloc] initWithData:issueData.assetUnit encoding:NSUTF8StringEncoding];
        self.totalAmount = @(issueData.totalAmount);
        self.firstIssueAmount = @(issueData.firstIssueAmount);
        self.firstActualAmount = @(issueData.firstActualAmount);
        self.decimals = [NSNumber numberWithInt:[issueData.decimals UInt8AtOffset:0]];
        self.destory = @(issueData.destory);
        self.payCandy = @(issueData.payCandy);
        self.candyAmount = @(issueData.candyAmount);
        self.candyExpired = [NSNumber numberWithInt:[issueData.candyExpired UInt16AtOffset:0]];
        self.remarks = [[NSString alloc] initWithData:issueData.remarks encoding:NSUTF8StringEncoding];
        self.assetId = [BRSafeUtils generateIssueAssetID:issueData];
        self.txId = txHash;
        self.assetAddress = address;
        //        BRLog(@"assetId ====== %@ %@ %@", self.assetId, txHash, [[NSString alloc] initWithData:txHash encoding:NSUTF8StringEncoding]);
    }];
    
    return self;
}

@end
