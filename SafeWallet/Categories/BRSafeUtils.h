//
//  BRSafeUtils.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/23.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Safe.pbobjc.h"
#import "BRBalanceModel.h"
#import "BRTransaction.h"
#import "BRCommonDataModel.h"

#define TX_VERSION_NUMBER 102
#define TX_VERSION_SPOS_NUMBER 103
#define RESERVE_VERSION_NUMBER 1  // 安资序列号

#define SAFE_APP_ID @"88b2a905e89ee402ada6624b70c186062ea3606999e43081ade216f00b45e2cf" //安资APP_ID cfe2450bf016e2ad8130e4996960a32e0686c1704b62a6ad02e49ee805a9b288

#define BLACK_HOLE_ADDRESS @"XagqqFetxiDb9wbartKDrXgnqLah9fKoTx" //销毁SAFE黑洞地址

#define CANDY_BLACK_HOLE_ADDRESS @"XagqqFetxiDb9wbartKDrXgnqLahUovwfs" //销毁糖果黑洞地址

#define FILTER_BLACK_HOLE_ADDRESS  @[@"XagqqFetxiDb9wbartKDrXgnqLah6SqX2S", @"XagqqFetxiDb9wbartKDrXgnqLah9fKoTx", @"XagqqFetxiDb9wbartKDrXgnqLahHSe2VE", @"XagqqFetxiDb9wbartKDrXgnqLahUovwfs"]  // 黑洞地址

#if SAFEWallet_TESTNET // 测试
//#define BLOCKS_PER_MIN 2.5 // 一分钟产生的块（生产：0.4 | 测试：2.5）
#define BLOCKS_PER_MIN 0.4 // 一分钟产生的块（生产：0.4 | 测试：2.5） test 链 2.5分钟生成一个块
#else // 正式
#define BLOCKS_PER_MIN 0.4 // 一分钟产生的块（生产：0.4 | 测试：2.5）
#endif

#define BLOCKS_SPOS_PER_MIN 30 // spos 30秒产生一个块   10      30

#define BLOCKS_SPOS_PER_DAY (24 * 60 * 2)  // spos 一天产生的块   10 * 6  30 * 2

#if SAFEWallet_TESTNET // 测试
//#define BLOCKS_PER_DAY (24 * 60 / BLOCKS_PER_MIN) // 一天产生的区块
#define BLOCKS_PER_DAY (24 * 60 * BLOCKS_PER_MIN) // 一天产生的区块
#else // 正式
#define BLOCKS_PER_DAY (24 * 60 * BLOCKS_PER_MIN) // 一天产生的区块
#endif


#define BLOCKS_PER_MONTH 17280 //一个月产生区块 跟节点配置一样

#define BLOCKS_SPOS_PER_MONTH 86400 // spos 一个月产生区块 跟节点配置一样 10s - 259200  30s - 86400

#define APP_START_HEIGHT 300 // App启动高度

#define MAX_MONEY_SAFE 42000000 * 100000000 // SAFE最大发送金额

#define MAX_ASSETS 2000000000000000000 // 资产发行最大金额

// 修改环境配置
#if SAFEWallet_TESTNET // 测试
#define CriticalHeight 175 // 分叉高度
#else // 正式
#define CriticalHeight 807085 // 分叉高度
#endif


#define SubsidyDecreaseBlockCount 210240

#if SAFEWallet_TESTNET // 测试
#define BudgetPaymentsStartBlock 500 // 超级块
#else // 正式
#define BudgetPaymentsStartBlock 328008 // 超级块
#endif


#if SAFEWallet_TESTNET // 测试
#define DisableDash_TX_HEIGHT 400 // 600 // 封存dash交易
#else // 正式
#define DisableDash_TX_HEIGHT 943809 // 封存dash交易
#endif

#define SafeBlock_Amount_HEIGHT 943810 // 正式环境计算区块safe金额的高度

#define Candy_Count_Height 19 // 糖果延迟计算高度

#define beforehandBlockBodies 20 // 提前下载区块体

#if SAFEWallet_TESTNET // 测试
#define TEST_START_SPOS_HEIGHT 104077 // 开始SPOS高度
#else // 正式
#define TEST_START_SPOS_HEIGHT 1092826 // 开始SPOS高度
#endif

#if SAFEWallet_TESTNET // 测试
#define TEST_START_SPOS_UNLOCK_HEIGHT 121360 // 开始SPOS解锁高度
#else // 正式
#define TEST_START_SPOS_UNLOCK_HEIGHT  // 开始SPOS解锁高度
#endif


#if SAFEWallet_TESTNET // 测试
#define TEST_START_SPOS_PublishAsset_HEIGHT 5000 // 开始SPOS 计算发行资产消耗safe的高度
#else // 正式
#define TEST_START_SPOS_PublishAsset_HEIGHT  // 开始SPOS 计算发行资产消耗safe的高度
#endif


#if SAFEWallet_TESTNET // 测试
#define TEST_START_SPOS_BlockTimeRatio 5 // SPOS 产生区块时间比例。  spos以前是150s产生一个块 之后是30s产生一个块 150 / 30 = 5  150 / 10 = 15
#else // 正式
#define TEST_START_SPOS_BlockTimeRatio 5 // SPOS 产生区块时间比例。  spos以前是150s产生一个块 之后是30s产生一个块 150 / 30 = 5
#endif


