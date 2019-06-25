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

@interface BRDetaiTransantionViewController ()<UITableViewDelegate,UITableViewDataSource,BRDetailTxFooterViewDelegate>

@property (nonatomic,strong) UITableView *detailTableView;
@property (nonatomic,strong) BRDetailTxHeaderView *headerView;
@property (nonatomic,strong) BRDetailTxFooterView *footerView;
@property (nonatomic, strong) id txStatusObserver;
@property (nonatomic,copy) NSString *txId;

@end

@implementation BRDetaiTransantionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"Transaction Details", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
    
    if (!self.txStatusObserver) {
        self.txStatusObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerTxStatusNotification object:nil
                                                           queue:nil usingBlock:^(NSNotification *note) {
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
}

- (void)setTransaction:(BRTransaction *)transaction {
    
    _transaction = transaction;
    self.txId = [NSString hexWithData:[NSData dataWithBytes:_transaction.txHash.u8 length:sizeof(UInt256)].reverse];
    [self initDetailTransaction];
}

- (void)initDetailTransaction {
    
    self.headerView.transaction = self.transaction;
    self.footerView.transaction = self.transaction;
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
        NSString *sendAddress = @"";
        for (NSInteger i = 0; i < self.transaction.inputAddresses.count; i ++) {
            if (i == 0) {
                sendAddress = self.transaction.inputAddresses[i];
            } else {
                sendAddress = [NSString stringWithFormat:@"%@\n\n%@",sendAddress,self.transaction.inputAddresses[i]];
            }
        }
        CGSize titleSize = [sendAddress boundingRectWithSize:CGSizeMake(SCREEN_WIDTH * 30, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15.f]} context:nil].size;
        _footerView = [[BRDetailTxFooterView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, titleSize.height + 390)];
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
        NSString *string = [NSString stringWithFormat:@"http://10.0.0.249:3001/tx/%@",self.txId];
        SFSafariViewController * safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:string]];
        [self presentViewController:safariViewController animated:YES completion:nil];
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancle",nil) style:UIAlertActionStyleCancel handler:nil];
    [alertVc addAction:saveAction];
    [alertVc addAction:jumpAction];
    [alertVc addAction:cancleAction];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (void)loadImageFinished:(UIImage *)image
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //写入图片到相册
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"success = %d, error = %@", success, error);
        if (success) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.label.text = NSLocalizedString(@"Saved photo", nil);
            hud.label.numberOfLines = 0;
            hud.label.textColor = [UIColor blackColor];
            hud.label.font = [UIFont systemFontOfSize:17.0];
            hud.userInteractionEnabled= NO;
            hud.bezelView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];   //背景颜色
            hud.mode = MBProgressHUDModeText;
            // 隐藏时候从父控件中移除
            hud.removeFromSuperViewOnHide = YES;
            // 2.5秒之后再消失
            [hud hideAnimated:YES afterDelay:2.f];
        } else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.label.text = NSLocalizedString(@"Saved failure", nil);
            hud.label.numberOfLines = 0;
            hud.label.textColor = [UIColor blackColor];
            hud.label.font = [UIFont systemFontOfSize:17.0];
            hud.userInteractionEnabled= NO;
            hud.bezelView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];   //背景颜色
            hud.mode = MBProgressHUDModeText;
            // 隐藏时候从父控件中移除
            hud.removeFromSuperViewOnHide = YES;
            // 2.5秒之后再消失
            [hud hideAnimated:YES afterDelay:2.5];
        }
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
