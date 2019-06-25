//
//  BRReceivablesViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/19.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRReceivablesViewController.h"
#import "BRReceivablesAddressCell.h"
#import "BRPayAddressMoneyCell.h"
#import "BRReceivablesCodeCell.h"
#import "BRPaymentRequest.h"
#import "BRWalletManager.h"
#import "UIImage+Utils.h"
#import "NSString+Utils.h"
#import "BRSafeUtils.h"
#import <Social/Social.h>
#import "BRCoreDataManager.h"
@interface BRReceivablesViewController () <UITableViewDelegate, UITableViewDataSource, BRPayAddressMoneyCellDelegate, BRReceivablesCodeCellDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic,strong) BRPaymentRequest *paymentRequest;

@property (nonatomic,strong) NSString *paymentAddress;

@property (nonatomic, strong) UIImage *qrImage;

@property (nonatomic,strong) NSArray *issueList;

@end

@implementation BRReceivablesViewController

- (UITableView *)tableView {
    if(_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStylePlain)];
        
        UITableViewController *tvc = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
        [self addChildViewController:tvc];
        _tableView = tvc.tableView;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.separatorStyle = UITableViewCellSelectionStyleNone;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.navigationItem.title = NSLocalizedString(@"Receiving code", nil);
    [self updateAddress];
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesClick:)];
    tapGes.numberOfTapsRequired = 1;
    tapGes.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:tapGes];
//    UIButton *shareBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 15)];
//    [shareBtn setTitle:@"分享" forState:UIControlStateNormal];
//    [shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    shareBtn.titleLabel.font = [UIFont systemFontOfSize:15];
//    [shareBtn addTarget:self action:@selector(loadShareClick) forControlEvents:UIControlEventTouchUpInside];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareBtn];
    
    self.issueList = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] entity:@"BRIssueDataEnity" objectsMatching:[NSPredicate predicateWithFormat:@"assetId = %@", self.balanceModel.assetId]]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payAddressCellNotificationClick:) name:payAddressMoneyCellNotification object:nil];
}

- (void)tapGesClick:(UITapGestureRecognizer *) ges{
    [self.view endEditing:YES];
}


- (void) loadShareClick {
    NSArray *images = @[self.qrImage];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:images   applicationActivities:nil];

    if (@available(iOS 11.0, *)) {
        activityController.excludedActivityTypes = @[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo, UIActivityTypeAirDrop, UIActivityTypeOpenInIBooks, UIActivityTypeMarkupAsPDF];
    } else {
        activityController.excludedActivityTypes = @[UIActivityTypePostToFacebook, UIActivityTypePostToTwitter, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToFlickr, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo, UIActivityTypeAirDrop, UIActivityTypeOpenInIBooks];
    }
    [self.navigationController presentViewController:activityController animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma makr - UITableViewDelegate, UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        static NSString *receivablesAddressCellName = @"BRReceivablesAddressCell";
        BRReceivablesAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:receivablesAddressCellName];
        if(cell == nil) {
            cell = [[BRReceivablesAddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:receivablesAddressCellName];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.titleLabel.text = self.paymentAddress;
        return cell;
    } else if (indexPath.row == 1) {
        static NSString *payAddressMoneyCellName = @"BRPayAddressMoneyCell";
        BRPayAddressMoneyCell *cell = [tableView dequeueReusableCellWithIdentifier:payAddressMoneyCellName];
        if(cell == nil) {
            cell = [[BRPayAddressMoneyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:payAddressMoneyCellName];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        cell.balanceModel = self.balanceModel;
        cell.issueList = self.issueList;
        cell.titleLabel.text = NSLocalizedString(@"Requested amount (optional)", nil);
        return cell;
    } else {
        static NSString *receivablesCodeCellName = @"BRReceivablesCodeCell";
        BRReceivablesCodeCell *cell = [tableView dequeueReusableCellWithIdentifier:receivablesCodeCellName];
        if(cell == nil) {
            cell = [[BRReceivablesCodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:receivablesCodeCellName];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        cell.showCodeImageView.image = self.qrImage;
        return cell;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        return 45;
    } else if (indexPath.row == 1) {
        return 100;
    } else {
        return 262;
    }
}

- (void)updateAddress {
    //small hack to deal with bounds
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateAddress];
        });
        return;
    }
    __block CGSize qrViewBounds = CGSizeMake(200.0, 200.0);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BRWalletManager *manager = [BRWalletManager sharedInstance];
        BRPaymentRequest *req = self.paymentRequest;
        req.paymentAddress = self.paymentAddress;
        UIImage *image = nil;
        
        if (!image && req.data) {
            image = [UIImage imageWithQRCodeData:req.data color:[CIColor colorWithRed:0.0 green:0.0 blue:0.0]];
        }
        
        self.qrImage = [image resize:qrViewBounds withInterpolationQuality:kCGInterpolationNone];
        
        if (req.amount == 0) {
            if (req.isValid) {
                image = [UIImage imageWithQRCodeData:req.data color:[CIColor colorWithRed:1.0 green:1.0 blue:1.0]];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BRReceivablesCodeCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
            cell.showCodeImageView.image = self.qrImage;
        });
    });
}

- (BRPaymentRequest *)paymentRequest
{
    if(_paymentRequest == nil) {
        _paymentRequest = [[BRPaymentRequest alloc] initWithString:self.paymentAddress];
        _paymentRequest.balanceModel = self.balanceModel;
        if(self.balanceModel.assetId.length != 0) {
            _paymentRequest.assetName = self.balanceModel.nameString;
        }
    }
    return _paymentRequest;
}

- (NSString *)paymentAddress {
    return [BRWalletManager sharedInstance].wallet.receiveAddress;
}

#pragma mark - BRPayAddressMoneyCellDelegate
- (void)payAddressMoneyCellAmount:(NSString *)amount {
    if(self.balanceModel.assetId.length != 0) {
        self.paymentRequest.amount = [amount stringToUint64:self.balanceModel.multiple];
    } else {
        self.paymentRequest.amount = [BRSafeUtils safeUintAmount:amount];
        if(self.paymentRequest.amount > 37000000 * (uint64_t)pow(10, 8)) {
            self.paymentRequest.amount = 0;
        }
    }
    [self updateAddress];
}

#pragma mark - BRReceivablesCodeCellDelegate
- (void)receivablesCodeCellLoadCopyURLClick {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = [[NSString alloc] initWithData:self.paymentRequest.data encoding:NSUTF8StringEncoding];
    [AppTool showMessage:NSLocalizedString(@"Copy URI successfully", nil) showView:nil];
}

- (void)receivablesCodeCellLoadCopyAddressClick {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = self.paymentAddress;
    [AppTool showMessage:NSLocalizedString(@"Successful copy", nil) showView:nil];
}

- (void) payAddressCellNotificationClick:(NSNotification *)text {
    NSDictionary *dict = (NSDictionary *)text.userInfo;
    if(self.balanceModel.assetId.length != 0) {
        self.paymentRequest.amount = [[dict valueForKey:StringLength] stringToUint64:self.balanceModel.multiple];
    } else {
        self.paymentRequest.amount = [BRSafeUtils safeUintAmount:[dict valueForKey:StringLength]];
        if(self.paymentRequest.amount > 37000000 * (uint64_t)pow(10, 8)) {
            self.paymentRequest.amount = 0;
        }
    }
    [self updateAddress];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:payAddressMoneyCellNotification object:nil];
}


@end
