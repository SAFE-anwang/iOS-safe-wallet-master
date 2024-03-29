//
//  BRPeerManager.m
//  BreadWallet
//
//  Created by Aaron Voisine on 10/6/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "BRPeerManager.h"
#import "BRPeer.h"
#import "BRPeerEntity.h"
#import "BRBloomFilter.h"
#import "BRKeySequence.h"
#import "BRTransaction.h"
#import "BRTransactionEntity.h"
#import "BRMerkleBlock.h"
#import "BRMerkleBlockEntity.h"
#import "BRWalletManager.h"
#import "NSString+Bitcoin.h"
#import "NSData+Bitcoin.h"
#import "NSManagedObject+Sugar.h"
#import "BREventManager.h"
#import <netdb.h>
#import "BRSafeUtils.h"
#import "NSString+Dash.h"
#import "BRAppDelegate.h"
#import "BRCoreDataManager.h"

#if ! PEER_LOGGING
#define BRLog(...)
#endif

#define FIXED_PEERS          @"FixedPeers"
// TODO: 修改超时时间
#define PROTOCOL_TIMEOUT     100.0 // 20.0
#define MAX_CONNECT_FAILURES 20 // notify user of network problems after this many connect failures in a row
#define CHECKPOINT_COUNT     (sizeof(checkpoint_array)/sizeof(*checkpoint_array))
#define GENESIS_BLOCK_HASH   (*(UInt256 *)@(checkpoint_array[0].hash).hexToData.reverse.bytes)
#define SYNC_STARTHEIGHT_KEY @"SYNC_STARTHEIGHT"

#if DASH_TESTNET

static const struct { uint32_t height; const char *hash; uint32_t timestamp; uint32_t target; } checkpoint_array[] = {
//    {           0, "00000bafbc94add76cb75e2ec92894837288a481e5c005f6563d91623bf8bc2c", 1390666206, 0x1e0ffff0u },
//    {        2999, "0000024bc3f4f4cb30d29827c13d921ad77d2c6072e586c7f60d83c2722cdcc5", 1462856598, 0x1e03ffffu },
//    {        5000, "0000000097e4be8abd515e45947b165b367955457ef7b7efedf9e7e30fc059d0", 1507271366, 0x1d014188u }
//    {      0, "000d8b21044326f9b58110404510ce2b4ee30af5d97dd7de30d551c34dfdc9a2", 1515222820, 0x1f0ffff0u }
    {     0, "000d8b21044326f9b58110404510ce2b4ee30af5d97dd7de30d551c34dfdc9a2", 1515222820, 0x1f0ffff0 },
    {   175, "83379a918b4d93b7b7e1a764dfaa0f8253f7e7875619ace861efa163c5062e43", 1515638900, 0x1f0ffff0 }
};

//static const char *dns_seeds[] = {
//    "testnet-seed.dashdot.io"//,"testnet-seed.dashpay.info"
//};

#else // main net

// blockchain checkpoints - these are also used as starting points for partial chain downloads, so they need to be at
// difficulty transition boundaries in order to verify the block difficulty at the immediately following transition
//static const struct { uint32_t height; const char *hash; uint32_t timestamp; uint32_t target; } checkpoint_array[] = {
//    {      0, "000d8b21044326f9b58110404510ce2b4ee30af5d97dd7de30d551c34dfdc9a2", 1515222820, 0x1f0ffff0u },//dash
//    {    175, "db7cd40b7b9dd3f2107942b21ad59e07051e712390d770d084da5ca2a43e0f81", 1515638657, 0x1e0ffff0u }
//    {   1500, "000000aaf0300f59f49bc3e970bad15c11f961fe2347accffff19d96ec9778e3", 1390109863, 0x1e00ffffu },//dash
//    {   4991, "000000003b01809551952460744d5dbb8fcbd6cbae3c220267bf7fa43f837367", 1390271049, 0x1c426980u },//dash
//    {   9918, "00000000213e229f332c0ffbe34defdaa9e74de87f2d8d1f01af8d121c3c170b", 1391392449, 0x1c41cc20u },//dash
//    {  16912, "00000000075c0d10371d55a60634da70f197548dbbfa4123e12abfcbc5738af9", 1392328997, 0x1c07cc3bu },//dash
//    {  23912, "0000000000335eac6703f3b1732ec8b2f89c3ba3a7889e5767b090556bb9a276", 1393373461, 0x1c0177efu },//dash
//    {  35457, "0000000000b0ae211be59b048df14820475ad0dd53b9ff83b010f71a77342d9f", 1395110315, 0x1c00da53u },//dash
//    {  45479, "000000000063d411655d590590e16960f15ceea4257122ac430c6fbe39fbf02d", 1396620889, 0x1c009c80u },//dash
//    {  55895, "0000000000ae4c53a43639a4ca027282f69da9c67ba951768a20415b6439a2d7", 1398190161, 0x1c00bae3u },//dash
//    {  68899, "0000000000194ab4d3d9eeb1f2f792f21bb39ff767cb547fe977640f969d77b7", 1400148293, 0x1b25df16u },//dash
//    {  74619, "000000000011d28f38f05d01650a502cc3f4d0e793fbc26e2a2ca71f07dc3842", 1401048723, 0x1b1905e3u },//dash
//    {  75095, "0000000000193d12f6ad352a9996ee58ef8bdc4946818a5fec5ce99c11b87f0d", 1401126238, 0x1b2587e3u },//dash
//    {  88805, "00000000001392f1652e9bf45cd8bc79dc60fe935277cd11538565b4a94fa85f", 1403283082, 0x1b194dfbu },//dash
//    { 107996, "00000000000a23840ac16115407488267aa3da2b9bc843e301185b7d17e4dc40", 1406300692, 0x1b11c217u },//dash
//    { 137993, "00000000000cf69ce152b1bffdeddc59188d7a80879210d6e5c9503011929c3c", 1411014812, 0x1b1142abu },//dash
//    { 167996, "000000000009486020a80f7f2cc065342b0c2fb59af5e090cd813dba68ab0fed", 1415730882, 0x1b112d94u },//dash
//    { 207992, "00000000000d85c22be098f74576ef00b7aa00c05777e966aff68a270f1e01a5", 1422026638, 0x1b113c01u },//dash
//    { 217752, "00000000000a7baeb2148272a7e14edf5af99a64af456c0afc23d15a0918b704", 1423563332, 0x1b10c9b6u },//dash
//    { 227121, "00000000000455a2b3a2ed5dfb03990043ca0074568b939acec62820e89a6c45", 1425039295, 0x1b1261d6u },//dash
//    { 246209, "00000000000eec6f7871d3d70321ae98ef1007ab0812d876bda1208afcfb7d7d", 1428046505, 0x1b1a5e27u },//dash
//    { 298549, "00000000000cc467fbfcfd49b82e4f9dc8afb0ef83be7c638f573be6a852ba56", 1436306353, 0x1b1ff0dbu },//dash
//    { 312645, "0000000000059dcb71ad35a9e40526c44e7aae6c99169a9e7017b7d84b1c2daf", 1438525019, 0x1b1c46ceu },//dash
//    { 340000, "000000000014f4e32be2038272cc074a75467c342e25bfe0b566fabe927240b4", 1442833344, 0x1b1acd73u },
//    { 360000, "0000000000136c1c34bfeb783103c77331930768e864aaf91859b302558d292c", 1445983058, 0x1b21ec4eu },
//    { 380000, "00000000000a5ab368be389a048caac7435d7244960e69adaa53eb0b94f8b3c3", 1442833344, 0x1b16c480u },
//    { 400000, "00000000000132b9afeca5e9a2fdf4477338df6dcff1342300240bc70397c4bb", 1452288263, 0x1b0d642eu },
//    { 420000, "000000000006bd43eeab52946f5f47517441ac2339568401468ed6079b83c38e", 1455442477, 0x1b0eda3au },
//    { 440000, "000000000005aca0dc68800e5cd701f4f3bf53e8e0c85d25f03d21a372e23f17", 1458594501, 0x1b124590u },
//    { 460000, "00000000000eab034824bb5284946b36d8890d7c9f657048d3c7d1f405b1a36c", 1461747567, 0x1b14a0c0u },
//    { 480000, "0000000000032ddb3552f63d2c641af5e4e2ca3c25bdcee85c1453876356ff81", 1464893443, 0x1b091760u },
//    { 500000, "000000000002be1cff717f4aa6efc504fa06dc9c453c83773de0b712b8690b7d", 1468042975, 0x1b06a6cfu },
//    { 520000, "000000000002dbfe2d15094c45b9bdf2c511e491af72aeadcb935a926389f468", 1471190891, 0x1b02e8bdu },
//    { 540000, "000000000000daaac22af98ed775d153878c343e019155ed34c46110a12bd112", 1474340382, 0x1b01a7e0u },
//    { 560000, "000000000000b7c1e52ebc9858305793af9554e67399e8d5c6839915b3e91214", 1477493476, 0x1b01da33u },
//    { 580000, "000000000001636ac338ed16dc9fc06aeed60b595e647e014c89a2f0724e3086", 1480643973, 0x1b0184aeu },
//    { 600000, "000000000000a0b730b5be60e65b4a730d1fdcf1d023c9e42c0e5bf4a059f709", 1483795508, 0x1b00db54u },
//    { 620000, "0000000000002e7f2ab6cefe6f63b34c821e7f2f8aa5525c6409dc57677044b4", 1486948317, 0x1b0100c5u },
//    { 640000, "00000000000079dfa97353fd50a420a4425b5e96b1699927da5e89cbabe730bf", 1490098758, 0x1b009c90u },
//    { 660000, "000000000000124a71b04fa91cc37e510fabd66f2286491104ecf54f96148275", 1493250273, 0x1a710fe7u },
//    { 680000, "00000000000012b333e5ba8a85895bcafa8ad3674c2fb8b2de98bf3a5f08fa81", 1496400309, 0x1a64bc7au },
//    { 700000, "00000000000002958852d255726d695ecccfbfacfac318a9d0ebc558eecefeb9", 1499552504, 0x1a37e005u },
//    { 720000, "0000000000000acfc49b67e8e72c6faa2d057720d13b9052161305654b39b281", 1502702260, 0x1a158e98u },
//    { 740000, "00000000000008d0d8a9054072b0272024a01d1920ab4d5a5eb98584930cbd4c", 1505852282, 0x1a0ab756u },
//    { 760000, "000000000000011131c4a8c6446e6ce4597a192296ecad0fb47a23ae4b506682", 1508998683, 0x1a014ed1u },
//    { 807085, "a39e69b248f2ecf4b3a0d881722d339ba14dc6c4e28a88f1e35eb4b3aef05b82",1516415216,0x1e0ffff0}
//};

//static const char *dns_seeds[] = {
    //"dnsseed.dashpay.io","dnsseed.masternode.io","dnsseed.dashdot.io"
//    "120.78.227.96",
//    "114.215.31.37",
//    "47.95.23.220",
//    "47.96.254.235",
//    "106.14.66.206",
//    "47.52.9.168",
//    "47.75.17.223",
//    "47.88.247.232",
//    "47.89.208.160",
//    "47.74.13.245"
//    "120.79.212.222",
//    "47.104.181.37",
//    "47.106.158.88",
//    "118.190.151.31"
//    "54.222.223.23",
//    "52.80.207.207",
//    "54.223.251.201",
//    "54.222.152.47",
//};

#endif

// 修改环境配置
#if SAFEWallet_TESTNET // 测试
static const struct { uint32_t height; const char *hash; uint32_t timestamp; uint32_t target; uint32_t nonce;} checkpoint_array[] = {
    {      0, "000d8b21044326f9b58110404510ce2b4ee30af5d97dd7de30d551c34dfdc9a2", 1515222820, 0x1f0ffff0u, 4705 },//dash
};

