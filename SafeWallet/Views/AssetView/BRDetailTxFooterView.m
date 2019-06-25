//
//  BRDetailTxFooterView.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/21.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRDetailTxFooterView.h"
#import "BRWalletManager.h"
#import "BRPeerManager.h"
#import "NSString+Bitcoin.h"
#import <CoreImage/CoreImage.h>
#import "BRSafeUtils.h"
#import "Safe.pbobjc.h"


static NSString *dateFormat(NSString *template)
{
    NSString *format = [NSDateFormatter dateFormatFromTemplate:template options:0 locale:[NSLocale currentLocale]];
    
    format = [format stringByReplacingOccurrencesOfString:@", " withString:@" "];
    format = [format stringByReplacingOccurrencesOfString:@" a" withString:@"a"];
    format = [format stringByReplacingOccurrencesOfString:@"hh" withString:@"h"];
    format = [format stringByReplacingOccurrencesOfString:@" ha" withString:@"@ha"];
    format = [format stringByReplacingOccurrencesOfString:@"HH" withString:@"H"];
    format = [format stringByReplacingOccurrencesOfString:@"H '" withString:@"H'"];
    format = [format stringByReplacingOccurrencesOfString:@"H " withString:@"H'h' "];
    format = [format stringByReplacingOccurrencesOfString:@"H" withString:@"H'h'"
                                                  options:NSBackwardsSearch|NSAnchoredSearch range:NSMakeRange(0, format.length)];
    return format;
}

@interface BRDetailTxFooterView ()

@property (nonatomic,strong) UILabel *receiveLable;
@property (nonatomic,strong) UILabel *feeTextLable;
@property (nonatomic,strong) UILabel *blockLable;
@property (nonatomic,strong) UILabel *timeLable;
@property (nonatomic,strong) UILabel *idLable;
@property (nonatomic,strong) UIImageView *codeImageView;

@property (nonatomic,strong) UILabel *sendAddressLable;//发送方地址
@property (nonatomic,strong) UILabel *receiveAddressLable;//接收方地址
@property (nonatomic,strong) UILabel *feeLable;//矿工费用
@property (nonatomic,strong) UILabel *confirmLable;//区块
@property (nonatomic,strong) UILabel *txTimeLable;//交易时间
@property (nonatomic,strong) UILabel *txIdLable;//交易ID
@property (nonatomic,strong) UILabel *txTypeLable;//交易类型
@property (nonatomic,strong) UILabel *txContentLabel;//交易内容
@property (nonatomic,strong) UILabel *assetAmountLabel; // 资产总额
@property (nonatomic,strong) UILabel *firstAmountLabel; // 第一发行总额
@property (nonatomic,strong) UILabel *ActualAmountLabel; // 实际发行总额
@property (nonatomic,strong) UILabel *candyAmountLabel; // 糖果发放数量
@property (nonatomic,strong) NSMutableArray *receiveAddressArray;
@property (nonatomic,strong) NSMutableArray *sendAddressArray;
@property (nonatomic, strong) NSMutableDictionary *txDates;
@property (nonatomic, strong) UIButton *moreBtn;
@property (nonatomic, strong) UIButton *browsBtn;
@property (nonatomic, strong) UILabel *sureLabel;

@end

@implementation BRDetailTxFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)setTransaction:(BRTransaction *)transaction {
    _transaction = transaction;
}

