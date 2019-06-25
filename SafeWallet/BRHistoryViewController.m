//
//  BRHistoryViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/21.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRHistoryViewController.h"
#import "BRHistoryHeaderView.h"
#import "BRHistoryCell.h"
#import "BRDetaiTransantionViewController.h"
#import "BRSendViewController.h"
#import "BRReceiveViewController.h"
#import "BRWalletManager.h"

#import "BRPeerManager.h"
#import "BRTransaction.h"
#import "NSString+Bitcoin.h"
#import "NSData+Bitcoin.h"
#import "UIImage+Utils.h"
#import "BREventConfirmView.h"
#import "BREventManager.h"
#import "NSString+Dash.h"
#import <WebKit/WebKit.h>

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

@interface BRHistoryViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *historyTableView;
@property (nonatomic,strong) BRHistoryHeaderView *headerView;

@property (nonatomic, strong) NSArray *transactions;
@property (nonatomic, assign) BOOL moreTx;
@property (nonatomic, strong) NSMutableDictionary *txDates;
@property (nonatomic, strong) id backgroundObserver, balanceObserver, txStatusObserver;
@property (nonatomic, strong) id syncStartedObserver, syncFinishedObserver, syncFailedObserver;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,strong) NSMutableArray *showTransactionArray;

@end

@implementation BRHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.moreTx = YES;
    self.index = 1;
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.transactions = manager.wallet.allTransactions;
        if (self.transactions.count > 10) {
            self.moreTx = YES;
        } else {
            self.moreTx = NO;
        }
        [self addTxToShowTransactionArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.historyTableView reloadData];
        });
    });
    
    if (!self.backgroundObserver) {
        self.backgroundObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                          object:nil queue:nil usingBlock:^(NSNotification *note) {
                                                              self.transactions = manager.wallet.allTransactions;
                                                              if (self.transactions.count > 10) {
                                                                  self.moreTx = YES;
                                                              } else {
                                                                  self.moreTx = NO;
                                                              }
                                                              [self addTxToShowTransactionArray];
                                                              [self.historyTableView reloadData];
                                                          }];
    }
    
    if (!self.balanceObserver) {
        self.balanceObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRWalletBalanceChangedNotification object:nil
                                                           queue:nil usingBlock:^(NSNotification *note) {
                                                               BRTransaction *tx = self.transactions.firstObject;
                                                               self.transactions = manager.wallet.allTransactions;
                                                               
                                                               if (self.transactions.count > 10) {
                                                                   self.moreTx = YES;
                                                               } else {
                                                                   self.moreTx = NO;
                                                               }
                                                               [self addTxToShowTransactionArray];
                                                               if (self.headerView) {
                                                                   [self.headerView layoutSubviews];
                                                               }
                                                               
                                                               if (self.transactions.firstObject != tx) {
                                                                   [self.historyTableView reloadSections:[NSIndexSet indexSetWithIndex:0]
                                                                                 withRowAnimation:UITableViewRowAnimationAutomatic];
                                                               }
                                                               else [self.historyTableView reloadData];
                                                           }];
    }
    
    if (!self.txStatusObserver) {
        self.txStatusObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerTxStatusNotification object:nil
                                                           queue:nil usingBlock:^(NSNotification *note) {
                                                               self.transactions = manager.wallet.allTransactions;
                                                               if (self.transactions.count > 10) {
                                                                   self.moreTx = YES;
                                                               } else {
                                                                   self.moreTx = NO;
                                                               }
                                                               [self addTxToShowTransactionArray];
                                                               [self.historyTableView reloadData];
                                                           }];
    }
    
    if (!self.syncStartedObserver) {
        self.syncStartedObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncStartedNotification object:nil
                                                           queue:nil usingBlock:^(NSNotification *note) {
                                                               if ([[BRPeerManager sharedInstance]
                                                                    timestampForBlockHeight:[BRPeerManager sharedInstance].lastBlockHeight] + WEEK_TIME_INTERVAL <
                                                                   [NSDate timeIntervalSinceReferenceDate] &&
                                                                   manager.seedCreationTime + DAY_TIME_INTERVAL < [NSDate timeIntervalSinceReferenceDate]) {
                                                               }
                                                           }];
    }
    
    if (!self.syncFinishedObserver) {
        self.syncFinishedObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncFinishedNotification object:nil
                                                           queue:nil usingBlock:^(NSNotification *note) {

                                                           }];
    }
    
    if (!self.syncFailedObserver) {
        self.syncFailedObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncFailedNotification object:nil
                                                           queue:nil usingBlock:^(NSNotification *note) {
                                                               
                                                           }];
    }
}

- (void)dealloc
{
    if (self.backgroundObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.backgroundObserver];
    if (self.balanceObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.balanceObserver];
    if (self.txStatusObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.txStatusObserver];
    if (self.syncStartedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.syncStartedObserver];
    if (self.syncFinishedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.syncFinishedObserver];
    if (self.syncFailedObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.syncFailedObserver];
}