static const char *dns_seeds[] = {
//    "54.222.223.23",
//    "52.80.207.207",
//    "54.223.251.201",
//    "54.222.152.47",
//    "106.12.132.195",
//    "182.61.45.230",
//    "182.61.15.31",
//    "182.61.37.132",
//    "106.12.110.113",
    
    "182.61.31.120",
    "182.61.36.187",
    "182.61.37.132",
//    "182.61.13.214",
//    "106.12.110.113",
//    "106.12.110.42",
//    "182.61.134.11",
    
//    "123.207.33.176"   // test链
//    "115.159.235.177", // test链
//    "123.206.90.90",  // test链
//    "119.29.66.245",  // test链
//    "119.29.216.77",  // test链
//    "119.29.161.75",  // test链
//    "119.29.99.238",  // test链
//    "119.29.220.213",  // test链
};
#else // 正式
static const struct { uint32_t height; const char *hash; uint32_t timestamp; uint32_t target; uint32_t nonce; } checkpoint_array[] = {
//    {      0, "00000ffd590b1485b3caadc19b22e6379c733355108f107a430458cdf3407ab6", 1390095618, 0x1e0ffff0u, 28917698 },
    { 807085, "a39e69b248f2ecf4b3a0d881722d339ba14dc6c4e28a88f1e35eb4b3aef05b82", 1516415216, 0x1e0ffff0,  0}
//    {      806075, "0000000000000041c10c85b4e3a15002ffcda76905b658891e2cbe58d99c0fa2", 1516256017, 0x1946436cu, 4173287745 },
};

static const char *dns_seeds[] = {
    "120.78.227.96",
    "114.215.31.37",
    "47.95.23.220",
    "47.96.254.235",
    "106.14.66.206",
    "47.52.9.168",
    "47.75.17.223",
    "47.88.247.232",
    "47.89.208.160",
    "47.74.13.245"
};
#endif

@interface BRPeerManager ()

@property (nonatomic, strong) NSMutableOrderedSet *peers;
@property (nonatomic, strong) NSMutableSet *connectedPeers, *misbehavinPeers, *nonFpTx;
@property (nonatomic, strong) BRPeer *downloadPeer, *fixedPeer;
@property (nonatomic, assign) uint32_t syncStartHeight, filterUpdateHeight;
@property (nonatomic, strong) BRBloomFilter *bloomFilter;
@property (nonatomic, assign) double fpRate;
@property (nonatomic, assign) NSUInteger taskId, connectFailures, misbehavinCount, maxConnectCount;
@property (nonatomic, assign) NSTimeInterval earliestKeyTime, lastRelayTime;
@property (nonatomic, strong) NSMutableDictionary *blocks, *orphans, *checkpoints, *txRelays, *txRequests;
@property (nonatomic, strong) NSMutableDictionary *publishedTx, *publishedCallback;
@property (nonatomic, strong) BRMerkleBlock *lastBlock, *lastOrphan;
@property (nonatomic, strong) dispatch_queue_t q, saveDataQueue, timeQueue;
@property (nonatomic, strong) id backgroundObserver, seedObserver;

@end

@implementation BRPeerManager

+ (instancetype)sharedInstance
{
    static id singleton = nil;
    static dispatch_once_t onceToken = 0;
    
    dispatch_once(&onceToken, ^{
        singleton = [self new];
    });
    
    return singleton;
}

- (instancetype)init
{
    if (! (self = [super init])) return nil;
    
    self.earliestKeyTime = [BRWalletManager sharedInstance].seedCreationTime;
    [self initializationData];
    // TODO: 获取正在发送中的交易
    self.publishedCallback = [NSMutableDictionary dictionaryWithDictionary:[BRSafeUtils getPublishedTx]];

    self.backgroundObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           [self savePeers];
                                                           [self saveBlocks];
                                                           
                                                           if (self.taskId == UIBackgroundTaskInvalid) {
                                                               self.misbehavinCount = 0;
//                                                               [self.connectedPeers makeObjectsPerformSelector:@selector(disconnect)];
                                                           }
                                                       }];
    
    self.seedObserver =
    [[NSNotificationCenter defaultCenter] addObserverForName:BRWalletManagerSeedChangedNotification object:nil
                                                       queue:nil usingBlock:^(NSNotification *note) {
                                                           self.earliestKeyTime = [BRWalletManager sharedInstance].seedCreationTime;
                                                           self.syncStartHeight = 0;
                                                           [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:SYNC_STARTHEIGHT_KEY];
                                                           [self.txRelays removeAllObjects];
                                                           [self.publishedTx removeAllObjects];
                                                           // TODO: 删除正在发送中的全部交易
                                                           [BRSafeUtils deleteAllPublishedTx];
                                                           [self.publishedCallback removeAllObjects];
                                                           [BRMerkleBlockEntity deleteObjects:[BRMerkleBlockEntity allObjects]];
                                                           [BRMerkleBlockEntity saveContext];
                                                           _blocks = nil;
                                                           _bloomFilter = nil;
                                                           _lastBlock = nil;
                                                           [[self.connectedPeers copy] makeObjectsPerformSelector:@selector(disconnect)];
                                                       }];
    
    return self;
}
// 初始化数据
- (void) initializationData  {
    self.connectedPeers = [NSMutableSet set];
    self.misbehavinPeers = [NSMutableSet set];
    self.nonFpTx = [NSMutableSet set];
    self.taskId = UIBackgroundTaskInvalid;
    self.q = dispatch_queue_create("peermanager", NULL);
    self.orphans = [NSMutableDictionary dictionary];
    self.txRelays = [NSMutableDictionary dictionary];
    self.txRequests = [NSMutableDictionary dictionary];
    self.publishedTx = [NSMutableDictionary dictionary];
    self.publishedCallback = [NSMutableDictionary dictionary];
    self.maxConnectCount = PEER_MAX_CONNECTIONS;
    self.saveDataQueue = dispatch_queue_create("saveDataQueue_safe", NULL);
    self.timeQueue = dispatch_queue_create("isMeTxTimeQueue_safe", NULL);
    
    self.lastBlock = nil;
    self.blocks = nil;
}

- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    if (self.backgroundObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.backgroundObserver];
    if (self.seedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.seedObserver];
}

- (NSMutableOrderedSet *)peers
{
    if (_fixedPeer) return [NSMutableOrderedSet orderedSetWithObject:_fixedPeer];
    if (_peers.count >= _maxConnectCount) return _peers;
    
    @synchronized(self) {
        if (_peers.count >= _maxConnectCount) return _peers;
        _peers = [NSMutableOrderedSet orderedSet];
        
        [[BRPeerEntity context] performBlockAndWait:^{
            for (BRPeerEntity *e in [BRPeerEntity allObjects]) {
                @autoreleasepool {
                    if (e.misbehavin == 0) [_peers addObject:[e peer]];
                    else [self.misbehavinPeers addObject:[e peer]];
                }
            }
        }];
        
        [self sortPeers];
        
        // DNS peer discovery
        NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
        NSMutableArray *peers = [NSMutableArray arrayWithObject:[NSMutableArray array]];
        
        if (_peers.count < PEER_MAX_CONNECTIONS ||
            ((BRPeer *)_peers[PEER_MAX_CONNECTIONS - 1]).timestamp + 3*24*60*60 < now) {
            while (peers.count < sizeof(dns_seeds)/sizeof(*dns_seeds)) [peers addObject:[NSMutableArray array]];
        }

        if (peers.count > 0) {
            dispatch_apply(peers.count, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(size_t i) {
                NSString *servname = @(DASH_STANDARD_PORT).stringValue;
                struct addrinfo hints = { 0, AF_UNSPEC, SOCK_STREAM, 0, 0, 0, NULL, NULL }, *servinfo, *p;
                UInt128 addr = { .u32 = { 0, 0, CFSwapInt32HostToBig(0xffff), 0 } };

                //BRLog(@"DNS lookup %s", dns_seeds[i]);

                if (getaddrinfo(dns_seeds[i], servname.UTF8String, &hints, &servinfo) == 0) {
                    for (p = servinfo; p != NULL; p = p->ai_next) {
                        if (p->ai_family == AF_INET) {
                            addr.u64[0] = 0;
                            addr.u32[2] = CFSwapInt32HostToBig(0xffff);
                            addr.u32[3] = ((struct sockaddr_in *)p->ai_addr)->sin_addr.s_addr;
                        }
//                                                else if (p->ai_family == AF_INET6) {
//                                                    addr = *(UInt128 *)&((struct sockaddr_in6 *)p->ai_addr)->sin6_addr;
//                                                }
                        else continue;

                        uint16_t port = CFSwapInt16BigToHost(((struct sockaddr_in *)p->ai_addr)->sin_port);
                        NSTimeInterval age = 3*24*60*60 + arc4random_uniform(4*24*60*60); // add between 3 and 7 days

                        [peers[i] addObject:[[BRPeer alloc] initWithAddress:addr port:port
                                                                  timestamp:(i > 0 ? now - age : now)
                                                                   services:SERVICES_NODE_NETWORK | SERVICES_NODE_BLOOM]];
                    }

                    freeaddrinfo(servinfo);
                }
            });
         
            for (NSArray *a in peers) [_peers addObjectsFromArray:a];
            
#if DASH_TESTNET
            [self sortPeers];
            return _peers;
#endif
            // if DNS peer discovery fails, fall back on a hard coded list of peers (list taken from satoshi client)
//            if (_peers.count < PEER_MAX_CONNECTIONS) {
//                UInt128 addr = { .u32 = { 0, 0, CFSwapInt32HostToBig(0xffff), 0 } };
//
//                for (NSNumber *address in [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]
//                                                                            pathForResource:FIXED_PEERS ofType:@"plist"]]) {
//                    // give hard coded peers a timestamp between 7 and 14 days ago
//                    addr.u32[3] = CFSwapInt32HostToBig(address.unsignedIntValue);
//                    [_peers addObject:[[BRPeer alloc] initWithAddress:addr port:DASH_STANDARD_PORT
//                                                            timestamp:now - (7*24*60*60 + arc4random_uniform(7*24*60*60))
//                                                             services:SERVICES_NODE_NETWORK | SERVICES_NODE_BLOOM]];
//                }
//            }

            [self sortPeers];
        }
        return _peers;
    }
}

- (NSMutableDictionary *)blocks
{
    if (_blocks.count > 0) return _blocks;
    
    [[BRMerkleBlockEntity context] performBlockAndWait:^{
        if (_blocks.count > 0) return;
        _blocks = [NSMutableDictionary dictionary];
        self.checkpoints = [NSMutableDictionary dictionary];
// TODO:- 向区块中添加检查节点 配置参数  4705
        for (int i = 0; i < CHECKPOINT_COUNT; i++) { // add checkpoints to the block collection
            UInt256 hash = *(UInt256 *)@(checkpoint_array[i].hash).hexToData.reverse.bytes;
            
            _blocks[uint256_obj(hash)] = [[BRMerkleBlock alloc] initWithBlockHash:hash version:1 prevBlock:UINT256_ZERO
                                                                       merkleRoot:UINT256_ZERO timestamp:checkpoint_array[i].timestamp
                                                                           target:checkpoint_array[i].target nonce:checkpoint_array[i].nonce totalTransactions:0 hashes:nil
                                                                            flags:nil height:checkpoint_array[i].height];
            self.checkpoints[@(checkpoint_array[i].height)] = uint256_obj(hash);
        }

        for (BRMerkleBlockEntity *e in [BRMerkleBlockEntity allObjects]) {
            @autoreleasepool {
                BRMerkleBlock *b = e.merkleBlock;
                
                if (b) _blocks[uint256_obj(b.blockHash)] = b;
            }
        };
    }];
    
    
    return _blocks;
}

// this is used as part of a getblocks or getheaders request
- (NSArray *)blockLocatorArray
{
    // append 10 most recent block hashes, decending, then continue appending, doubling the step back each time,
    // finishing with the genesis block (top, -1, -2, -3, -4, -5, -6, -7, -8, -9, -11, -15, -23, -39, -71, -135, ..., 0)
    NSMutableArray *locators = [NSMutableArray array];
    int32_t step = 1, start = 0;
    BRMerkleBlock *b = self.lastBlock;
    
    while (b && b.height > 0) {
        [locators addObject:uint256_obj(b.blockHash)];
        if (++start >= 10) step *= 2;
        
        for (int32_t i = 0; b && i < step; i++) {
            b = self.blocks[uint256_obj(b.prevBlock)];
        }
    }
    
    [locators addObject:uint256_obj(GENESIS_BLOCK_HASH)];
    return locators;
}