- (void)initUI {
    
    self.backgroundColor = [UIColor whiteColor];
    if (!self.receiveAddressArray) {
        self.receiveAddressArray = [NSMutableArray array];
    }
    if (!self.sendAddressArray) {
        self.sendAddressArray = [NSMutableArray array];
    }

//    UILabel *sendlable = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, SCREEN_WIDTH - 30, 20)];
//    sendlable.text = NSLocalizedString(@"Sender", nil);
//    sendlable.textColor = [UIColor blackColor];
//    sendlable.textAlignment = NSTextAlignmentLeft;
//    sendlable.font = [UIFont systemFontOfSize:16.f];
//    [self addSubview:sendlable];
    
//    UILabel *sendAddressLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(sendlable.frame) + 5, SCREEN_WIDTH - 30, 20)];
//    sendAddressLable.numberOfLines = 0;
//    sendAddressLable.textColor = ColorFromRGB(0x666666);
//    sendAddressLable.textAlignment = NSTextAlignmentLeft;
//    sendAddressLable.font = [UIFont systemFontOfSize:15.f];
//    [self addSubview:sendAddressLable];
//    self.sendAddressLable = sendAddressLable;
    
    UILabel *receiveLable = [[UILabel alloc] init];
    receiveLable.text = NSLocalizedString(@"Receiver", nil);
    receiveLable.textColor = [UIColor blackColor];
    receiveLable.textAlignment = NSTextAlignmentLeft;
    receiveLable.font = kRegularFont(14);//[UIFont systemFontOfSize:16.f];
//    receiveLable.backgroundColor = [UIColor cyanColor];
    [self addSubview:receiveLable];
    self.receiveLable = receiveLable;
    
    UIButton *moreBtn = [[UIButton alloc] init];
    self.moreBtn = moreBtn;
//    moreBtn.backgroundColor = [UIColor redColor];
//    moreBtn.frame = CGRectMake(SCREEN_WIDTH - 60, CGRectGetMaxY(sendAddressLable.frame) + 15,  50, 20);
    moreBtn.titleLabel.font = [UIFont systemFontOfSize:14];
#warning Language International
    [moreBtn setTitle:NSLocalizedString(@"View", nil) forState:UIControlStateNormal];
    [moreBtn setTitleColor:MAIN_COLOR forState:UIControlStateNormal];
    [moreBtn addTarget:self action:@selector(more:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:moreBtn];
    
    UILabel *receiveAddressLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(receiveLable.frame) + 5, SCREEN_WIDTH - 30, 20)];
    receiveAddressLable.numberOfLines = 0;
    receiveAddressLable.textColor = ColorFromRGB(0x666666);
    receiveAddressLable.textAlignment = NSTextAlignmentLeft;
    receiveAddressLable.font = kFont(13);//[UIFont systemFontOfSize:15.f];
    [self addSubview:receiveAddressLable];
    self.receiveAddressLable = receiveAddressLable;
    
    UILabel *feeLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(receiveAddressLable.frame) + 15, SCREEN_WIDTH - 30, 20)];
    feeLable.text = NSLocalizedString(@"Fee", nil);
    feeLable.textColor = [UIColor blackColor];
    feeLable.textAlignment = NSTextAlignmentLeft;
    feeLable.font = kRegularFont(14);//[UIFont systemFontOfSize:16.f];
    [self addSubview:feeLable];
    self.feeTextLable = feeLable;
    
    UILabel *feeAmountLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(feeLable.frame) + 5, SCREEN_WIDTH - 30, 20)];
    feeAmountLable.textColor = ColorFromRGB(0x666666);
    feeAmountLable.textAlignment = NSTextAlignmentLeft;
    feeAmountLable.font = kFont(13);//[UIFont systemFontOfSize:15.f];
    [self addSubview:feeAmountLable];
    self.feeLable = feeAmountLable;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 15 - 100, CGRectGetMinY(feeLable.frame), 100, 100)];
    imageView.userInteractionEnabled = YES;
    [self addSubview:imageView];
    self.codeImageView = imageView;
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewLongPress:)];
    [imageView addGestureRecognizer:longGesture];
    
    UILabel *blockLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(feeAmountLable.frame) + 40, SCREEN_WIDTH - 30, 20)];
    blockLable.text = NSLocalizedString(@"Block", nil);
    blockLable.textColor = [UIColor blackColor];
    blockLable.textAlignment = NSTextAlignmentLeft;
    blockLable.font = kRegularFont(14);//[UIFont systemFontOfSize:16.f];
    [self addSubview:blockLable];
    self.blockLable = blockLable;
    
    UILabel *blockHeightLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(blockLable.frame) + 5, SCREEN_WIDTH - 30, 20)];
    blockHeightLable.textColor = ColorFromRGB(0x666666);
    blockHeightLable.textAlignment = NSTextAlignmentLeft;
    blockHeightLable.font = kFont(13);//[UIFont systemFontOfSize:15.f];
    [self addSubview:blockHeightLable];
    self.confirmLable = blockHeightLable;
    
    UILabel *txLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(blockHeightLable.frame) + 10, SCREEN_WIDTH - 30, 20)];
    txLable.text = NSLocalizedString(@"Transaction time", nil);
    txLable.textColor = [UIColor blackColor];
    txLable.textAlignment = NSTextAlignmentLeft;
    txLable.font = kRegularFont(14);//[UIFont systemFontOfSize:16.f];
    [self addSubview:txLable];
    self.timeLable = txLable;
    
    UILabel *txTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(txLable.frame) + 5, SCREEN_WIDTH - 30, 20)];
    txTimeLable.textColor = ColorFromRGB(0x666666);
    txTimeLable.textAlignment = NSTextAlignmentLeft;
    txTimeLable.font = kFont(13);//[UIFont systemFontOfSize:15.f];
    [self addSubview:txTimeLable];
    self.txTimeLable = txTimeLable;
    
    UILabel *sureLabel = [[UILabel alloc] init];
    sureLabel.textColor = MAIN_COLOR;
    sureLabel.textAlignment = NSTextAlignmentRight;
    sureLabel.font = kFont(13);
    self.sureLabel = sureLabel;
    [self addSubview:sureLabel];
    
    UILabel *idLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(txTimeLable.frame) + 10, SCREEN_WIDTH - 30, 20)];
    idLable.text = NSLocalizedString(@"Transaction ID", nil);
    idLable.textColor = [UIColor blackColor];
    idLable.textAlignment = NSTextAlignmentLeft;
    idLable.font = kRegularFont(14);//[UIFont systemFontOfSize:16.f];
    [self addSubview:idLable];
    self.idLable = idLable;
    
    UIButton *browsBtn = [UIButton new];
    self.browsBtn = browsBtn;
    [browsBtn setTitle:NSLocalizedString(@"Browse", nil) forState:UIControlStateNormal];
    browsBtn.titleLabel.font = kRegularFont(14);
    browsBtn.backgroundColor = MAIN_COLOR;
    [self.browsBtn addTarget:self action:@selector(goBrowser:) forControlEvents:(UIControlEventTouchUpInside)];
    [self addSubview:browsBtn];
    
    UILabel *txIDLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(idLable.frame) + 5, SCREEN_WIDTH - 30, 40)];
    txIDLable.numberOfLines = 0;
    txIDLable.textColor = ColorFromRGB(0x666666);
    txIDLable.textAlignment = NSTextAlignmentLeft;
    txIDLable.font = kRegularFont(12);//[UIFont systemFontOfSize:15.f];
    [self addSubview:txIDLable];
    self.txIdLable = txIDLable;
    
    
    
    UILabel *txTypeLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(txIDLable.frame) + 10, SCREEN_WIDTH - 30, 20)];
    txTypeLable.textColor = [UIColor blackColor];
    txTypeLable.textAlignment = NSTextAlignmentLeft;
    txTypeLable.font = kRegularFont(14);//[UIFont systemFontOfSize:16.f];
    [self addSubview:txTypeLable];
    self.txTypeLable = txTypeLable;
    
    UILabel *txContentLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(txTypeLable.frame) + 5, SCREEN_WIDTH - 30, 20)];
    txContentLabel.numberOfLines = 0;
    txContentLabel.textColor = ColorFromRGB(0x666666);
    txContentLabel.textAlignment = NSTextAlignmentLeft;
    txContentLabel.font = kRegularFont(12);//[UIFont systemFontOfSize:15.f];
    [self addSubview:txContentLabel];
    self.txContentLabel = txContentLabel;
    
    UILabel *assetAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(txContentLabel.frame) + 5, SCREEN_WIDTH - 30, 20)];
    assetAmountLabel.numberOfLines = 0;
    assetAmountLabel.textColor = ColorFromRGB(0x666666);
    assetAmountLabel.textAlignment = NSTextAlignmentLeft;
    assetAmountLabel.font = kRegularFont(12);//[UIFont systemFontOfSize:15.f];
    [self addSubview:assetAmountLabel];
    self.assetAmountLabel = assetAmountLabel;
    
    UILabel *firstAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(assetAmountLabel.frame) + 5, SCREEN_WIDTH - 30, 20)];
    firstAmountLabel.numberOfLines = 0;
    firstAmountLabel.textColor = ColorFromRGB(0x666666);
    firstAmountLabel.textAlignment = NSTextAlignmentLeft;
    firstAmountLabel.font = kRegularFont(12);//[UIFont systemFontOfSize:15.f];
    [self addSubview:firstAmountLabel];
    self.firstAmountLabel = firstAmountLabel;
    
    UILabel *candyAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(firstAmountLabel.frame) + 5, SCREEN_WIDTH - 30, 20)];
    candyAmountLabel.numberOfLines = 0;
    candyAmountLabel.textColor = ColorFromRGB(0x666666);
    candyAmountLabel.textAlignment = NSTextAlignmentLeft;
    candyAmountLabel.font = kRegularFont(12);//[UIFont systemFontOfSize:15.f];
    [self addSubview:candyAmountLabel];
    self.candyAmountLabel = candyAmountLabel;
    
    UILabel *ActualAmountLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(candyAmountLabel.frame) + 5, SCREEN_WIDTH - 30, 20)];
    ActualAmountLabel.numberOfLines = 0;
    ActualAmountLabel.textColor = ColorFromRGB(0x666666);
    ActualAmountLabel.textAlignment = NSTextAlignmentLeft;
    ActualAmountLabel.font = kRegularFont(12);//[UIFont systemFontOfSize:15.f];
    [self addSubview:ActualAmountLabel];
    self.ActualAmountLabel = ActualAmountLabel;
}

