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

#import "BRSafeUtils.h"
#import "AppTool.h"
#import "UIScrollView+Refresh.h"
#import "BRPayViewController.h"
#import "BRReceivablesViewController.h"

static NSString *identifier = @"BRHistoryCell";

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
@property (nonatomic, weak) id backgroundObserver, balanceObserver, txStatusObserver;
@property (nonatomic, weak) id syncStartedObserver, syncFinishedObserver, syncFailedObserver;
@property (nonatomic,assign) NSInteger index;
@property (nonatomic,strong) NSMutableArray *showTransactionArray;

@property (nonatomic,assign) NSInteger showTxCount;

@end

@implementation BRHistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 144, 44)];
    titleView.backgroundColor = [UIColor clearColor];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:titleView.bounds];
    titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    titleLabel.text = self.balanceModel.nameString;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.backgroundColor = [UIColor clearColor];
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
//    self.navigationItem.title = self.balanceModel.nameString;
    self.view.backgroundColor = [UIColor whiteColor];
    self.moreTx = YES;
    self.index = 1;
    [self initUI];
}

- (void)loadMoreData {
    self.index++;
    [BREventManager saveEvent:@"tx_history:more"];
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSUInteger txCount = self.transactions.count;
    self.showTxCount = self.showTransactionArray.count;
    [self.showTransactionArray removeAllObjects];
    [self addTxToShowTransactionArray];
    [self.headerView reloadBalanceShow];
    [self.historyTableView reloadData];
    [self.historyTableView endFooterRefresh];
    if(self.showTransactionArray.count == self.showTxCount) {
        [AppTool showMessage:NSLocalizedString(@"No more data yet", nil) showView:self.view];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.headerView.balanceModel = self.balanceModel;
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // TODO: 修改数据
        //        self.transactions = manager.wallet.allTransactions;
        self.transactions = self.balanceModel.txArray;
        if (self.transactions.count > 10) {
            self.moreTx = YES;
        } else {
            self.moreTx = NO;
        }
        [self addTxToShowTransactionArray];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.headerView reloadBalanceShow];
            [self.historyTableView reloadData];
        });
    });
    @weakify(self);
    if (!self.backgroundObserver) {
        self.backgroundObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification
                                                          object:nil queue:nil usingBlock:^(NSNotification *note) {
                                                              // TODO: 修改数据
                                                              //                                                              self.transactions = manager.wallet.allTransactions;
                                                              @strongify(self);
                                                              for(int i=0; i<manager.wallet.balanceArray.count; i++) {
                                                                  BRBalanceModel *balanceModel = manager.wallet.balanceArray[i];
                                                                  if(self.balanceModel.assetId.length == 0) {
                                                                      self.transactions = [balanceModel.txArray copy];
                                                                      self.balanceModel = balanceModel;
                                                                      break;
                                                                  } else {
                                                                      if([balanceModel.assetId isEqual:self.balanceModel.assetId]) {
                                                                          self.transactions = [balanceModel.txArray copy];
                                                                          self.balanceModel = balanceModel;
                                                                          break;
                                                                      }
                                                                  }
                                                              }
                                                              if (self.transactions.count > 10) {
                                                                  self.moreTx = YES;
                                                              } else {
                                                                  self.moreTx = NO;
                                                              }
                                                              [self addTxToShowTransactionArray];
                                                              [self.headerView reloadBalanceShow];
                                                              [self.historyTableView reloadData];
                                                          }];
    }

    if (!self.balanceObserver) {
        self.balanceObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRWalletBalanceChangedNotification object:nil
                                                           queue:nil usingBlock:^(NSNotification *note) {
                                                               @strongify(self);
                                                               BRTransaction *tx = self.transactions.firstObject;
                                                               // TODO: 修改数据
                                                               //                                                              self.transactions = manager.wallet.allTransactions;
                                                               for(int i=0; i<manager.wallet.balanceArray.count; i++) {
                                                                   BRBalanceModel *balanceModel = manager.wallet.balanceArray[i];
                                                                   if(self.balanceModel.assetId.length == 0) {
                                                                       self.transactions = [balanceModel.txArray copy];
                                                                       self.balanceModel = balanceModel;
                                                                       break;
                                                                   } else {
                                                                       if([balanceModel.assetId isEqual:self.balanceModel.assetId]) {
                                                                           self.transactions = [balanceModel.txArray copy];
                                                                           self.balanceModel = balanceModel;
                                                                           break;
                                                                       }
                                                                   }
                                                               }
                                                               
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
                                                               else {
                                                                   [self.headerView reloadBalanceShow];
                                                                   [self.historyTableView reloadData];
                                                               }
                                                           }];
    }

    if (!self.txStatusObserver) {
        self.txStatusObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerTxStatusNotification object:nil
                                                           queue:nil usingBlock:^(NSNotification *note) {
                                                               // TODO: 修改数据
                                                               //                                                              self.transactions = manager.wallet.allTransactions;
                                                               @strongify(self);
                                                               for(int i=0; i<manager.wallet.balanceArray.count; i++) {
                                                                   BRBalanceModel *balanceModel = manager.wallet.balanceArray[i];
                                                                   if(self.balanceModel.assetId.length == 0) {
                                                                       self.transactions = [balanceModel.txArray copy];
                                                                       self.balanceModel = balanceModel;
                                                                       break;
                                                                   } else {
                                                                       if([balanceModel.assetId isEqual:self.balanceModel.assetId]) {
                                                                           self.transactions = [balanceModel.txArray copy];
                                                                           self.balanceModel = balanceModel;
                                                                           break;
                                                                       }
                                                                   }
                                                               }
                                                               if (self.transactions.count > 10) {
                                                                   self.moreTx = YES;
                                                               } else {
                                                                   self.moreTx = NO;
                                                               }
                                                               [self addTxToShowTransactionArray];
                                                               [self.headerView reloadBalanceShow];
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
    BRLog(@"%s", __func__);
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
    [self.headerView reloadBalanceShow];
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
        _headerView = [[BRHistoryHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 230)];
    }
    return _headerView;
}