- (BRMerkleBlock *)lastBlock
{
    if (! _lastBlock) {
        NSFetchRequest *req = [BRMerkleBlockEntity fetchReq];
        
        req.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"height" ascending:NO]];
        req.predicate = [NSPredicate predicateWithFormat:@"height >= 0 && height != %d", BLOCK_UNKNOWN_HEIGHT];
        req.fetchLimit = 1;
        _lastBlock = [[BRMerkleBlockEntity fetchObjects:req].lastObject merkleBlock];
        //BRLog(@"_lastBlock ----------------------------------------- %@",_lastBlock);
        
        // if we don't have any blocks yet, use the latest checkpoint that's at least a week older than earliestKeyTime
        for (int i = CHECKPOINT_COUNT - 1; ! _lastBlock && i >= 0; i--) {
            if (i == 0 || checkpoint_array[i].timestamp + 7*24*60*60 < self.earliestKeyTime + NSTimeIntervalSince1970) {
                UInt256 hash = *(UInt256 *)@(checkpoint_array[i].hash).hexToData.reverse.bytes;
                //TODO: 修改nonce参数 4705
                _lastBlock = [[BRMerkleBlock alloc] initWithBlockHash:hash version:1 prevBlock:UINT256_ZERO
                                                           merkleRoot:UINT256_ZERO timestamp:checkpoint_array[i].timestamp
                                                               target:checkpoint_array[i].target nonce:checkpoint_array[i].nonce totalTransactions:0 hashes:nil flags:nil
                                                               height:checkpoint_array[i].height];
            }
        }
        
        if (_lastBlock.height > _estimatedBlockHeight) _estimatedBlockHeight = _lastBlock.height;
    }
    return _lastBlock;
}

- (uint32_t)lastBlockHeight
{
    return self.lastBlock.height;
}

- (double)syncProgress
{
    if (! self.downloadPeer && self.syncStartHeight == 0) return 0.0;
    if (self.downloadPeer.status != BRPeerStatusConnected) return 0.05;
    if (self.lastBlockHeight >= self.estimatedBlockHeight) return 1.0;
    return 0.1 + 0.9 * self.lastBlockHeight / self.estimatedBlockHeight;
//    BRLog(@"lastBlockHeight %d %d %d", self.lastBlockHeight, self.syncStartHeight, self.estimatedBlockHeight);
//    return 0.1 + 0.9*(self.lastBlockHeight - self.syncStartHeight)/(self.estimatedBlockHeight - self.syncStartHeight);
}

// number of connected peers
- (NSUInteger)peerCount
{
    NSUInteger count = 0;
    
    for (BRPeer *peer in [self.connectedPeers copy]) {
        if (peer.status == BRPeerStatusConnected) count++;
    }
    return count;
}

- (NSString *)downloadPeerName
{
    return [self.downloadPeer.host stringByAppendingFormat:@":%d", self.downloadPeer.port];
}

- (BRBloomFilter *)bloomFilterForPeer:(BRPeer *)peer
{
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    
    // every time a new wallet address is added, the bloom filter has to be rebuilt, and each address is only used for
    // one transaction, so here we generate some spare addresses to avoid rebuilding the filter each time a wallet
    // transaction is encountered during the blockchain download
    [manager.wallet addressesWithGapLimit:SEQUENCE_GAP_LIMIT_EXTERNAL + 100 internal:NO];
    [manager.wallet addressesWithGapLimit:SEQUENCE_GAP_LIMIT_INTERNAL + 100 internal:YES];
    
    [manager.wallet addressesBIP32NoPurposeWithGapLimit:SEQUENCE_GAP_LIMIT_EXTERNAL + 100 internal:NO];
    [manager.wallet addressesBIP32NoPurposeWithGapLimit:SEQUENCE_GAP_LIMIT_INTERNAL + 100 internal:YES];
    
    [self.orphans removeAllObjects]; // clear out orphans that may have been received on an old filter
    self.lastOrphan = nil;
    self.filterUpdateHeight = self.lastBlockHeight;
    self.fpRate = BLOOM_REDUCED_FALSEPOSITIVE_RATE;
    
    BRUTXO o;
    NSData *d;
    NSSet *addresses = [manager.wallet.allReceiveAddresses setByAddingObjectsFromSet:manager.wallet.allChangeAddresses];
    NSUInteger i, elemCount = addresses.count + manager.wallet.unspentOutputs.count;
    NSMutableArray *inputs = [NSMutableArray new];

    for (BRTransaction *tx in manager.wallet.allTransactions) { // find TXOs spent within the last 100 blocks
        [self addTransactionToPublishList:tx]; // also populate the tx publish list
        if (tx.blockHeight != TX_UNCONFIRMED && tx.blockHeight + 100 < self.lastBlockHeight) break;
        i = 0;

        for (NSValue *hash in tx.inputHashes) {
            [hash getValue:&o.hash];
            o.n = [tx.inputIndexes[i++] unsignedIntValue];

            BRTransaction *t = [manager.wallet transactionForHash:o.hash];

            if (o.n < t.outputAddresses.count && [manager.wallet containsAddress:t.outputAddresses[o.n]]) {
                [inputs addObject:brutxo_data(o)];
                elemCount++;
            }
        }
    }
    // TODO: 修改数据
    BRBloomFilter *filter = [[BRBloomFilter alloc] initWithFalsePositiveRate:self.fpRate
                                                             forElementCount:(elemCount < 200 ? 300 : elemCount + 100) tweak:(uint32_t)peer.hash
                                                                       flags:BLOOM_UPDATE_ALL];
    
    for (NSString *addr in addresses) {// add addresses to watch for tx receiveing money to the wallet
        if([addr isEqual:[NSNull null]]) continue;
        NSData *hash = addr.addressToHash160;

        if (hash && ! [filter containsData:hash]) [filter insertData:hash];
    }

    for (NSValue *utxo in manager.wallet.unspentOutputs) { // add UTXOs to watch for tx sending money from the wallet
        [utxo getValue:&o];
        d = brutxo_data(o);
        if (! [filter containsData:d]) [filter insertData:d];
    }

    for (d in inputs) { // also add TXOs spent within the last 100 blocks
        if (! [filter containsData:d]) [filter insertData:d];
    }

    // TODO: XXXX if already synced, recursively add inputs of unconfirmed receives
    _bloomFilter = filter;
    return _bloomFilter;
}

- (void)connect
{
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    
    dispatch_async(self.q, ^{
        if ([BRWalletManager sharedInstance].noWallet) return; // check to make sure the wallet has been created
        if (self.connectFailures >= MAX_CONNECT_FAILURES) self.connectFailures = 0; // this attempt is a manual retry
        
        if (self.syncProgress < 1.0) {
            if (self.syncStartHeight == 0) self.syncStartHeight = (uint32_t)[defs integerForKey:SYNC_STARTHEIGHT_KEY];
            
            if (self.syncStartHeight == 0) {
                self.syncStartHeight = self.lastBlockHeight;
                [[NSUserDefaults standardUserDefaults] setInteger:self.syncStartHeight forKey:SYNC_STARTHEIGHT_KEY];
            }
            
            if (self.taskId == UIBackgroundTaskInvalid) { // start a background task for the chain sync
                self.taskId =
                [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                    dispatch_async(self.q, ^{
                        [self saveBlocks];
                    });
                    
                    [self syncStopped];
                }];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerSyncStartedNotification
                                                                    object:nil];
            });
        }
        
        [self.connectedPeers minusSet:[self.connectedPeers objectsPassingTest:^BOOL(id obj, BOOL *stop) {
            return ([obj status] == BRPeerStatusDisconnected) ? YES : NO;
        }]];
        
        self.fixedPeer = [BRPeer peerWithHost:[defs stringForKey:SETTINGS_FIXED_PEER_KEY]];
        self.maxConnectCount = (self.fixedPeer) ? 1 : PEER_MAX_CONNECTIONS;
        if (self.connectedPeers.count >= self.maxConnectCount) return; // already connected to maxConnectCount peers
        
        NSMutableOrderedSet *peers = [NSMutableOrderedSet orderedSetWithOrderedSet:self.peers];
        
        if (peers.count > 100) [peers removeObjectsInRange:NSMakeRange(100, peers.count - 100)];
        
        while (peers.count > 0 && self.connectedPeers.count < self.maxConnectCount) {
            // pick a random peer biased towards peers with more recent timestamps
            BRPeer *p = peers[(NSUInteger)(pow(arc4random_uniform((uint32_t)peers.count), 2)/peers.count)];
            
            if (p && ! [self.connectedPeers containsObject:p]) {
//                [p setDelegate:self queue:self.q];
                // TODO: 添加保存数据队列
                [p setDelegate:self queue:self.q dataQueue:self.saveDataQueue timeQueue:self.timeQueue];
                p.earliestKeyTime = self.earliestKeyTime;
                [self.connectedPeers addObject:p];
                [p connect];
            }
            
            [peers removeObject:p];
        }
        
        if (self.connectedPeers.count == 0) {
            [self syncStopped];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = [NSError errorWithDomain:@"SafeWallet" code:1
                                                 userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"no peers found", nil)}];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerSyncFailedNotification
                                                                    object:nil userInfo:@{@"error":error}];
            });
        }
    });
}

- (void)disconnect
{
    for (BRPeer *peer in self.connectedPeers) {
        self.connectFailures = MAX_CONNECT_FAILURES; // prevent futher automatic reconnect attempts
        [peer disconnect];
    }
}

// rescans blocks and transactions after earliestKeyTime, a new random download peer is also selected due to the
// possibility that a malicious node might lie by omitting transactions that match the bloom filter
- (void)rescan
{
    if (! self.connected) return;
    
    dispatch_async(self.q, ^{
        _lastBlock = nil;
        
        // start the chain download from the most recent checkpoint that's at least a week older than earliestKeyTime
        for (int i = CHECKPOINT_COUNT - 1; ! _lastBlock && i >= 0; i--) {
            if (i == 0 || checkpoint_array[i].timestamp + 7*24*60*60 < self.earliestKeyTime + NSTimeIntervalSince1970) {
                UInt256 hash = *(UInt256 *)@(checkpoint_array[i].hash).hexToData.reverse.bytes;

                _lastBlock = self.blocks[uint256_obj(hash)];
            }
        }
        
        if (self.downloadPeer) { // disconnect the current download peer so a new random one will be selected
            [self.peers removeObject:self.downloadPeer];
            [self.downloadPeer disconnect];
        }
        
        self.syncStartHeight = self.lastBlockHeight;
        
        [[NSUserDefaults standardUserDefaults] setInteger:self.syncStartHeight forKey:SYNC_STARTHEIGHT_KEY];
        [self connect];
    });
}

// adds transaction to list of tx to be published, along with any unconfirmed inputs
- (void)addTransactionToPublishList:(BRTransaction *)transaction
{
    if (transaction.blockHeight == TX_UNCONFIRMED) {
        BRLog(@"[BRPeerManager] add transaction to publish list %@", transaction);
        self.publishedTx[uint256_obj(transaction.txHash)] = transaction;
    
        for (NSValue *hash in transaction.inputHashes) {
            UInt256 h = UINT256_ZERO;
            
            [hash getValue:&h];
            [self addTransactionToPublishList:[[BRWalletManager sharedInstance].wallet transactionForHash:h]];
        }
    }
}