- (NSString *)dateForTx:(BRTransaction *)tx
{
    self.txDates = [NSMutableDictionary dictionary];
    static NSDateFormatter *monthDayHourFormatter = nil;
    static NSDateFormatter *yearMonthDayHourFormatter = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{ // BUG: need to watch for NSCurrentLocaleDidChangeNotification
        monthDayHourFormatter = [NSDateFormatter new];
        monthDayHourFormatter.dateFormat = dateFormat(@"Mdjmma");
        yearMonthDayHourFormatter = [NSDateFormatter new];
        yearMonthDayHourFormatter.dateFormat = dateFormat(@"yyMdjmma");
    });
    
    NSString *date = self.txDates[uint256_obj(tx.txHash)];
    NSTimeInterval now = [[BRPeerManager sharedInstance] timestampForBlockHeight:TX_UNCONFIRMED];
    NSTimeInterval year = [NSDate timeIntervalSinceReferenceDate] - 364*24*60*60;
    
    if (date) return date;
    
    NSTimeInterval txTime = (tx.timestamp > 1) ? tx.timestamp : now;
    NSDateFormatter *desiredFormatter = yearMonthDayHourFormatter;
    
    date = [desiredFormatter stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:txTime]];
    if (tx.blockHeight != TX_UNCONFIRMED) self.txDates[uint256_obj(tx.txHash)] = date;
    return date;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self.receiveAddressArray removeAllObjects];
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    BRTransaction *tx = self.transaction;
    static uint32_t blockHeight = 0;
    uint32_t h = [BRPeerManager sharedInstance].lastBlockHeight;
    NSUInteger peerCount = [BRPeerManager sharedInstance].peerCount;
    NSUInteger relayCount = [[BRPeerManager sharedInstance] relayCountForTransaction:self.transaction.txHash];
    if (h > blockHeight) blockHeight = h;
    uint32_t confirms = (tx.blockHeight > blockHeight) ? 0 : (blockHeight - tx.blockHeight) + 1;
    BOOL isPublishAssetTX = NO;
    for(int i=0; i<tx.outputReserves.count; i++) {
        if(![BRSafeUtils isSafeTransaction:tx.outputReserves[i]]) { // [tx.outputReserves[i] length] > 42
            if([tx.outputReserves[i] isEqual:[NSNull null]]) continue;
            NSNumber * l = 0;
            NSUInteger off = 0;
            NSData *d = [tx.outputReserves[i] dataAtOffset:off length:&l];
            if([d UInt16AtOffset:38] == 200 || [d UInt16AtOffset:38] == 201) {
                isPublishAssetTX = YES;
                break;
            }
        }
    }
    uint64_t fee;
    if(!isPublishAssetTX) {
        BOOL isCandy = NO;
        for(NSData *reserves in tx.outputReserves) {
            if(![BRSafeUtils isSafeTransaction:reserves]) { // reserves.length > 42
                if([reserves isEqual:[NSNull null]]) continue;
                NSNumber * l = 0;
                NSUInteger off = 0;
                NSData *d = [reserves dataAtOffset:off length:&l];
                if([d UInt16AtOffset:38] == 206) {
                    isCandy = YES;
                    break;
                }
            }
        }
        if(isCandy) {
            fee = [manager.wallet feeForCandyTransaction:tx];
        } else {
            fee = [manager.wallet feeForTransaction:tx];
        }
    } else {
        fee = [manager.wallet feeForPublishAssetTransaction:tx];
    }
    uint64_t received = [manager.wallet amountReceivedFromTransaction:tx];
    uint64_t sent = [manager.wallet amountSentByTransaction:tx];
    
    BOOL isSend;
    //判断是发送还是接收
    if (received > 0 && sent == 0) {
        isSend = NO;//接收
    } else {
        isSend = YES;//发送
    }
    if (self.sendAddressArray.count == 0) {
        for (NSString *inputAddress in tx.inputAddresses) {
            [self.sendAddressArray addObject:inputAddress];
        }
    }

    self.receiveLable.frame = CGRectMake(15, 20, SCREEN_WIDTH - 100, 20);//接收方
    self.moreBtn.frame = CGRectMake(SCREEN_WIDTH - 60, 20, 50, 20);
    self.feeTextLable.frame = CGRectMake(15, CGRectGetMaxY(self.receiveAddressLable.frame) + 15, SCREEN_WIDTH - 30, 20);//矿工费用
    self.feeLable.frame = CGRectMake(15, CGRectGetMaxY(self.feeTextLable.frame) + 5, SCREEN_WIDTH - 30, 20);//矿工费用数量
    self.codeImageView.frame = CGRectMake(SCREEN_WIDTH - 15 - 100, CGRectGetMinY(self.feeTextLable.frame), 100, 100);//二维码
    self.blockLable.frame = CGRectMake(15, CGRectGetMaxY(self.feeLable.frame) + 40, SCREEN_WIDTH - 30, 20);//区块
    self.confirmLable.frame = CGRectMake(15, CGRectGetMaxY(self.blockLable.frame) + 5, SCREEN_WIDTH - 30, 20);//区块状态
    self.timeLable.frame = CGRectMake(15, CGRectGetMaxY(self.confirmLable.frame) + 10, SCREEN_WIDTH - 30, 20);//交易时间
    self.txTimeLable.frame = CGRectMake(15, CGRectGetMaxY(self.timeLable.frame) + 5, SCREEN_WIDTH - 30, 20);//交易时间日期
    self.sureLabel.frame = CGRectMake(130, CGRectGetMinY(self.txTimeLable.frame), SCREEN_WIDTH - 145, 20);
    self.idLable.frame = CGRectMake(15, CGRectGetMaxY(self.txTimeLable.frame) + 10, 130, 20);//交易id
    self.browsBtn.frame = CGRectMake(SCREEN_WIDTH - 75, CGRectGetMinY(self.idLable.frame) - 5, 60, 30);
    self.browsBtn.layer.cornerRadius = 3;
    self.txIdLable.frame = CGRectMake(15, CGRectGetMaxY(self.idLable.frame) + 5, SCREEN_WIDTH - 30, 40);//交易id号
    self.txTypeLable.frame = CGRectMake(15, CGRectGetMaxY(self.txIdLable.frame) + 10, SCREEN_WIDTH - 30, 20);//交易类型
    self.txContentLabel.frame = CGRectMake(15, CGRectGetMaxY(self.txTypeLable.frame) + 5, SCREEN_WIDTH - 30, 20);//交易内容
    self.assetAmountLabel.frame = CGRectMake(15, CGRectGetMaxY(self.txContentLabel.frame) + 5, SCREEN_WIDTH - 30, 20);//交易内容
    self.firstAmountLabel.frame = CGRectMake(15, CGRectGetMaxY(self.assetAmountLabel.frame) + 5, SCREEN_WIDTH - 30, 20);//交易内容
    self.candyAmountLabel.frame = CGRectMake(15, CGRectGetMaxY(self.firstAmountLabel.frame) + 5, SCREEN_WIDTH - 30, 20);//交易内容
    self.ActualAmountLabel.frame = CGRectMake(15, CGRectGetMaxY(self.candyAmountLabel.frame) + 5, SCREEN_WIDTH - 30, 20);//交易内容
    //接收方地址