- (uint32_t)blockHeight
{
    static uint32_t height = 0;
    uint32_t h = [BRPeerManager sharedInstance].lastBlockHeight;
    if (h > height) height = h;
    return height;
}

- (NSString *)dateForTx:(BRTransaction *)tx
{
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

- (void)addTxToShowTransactionArray {
    
    if (self.showTransactionArray.count > 0) {
        [self.showTransactionArray removeAllObjects];
    }
    NSUInteger txCount = self.transactions.count;
    if (txCount > 10) {
        if (self.index * 10 >= txCount) {
            self.showTransactionArray = [NSMutableArray arrayWithArray:self.transactions];
            self.moreTx = NO;
        } else {
            self.showTransactionArray = [NSMutableArray arrayWithArray:[self.transactions subarrayWithRange:NSMakeRange(0, self.index * 10)]];
            self.moreTx = YES;
        }
    } else {
        self.showTransactionArray = [NSMutableArray arrayWithArray:self.transactions];
    }
}

#pragma mark -- MARK:"更多..."点击事件
- (void)clickMoreTx
{
    [BREventManager saveEvent:@"tx_history:more"];
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSUInteger txCount = self.transactions.count;
    
    self.index += 1;
    [self.showTransactionArray removeAllObjects];
    [self addTxToShowTransactionArray];
    [self.historyTableView reloadData];
}

- (NSMutableArray *)showTransactionArray {
    if (_showTransactionArray == nil) {
        _showTransactionArray = [NSMutableArray array];
    }
    return _showTransactionArray;
}

- (NSArray *)transactions {
    if (_transactions == nil) {
        _transactions = [NSArray array];
    }
    return _transactions;
}

- (NSMutableDictionary *)txDates {
    if (_txDates == nil) {
        _txDates = [NSMutableDictionary dictionary];
    }
    return _txDates;
}

- (BRHistoryHeaderView *)headerView {
    if (_headerView == nil) {
        _headerView = [[BRHistoryHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 180)];
    }
    return _headerView;
}

- (void)initUI {
    
    self.navigationItem.title = @"SAFE";
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.bounds.size.height - 50 - SafeAreaBottomHeight) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    [self.view addSubview:tableView];
    self.historyTableView = tableView;
    tableView.tableHeaderView = self.headerView;
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(0, self.view.bounds.size.height - 50 - SafeAreaBottomHeight, SCREEN_WIDTH * 0.5, 50);
    [sendButton setTitle:NSLocalizedString(@"Transfer", nil) forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sendButton.backgroundColor = MAIN_COLOR;
    sendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    sendButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [self.view addSubview:sendButton];
    [sendButton addTarget:self action:@selector(sendAsset) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *receiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    receiveButton.frame = CGRectMake(SCREEN_WIDTH * 0.5, self.view.bounds.size.height - 50 - SafeAreaBottomHeight, SCREEN_WIDTH * 0.5, 50);
    [receiveButton setTitle:NSLocalizedString(@"Gathering", nil) forState:UIControlStateNormal];
    [receiveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    receiveButton.backgroundColor = ColorFromRGB(0xf0f0f0);
    receiveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    receiveButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [self.view addSubview:receiveButton];
    [receiveButton addTarget:self action:@selector(receiveAsset) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark -- MARK:转账点击事件
- (void)sendAsset {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BRSendViewController *sendVc = [storyBoard instantiateViewControllerWithIdentifier:@"SendViewController"];
    [self.navigationController pushViewController:sendVc animated:YES];
}

#pragma mark -- MARK:收款点击事件
- (void)receiveAsset {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BRReceiveViewController *receiveVc = [storyBoard instantiateViewControllerWithIdentifier:@"ReceiveViewController"];
    [self.navigationController pushViewController:receiveVc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.transactions.count == 0) return 0;

    if (self.moreTx) {
        return self.showTransactionArray.count + 1;
    } else {
        return self.showTransactionArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.transactions.count > 0) {
        BRWalletManager *manager = [BRWalletManager sharedInstance];
        static NSString *identifier = @"BRHistoryCell";
        static NSString *moreIdentifier = @"MoreCell";
        BRHistoryCell *cell = (BRHistoryCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[BRHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        NSInteger showCount = self.index * 10;
        if (self.moreTx && indexPath.row >= showCount) {
            
            UITableViewCell *moreCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:moreIdentifier];
            moreCell.textLabel.text = NSLocalizedString(@"more...", nil);
            moreCell.textLabel.textColor = MAIN_COLOR;
            return moreCell;
            
        } else {
            
            BRTransaction *tx = self.showTransactionArray[indexPath.row];
            uint64_t received = [manager.wallet amountReceivedFromTransaction:tx],
            sent = [manager.wallet amountSentByTransaction:tx],
            balance = [manager.wallet balanceAfterTransaction:tx];
            uint32_t blockHeight = self.blockHeight;
            uint32_t confirms = (tx.blockHeight > blockHeight) ? 0 : (blockHeight - tx.blockHeight) + 1;
            
            for (NSInteger i = 0; i < tx.outputUnlockHeights.count; i ++) {
                uint64_t unlockheight = [tx.outputUnlockHeights[i] unsignedLongLongValue];
                if (unlockheight > 0 && unlockheight < blockHeight) {
                    cell.lockImageView.hidden = NO;
                } else {
                    cell.lockImageView.hidden = YES;
                }
            }
            
            NSString *sendAddress = @"";
            if (received > 0 && sent == 0) {
                for (NSString *outputAddress in tx.outputAddresses) {
                    if ([manager.wallet containsAddress:outputAddress]) {
                        sendAddress = outputAddress;
                    }
                }
            } else {
                for (NSString *outputAddress in tx.outputAddresses) {
                    if (![manager.wallet containsAddress:outputAddress]) {
                        sendAddress = outputAddress;
                    }
                }
            }
            cell.addressLable.text = sendAddress;
            
            if (received > 0 && sent == 0) {
                cell.arrowImageView.image = [UIImage imageNamed:@"right"];
                cell.loseOrGetAssetLable.attributedText = [manager attributedStringForDashAmount:received];
            } else {
                cell.arrowImageView.image = [UIImage imageNamed:@"left"];
                cell.loseOrGetAssetLable.attributedText = [manager attributedStringForDashAmount:received - sent];
            }
            
            if (confirms == 0 && ! [manager.wallet transactionIsValid:tx]) {
                cell.statusLable.tag = 222;
                cell.statusLable.text = NSLocalizedString(@"INVALID", nil);
            }
            else if (confirms == 0 && [manager.wallet transactionIsPending:tx]) {
                cell.statusLable.tag = 333;
                cell.statusLable.text = NSLocalizedString(@"pending", nil);
            }
            else if (confirms == 0 && ! [manager.wallet transactionIsVerified:tx]) {
                cell.statusLable.tag = 444;
                cell.statusLable.text = NSLocalizedString(@"unverified", nil);
            }
            else if (confirms < 6) {
                cell.statusLable.tag = 111;
                if (confirms == 0) cell.statusLable.text = NSLocalizedString(@"0 confirmations", nil);
                else if (confirms == 1) cell.statusLable.text = NSLocalizedString(@"1 confirmation", nil);
                else cell.statusLable.text = [NSString stringWithFormat:NSLocalizedString(@"%d confirmations", nil),
                                              (int)confirms];
            } else {
                if (sent > 0) {
                    if (received == sent) {
                        cell.statusLable.tag = 555;
                        cell.statusLable.text = NSLocalizedString(@"moved", nil);
                    } else {
                        cell.statusLable.tag = 555;
                        cell.statusLable.text = NSLocalizedString(@"sent", nil);
                    }
                    //uint64_t tempBalance = received - sent;
                    //NSLog(@"tempBalance = %ld",(long)tempBalance);
//                    NSString *stringA = [NSString stringWithFormat:@"%ld",(long)-tempBalance];
//                    NSString *stringB = [NSString stringWithFormat:@"100000000.0000"];
//                    NSDecimalNumber *totalBalance = [NSDecimalNumber decimalNumberWithString:stringA];
//                    NSDecimalNumber *actualBalance = [NSDecimalNumber decimalNumberWithString:stringB];
//                    NSDecimalNumber *finalBalance = [totalBalance decimalNumberByDividingBy:actualBalance];
//                    cell.loseOrGetAssetLable.text = [NSString stringWithFormat:@"- %@ SAFE",finalBalance];
                    
//                    cell.loseOrGetAssetLable.attributedText = [manager attributedStringForDashAmount:received - sent];
                }
                if (received > 0 && sent == 0) {
                    cell.statusLable.tag = 666;
                    cell.statusLable.text = NSLocalizedString(@"received", nil);
//                    uint64_t tempBalance = received;
//                    NSString *stringA = [NSString stringWithFormat:@"%.4f",(double)tempBalance];
//                    NSString *stringB = [NSString stringWithFormat:@"100000000.0000"];
//                    NSDecimalNumber *totalBalance = [NSDecimalNumber decimalNumberWithString:stringA];
//                    NSDecimalNumber *actualBalance = [NSDecimalNumber decimalNumberWithString:stringB];
//                    NSDecimalNumber *finalBalance = [totalBalance decimalNumberByDividingBy:actualBalance];
//                    cell.loseOrGetAssetLable.text = [NSString stringWithFormat:@"+%@ SAFE",finalBalance];
                }
            }
            
            cell.timeLable.text = [self dateForTx:tx];
            //cell.amoutLable.attributedText = [manager attributedStringForDashAmount:balance withTintColor:cell.amoutLable.textColor dashSymbolSize:CGSizeMake(12, 12)];
            return cell;
        }
    }
    else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSInteger txCount = self.transactions.count;
    NSInteger count = self.index * 10;
    if (self.moreTx && indexPath.row >= count) {
        [self clickMoreTx];
    } else {
        BRDetaiTransantionViewController *detailVc = [[BRDetaiTransantionViewController alloc] init];
        detailVc.transaction = self.showTransactionArray[indexPath.row];
        detailVc.txDateString = [self dateForTx:self.showTransactionArray[indexPath.row]];
        [self.navigationController pushViewController:detailVc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