- (void)publishTransaction:(BRTransaction *)transaction completion:(void (^)(NSError *error))completion
{
    BRLog(@"[BRPeerManager] publish transaction %@", transaction);
    if (! transaction.isSigned) {
        if (completion) {
            [[BREventManager sharedEventManager] saveEvent:@"peer_manager:not_signed"];
            completion([NSError errorWithDomain:@"SafeWallet" code:401 userInfo:@{NSLocalizedDescriptionKey:
                                                                                      NSLocalizedString(@"dash transaction not signed", nil)}]);
        }
        
        return;
    }
//    else if (! self.connected && self.connectFailures >= MAX_CONNECT_FAILURES) {
//        if (completion) {
//            [[BREventManager sharedEventManager] saveEvent:@"peer_manager:not_connected"];
//            completion([NSError errorWithDomain:@"SafeWallet" code:-1009 userInfo:@{NSLocalizedDescriptionKey:
//                                                                                        NSLocalizedString(@"not connected to the dash network", nil)}]);
//        }
//        
//        return;
//    }
    
    NSMutableSet *peers = [NSMutableSet setWithSet:self.connectedPeers];
    NSValue *hash = uint256_obj(transaction.txHash);
    
    [self addTransactionToPublishList:transaction];

    // TODO: 添加到所有交易中  
    dispatch_async(self.q, ^{
        [[BRWalletManager sharedInstance].wallet registerTransaction:transaction];
        [BRSafeUtils saveIssueData:transaction isMe:YES blockTime:[[NSDate date] timeIntervalSince1970] blockHeight:INT32_MAX];
        // TODO: 保存正在发送中的交易
        [BRSafeUtils savePublishedTx:transaction];
    });
    
    if (completion) self.publishedCallback[hash] = completion;
    
    NSArray *txHashes = self.publishedTx.allKeys;
    // instead of publishing to all peers, leave out the download peer to see if the tx propogates and gets relayed back
    // TODO: XXX connect to a random peer with an empty or fake bloom filter just for publishing
    if (self.peerCount > 1 && self.downloadPeer) [peers removeObject:self.downloadPeer];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self performSelector:@selector(txTimeout:) withObject:hash afterDelay:PROTOCOL_TIMEOUT];
        
        for (BRPeer *p in peers) {
            if (p.status != BRPeerStatusConnected) continue;
            [p sendInvMessageWithTxHashes:txHashes];
            [p sendPingMessageWithPongHandler:^(BOOL success) {
                if (! success) return;
                for (NSValue *h in txHashes) {
                    if ([self.txRelays[h] containsObject:p] || [self.txRequests[h] containsObject:p]) continue;
                    if (! self.txRequests[h]) self.txRequests[h] = [NSMutableSet set];
                    [self.txRequests[h] addObject:p];
                    [p sendGetdataMessageWithTxHashes:@[h] andBlockHashes:nil];
                }
            }];
        }
    });
}

// number of connected peers that have relayed the transaction
- (NSUInteger)relayCountForTransaction:(UInt256)txHash
{
    return [self.txRelays[uint256_obj(txHash)] count];
}

// seconds since reference date, 00:00:00 01/01/01 GMT
// NOTE: this is only accurate for the last two weeks worth of blocks, other timestamps are estimated from checkpoints
- (NSTimeInterval)timestampForBlockHeight:(uint32_t)blockHeight
{
//    if (blockHeight == TX_UNCONFIRMED) return (self.lastBlock.timestamp - NSTimeIntervalSince1970) + 10*60; //next block
    
    if (blockHeight == TX_UNCONFIRMED) return (self.lastBlock.timestamp - NSTimeIntervalSince1970);

    if (blockHeight >= self.lastBlockHeight) { // future block, assume 10 minutes per block after last block
        return (self.lastBlock.timestamp - NSTimeIntervalSince1970) + (blockHeight - self.lastBlockHeight)*10*60;
    }

    if (_blocks.count > 0) {
        if (blockHeight >= self.lastBlockHeight - DGW_PAST_BLOCKS_MAX) { // recent block we have the header for
            BRMerkleBlock *block = self.lastBlock;

            while (block && block.height > blockHeight) block = self.blocks[uint256_obj(block.prevBlock)];
            if (block) return block.timestamp - NSTimeIntervalSince1970;
        }
    }
    else [[BRMerkleBlockEntity context] performBlock:^{ [self blocks]; }];

    uint32_t h = self.lastBlockHeight, t = self.lastBlock.timestamp;

    for (int i = CHECKPOINT_COUNT - 1; i >= 0; i--) { // estimate from checkpoints
        if (checkpoint_array[i].height <= blockHeight) {
            t = checkpoint_array[i].timestamp + (t - checkpoint_array[i].timestamp)*
            (blockHeight - checkpoint_array[i].height)/(h - checkpoint_array[i].height);
            return t - NSTimeIntervalSince1970;
        }

        h = checkpoint_array[i].height;
        t = checkpoint_array[i].timestamp;
    }
    return checkpoint_array[0].timestamp - NSTimeIntervalSince1970;
}

- (void)setBlockHeight:(int32_t)height andTimestamp:(NSTimeInterval)timestamp forTxHashes:(NSArray *)txHashes
{
    NSArray *updatedTx = [[BRWalletManager sharedInstance].wallet setBlockHeight:height andTimestamp:timestamp
                                                                     forTxHashes:txHashes];
    
    if (height != TX_UNCONFIRMED) { // remove confirmed tx from publish list and relay counts
        [self.publishedTx removeObjectsForKeys:txHashes];
        [self.publishedCallback removeObjectsForKeys:txHashes];
        [self.txRelays removeObjectsForKeys:txHashes];
        
        // TODO: 删除正在发送中的交易
        [BRSafeUtils deletePublishedTx:txHashes];
    }
    
    //    for (NSValue *hash in updatedTx) {
    //        NSError *kvErr = nil;
    //        BRTxMetadataObject *txm;
    //        UInt256 h;
    //
    //        [hash getValue:&h];
    //        //todo reenable this, crashes now
    //        //txm = [[BRTxMetadataObject alloc] initWithTxHash:h store:[BRAPIClient sharedClient].kv];
    //        //txm.blockHeight = height;
    //        if (txm) [[BRAPIClient sharedClient].kv set:txm error:&kvErr];
    //    }
}

- (void)txTimeout:(NSValue *)txHash
{
    void (^callback)(NSError *error) = self.publishedCallback[txHash];
    
//    [self.publishedTx removeObjectForKey:txHash];
    // TODO: 修改正在发送中的交易
//    [BRSafeUtils deletePublishedTx:@[txHash]];
//    [self.publishedCallback removeObjectForKey:txHash];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(txTimeout:) object:txHash];
    
    if (callback) {
        [[BREventManager sharedEventManager] saveEvent:@"peer_manager:tx_canceled_timeout"];
        callback([NSError errorWithDomain:@"SafeWallet" code:BITCOIN_TIMEOUT_CODE userInfo:@{NSLocalizedDescriptionKey:
                                                                                                 NSLocalizedString(@"transaction canceled, network timeout", nil)}]);
    }
}

- (void)syncTimeout
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if (now - self.lastRelayTime < PROTOCOL_TIMEOUT) { // the download peer relayed something in time, so restart timer
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(syncTimeout) object:nil];
        [self performSelector:@selector(syncTimeout) withObject:nil
                   afterDelay:PROTOCOL_TIMEOUT - (now - self.lastRelayTime)];
        return;
    }
    
    dispatch_async(self.q, ^{
        if (! self.downloadPeer) return;
//        BRLog(@"%@:%d chain sync timed out", self.downloadPeer.host, self.downloadPeer.port);
        [self.peers removeObject:self.downloadPeer];
        [self.downloadPeer disconnect];
    });
}

- (void)syncStopped
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(syncTimeout) object:nil];
        
        if (self.taskId != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:self.taskId];
            self.taskId = UIBackgroundTaskInvalid;
        }
    });
}

- (void)loadMempools
{
    for (BRPeer *p in self.connectedPeers) { // after syncing, load filters and get mempools from other peers
        if (p.status != BRPeerStatusConnected) continue;
        
        if (p != self.downloadPeer || self.fpRate > BLOOM_REDUCED_FALSEPOSITIVE_RATE*5.0) {
            [p sendFilterloadMessage:[self bloomFilterForPeer:p].data];
        }

        [p sendInvMessageWithTxHashes:self.publishedCallback.allKeys]; // publish pending tx
        [p sendPingMessageWithPongHandler:^(BOOL success) {
            if (success) {
                [p sendMempoolMessage:self.publishedTx.allKeys completion:^(BOOL success) {
                    if (success) {
                        p.synced = YES;
                        [self removeUnrelayedTransactions];
                        [p sendGetaddrMessage]; // request a list of other bitcoin peers
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter]
                             postNotificationName:BRPeerManagerTxStatusNotification object:nil];
                        });
                    }
                    
                    if (p == self.downloadPeer) {
                        [self syncStopped];
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[NSNotificationCenter defaultCenter]
                             postNotificationName:BRPeerManagerSyncFinishedNotification object:nil];
                        });
                    }
                }];
            }
            else if (p == self.downloadPeer) {
                [self syncStopped];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter]
                     postNotificationName:BRPeerManagerSyncFinishedNotification object:nil];
                });
            }
        }];
    }
}

// unconfirmed transactions that aren't in the mempools of any of connected peers have likely dropped off the network
- (void)removeUnrelayedTransactions
{
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    BOOL rescan = NO, notify = NO;
    NSValue *hash;
    UInt256 h;
    
    // don't remove transactions until we're connected to maxConnectCount peers
    if (self.peerCount < self.maxConnectCount) return;
    
    for (BRPeer *p in self.connectedPeers) { // don't remove tx until all peers have finished relaying their mempools
        if (! p.synced) return;
    }

    for (BRTransaction *tx in manager.wallet.allTransactions) {
        if (tx.blockHeight != TX_UNCONFIRMED) break;
        hash = uint256_obj(tx.txHash);
        if (self.publishedCallback[hash] != NULL) continue;
        
        if ([self.txRelays[hash] count] == 0 && [self.txRequests[hash] count] == 0) {
            // if this is for a transaction we sent, and it wasn't already known to be invalid, notify user of failure
            if (! rescan && [manager.wallet amountSentByTransaction:tx] > 0 && [manager.wallet transactionIsValid:tx]) {
                //BRLog(@"failed transaction %@", tx);
                rescan = notify = YES;
                
                for (NSValue *hash in tx.inputHashes) { // only recommend a rescan if all inputs are confirmed
                    [hash getValue:&h];
                    if ([manager.wallet transactionForHash:h].blockHeight != TX_UNCONFIRMED) continue;
                    rescan = NO;
                    break;
                }
            }
            
            [manager.wallet removeTransaction:tx.txHash];
        }
        else if ([self.txRelays[hash] count] < self.maxConnectCount) {
            // set timestamp 0 to mark as unverified
            BRLog(@"removeUnrelayedTransactions ====== andTimestamp:0");
            // TODO:修改未验证提示
//            [self setBlockHeight:TX_UNCONFIRMED andTimestamp:0 forTxHashes:@[hash]];
        }
    }
    
//    if (notify) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (rescan) {
//                [[BREventManager sharedEventManager] saveEvent:@"peer_manager:tx_rejected_rescan"];
//                NSString *subTitle = NSLocalizedString(@"Your wallet may be out of sync.\n"
//                                                       "This can often be fixed by rescanning the blockchain.", nil);
//                NSMutableParagraphStyle *leftP = [[NSMutableParagraphStyle alloc] init];
//                leftP.alignment = NSTextAlignmentLeft;
//                NSAttributedString *attSubTitle = [[NSAttributedString alloc] initWithString:subTitle attributes:@{NSParagraphStyleAttributeName : leftP}];
//                NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
//                [attrString appendAttributedString:attSubTitle];
//                [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attrString.length)];
//
//                UIAlertController * alert = [UIAlertController
//                                             alertControllerWithTitle:NSLocalizedString(@"transaction rejected", nil)
//                                             message:attrString.string
//                                             preferredStyle:UIAlertControllerStyleAlert];
//                [alert setValue:attrString forKey:@"attributedMessage"];
//
//                UIAlertAction* cancelButton = [UIAlertAction
//                                           actionWithTitle:NSLocalizedString(@"cancel", nil)
//                                           style:UIAlertActionStyleCancel
//                                           handler:^(UIAlertAction * action) {
//                                           }];
//                UIAlertAction* rescanButton = [UIAlertAction
//                                               actionWithTitle:NSLocalizedString(@"rescan", nil)
//                                               style:UIAlertActionStyleDefault
//                                               handler:^(UIAlertAction * action) {
//                                                   [self.publishedCallback removeAllObjects];
//                                                   [self disconnect];
//                                                   [AppTool showHUDView:nil animated:YES];
//                                                   dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
//                                                   dispatch_after(delayTime, dispatch_get_main_queue(), ^{
//                                                       @weakify(self);
//                                                       dispatch_async(dispatch_queue_create("deleteLocalCoreDataData", NULL), ^{
//                                                           @strongify(self);
//                                                           // TODO: 删除本地数据
//                                                           [BRSafeUtils deleteCoreDataData:YES];
//                                                           @weakify(self);
//                                                           dispatch_async(dispatch_get_main_queue(), ^{
//                                                               @strongify(self);
//                                                               [AppTool hideHUDView:nil animated:NO];
//                                                               [self selectTabbarVCSelectedInde];
//                                                               [self rescan];
//                                                           });
//                                                       });
//                                                   });
//                                               }];
//                [alert addAction:cancelButton];
//                [alert addAction:rescanButton];
//                [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
//
//            }
//            else {
//                [[BREventManager sharedEventManager] saveEvent:@"peer_manager_tx_rejected"];
//                UIAlertController * alert = [UIAlertController
//                                             alertControllerWithTitle:NSLocalizedString(@"transaction rejected", nil)
//                                             message:@""
//                                             preferredStyle:UIAlertControllerStyleAlert];
//                UIAlertAction* okButton = [UIAlertAction
//                                           actionWithTitle:NSLocalizedString(@"ok", nil)
//                                           style:UIAlertActionStyleCancel
//                                           handler:^(UIAlertAction * action) {
//                                           }];
//                [alert addAction:okButton];
//                [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
//            }
//        });
//    }
}