@interface BRSafeUtils : NSObject

+ (NSMutableData *)convertHexStrToData:(NSString *)str;

// 解析发布资产ID assetID
+ (NSData *) generateIssueAssetID:(IssueData *) issueData;

// 生成资产转让 reserve 数据
+ (NSData *) generateTransferredAssetData:(BRBalanceModel *) balanceModel;

// 生成资产找零 reserve 数据
+ (NSData *) generateGiveChangeAssetData:(BRBalanceModel *) balanceModel;

// 生成发行资产 reserve 数据
+ (NSData *)  generatePublishAseetData:(NSData *) issueProtoBufData;

// 生成发放糖果 reserve 数据
+ (NSData *) generatePutCandyData:(NSData *) putCandyData;

// 生成追加发行资产 reserve 数据
+ (NSData *) generateAdditionalPublishAsset:(NSData *) commonData;

// 生成领取糖果 reserve 数据
+ (NSData *) generateGetCandy:(uint64_t) amount assetId:(NSData *) assetId  remarks:(NSData *) remarks;

+ (AuthData *) analysisAuthData:(NSData *) originalData;

+ (ExtendData *) analysisExtendData:(NSData *) originalData;

+ (IssueData *) analysisIssueData:(NSData *) originalData;

+ (CommonData *) analysisCommonData:(NSData *) originalData;

+ (PutCandyData *) analysisPutCandyData:(NSData *) originalData;

+ (GetCandyData *) analysisGetCandyData:(NSData *) originalData;

// 计算资产发行消耗safe
+ (uint64_t) publishAssetConsumeSafe;

// safe输出格式
+ (NSDecimalNumber *)translateAssetWithAmount:(uint64_t)amount;

// 计算reserve字段矿工费
+ (uint64_t) feeReserve:(NSInteger) reserveLength;

// 过滤 安网、银链、安網、銀鏈    （模糊匹配)
+ (NSString *) fuzzyMatchingPublishAssetWithText:(NSString *)text;

+ (NSString *) matchingPublishAssetWithText:(NSString *) text;

// 保存资产信息
+ (void) saveIssueData:(BRTransaction *)tx isMe:(BOOL) isMe blockTime:(int) blockTime blockHeight:(NSInteger) blockHeight;

// 输出资产金额
+ (NSString *) amountForAssetAmount:(uint64_t) amount decimals:(NSInteger) decimals;
+ (NSString *) amountForAssetAmount:(uint64_t) amount decimals:(NSInteger) decimals name:(NSString *) name;

// TODO: 输出发送资产金额
+ (NSString *) amountForSendAssetAmount:(uint64_t) amount decimals:(NSInteger) decimals;

// 删除本地数据库所有数据
+ (void) deleteCoreDataData:(BOOL) isReExecution;

// 保存区块safe数量
+ (void) saveBlockSafeAmount:(int) height nPrevTarget:(long) nPrevTarget;

// 计算区块中黑洞地址中的safe
+ (void) saveBlackHoleAddressSafe:(int) height transaction:(BRTransaction *) tx;

//// 保存某个区块以前所有可用address的safe
+ (void) saveBlockAvailableSafeAddress:(int) height;
+ (uint64_t) getBlockInflation:(int) height nPrevTarget:(long) nPrevTarget fSuperblockPartOnly:(BOOL) fSuperblockPartOnly;
+ (void) saveBlockSafeAmountTx:(BRTransaction *) tx Height:(int) height;
// 计算糖果可领取时间
+ (NSString *) getCandyTime:(NSInteger) blockHeight;

// TODO: 打印交易信息
+ (void) logTransaction:(BRTransaction *) transaction;

// 统计某个高度下黑洞地址的safe总和
+ (uint64_t) returnBRBlackHoleAddressSafeEntityTotalAmountSumToHeight:(uint32_t) height;

// 统计某个高度下safe总和
+ (uint64_t) returnBRBlockSafeEntityTotalAmountSumToHeight:(uint32_t) height;

// 显示SAFE金额
+ (NSString *) showSAFEAmount:(uint64_t) amount;

// 显示SAFE单位
+ (NSString *) showSAFEUint;

// safe单位换算uint64
+ (uint64_t) safeUintAmount:(NSString *) amount;

// 返回safe小数位输入
+ (NSInteger) limitSafeDecimal;

// 判断是否是safe交易
+ (BOOL) isSafeTransaction:(NSData *) tx;

// 删除发送中数据本地数据
+ (void) deletePublishedTx:(NSArray *) txHashes;

// 保存发送中的数据
+ (void) savePublishedTx:(BRTransaction *) tx;

// 获取正在发送中的交易
+ (NSDictionary *) getPublishedTx;

// 删除正在发送中的所有数据
+ (void) deleteAllPublishedTx;

// 判断是否是dash交易
+ (BOOL) isDashTransaction:(BRTransaction *) tx;

// App启动计算本地为计算的糖果
+ (void) AppStartUpCountCandyIsGet;

// 返回已领取糖果总数
+ (uint64_t) returnCandyNumberEntityGetCandyTotalAmount:(NSData *) txId;

+ (NSData *) writeSerializeSize:(NSInteger )  nSize;

/// 获取交易版本
+ (NSInteger) getTxVersionNumber;
@end
