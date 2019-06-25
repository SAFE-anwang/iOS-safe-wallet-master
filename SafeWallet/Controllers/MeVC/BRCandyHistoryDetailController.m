//
//  BRCandyHistoryDetailController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/24.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRCandyHistoryDetailController.h"
#import "BRCandyHistoryDetailCell.h"
#import <Photos/Photos.h>
#import "MBProgressHUD.h"
#import "BRSafeUtils.h"
#import "NSString+Bitcoin.h"
#import "NSData+Bitcoin.h"
#import <SafariServices/SafariServices.h>
#import "BRIssueDataEnity+CoreDataProperties.h"
#import "BRCoreDataManager.h"
#import "BRPeerManager.h"
#import "BRWalletManager.h"

@interface BRCandyHistoryDetailController ()<UITableViewDelegate,UITableViewDataSource,BRCandyHistoryDetailCellDelegate>

@property (nonatomic,strong) UITableView *detailTableView;

@property (nonatomic, strong) id txStatusObserver;

@end

@implementation BRCandyHistoryDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"Receive Details", nil);
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnClick)];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
    @weakify(self);
    if (! self.txStatusObserver) {
        self.txStatusObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerTxStatusNotification object:nil
                                                           queue:nil usingBlock:^(NSNotification *note) {
                                                               @strongify(self);
                                                               [self.detailTableView reloadData];
                                                           }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.txStatusObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.txStatusObserver];
    self.txStatusObserver = nil;
    
    [super viewWillDisappear:animated];
}

- (void) returnClick {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initUI {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height - SafeAreaBottomHeight) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.estimatedRowHeight = 0;
    tableView.separatorStyle = NO;
    [self.view addSubview:tableView];
    self.detailTableView = tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

#warning Language International
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"BRCandyHistoryDetailCell";
    BRCandyHistoryDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[BRCandyHistoryDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
//    cell.nameLable.text = [NSString stringWithFormat:@"%@", self.getCandyEntity.assetName];
//    cell.numberLable.text = [NSString stringWithFormat:@"资产数量：%@", [BRSafeUtils amountForAssetAmount:[self.getCandyEntity.candyAmount unsignedLongLongValue] decimals:[self.getCandyEntity.decimals integerValue]]];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", NSLocalizedString(@"Number of assets", nil)] attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : kBlodFont(12)}];
    NSString *total = [BRSafeUtils amountForAssetAmount:[self.getCandyEntity.candyAmount unsignedLongLongValue] decimals:[self.getCandyEntity.decimals integerValue]];
    BRIssueDataEnity *candy =  [[BRCoreDataManager sharedInstance] entity:@"BRIssueDataEnity" objectsMatching:[NSPredicate predicateWithFormat:@"assetId = %@", self.getCandyEntity.assetId]].firstObject;
    NSString *unit = candy.assetUnit;
    NSString *amount = [NSString stringWithFormat:@"\n%@(%@)", total, unit];
    NSAttributedString *amountAttr = [[NSAttributedString alloc] initWithString:amount attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : kBlodFont(14)}];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] init];
    [attrStr appendAttributedString:title];
    [attrStr appendAttributedString:amountAttr];
    cell.amountLabel.attributedText = attrStr;
    cell.addressLable.text = self.getCandyEntity.address;
    BRTransaction *candyTx = [[BRWalletManager sharedInstance].wallet transactionForHash:[self.getCandyEntity.txId hashAtOffset:0]];
    if(candyTx.blockHeight == 0 || candyTx.blockHeight == INT32_MAX) {
        cell.blockHeightLable.text = NSLocalizedString(@"None", nil);
    } else {
        cell.blockHeightLable.text = [NSString stringWithFormat:@"%u", candyTx.blockHeight];
    }
//    if([self.getCandyEntity.blockHeight integerValue] == 0 || [self.getCandyEntity.blockHeight integerValue] == INT32_MAX) {
//        cell.blockHeightLable.text = @"无";
//    } else {
//        cell.blockHeightLable.text = [NSString stringWithFormat:@"%@", self.getCandyEntity.blockHeight];
//    }
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy/MM/dd HH:mm";
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self.getCandyEntity.blockTime doubleValue]];
    cell.txTimeLable.text = [fmt stringFromDate:date];
    NSString *txId = [NSString hexWithData:[NSData dataWithBytes:[self.getCandyEntity.txId hashAtOffset:0].u8 length:sizeof(UInt256)].reverse];
    cell.txId = txId;
    cell.txIDLable.text = txId;
    cell.delegate = self;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 492;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (void)qrcodeLongpress:(UIImage *)longpressImage {
    
//    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Save photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self loadImageFinished:longpressImage];
//    }];
//    UIAlertAction *jumpAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Check transaction", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *string = [NSString stringWithFormat:@"%@%@", BLOCKWEB_URL, [NSString hexWithData:[NSData dataWithBytes:[self.getCandyEntity.txId hashAtOffset:0].u8 length:sizeof(UInt256)].reverse]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:string]];
//        SFSafariViewController * safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:string]];
//        [self presentViewController:safariViewController animated:YES completion:nil];
//    }];
//    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancle",nil) style:UIAlertActionStyleCancel handler:nil];
//    [alertVc addAction:saveAction];
//    [alertVc addAction:jumpAction];
//    [alertVc addAction:cancleAction];
//    [self presentViewController:alertVc animated:YES completion:nil];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