- (void) selectTabbarVCSelectedInde {
    BRAppDelegate *delegate = (BRAppDelegate *)[[UIApplication sharedApplication] delegate];
    UITabBarController *tab = (UITabBarController *)delegate.window.rootViewController;
    [[self topViewControllerWithRootViewController:tab].navigationController popToRootViewControllerAnimated:NO];
    tab.selectedIndex = 0;
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController {
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

- (void)updateFilter
{
    if (self.downloadPeer.needsFilterUpdate) return;
    self.downloadPeer.needsFilterUpdate = YES;
    //BRLog(@"filter update needed, waiting for pong");
    
    [self.downloadPeer sendPingMessageWithPongHandler:^(BOOL success) { // wait for pong so we include already sent tx
        if (! success) return;
        //BRLog(@"updating filter with newly created wallet addresses");
        _bloomFilter = nil;
        
        if (self.lastBlockHeight < self.estimatedBlockHeight) { // if we're syncing, only update download peer
            [self.downloadPeer sendFilterloadMessage:[self bloomFilterForPeer:self.downloadPeer].data];
            [self.downloadPeer sendPingMessageWithPongHandler:^(BOOL success) { // wait for pong so filter is loaded
                if (! success) return;
                self.downloadPeer.needsFilterUpdate = NO;
                [self.downloadPeer rerequestBlocksFrom:self.lastBlock.blockHash];
                [self.downloadPeer sendPingMessageWithPongHandler:^(BOOL success) {
                    if (! success || self.downloadPeer.needsFilterUpdate) return;
                    [self.downloadPeer sendGetblocksMessageWithLocators:[self blockLocatorArray]
                                                            andHashStop:UINT256_ZERO];
                }];
            }];
        }
        else {
            for (BRPeer *p in self.connectedPeers) {
                if (p.status != BRPeerStatusConnected) continue;
                [p sendFilterloadMessage:[self bloomFilterForPeer:p].data];
                [p sendPingMessageWithPongHandler:^(BOOL success) { // wait for pong so we know filter is loaded
                    if (! success) return;
                    p.needsFilterUpdate = NO;
                    [p sendMempoolMessage:self.publishedTx.allKeys completion:nil];
                }];
            }
        }
    }];
}

- (void)peerMisbehavin:(BRPeer *)peer
{
    peer.misbehavin++;
    [self.peers removeObject:peer];
    [self.misbehavinPeers addObject:peer];
    
    if (++self.misbehavinCount >= 10) { // clear out stored peers so we get a fresh list from DNS for next connect
        self.misbehavinCount = 0;
        [self.misbehavinPeers removeAllObjects];
        [BRPeerEntity deleteObjects:[BRPeerEntity allObjects]];
        _peers = nil;
    }
    
    [peer disconnect];
    [self connect];
}

- (void)sortPeers
{
    [_peers sortUsingComparator:^NSComparisonResult(BRPeer *p1, BRPeer *p2) {
        if (p1.timestamp > p2.timestamp) return NSOrderedAscending;
        if (p1.timestamp < p2.timestamp) return NSOrderedDescending;
        return NSOrderedSame;
    }];
}

- (void)savePeers
{
    //BRLog(@"[BRPeerManager] save peers");
    NSMutableSet *peers = [[self.peers.set setByAddingObjectsFromSet:self.misbehavinPeers] mutableCopy];
    NSMutableSet *addrs = [NSMutableSet set];
    
    for (BRPeer *p in peers) {
        if (p.address.u64[0] != 0 || p.address.u32[2] != CFSwapInt32HostToBig(0xffff)) continue; // skip IPv6 for now
        [addrs addObject:@(CFSwapInt32BigToHost(p.address.u32[3]))];
    }
    
    [[BRPeerEntity context] performBlock:^{
        [BRPeerEntity deleteObjects:[BRPeerEntity objectsMatching:@"! (address in %@)", addrs]]; // remove deleted peers
        
        for (BRPeerEntity *e in [BRPeerEntity objectsMatching:@"address in %@", addrs]) { // update existing peers
            @autoreleasepool {
                BRPeer *p = [peers member:[e peer]];
                
                if (p) {
                    e.timestamp = p.timestamp;
                    e.services = p.services;
                    e.misbehavin = p.misbehavin;
                    [peers removeObject:p];
                }
                else [e deleteObject];
            }
        }
        
        for (BRPeer *p in peers) {
            @autoreleasepool {
                [[BRPeerEntity managedObject] setAttributesFromPeer:p]; // add new peers
            }
        }
    }];
}

- (void)saveBlocks
{
    //BRLog(@"[BRPeerManager] save blocks");
    NSMutableDictionary *blocks = [NSMutableDictionary dictionary];
    BRMerkleBlock *b = self.lastBlock;
    
    while (b) {
        blocks[[NSData dataWithBytes:b.blockHash.u8 length:sizeof(UInt256)]] = b;
        b = self.blocks[uint256_obj(b.prevBlock)];
    }
    
    [[BRMerkleBlockEntity context] performBlock:^{
        [BRMerkleBlockEntity deleteObjects:[BRMerkleBlockEntity objectsMatching:@"! (blockHash in %@)",
                                            blocks.allKeys]];
        
        for (BRMerkleBlockEntity *e in [BRMerkleBlockEntity objectsMatching:@"blockHash in %@", blocks.allKeys]) {
            @autoreleasepool {
                [e setAttributesFromBlock:blocks[e.blockHash]];
                [blocks removeObjectForKey:e.blockHash];
            }
        }
        
        for (BRMerkleBlock *b in blocks.allValues) {
            @autoreleasepool {
                [[BRMerkleBlockEntity managedObject] setAttributesFromBlock:b];
            }
        }
        
        [BRMerkleBlockEntity saveContext];
    }];
}

// MARK: - BRPeerDelegate

- (void)peerConnected:(BRPeer *)peer
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    if (peer.timestamp > now + 2*60*60 || peer.timestamp < now - 2*60*60) peer.timestamp = now; //timestamp sanity check
    self.connectFailures = 0;
    //BRLog(@"%@:%d connected with lastblock %d", peer.host, peer.port, peer.lastblock);
    
    // drop peers that don't carry full blocks, or aren't synced yet
    // TODO: XXXX does this work with 0.11 pruned nodes?
    if (! (peer.services & SERVICES_NODE_NETWORK) || peer.lastblock + 10 < self.lastBlockHeight) {
        [peer disconnect];
        return;
    }
    
    // drop peers that don't support SPV filtering
    if (peer.version >= 70206 && ! (peer.services & SERVICES_NODE_BLOOM)) {
        [peer disconnect];
        return;
    }
    
    if (self.connected && (self.estimatedBlockHeight >= peer.lastblock || self.lastBlockHeight >= peer.lastblock)) {
        if (self.lastBlockHeight < self.estimatedBlockHeight) return; // don't load bloom filter yet if we're syncing
        [peer sendFilterloadMessage:[self bloomFilterForPeer:peer].data];

        [peer sendInvMessageWithTxHashes:self.publishedCallback.allKeys]; // publish pending tx
        [peer sendPingMessageWithPongHandler:^(BOOL success) {
            if (! success) return;
            [peer sendMempoolMessage:self.publishedTx.allKeys completion:^(BOOL success) {
                if (! success) return;
                peer.synced = YES;
                [self removeUnrelayedTransactions];
                [peer sendGetaddrMessage]; // request a list of other bitcoin peers
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerTxStatusNotification
                                                                        object:nil];
                });
            }];
        }];
        return; // we're already connected to a download peer
    }
    
    // select the peer with the lowest ping time to download the chain from if we're behind
    // BUG: XXX a malicious peer can report a higher lastblock to make us select them as the download peer, if two
    // peers agree on lastblock, use one of them instead
    for (BRPeer *p in self.connectedPeers) {
        if (p.status != BRPeerStatusConnected) continue;
        if ((p.pingTime < peer.pingTime && p.lastblock >= peer.lastblock) || p.lastblock > peer.lastblock) peer = p;
    }
    
    [self.downloadPeer disconnect];
    self.downloadPeer = peer;
    _connected = YES;
    _estimatedBlockHeight = peer.lastblock;
    // TODO: 修改接收全部交易数据
    [peer sendFilterloadMessage:[self bloomFilterForPeer:peer].data];
    peer.currentBlockHeight = self.lastBlockHeight;
    
    //同步区块
    if (self.lastBlockHeight < peer.lastblock) { // start blockchain sync
        self.lastRelayTime = 0;
    
        dispatch_async(dispatch_get_main_queue(), ^{ // setup a timer to detect if the sync stalls
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(syncTimeout) object:nil];
            [self performSelector:@selector(syncTimeout) withObject:nil afterDelay:PROTOCOL_TIMEOUT];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerTxStatusNotification object:nil];
            
            dispatch_async(self.q, ^{
                // request just block headers up to a week before earliestKeyTime, and then merkleblocks after that
                // BUG: XXX headers can timeout on slow connections (each message is over 160k)
                // TODO: 同步所以区块 修改
//                if (self.lastBlock.timestamp + 6*24*60*60 >= self.earliestKeyTime + NSTimeIntervalSince1970) {
                    [peer sendGetblocksMessageWithLocators:[self blockLocatorArray] andHashStop:UINT256_ZERO];
//                }
//                else [peer sendGetheadersMessageWithLocators:[self blockLocatorArray] andHashStop:UINT256_ZERO];
            });
        });
    }
    else { // we're already synced
        self.syncStartHeight = 0;
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:SYNC_STARTHEIGHT_KEY];
        [self loadMempools];
    }
}

- (void)peer:(BRPeer *)peer disconnectedWithError:(NSError *)error
{
    BRLog(@"%@:%d disconnected%@%@", peer.host, peer.port, (error ? @", " : @""), (error ? error : @""));
    
    if ([error.domain isEqual:@"SafeWallet"] && error.code != BITCOIN_TIMEOUT_CODE) {
        [self peerMisbehavin:peer]; // if it's protocol error other than timeout, the peer isn't following the rules
    }
    else if (error) { // timeout or some non-protocol related network error
        [self.peers removeObject:peer];
        self.connectFailures++;
    }
    
    for (NSValue *txHash in self.txRelays.allKeys) {
        [self.txRelays[txHash] removeObject:peer];
    }
    
    if ([self.downloadPeer isEqual:peer]) { // download peer disconnected
        _connected = NO;
        self.downloadPeer = nil;
        if (self.connectFailures > MAX_CONNECT_FAILURES) self.connectFailures = MAX_CONNECT_FAILURES;
    }
    
    if (! self.connected && self.connectFailures == MAX_CONNECT_FAILURES) {
        [self syncStopped];
        
        // clear out stored peers so we get a fresh list from DNS on next connect attempt
        [self.misbehavinPeers removeAllObjects];
        [BRPeerEntity deleteObjects:[BRPeerEntity allObjects]];
        _peers = nil;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *errorStr = [NSString stringWithFormat:@"%@", error];
            if([errorStr rangeOfString:@"invalid merkleblock:"].location != NSNotFound) {
                
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerSyncFailedNotification
                                                                object:nil userInfo:(error) ? @{@"error":error} : nil];
            }
        });
    }
    else if (self.connectFailures < MAX_CONNECT_FAILURES) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.taskId != UIBackgroundTaskInvalid ||
                [UIApplication sharedApplication].applicationState != UIApplicationStateBackground) {
                [self connect]; // try connecting to another peer
            }
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerTxStatusNotification object:nil];
    });
}