//    self.receiveAddressLable.text = [self.receiveAddressArray firstObject];
    
    
    //矿工费用
    if (isSend) {
//        self.feeLable.attributedText = [manager attributedStringForDashAmount:fee];
        if([[BRSafeUtils showSAFEUint] length] == 0) {
            self.feeLable.text = [NSString stringWithFormat:@"-%@SAFE", [BRSafeUtils showSAFEAmount:fee]];
        } else {
            self.feeLable.text = [NSString stringWithFormat:@"-%@%@", [BRSafeUtils showSAFEAmount:fee], [BRSafeUtils showSAFEUint]];
        }
    } else {
//        self.feeLable.attributedText = [manager attributedStringForDashAmount:-fee];
        self.feeLable.text = NSLocalizedString(@"None", nil);
    }
    
    //区块确认状态及高度
    if (tx.blockHeight != TX_UNCONFIRMED) {
        self.confirmLable.text = [NSString stringWithFormat:@"%ld",(long)tx.blockHeight];
    }
    else if (![manager.wallet transactionIsValid:self.transaction]) {
        self.confirmLable.text = NSLocalizedString(@"double spend", nil);
    }
    else if ([manager.wallet transactionIsPending:self.transaction]) {
        self.confirmLable.text = NSLocalizedString(@"pending", nil);
    }
    else if (![manager.wallet transactionIsVerified:self.transaction]) {
        self.confirmLable.text = [NSString stringWithFormat:NSLocalizedString(@"seen by %d of %d peers", nil),
                            relayCount, peerCount];
    }
    else self.confirmLable.text = NSLocalizedString(@"verified, waiting for confirmation", nil);
    
    //交易时间
    self.txTimeLable.text = [self dateForTx:tx];
    
    // 确认个数
    int32_t count;
    if (tx.blockHeight == 0 || tx.blockHeight == INT32_MAX) {
        count = 0;
    } else {
        count = [BRPeerManager sharedInstance].lastBlockHeight - tx.blockHeight + 1;
    }
    
    if (count == 0) {
        self.sureLabel.text = NSLocalizedString(@"0 confirmations", nil);
    } else if (count == 1) {
        self.sureLabel.text = NSLocalizedString(@"1 confirmation", nil);
    } else {
        self.sureLabel.text = [NSString stringWithFormat:NSLocalizedString(@"%d confirmations", nil),
                           (int)count];
    }
    //交易ID
    NSString *txId = [NSString hexWithData:[NSData dataWithBytes:tx.txHash.u8 length:sizeof(UInt256)].reverse];
    self.txIdLable.text = txId;
    BRLog(@"%@", txId);
    //二维码
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSString *string = [NSString stringWithFormat:@"%@%@", BLOCKWEB_URL, txId];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    CIImage *image = [filter outputImage];
    self.codeImageView.image = [self creatNonInterpolatedUIImageFormCIImage:image withSize:100];
