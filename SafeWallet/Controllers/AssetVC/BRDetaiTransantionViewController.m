//
//  BRDetaiTransantionViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/21.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRDetaiTransantionViewController.h"
#import "BRDetailTxHeaderView.h"
#import "BRDetailTxFooterView.h"
#import "BRSendViewController.h"
#import "BRReceiveViewController.h"
#import "BRWalletManager.h"
#import "BRPeerManager.h"
#import "BRCopyLabel.h"
#import "NSString+Bitcoin.h"
#import "NSData+Bitcoin.h"
#import "BREventManager.h"
#import "NSString+Dash.h"
#import "NSData+Dash.h"
#import <Photos/Photos.h>
#import <SafariServices/SafariServices.h>
#import "MBProgressHUD.h"
#import "BRCandyTXHistoryController.h"
#import "BRTXHistoryListViewController.h"
#import "BRTxWebViewController.h"
#import "BRSafeUtils.h"

@interface BRDetaiTransantionViewController ()<UITableViewDelegate,UITableViewDataSource,BRDetailTxFooterViewDelegate>

@property (nonatomic,strong) UITableView *detailTableView;
@property (nonatomic,strong) BRDetailTxHeaderView *headerView;
@property (nonatomic,strong) BRDetailTxFooterView *footerView;
@property (nonatomic, weak) id txStatusObserver;
@property (nonatomic,copy) NSString *txId;

@end

@implementation BRDetaiTransantionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"Transaction details", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
    @weakify(self);
    if (!self.txStatusObserver) {
        self.txStatusObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerTxStatusNotification object:nil
                                                           queue:nil usingBlock:^(NSNotification *note) {
                                                               @strongify(self);
                                                               BRTransaction *tx = [[BRWalletManager sharedInstance].wallet
                                                                                    transactionForHash:self.transaction.txHash];
                                                               
                                                               if (tx) self.transaction = tx;
                                                               self.txId = [NSString hexWithData:[NSData dataWithBytes:self.transaction.txHash.u8 length:sizeof(UInt256)].reverse];
                                                               [self initDetailTransaction];
                                                               [self.detailTableView reloadData];
                                                           }];
    }
}

- (void)dealloc
{
    if (self.txStatusObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.txStatusObserver];
    BRLog(@"%s", __func__);
}

- (void)setTransaction:(BRTransaction *)transaction {
    
    _transaction = transaction;
    self.txId = [NSString hexWithData:[NSData dataWithBytes:_transaction.txHash.u8 length:sizeof(UInt256)].reverse];
    [self initDetailTransaction];
}

- (void)initDetailTransaction {
    
    self.headerView.transaction = self.transaction;
    self.headerView.balanceModel = self.balanceModel;
    self.footerView.transaction = self.transaction;
    self.footerView.balanceModel = self.balanceModel;
    [self.headerView layoutSubviews];
    [self.footerView layoutSubviews];
}

- (BRDetailTxHeaderView *)headerView {
    
    if (_headerView == nil) {
        _headerView = [[BRDetailTxHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 180)];
    }
    return _headerView;
}

- (BRDetailTxFooterView *)footerView {
    if (_footerView == nil) {
//        NSString *sendAddress = @"";
//        for (NSInteger i = 0; i < self.transaction.inputAddresses.count; i ++) {
//            if([self.transaction.inputAddresses[i] isEqual:[NSNull null]]) continue;
//            if (i == 0) {
//                sendAddress = self.transaction.inputAddresses[i];
//            } else {
//                sendAddress = [NSString stringWithFormat:@"%@\n\n%@",sendAddress,self.transaction.inputAddresses[i]];
//            }
//        }
//        CGSize titleSize = [sendAddress boundingRectWithSize:CGSizeMake(SCREEN_WIDTH * 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.f]} context:nil].size;
        BOOL isPublishAsset = NO;
        BOOL isCandy = NO;
        for(int i=0; i <self.transaction.outputReserves.count; i++) {
            if([self.transaction.outputReserves[i] isEqual:[NSNull null]]) continue;
            NSNumber * l = 0;
            NSUInteger off = 0;
            NSData *d = [self.transaction.outputReserves[i] dataAtOffset:off length:&l];
            if([d UInt16AtOffset:38] == 200) {
                isPublishAsset = YES;
            } else if ([d UInt16AtOffset:38] == 205) {
                isCandy = YES;
            }
        }
        _footerView = [[BRDetailTxFooterView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, isPublishAsset ? (480 + (isCandy ? 26 : 0)) : 390)];
        _footerView.delegate = self;
    }
    return _footerView;
}

- (void)initUI {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.bounds.size.height - SafeAreaBottomHeight) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:tableView];
    self.detailTableView = tableView;
    tableView.tableHeaderView = self.headerView;
    tableView.tableFooterView = self.footerView;
}

- (void)qrcodeLongpress:(UIImage *)longpressImage {
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Save photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self loadImageFinished:longpressImage];
    }];
    UIAlertAction *jumpAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Check transaction", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *string = [NSString stringWithFormat:@"%@%@", BLOCKWEB_URL, self.txId];
//        SFSafariViewController * safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:string]];
//        [self presentViewController:safariViewController animated:YES completion:nil];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancle",nil) style:UIAlertActionStyleCancel handler:nil];
    [alertVc addAction:saveAction];
    [alertVc addAction:jumpAction];
    [alertVc addAction:cancleAction];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (void)footerView:(BRDetailTxFooterView *)footerView moreBtnDidTapped:(UIButton *)btn {
    if([self isCandyTransaction]) {
        BRCandyTXHistoryController *history = [BRCandyTXHistoryController new];
        history.candyTx = self.transaction;
        [self.navigationController pushViewController:history animated:YES];
    } else {
        BRTXHistoryListViewController *txhistoryListVC = [[BRTXHistoryListViewController alloc] init];
        txhistoryListVC.tx = self.transaction;
        txhistoryListVC.balanceModel = self.balanceModel;
        [self.navigationController pushViewController:txhistoryListVC animated:self];
    }
}

- (void)footerView:(BRDetailTxFooterView *)footerView browserBtnDidTapped:(UIButton *)btn {
    NSString *string = [NSString stringWithFormat:@"%@%@", BLOCKWEB_URL, self.txId];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
}

- (BOOL) isCandyTransaction {
    for(int i=0; i<self.transaction.outputReserves.count; i++) {
        if(![BRSafeUtils isSafeTransaction:self.transaction.outputReserves[i]]) { // [self.transaction.outputReserves[i] length] > 42
            NSNumber * l = 0;
            NSUInteger off = 0;
            NSData *d = [self.transaction.outputReserves[i] dataAtOffset:off length:&l];
            if([d UInt16AtOffset:38] == 206) {
                return YES;
            }
        }
    }
    return NO;
}

- (void)loadImageFinished:(UIImage *)image
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //写入图片到相册
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            BRLog(@"success = %d, error = %@", success, error);
            if (success) {
                [AppTool showMessage:NSLocalizedString(@"Saved photo", nil) showView:nil];
            } else {
                [AppTool showMessage:NSLocalizedString(@"Saved failure", nil) showView:nil];
            }
        });
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.00001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00001;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