- (void)peer:(BRPeer *)peer relayedPeers:(NSArray *)peers
{
    //BRLog(@"%@:%d relayed %d peer(s)", peer.host, peer.port, (int)peers.count);
    [self.peers addObjectsFromArray:peers];
    [self.peers minusSet:self.misbehavinPeers];
    [self sortPeers];
    
    // limit total to 2500 peers
    if (self.peers.count > 2500) [self.peers removeObjectsInRange:NSMakeRange(2500, self.peers.count - 2500)];
    
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    // remove peers more than 3 hours old, or until there are only 1000 left
    while (self.peers.count > 1000 && ((BRPeer *)self.peers.lastObject).timestamp + 3*60*60 < now) {
        [self.peers removeObject:self.peers.lastObject];
    }
    
    if (peers.count > 1 && peers.count < 1000) [self savePeers]; // peer relaying is complete when we receive <1000
}

- (void)peer:(BRPeer *)peer relayedTransaction:(BRTransaction *)transaction
{
//    //TODO ZC ADD VALIAD
//    if (self.lastBlockHeight + 1 >= 809220) {
//        // 809220之前的交易不做tx.version判断, 809220之后的交易版本必须大于等于101
//        if (transaction.version >= TX_VERSION_NUMBER) {
//            if (transaction.outputUnlockHeights.count > 0 && transaction.outputReserves.count > 0) {
//                for (NSInteger i = 0; i < transaction.outputReserves.count; i ++) {
//                    NSData *vReserve = transaction.outputReserves[i];
//                    //uint64_t unlockheight = (uint64_t)transaction.outputUnlockHeights[i];
//                    //817480之前的nUnlockHeight和vReserve判断，vReserve必须在4-3000个字节以内，并且以safe开头
//                    if (self.lastBlockHeight + 1 < 817480) {
//                        NSString *vReserveString = @"";
//                        if(vReserve.length > 4) vReserveString = [NSString stringWithUTF8String:[[vReserve subdataWithRange:NSMakeRange(0, 4)] bytes]];
//                        if (vReserve.length < 4 || vReserve.length > 3000 || ![vReserveString hasPrefix:@"safe"]) {
//                            //BRLog(@"----无效交易");
//                            return;
//                        }
//                    }
//                    //817480之后的nUnlockHeight必须为0，vReserve必须为safe
//                    else {
//                        //uint64_t height = 0;
//                        //NSString *unlockString = [NSString stringWithFormat:@"%ld",(long)unlockheight];
//                        //BRLog(@"%@",unlockString);
//                        NSNumber *height = [NSNumber numberWithUnsignedLongLong:0];
//                        NSString *vReserveString = [[NSString alloc] initWithData:vReserve encoding:NSUTF8StringEncoding];
//                        if (transaction.outputUnlockHeights[i] != height || vReserve.length != 4 || ![vReserveString isEqualToString:@"safe"]) {
//                            //BRLog(@"--------无效交易");
//                            return;
//                        }
//                    }
//                }
//            }
//        }
//        else {
//            //BRLog(@"交易版本号不为101 ------ tx.version = %ld",(long)transaction.version);
//            return;
//        }
//    }
    
//    BRUTXO o;
//    for (NSValue *hash in transaction.inputHashes) {
//        [hash getValue:&o.hash];
//        BRTransaction *tx = [[BRWalletManager sharedInstance].wallet transactionForHash:o.hash];
//        //判断交易输入里是否含有被锁定的交易
//        for (NSInteger i = 0; i < tx.outputUnlockHeights.count; i ++) {
//            uint64_t unlockheight = [tx.outputUnlockHeights[i] unsignedLongLongValue];
//            if (unlockheight > 0 && unlockheight > self.lastBlockHeight) {
//                continue;
//            }
//        }
//    }

    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSValue *hash = uint256_obj(transaction.txHash);
    BOOL syncing = (self.lastBlockHeight < self.estimatedBlockHeight);
    void (^callback)(NSError *error) = self.publishedCallback[hash];
    
//    BRLog(@"%@:%d relayed transaction %@ inputAddress%@ outputAddress%@", peer.host, peer.port, hash, transaction.inputAddresses, transaction.outputAddresses);

    transaction.timestamp = [NSDate timeIntervalSinceReferenceDate];
    if (syncing && ! [manager.wallet containsTransaction:transaction]) return;
    if (! [manager.wallet registerTransaction:transaction]) return;
    if (peer == self.downloadPeer) self.lastRelayTime = [NSDate timeIntervalSinceReferenceDate];
    
    if ([manager.wallet amountSentByTransaction:transaction] > 0 && [manager.wallet transactionIsValid:transaction]) {
        [self addTransactionToPublishList:transaction]; // add valid send tx to mempool
    }
    
    // keep track of how many peers have or relay a tx, this indicates how likely the tx is to confirm
    if (callback || (! syncing && ! [self.txRelays[hash] containsObject:peer])) {
        if (! self.txRelays[hash]) self.txRelays[hash] = [NSMutableSet set];
        [self.txRelays[hash] addObject:peer];
        // TODO: 修改正在发送中的交易
//        if (callback) {
//            [self.publishedCallback removeObjectForKey:hash];
//            // TODO: 删除正在发送的交易
//            [BRSafeUtils deletePublishedTx:@[hash]];
//        }
        
        if ([self.txRelays[hash] count] >= self.maxConnectCount &&
            [manager.wallet transactionForHash:transaction.txHash].blockHeight == TX_UNCONFIRMED &&
            [manager.wallet transactionForHash:transaction.txHash].timestamp == 0) {
            [self setBlockHeight:TX_UNCONFIRMED andTimestamp:[NSDate timeIntervalSinceReferenceDate]
                     forTxHashes:@[hash]]; // set timestamp when tx is verified
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *kvErr = nil;
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(txTimeout:) object:hash];
            [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerTxStatusNotification object:nil];
            if (callback) callback(nil);
            
            //            [[BRAPIClient sharedClient].kv
            //             set:[[BRTxMetadataObject alloc] initWithTransaction:transaction exchangeRate:manager.localCurrencyDashPrice.doubleValue
            //                  exchangeRateCurrency:manager.localCurrencyCode feeRate:manager.wallet.feePerKb
            //                  deviceId:[BRAPIClient sharedClient].deviceId] error:&kvErr];
        });
    }
    
    [self.nonFpTx addObject:hash];
    [self.txRequests[hash] removeObject:peer];
    if (! _bloomFilter) return; // bloom filter is aready being updated
    
    // the transaction likely consumed one or more wallet addresses, so check that at least the next <gap limit>
    // unused addresses are still matched by the bloom filter
    NSArray *external = [manager.wallet addressesWithGapLimit:SEQUENCE_GAP_LIMIT_EXTERNAL internal:NO],
    *internal = [manager.wallet addressesWithGapLimit:SEQUENCE_GAP_LIMIT_INTERNAL internal:YES],
    *externalBIP32 = [manager.wallet addressesBIP32NoPurposeWithGapLimit:SEQUENCE_GAP_LIMIT_EXTERNAL internal:NO],
    *internalBIP32 = [manager.wallet addressesBIP32NoPurposeWithGapLimit:SEQUENCE_GAP_LIMIT_INTERNAL internal:YES];
    
    for (NSString *address in [[[external arrayByAddingObjectsFromArray:internal] arrayByAddingObjectsFromArray:externalBIP32] arrayByAddingObjectsFromArray:internalBIP32]) {
        NSData *hash = address.addressToHash160;
        
        if (! hash || [_bloomFilter containsData:hash]) continue;
        _bloomFilter = nil; // reset bloom filter so it's recreated with new wallet addresses
        [self updateFilter];
        break;
    }
}

- (void)peer:(BRPeer *)peer hasTransaction:(UInt256)txHash
{
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSValue *hash = uint256_obj(txHash);
    BOOL syncing = (self.lastBlockHeight < self.estimatedBlockHeight);
    BRTransaction *tx = self.publishedTx[hash];
    void (^callback)(NSError *error) = self.publishedCallback[hash];
    
    //BRLog(@"%@:%d has transaction %@", peer.host, peer.port, hash);
    if (! tx) tx = [manager.wallet transactionForHash:txHash];
    if (! tx || (syncing && ! [manager.wallet containsTransaction:tx])) return;
    if (! [manager.wallet registerTransaction:tx]) return;
    if (peer == self.downloadPeer) self.lastRelayTime = [NSDate timeIntervalSinceReferenceDate];
    
    // keep track of how many peers have or relay a tx, this indicates how likely the tx is to confirm
    if (callback || (! syncing && ! [self.txRelays[hash] containsObject:peer])) {
        if (! self.txRelays[hash]) self.txRelays[hash] = [NSMutableSet set];
        [self.txRelays[hash] addObject:peer];
        // TODO:修改正在发送中的交易
//        if (callback) {
//            [self.publishedCallback removeObjectForKey:hash];
//            // 删除真正发送的交易
//            [BRSafeUtils deletePublishedTx:@[hash]];
//        }
        
        if ([self.txRelays[hash] count] >= self.maxConnectCount &&
            [manager.wallet transactionForHash:txHash].blockHeight == TX_UNCONFIRMED &&
            [manager.wallet transactionForHash:txHash].timestamp == 0) {
            [self setBlockHeight:TX_UNCONFIRMED andTimestamp:[NSDate timeIntervalSinceReferenceDate]
                     forTxHashes:@[hash]]; // set timestamp when tx is verified
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSError *kvErr = nil;
            
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(txTimeout:) object:hash];
            [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerTxStatusNotification object:nil];
            if (callback) callback(nil);
            
            //            [[BRAPIClient sharedClient].kv
            //             set:[[BRTxMetadataObject alloc] initWithTransaction:tx exchangeRate:manager.localCurrencyDashPrice.doubleValue
            //                  exchangeRateCurrency:manager.localCurrencyCode feeRate:manager.wallet.feePerKb
            //                  deviceId:[BRAPIClient sharedClient].deviceId] error:&kvErr];
        });
    }
    
    [self.nonFpTx addObject:hash];
    [self.txRequests[hash] removeObject:peer];
}

