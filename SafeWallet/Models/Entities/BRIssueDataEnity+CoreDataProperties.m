//
//  BRIssueDataEnity+CoreDataProperties.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/22.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//
//

#import "BRIssueDataEnity+CoreDataProperties.h"
#import "BRSafeUtils.h"
#import "NSData+Bitcoin.h"

@implementation BRIssueDataEnity (CoreDataProperties)

+ (NSFetchRequest<BRIssueDataEnity *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"BRIssueDataEnity"];
}

@dynamic version;
@dynamic shortName;
@dynamic assetName;
@dynamic assetDesc;
@dynamic assetUnit;
@dynamic totalAmount;
@dynamic firstIssueAmount;
@dynamic firstActualAmount;
@dynamic decimals;
@dynamic destory;
@dynamic payCandy;
@dynamic candyAmount;
@dynamic candyExpired;
@dynamic remarks;
@dynamic assetId;
@dynamic txId;

- (instancetype)setAttributesFromIssueData:(IssueData *) issueData txHash:(nonnull NSData *)txHash;
{
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
//        BRLog(@"assetId ====== %@ %@ %@", self.assetId, txHash, [[NSString alloc] initWithData:txHash encoding:NSUTF8StringEncoding]);
    }];
    
    return self;
}

@end