#warning Language International
    if([self isPublishAsset:tx].length != 0) {
        self.txContentLabel.text = [self showTransactionType:tx];
        for(int i=0; i < tx.outputReserves.count; i++) {
            NSNumber * l = 0;
            NSUInteger off = 0;
            NSData *d = [tx.outputReserves[i] dataAtOffset:off length:&l];
            if([d UInt16AtOffset:38] == 200) {
                IssueData *issueData = [BRSafeUtils analysisIssueData:[d subdataWithRange:NSMakeRange(42, d.length-42)]];
                self.txTypeLable.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"Issue assets", nil), [[NSString alloc] initWithData:issueData.assetName encoding:NSUTF8StringEncoding]];
                self.assetAmountLabel.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"Total assets", nil), [BRSafeUtils amountForAssetAmount:issueData.totalAmount decimals:[issueData.decimals UInt8AtOffset:0]]];
                self.firstAmountLabel.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"Total initial issuarance", nil), [BRSafeUtils amountForAssetAmount:issueData.firstIssueAmount decimals:[issueData.decimals UInt8AtOffset:0]]];
                if(issueData.candyAmount > 0) {
                    self.candyAmountLabel.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"Number of candy", nil), [BRSafeUtils amountForAssetAmount:issueData.candyAmount decimals:[issueData.decimals UInt8AtOffset:0]]];
                    self.ActualAmountLabel.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"Total amount of actual issuance", nil), [BRSafeUtils amountForAssetAmount:issueData.firstActualAmount decimals:[issueData.decimals UInt8AtOffset:0]]];
                } else {
                    self.candyAmountLabel.text = [NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"Total amount of actual issuance", nil), [BRSafeUtils amountForAssetAmount:issueData.firstActualAmount decimals:[issueData.decimals UInt8AtOffset:0]]];
                    self.ActualAmountLabel.text = @"";
                }
                break;
            }
        }
    } else {
        self.txTypeLable.text = [self showTransactionType:tx];
        self.txContentLabel.text = @"";
        self.ActualAmountLabel.text = @"";
        self.firstAmountLabel.text = @"";
        self.ActualAmountLabel.text = @"";
        self.candyAmountLabel.text = @"";
    }
    if ([self.txTypeLable.text isEqualToString:[NSString stringWithFormat:@"%@:%@", NSLocalizedString(@"Receive candy", nil), self.balanceModel.nameString]]) {
        if (self.receiveAddressArray.count == 0) {
            for(int i=0; i<tx.outputReserves.count; i++) {
                if(![BRSafeUtils isSafeTransaction:tx.outputReserves[i]]) { // [tx.outputReserves[i] length] > 42
                    NSNumber * l = 0;
                    NSUInteger off = 0;
                    NSData *d = [tx.outputReserves[i] dataAtOffset:off length:&l];
                    if([d UInt16AtOffset:38] == 206) {
                        [self.receiveAddressArray addObject:tx.outputAddresses[i]];
                        BRLog(@"amount = %@, address = %@", tx.outputAmounts[i], tx.outputAddresses[i]);
                    }
                }
            }
        }
    } else if ([[self isPublishAsset:tx] length] != 0) {
        if(self.balanceModel.assetId.length == 0) {
            for(NSString *address in tx.outputAddresses) {
                if([address isEqualToString:BLACK_HOLE_ADDRESS]) {
                    [self.receiveAddressArray addObject:address];
                    break;
                }
            }
        } else {
            [self.receiveAddressArray addObject:[self isPublishAsset:tx]];
        }
    } else {
        if (self.receiveAddressArray.count == 0) {
            if (isSend == YES) {
                for (NSString *outputAddress in tx.outputAddresses) {
                    if (![manager.wallet containsAddress:outputAddress]) {
                        [self.receiveAddressArray addObject:outputAddress];
                    }
                }
            } else {
                for (NSString *outputAddress in tx.outputAddresses) {
                    if ([manager.wallet containsAddress:outputAddress]) {
                        [self.receiveAddressArray addObject:outputAddress];
                    }
                }
            }
        }
    }
    