- (void)initUI {
    
    //    self.navigationItem.title = @"SAFE";
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.bounds.size.height - 50 - SafeAreaBottomHeight) style:UITableViewStylePlain];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    tableView.estimatedRowHeight = 0;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    [self.view addSubview:tableView];
    self.historyTableView = tableView;
    tableView.tableHeaderView = self.headerView;
    tableView.tableFooterView = [UIView new];
    
    UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sendButton.frame = CGRectMake(0, self.view.bounds.size.height - 50 - SafeAreaBottomHeight, SCREEN_WIDTH * 0.5, 50);
    [sendButton setTitle:NSLocalizedString(@"Send ", nil) forState:UIControlStateNormal];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sendButton.backgroundColor = MAIN_COLOR;
    sendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    sendButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [self.view addSubview:sendButton];
    [sendButton addTarget:self action:@selector(sendAsset) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *receiveButton = [UIButton buttonWithType:UIButtonTypeCustom];
    receiveButton.frame = CGRectMake(SCREEN_WIDTH * 0.5, self.view.bounds.size.height - 50 - SafeAreaBottomHeight, SCREEN_WIDTH * 0.5, 50);
    [receiveButton setTitle:NSLocalizedString(@"Receive ", nil) forState:UIControlStateNormal];
    [receiveButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    receiveButton.backgroundColor = ColorFromRGB(0xf0f0f0);
    receiveButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    receiveButton.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [self.view addSubview:receiveButton];
    [receiveButton addTarget:self action:@selector(receiveAsset) forControlEvents:UIControlEventTouchUpInside];
    
    __weak typeof(self) weakSelf = self;
    [self.historyTableView addFooterRefresh:^{
        [weakSelf loadMoreData];
    }];
}

#pragma mark -- MARK:转账点击事件
- (void)sendAsset {
    if([BRPeerManager sharedInstance].syncProgress < 1) {
#warning Language International
        [AppTool showMessage:NSLocalizedString(@"Syncing block data, please wait ...", nil) showView:self.view];
        return;
    }
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    BRSendViewController *sendVc = [storyBoard instantiateViewControllerWithIdentifier:@"SendViewController"];
//    sendVc.balanceModel = self.balanceModel;
//    [self.navigationController pushViewController:sendVc animated:YES];
    
    BRPayViewController *payVC = [[BRPayViewController alloc] init];
    payVC.balanceModel = self.balanceModel;
    [self.navigationController pushViewController:payVC animated:YES];
}

#pragma mark -- MARK:收款点击事件
- (void)receiveAsset {
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    BRReceiveViewController *receiveVc = [storyBoard instantiateViewControllerWithIdentifier:@"ReceiveViewController"];
//    receiveVc.balanceModel = self.balanceModel;
//    [self.navigationController pushViewController:receiveVc animated:YES];
    
    BRReceivablesViewController *receivablesVC = [[BRReceivablesViewController alloc] init];
    receivablesVC.balanceModel = self.balanceModel;
    [self.navigationController pushViewController:receivablesVC animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (self.transactions.count == 0) return 1;
    
    //    if (self.moreTx) {
    //        return self.showTransactionArray.count + 1;
    //    } else {
    return self.showTransactionArray.count;
    //    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.transactions.count == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"emptyCellName"];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"emptyCellName"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, SCREEN_WIDTH);
        }
        cell.textLabel.text = NSLocalizedString(@"No transaction history", nil);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        return cell;
    } else {
        BRWalletManager *manager = [BRWalletManager sharedInstance];
        BRHistoryCell *cell = (BRHistoryCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[BRHistoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        if(indexPath.row < self.showTransactionArray.count) {
            BRTransaction *tx = self.showTransactionArray[indexPath.row];

            cell.balanceModel = self.balanceModel;
            cell.blockHeight = self.blockHeight;
            cell.tx = tx;
            cell.timeStr = [self dateForTx:tx];
        }
        //cell.amoutLable.attributedText = [manager attributedStringForDashAmount:balance withTintColor:cell.amoutLable.textColor dashSymbolSize:CGSizeMake(12, 12)];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(self.transactions.count == 0) return;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BRDetaiTransantionViewController *detailVc = [[BRDetaiTransantionViewController alloc] init];
    detailVc.balanceModel = self.balanceModel;
    detailVc.transaction = self.showTransactionArray[indexPath.row];
    detailVc.txDateString = [self dateForTx:self.showTransactionArray[indexPath.row]];
    [self.navigationController pushViewController:detailVc animated:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