- (void)peer:(BRPeer *)peer rejectedTransaction:(UInt256)txHash withCode:(uint8_t)code errorString:(NSString *)errorStr
{
    if (code == 0x61) {
        //  已发送领取糖果交易，可能领取成功
        return;
    }
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    BRTransaction *tx = [manager.wallet transactionForHash:txHash];
    NSValue *hash = uint256_obj(txHash);
   
    
    if ([self.txRelays[hash] containsObject:peer]) {
        [self.txRelays[hash] removeObject:peer];
        
        if (tx.blockHeight == TX_UNCONFIRMED) { // set timestamp 0 for unverified
            BRLog(@"交易被拒绝 ====== 设置成未验证交易 === andTimestamp:0");
            [self setBlockHeight:TX_UNCONFIRMED andTimestamp:0 forTxHashes:@[hash]];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerTxStatusNotification object:nil];
//#if DEBUG
//            UIAlertController * alert = [UIAlertController
//                                         alertControllerWithTitle:@"transaction rejected"
//                                         message:[NSString stringWithFormat:@"rejected by %@:%d with code 0x%x", peer.host, peer.port, code]
//                                         preferredStyle:UIAlertControllerStyleAlert];
                if(tx) {
                    BOOL isDash = NO;
                    for(int i=0; i<tx.inputHashes.count; i++) {
                        BRUTXO o;
                        [tx.inputHashes[i] getValue:&o];
                        BRTransaction *dashTx = [manager.wallet transactionForHash:o.hash];
                        if([dashTx.outputReserves[[tx.inputIndexes[i] integerValue]] isEqual:[NSNull null]]) {
                            isDash = YES;
                            break;
                        }
                    }
                    if([errorStr rangeOfString:@"bad-txns-forbid"].location != NSNotFound){
                        isDash = YES;
                    }
                    if (isDash) {
                        // 删除拒绝交易
                        [manager.wallet removeTransaction:txHash];
                        [self.publishedCallback removeObjectForKey:uint256_obj(txHash)];
                        [BRSafeUtils deletePublishedTx:@[uint256_obj(txHash)]];
                        NSString *subTitle = NSLocalizedString(@"The transaction was rejected and the transaction (partial) amount has been sealed.", nil);
                        NSMutableParagraphStyle *leftP = [[NSMutableParagraphStyle alloc] init];
                        leftP.alignment = NSTextAlignmentLeft;
                        NSAttributedString *attSubTitle = [[NSAttributedString alloc] initWithString:subTitle attributes:@{NSParagraphStyleAttributeName : leftP}];
                        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
                        [attrString appendAttributedString:attSubTitle];
                        [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attrString.length)];
                        UIAlertController * alert = [UIAlertController
                                                     alertControllerWithTitle:@""
                                                     message:attrString.string
                                                     preferredStyle:UIAlertControllerStyleAlert];
                        [alert setValue:attrString forKey:@"attributedMessage"];
                        UIAlertAction* okButton = [UIAlertAction
                                                   actionWithTitle:NSLocalizedString(@"ok", nil)
                                                   style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {  }];
                        [alert addAction:okButton];
                        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
                    } else {
                        if([errorStr rangeOfString:@"invalid txout unlocked height"].location != NSNotFound){
                            [manager.wallet removeTransaction:txHash];
                            [self.publishedCallback removeObjectForKey:uint256_obj(txHash)];
                            [BRSafeUtils deletePublishedTx:@[uint256_obj(txHash)]];
                            NSString *subTitle = NSLocalizedString(@"The transaction was rejected and the transaction lockout height has passed.", nil);
                            NSMutableParagraphStyle *leftP = [[NSMutableParagraphStyle alloc] init];
                            leftP.alignment = NSTextAlignmentLeft;
                            NSAttributedString *attSubTitle = [[NSAttributedString alloc] initWithString:subTitle attributes:@{NSParagraphStyleAttributeName : leftP}];
                            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
                            [attrString appendAttributedString:attSubTitle];
                            [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attrString.length)];
                            UIAlertController * alert = [UIAlertController
                                                         alertControllerWithTitle:@""
                                                         message:attrString.string
                                                         preferredStyle:UIAlertControllerStyleAlert];
                            [alert setValue:attrString forKey:@"attributedMessage"];
                            UIAlertAction* okButton = [UIAlertAction
                                                       actionWithTitle:NSLocalizedString(@"ok", nil)
                                                       style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * action) {  }];
                            [alert addAction:okButton];
                            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
                        } else if ([errorStr rangeOfString:@"more than the total number of candy issued"].location != NSNotFound) {
                            [manager.wallet removeTransaction:txHash];
                            [self.publishedCallback removeObjectForKey:uint256_obj(txHash)];
                            [BRSafeUtils deletePublishedTx:@[uint256_obj(txHash)]];
                            // 删除领取记录交易
                            NSArray *getCandyList = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] entity:@"BRGetCandyEntity" objectsMatching:[NSPredicate predicateWithFormat:@"txId = %@", [NSData dataWithUInt256:txHash]]]];
                            [[BRCoreDataManager sharedInstance] deleteEntity:getCandyList];
                            NSString *subTitle = NSLocalizedString(@"The candy pool is dry", nil);
                            NSMutableParagraphStyle *leftP = [[NSMutableParagraphStyle alloc] init];
                            leftP.alignment = NSTextAlignmentLeft;
                            NSAttributedString *attSubTitle = [[NSAttributedString alloc] initWithString:subTitle attributes:@{NSParagraphStyleAttributeName : leftP}];
                            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
                            [attrString appendAttributedString:attSubTitle];
                            [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attrString.length)];
                            UIAlertController * alert = [UIAlertController
                                                         alertControllerWithTitle:@""
                                                         message:attrString.string
                                                         preferredStyle:UIAlertControllerStyleAlert];
                            [alert setValue:attrString forKey:@"attributedMessage"];
                            UIAlertAction* okButton = [UIAlertAction
                                                       actionWithTitle:NSLocalizedString(@"ok", nil)
                                                       style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * action) {  }];
                            [alert addAction:okButton];
                            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
                        } else {
                            NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
                            [defs setBool:true forKey:USER_REJECTED_TRANSACTION];
                            NSString *subTitle = [NSString stringWithFormat:NSLocalizedString(@"The transaction was rejected and needs to be repaired for normal use.", nil)];
//#if SAFEWallet_TESTNET // 测试
                            subTitle = [NSString stringWithFormat:@"%@%@", subTitle, errorStr];
//#else // 正式
//
//#endif
                            NSMutableParagraphStyle *leftP = [[NSMutableParagraphStyle alloc] init];
                            leftP.alignment = NSTextAlignmentLeft;
                            NSAttributedString *attSubTitle = [[NSAttributedString alloc] initWithString:subTitle attributes:@{NSParagraphStyleAttributeName : leftP}];
                            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
                            [attrString appendAttributedString:attSubTitle];
                            [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attrString.length)];
                            UIAlertController * alert = [UIAlertController
                                                         alertControllerWithTitle:@"钱包拒绝消息"
                                                         message:attrString.string
                                                         preferredStyle:UIAlertControllerStyleAlert];
                            [alert setValue:attrString forKey:@"attributedMessage"];
                            UIAlertAction* okButton = [UIAlertAction
                                                       actionWithTitle:@"修复钱包"
                                                       style:UIAlertActionStyleCancel
                                                       handler:^(UIAlertAction * action) {
                                                           [defs setBool:false forKey:USER_REJECTED_TRANSACTION];
                                                           [self.publishedCallback removeAllObjects];
                                                           [self disconnect];
                                                           [AppTool showHUDView:nil animated:YES];
                                                           dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
                                                           dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                                                               @weakify(self);
                                                               dispatch_async(dispatch_queue_create("deleteLocalCoreDataData", NULL), ^{
                                                                   @strongify(self);
                                                                   
                                                                   // TODO: 删除本地数据
                                                                   [BRSafeUtils deleteCoreDataData:YES];
                                                                   @weakify(self);
                                                                   dispatch_async(dispatch_get_main_queue(), ^{
                                                                       @strongify(self);
                                                                       [AppTool hideHUDView:nil animated:NO];
                                                                       [self selectTabbarVCSelectedInde];
                                                                       [self rescan];
                                                                   });
                                                               });
                                                           });
                                                       }];
                            [alert addAction:okButton];
                            [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
                        }
                    }
                }
    //#endif
            });
    }
    
    [self.txRequests[hash] removeObject:peer];
    
    // if we get rejected for any reason other than double-spend, the peer is likely misconfigured
    if (code != REJECT_SPENT && [manager.wallet amountSentByTransaction:tx] > 0) {
        for (hash in tx.inputHashes) { // check that all inputs are confirmed before dropping peer
            UInt256 h = UINT256_ZERO;
            
            [hash getValue:&h];
            if ([manager.wallet transactionForHash:h].blockHeight == TX_UNCONFIRMED) return;
        }
        
        [self peerMisbehavin:peer];
    }
}

// TODO: 返回区块高度
- (int) currentBlockHeight: (BRMerkleBlock *) block {
    NSValue *blockHash = uint256_obj(block.blockHash), *prevBlock = uint256_obj(block.prevBlock);
    BRMerkleBlock *prev = self.blocks[prevBlock];
    if(!prev) return 0;
    block.height = prev.height + 1;
    return block.height;
}

// TODO: 返回发送中的交易
- (NSArray *) getPublishedTx {
    return self.publishedTx.allValues;
}