//    NSString *addresses = [self.receiveAddressArray componentsJoinedByString:@"\n"];
//    CGSize titleSize = [addresses boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:kFont(13)} context:nil].size;
    self.receiveAddressLable.frame = CGRectMake(15, CGRectGetMaxY(self.receiveLable.frame) + 5, SCREEN_WIDTH - 30, 20);//接收地址
    if(self.receiveAddressArray.count == 0) { // 内部
        self.receiveAddressLable.text = NSLocalizedString(@"Internal", nil);
        self.moreBtn.hidden = YES;
    } else {
        self.receiveAddressLable.text = self.receiveAddressArray.firstObject;
        if([self isPublishAsset:tx].length != 0) {
            self.moreBtn.hidden = YES;
        } else {
            self.moreBtn.hidden = NO;
        }
    }
}

- (NSString *) isPublishAsset:(BRTransaction *)tx {
    for(int i=0; i < tx.outputReserves.count; i++) {
        if([tx.outputReserves[i] isEqual:[NSNull null]]) continue;
        NSNumber * l = 0;
        NSUInteger off = 0;
        NSData *d = [tx.outputReserves[i] dataAtOffset:off length:&l];
        if([d UInt16AtOffset:38] == 200) {
            return tx.outputAddresses[i];
        }
    }
    return @"";
}

- (UIImage *)creatNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1. 创建bitmap
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    UIImage *newImage = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return newImage;
}


- (void)more:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(footerView:moreBtnDidTapped:)]) {
        [self.delegate footerView:self moreBtnDidTapped:btn];
    }
}

#pragma maek -- MARK:长按二维码事件
- (void)imageViewLongPress:(UILongPressGestureRecognizer *)longPress {
    UIImageView *imageView = (UIImageView *)longPress.view;
    UIImage *image = imageView.image;
    if (self.delegate && [self.delegate respondsToSelector:@selector(qrcodeLongpress:)]) {
        [self.delegate qrcodeLongpress:image];
    }
}

#warning Language International
- (NSString *)showTransactionType:(BRTransaction *) tx {
    NSString *showStr = @"";
    for(int i=0; i < tx.outputAddresses.count; i++) {
        if(![tx.outputAddresses[i] isEqual:[NSNull null]] && [tx.outputAddresses[i] isEqualToString:BLACK_HOLE_ADDRESS]) {
            showStr = [NSString stringWithFormat:@"%@%@%@", NSLocalizedString(@"Consumption", nil), [BRSafeUtils showSAFEAmount:[tx.outputAmounts[i] unsignedLongLongValue]], [BRSafeUtils showSAFEUint].length > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"];
            break;
        }
    }
    if(showStr.length != 0) {
        return showStr;
    }
    for(int i=0; i<tx.outputReserves.count; i++) {
        if(![BRSafeUtils isSafeTransaction:tx.outputReserves[i]]) { // [tx.outputReserves[i] length] > 42
            if([tx.outputReserves[i] isEqual:[NSNull null]]) continue;
            NSNumber * l = 0;
            NSUInteger off = 0;
            NSData *d = [tx.outputReserves[i] dataAtOffset:off length:&l];
            NSData *data = [d subdataWithRange:NSMakeRange(42, d.length-42)];
            if([d UInt16AtOffset:38] == 201) {
                showStr = NSLocalizedString(@"Additional issuance", nil);
                break;
            }
            if([d UInt16AtOffset:38] == 206) {
                showStr = NSLocalizedString(@"Receive candy", nil);
                break;
            }
            if([d UInt16AtOffset:38] == 205) {
                showStr = NSLocalizedString(@"Issuing candy", nil);
                break;
            }
            if([d UInt16AtOffset:38] == 202) {
                showStr = NSLocalizedString(@"Asset transfer", nil);
                break;
            }
        }
    }
    if(self.balanceModel.assetId.length == 0) return showStr;
    return [NSString stringWithFormat:@"%@:%@", showStr, self.balanceModel.nameString];
}


- (void)goBrowser:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(footerView:browserBtnDidTapped:)]) {
        [self.delegate footerView:self browserBtnDidTapped:btn];
    }
}

@end