- (void)peer:(BRPeer *)peer relayedBlock:(BRMerkleBlock *)block
{
    // ignore block headers that are newer than one week before earliestKeyTime (headers have 0 totalTransactions)
    if (block.totalTransactions == 0 &&
        block.timestamp + WEEK_TIME_INTERVAL/4 > self.earliestKeyTime + NSTimeIntervalSince1970 + HOUR_TIME_INTERVAL/2) {
        return;
    }
    NSArray *txHashes = block.txHashes;
    // track the observed bloom filter false positive rate using a low pass filter to smooth out variance
    if (peer == self.downloadPeer && block.totalTransactions > 0) {
        NSMutableSet *fp = [NSMutableSet setWithArray:txHashes];
        
        // 1% low pass filter, also weights each block by total transactions, using 1400 tx per block as typical
        [fp minusSet:self.nonFpTx]; // wallet tx are not false-positives
        [self.nonFpTx removeAllObjects];
        self.fpRate = self.fpRate*(1.0 - 0.01*block.totalTransactions/1400) + 0.01*fp.count/1400;
        
        // false positive rate sanity check
        // TODO: 修改 10 变 100
        if (self.downloadPeer.status == BRPeerStatusConnected && self.fpRate > BLOOM_DEFAULT_FALSEPOSITIVE_RATE*100.0) {
            BRLog(@"%@:%d bloom filter false positive rate %f too high after %d blocks, disconnecting...", peer.host,
                  peer.port, self.fpRate, self.lastBlockHeight + 1 - self.filterUpdateHeight);
            [self.downloadPeer disconnect];
        }
        else if (self.lastBlockHeight + 500 < peer.lastblock && self.fpRate > BLOOM_REDUCED_FALSEPOSITIVE_RATE*10.0) {
            [self updateFilter]; // rebuild bloom filter when it starts to degrade
        }
    }
    
    if (! _bloomFilter) { // ingore potentially incomplete blocks when a filter update is pending
        if (peer == self.downloadPeer) self.lastRelayTime = [NSDate timeIntervalSinceReferenceDate];
        return;
    }
    
    NSValue *blockHash = uint256_obj(block.blockHash), *prevBlock = uint256_obj(block.prevBlock);
    BRMerkleBlock *prev = self.blocks[prevBlock];
    uint32_t transitionTime = 0;
    uint32_t txTime = 0;
    UInt256 checkpoint = UINT256_ZERO;
    BOOL syncDone = NO;
    //TODO: 跳过根节点检查 && self.blocks.allValues.count > 0
    if (! prev ) { // block is an orphan
//        NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"height" ascending:TRUE];
//        for (BRMerkleBlock * merkleBlock in [[self.blocks allValues] sortedArrayUsingDescriptors:@[sortDescriptor]]) {
//            BRLog(@"printing previous block at height %d : %@",merkleBlock.height,uint256_obj(merkleBlock.blockHash));
//        }
//        BRLog(@"%@:%d relayed orphan block %@, previous %@, height = %d, last block is %@, height %d", peer.host, peer.port,
//              blockHash, prevBlock, block.height);

        // ignore orphans older than one week ago
        if (block.timestamp < [NSDate timeIntervalSinceReferenceDate] + NSTimeIntervalSince1970 - 7*24*60*60) return;

        // call getblocks, unless we already did with the previous block, or we're still downloading the chain
        if (self.lastBlockHeight >= peer.lastblock && ! uint256_eq(self.lastOrphan.blockHash, block.prevBlock)) {
            //BRLog(@"%@:%d calling getblocks", peer.host, peer.port);
            [peer sendGetblocksMessageWithLocators:[self blockLocatorArray] andHashStop:UINT256_ZERO];
        }

        self.orphans[prevBlock] = block; // orphans are indexed by prevBlock instead of blockHash
        self.lastOrphan = block;
        return;
    }
    
    block.height = prev.height + 1;
    txTime = block.timestamp/2 + prev.timestamp/2;
    
    
    //TODO change zc
    if ((block.height % 1000) == 0) { //free up some memory from time to time
        
        BRMerkleBlock *b = block;
        
        for (uint32_t i = 0; b && i < (DGW_PAST_BLOCKS_MAX + 50); i++) {
            b = self.blocks[uint256_obj(b.prevBlock)];
        }
        transitionTime = b.timestamp;
        
        while (b) { // free up some memory
            b = self.blocks[uint256_obj(b.prevBlock)];
            if (b) [self.blocks removeObjectForKey:uint256_obj(b.prevBlock)];
        }
    }
    
    // verify block difficulty if block is past last checkpoint
//    if (block.height > 575) {
//        if ((block.height > (checkpoint_array[CHECKPOINT_COUNT - 1].height + DGW_PAST_BLOCKS_MAX)) &&
//            ![block verifyDifficultyWithPreviousBlocks:self.blocks]) {
//            uint32_t foundDifficulty = [block darkGravityWaveTargetWithPreviousBlocks:self.blocks];
//            BRLog(@"%@:%d relayed block with invalid difficulty height %d target %x foundTarget %x, blockHash: %@", peer.host, peer.port,
//                  block.height,block.target,foundDifficulty, blockHash);
//            [self peerMisbehavin:peer];
//            return;
//        }
//    } else {
        if ((block.height > (checkpoint_array[CHECKPOINT_COUNT - 1].height + DGW_PAST_BLOCKS_MAX)) &&
            ![block verifyDifficultyFromPreviousBlock:self.blocks andTransitionTime:transitionTime]) {
            uint32_t foundDifficulty = [block darkGravityWaveTargetWithPreviousBlocks:self.blocks];
            //BRLog(@"%@:%d relayed block with invalid difficulty height %d target %x foundTarget %x, blockHash: %@", peer.host, peer.port,
                  //block.height,block.target,foundDifficulty, blockHash);
            [self peerMisbehavin:peer];
            return;
        }
//    }
    [self.checkpoints[@(block.height)] getValue:&checkpoint];
//    if(self.lastBlock.height == DisableDash_TX_HEIGHT - 1) {
//        BRLog(@"%d %d", self.lastBlock.height, block.height);
//    }

    // verify block chain checkpoints
//    if (! uint256_is_zero(checkpoint) && ! uint256_eq(block.blockHash, checkpoint)) {
//        BRLog(@"%@:%d relayed a block that differs from the checkpoint at height %d, blockHash: %@, expected: %@",
//              peer.host, peer.port, block.height, blockHash, self.checkpoints[@(block.height)]);
//        [self peerMisbehavin:peer];
//        return;
//    }
       // spos 检验区块  两个快块之间时间间隔不能小于28s 
       if(self.lastBlock.height >= TEST_START_SPOS_HEIGHT) {
           NSValue *checkPrevBlock = uint256_obj(self.lastBlock.prevBlock);
           BRMerkleBlock *checkPrev = self.blocks[checkPrevBlock];
           while (checkPrev && checkPrev.height >= self.lastBlock.height - 100) {
               checkPrevBlock = uint256_obj(checkPrev.prevBlock);
               checkPrev = self.blocks[checkPrevBlock];
           }
           NSValue *timePrevBlock = uint256_obj(block.prevBlock);
           BRMerkleBlock *checkBlock = self.blocks[timePrevBlock];
           if (block.height <= checkPrev.height || block.timestamp - checkBlock.timestamp < 28) {
               [self peerMisbehavin:peer];
               return;
           }
       } else {
           if (! uint256_is_zero(checkpoint) && ! uint256_eq(block.blockHash, checkpoint)) {
               BRLog(@"%@:%d relayed a block that differs from the checkpoint at height %d, blockHash: %@, expected: %@",
                     peer.host, peer.port, block.height, blockHash, self.checkpoints[@(block.height)]);
               [self peerMisbehavin:peer];
               return;
           }
       }
    
    if (uint256_eq(block.prevBlock, self.lastBlock.blockHash)) { // new block extends main chain
        if ((block.height % 500) == 0 || txHashes.count > 0 || block.height > peer.lastblock) {
            //BRLog(@"adding block at height: %d, false positive rate: %f", block.height, self.fpRate);
        }
        
        self.blocks[blockHash] = block;
        self.lastBlock = block;
        [self setBlockHeight:block.height andTimestamp:txTime - NSTimeIntervalSince1970 forTxHashes:txHashes];
        if (peer == self.downloadPeer) self.lastRelayTime = [NSDate timeIntervalSinceReferenceDate];
        self.downloadPeer.currentBlockHeight = block.height;
        if (block.height == _estimatedBlockHeight) syncDone = YES;
    }
    else if (self.blocks[blockHash] != nil) { // we already have the block (or at least the header)
        if ((block.height % 500) == 0 || txHashes.count > 0 || block.height > peer.lastblock) {
            //BRLog(@"%@:%d relayed existing block at height %d", peer.host, peer.port, block.height);
        }
        
        self.blocks[blockHash] = block;
        
        BRMerkleBlock *b = self.lastBlock;
        
        while (b && b.height > block.height) b = self.blocks[uint256_obj(b.prevBlock)]; // is block in main chain?
        
        if (uint256_eq(b.blockHash, block.blockHash)) { // if it's not on a fork, set block heights for its transactions
            [self setBlockHeight:block.height andTimestamp:txTime - NSTimeIntervalSince1970 forTxHashes:txHashes];
            if (block.height == self.lastBlockHeight) self.lastBlock = block;
        }
    }
    else { // new block is on a fork
        if (block.height <= checkpoint_array[CHECKPOINT_COUNT - 1].height) { // fork is older than last checkpoint
            //BRLog(@"ignoring block on fork older than most recent checkpoint, fork height: %d, blockHash: %@",
                 // block.height, blockHash);
            return;
        }
        
        // special case, if a new block is mined while we're rescanning the chain, mark as orphan til we're caught up
        if (self.lastBlockHeight < peer.lastblock && block.height > self.lastBlockHeight + 1) {
            //BRLog(@"marking new block at height %d as orphan until rescan completes", block.height);
            self.orphans[prevBlock] = block;
            self.lastOrphan = block;
            return;
        }
        
        //BRLog(@"chain fork to height %d", block.height);
        self.blocks[blockHash] = block;
        if (block.height <= self.lastBlockHeight) return; // if fork is shorter than main chain, ignore it for now
        
        NSMutableArray *txHashes = [NSMutableArray array];
        BRMerkleBlock *b = block, *b2 = self.lastBlock;
        
        while (b && b2 && ! uint256_eq(b.blockHash, b2.blockHash)) { // walk back to where the fork joins the main chain
            b = self.blocks[uint256_obj(b.prevBlock)];
            if (b.height < b2.height) b2 = self.blocks[uint256_obj(b2.prevBlock)];
        }
        
        //BRLog(@"reorganizing chain from height %d, new height is %d", b.height, block.height);
        
        // mark transactions after the join point as unconfirmed
        for (BRTransaction *tx in [BRWalletManager sharedInstance].wallet.allTransactions) {
            if (tx.blockHeight <= b.height) break;
            [txHashes addObject:uint256_obj(tx.txHash)];
        }
        BRLog(@"区块 new block is on a fork ===== andTimestamp:0");
        [self setBlockHeight:TX_UNCONFIRMED andTimestamp:0 forTxHashes:txHashes];
        b = block;
        
        while (b.height > b2.height) { // set transaction heights for new main chain
            [self setBlockHeight:b.height andTimestamp:txTime - NSTimeIntervalSince1970 forTxHashes:b.txHashes];
            b = self.blocks[uint256_obj(b.prevBlock)];
            txTime = b.timestamp/2 + ((BRMerkleBlock *)self.blocks[uint256_obj(b.prevBlock)]).timestamp/2;
        }
        
        self.lastBlock = block;
        if (block.height == _estimatedBlockHeight) syncDone = YES;
    }
    
    BRLog(@"height %ld", (long)block.height);
//    BRLog(@"%@:%d added block at height %ld target %x blockHash: %@ blockVersion: %ld blockTime:%ld nonce:%ld prevBlock:%@ txHashes:%@ totalTransactions:%x", peer.host, peer.port,
//          (long)block.height, block.target, blockHash, (long)block.version, (long)block.timestamp, (long)block.nonce, uint256_obj(block.prevBlock), block.txHashes, block.totalTransactions);
    
    // TODO: 添加 领取糖果方法
//    dispatch_async(self.q, ^{
        [BRSafeUtils saveBlockSafeAmount:block.height nPrevTarget:prev.target]; // 保存区块中safe
    if(block.height - Candy_Count_Height > 0) {
        [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlockAndWait:^{
            NSArray *putCandyArray = [[BRCoreDataManager sharedInstance] entity:@"BRPutCandyEntity" objectsMatching:[NSPredicate predicateWithFormat:@"blockHeight = %@", @(block.height - Candy_Count_Height)]];
            if(putCandyArray.count > 0) {
                [BRSafeUtils saveBlockAvailableSafeAddress:block.height - Candy_Count_Height];
            }
        }];
    }
    if(block.height == DisableDash_TX_HEIGHT) {
        [[BRWalletManager sharedInstance].wallet updateBalance];
    }
//    });
    // 添加代码
    if(block.height % 200 == 0) {
        [self saveBlocks];
    }
    if (syncDone) { // chain download is complete
        self.syncStartHeight = 0;
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:SYNC_STARTHEIGHT_KEY];
        [self saveBlocks];
        [self loadMempools];
        // 添加刷新糖果数量通知
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerChainDownloadIsCompleteNotification object:nil];
        });
    }
    
    if (block.height > _estimatedBlockHeight) {
        _estimatedBlockHeight = block.height;
        
        // notify that transaction confirmations may have changed
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:BRPeerManagerTxStatusNotification object:nil];
        });
    }
    
    // check if the next block was received as an orphan
    if (block == self.lastBlock && self.orphans[blockHash]) {
        BRMerkleBlock *b = self.orphans[blockHash];
        
        [self.orphans removeObjectForKey:blockHash];
        [self peer:peer relayedBlock:b];
    }
    // TODO:添加分叉前只下载头部信息
#if SAFEWallet_TESTNET // 测试
    if(block.height == CriticalHeight - beforehandBlockBodies) {
        [self saveBlocks];
        [self disconnect];
        [self connect];
    }
#else // 正式
    if(block.height == DisableDash_TX_HEIGHT - beforehandBlockBodies) {
        [self saveBlocks];
        [self disconnect];
        [self connect];
    }
#endif

}

- (void)peer:(BRPeer *)peer notfoundTxHashes:(NSArray *)txHashes andBlockHashes:(NSArray *)blockhashes
{
    for (NSValue *hash in txHashes) {
        [self.txRelays[hash] removeObject:peer];
        [self.txRequests[hash] removeObject:peer];
    }
}

- (void)peer:(BRPeer *)peer setFeePerKb:(uint64_t)feePerKb
{
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    uint64_t maxFeePerKb = 0, secondFeePerKb = 0;
    
    for (BRPeer *p in self.connectedPeers) { // find second highest fee rate
        if (p.status != BRPeerStatusConnected) continue;
        if (p.feePerKb > maxFeePerKb) secondFeePerKb = maxFeePerKb, maxFeePerKb = p.feePerKb;
    }
    
    if (secondFeePerKb*2 > MIN_FEE_PER_KB && secondFeePerKb*2 <= MAX_FEE_PER_KB &&
        secondFeePerKb*2 > manager.wallet.feePerKb) {
        //BRLog(@"increasing feePerKb to %llu based on feefilter messages from peers", secondFeePerKb*2);
        manager.wallet.feePerKb = secondFeePerKb*2;
    }
}

- (BRTransaction *)peer:(BRPeer *)peer requestedTransaction:(UInt256)txHash
{
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSValue *hash = uint256_obj(txHash);
    BRTransaction *tx = self.publishedTx[hash];
    void (^callback)(NSError *error) = self.publishedCallback[hash];
    NSError *error = nil;
    
    if (! self.txRelays[hash]) self.txRelays[hash] = [NSMutableSet set];
    [self.txRelays[hash] addObject:peer];
    [self.nonFpTx addObject:hash];
    [self.publishedCallback removeObjectForKey:hash];
    // TODO:删除正在发送中的交易
    [BRSafeUtils deletePublishedTx:@[hash]];
    
    if (callback && ! [manager.wallet transactionIsValid:tx]) {
        [self.publishedTx removeObjectForKey:hash];
        
        error = [NSError errorWithDomain:@"SafeWallet" code:401
                                userInfo:@{NSLocalizedDescriptionKey:NSLocalizedString(@"double spend", nil)}];
    }
    else if (tx && ! [manager.wallet transactionForHash:txHash] && [manager.wallet registerTransaction:tx]) {
        [[BRTransactionEntity context] performBlock:^{
            [BRTransactionEntity saveContext]; // persist transactions to core data
        }];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(txTimeout:) object:hash];
        if (callback) callback(error);
    });
    
    //    [peer sendPingMessageWithPongHandler:^(BOOL success) { // check if peer will relay the transaction back
    //        if (! success) return;
    //
    //        if (! [self.txRequests[hash] containsObject:peer]) {
    //            if (! self.txRequests[hash]) self.txRequests[hash] = [NSMutableSet set];
    //            [self.txRequests[hash] addObject:peer];
    //            [peer sendGetdataMessageWithTxHashes:@[hash] andBlockHashes:nil];
    //        }
    //    }];
    
    return tx;
}

@end
