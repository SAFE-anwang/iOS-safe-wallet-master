//
//  BRPayViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/17.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPayViewController.h"
#import "BRPayAddressCell.h"
#import "BRPayAddressFunctionCell.h"
#import "BRPayAddressMoneyCell.h"
#import "BRPaySendCell.h"
#import "BRPayLockCell.h"
#import "BRScanViewController.h"
#import "BRPaymentRequest.h"
#import "BRWalletManager.h"
#import "BREventManager.h"
#import "NSString+Bitcoin.h"
#import "NSString+Dash.h"
#import "BRBubbleView.h"
#import "BRSafeUtils.h"
#import "BRPeerManager.h"
#import "NSString+Utils.h"
#import "NSMutableData+Bitcoin.h"
#import "BRIssueDataEnity+CoreDataClass.h"
#import "BRCoreDataManager.h"
#import "BRSafeUtils.h"

@interface BRPayViewController () <UITableViewDelegate, UITableViewDataSource, BRPayAddressCellDelegate, BRPayAddressFunctionCellDelegate, BRPayAddressMoneyCellDelegate, BRPaySendCellDelegate, BRPayLockCellDelegate, AVCaptureMetadataOutputObjectsDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) BRScanViewController *scanController;

@property (nonatomic, strong) BRPaymentRequest *payRequest;

@property (nonatomic, strong) NSString *payAddress;

@property (nonatomic, assign) uint64_t payAmount;

@property (nonatomic, assign) uint32_t lockHeight;

@property (nonatomic, assign) BOOL isInstant;

@property (nonatomic, assign) BOOL isLock;

@property (nonatomic,strong) NSArray *issueList;

@property (nonatomic,assign) BOOL isHUDShow;

@property (nonatomic,assign) BOOL isLoadSendTx;

@end

@implementation BRPayViewController

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
    self.navigationItem.title = NSLocalizedString(@"Send ", nil);
    [self.view addSubview:self.tableView];
    self.issueList = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] entity:@"BRIssueDataEnity" objectsMatching:[NSPredicate predicateWithFormat:@"assetId = %@", self.balanceModel.assetId]]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payAddressCellNotificationClick:) name:payAddressCellNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payAddressCellNotificationClick:) name:payAddressMoneyCellNotification object:nil];
    
    UITapGestureRecognizer* tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesClick:)];
    tapGes.numberOfTapsRequired = 1;
    tapGes.numberOfTouchesRequired = 1;
    [self.tableView addGestureRecognizer:tapGes];
}

- (void)tapGesClick:(UITapGestureRecognizer *) ges{
    [self.view endEditing:YES];
}

#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        static NSString * payAddressCellName = @"BRPayAddressCell";
        BRPayAddressCell *cell = [tableView dequeueReusableCellWithIdentifier:payAddressCellName];
        if(cell == nil) {
            cell = [[BRPayAddressCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:payAddressCellName];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textField.placeholder = NSLocalizedString(@"Input address", nil);
        cell.textField.text = self.payAddress;
        cell.delegate = self;
        return cell;
    } else if (indexPath.row == 1) {
        static NSString *payAddressFunctionCellName = @"BRPayAddressFunctionCell";
        BRPayAddressFunctionCell *cell = [tableView dequeueReusableCellWithIdentifier:payAddressFunctionCellName];
        if(cell == nil) {
            cell = [[BRPayAddressFunctionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:payAddressFunctionCellName];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        return cell;
    } else if (indexPath.row == 2) {
        static NSString *payAddressMoneyCellName = @"BRPayAddressMoneyCell";
        BRPayAddressMoneyCell *cell = [tableView dequeueReusableCellWithIdentifier:payAddressMoneyCellName];
        if(cell == nil) {
            cell = [[BRPayAddressMoneyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:payAddressMoneyCellName];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.issueList = self.issueList;
        cell.delegate = self;
        cell.balanceModel = self.balanceModel;
        if(self.payAmount != 0) {
            if(self.balanceModel.assetId.length == 0) {
                int index = 8;
                if([[BRSafeUtils showSAFEUint] isEqualToString:@"mSAFE"]) {
                    index = 5;
                } else if([[BRSafeUtils showSAFEUint] isEqualToString:@"μSAFE"]) {
                    index = 2;
                }
                cell.textField.text = [[BRSafeUtils amountForSendAssetAmount:self.payAmount decimals:index] stringByReplacingOccurrencesOfString:@","withString:@""];
            } else {
                cell.textField.text = [[BRSafeUtils amountForSendAssetAmount:self.payAmount decimals:self.balanceModel.multiple] stringByReplacingOccurrencesOfString:@","withString:@""];
            }
        } else {
            cell.textField.text = @"";
        }
        return cell;
    } else if (indexPath.row == 3) {
        static NSString *payLockCellName = @"BRPayLockCell";
        BRPayLockCell *cell = [tableView dequeueReusableCellWithIdentifier:payLockCellName];
        if(cell == nil) {
            cell = [[BRPayLockCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:payLockCellName];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        if(self.balanceModel.assetId.length != 0) {
            cell.payBtn.hidden = YES;
            cell.payView.hidden = YES;
            cell.payLabel.hidden = YES;
        }
        [cell settingIsLock:self.isLock];
        [cell settingIsPay:self.isInstant];
        return cell;
    } else {
        static NSString *paySendCellName = @"BRPaySendCell";
        BRPaySendCell *cell = [tableView dequeueReusableCellWithIdentifier:paySendCellName];
        if(cell == nil) {
            cell = [[BRPaySendCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:paySendCellName];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        return cell;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        return 85;
    } else if (indexPath.row == 1) {
        return 60;
    } else if (indexPath.row == 2) {
        return 100;
    } else if (indexPath.row == 3) {
        return 120;
    } else {
        if(self.balanceModel.assetId.length != 0) {
            return 50;
        } else {
            return 80;
        }
    }
}

#pragma mark - BRPayAddressCellDelegate
- (void)payAddressCellForText:(NSString *)text {
    [self.view endEditing:YES];
    self.payAddress = text;
}

#pragma mark - BRPayAddressFunctionCellDelegate
- (void)payAddressFunctionCellLoadPasteClick {
    [self.view endEditing:YES];
    UIPasteboard* pasteboard = [UIPasteboard generalPasteboard];
    self.payAddress = pasteboard.string;
    [self refreshCellBtnShow];
    [self.tableView reloadData];
}

- (void)payAddressFunctionCellLoadCodeClick {
    [self.view endEditing:YES];
    if(self.scanController == nil) {
        UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.scanController = [mainStoryBoard instantiateViewControllerWithIdentifier:@"ScanViewController"];
        self.scanController.delegate = self;
        self.scanController.transitioningDelegate = self;
    }
    [self.navigationController presentViewController:self.scanController animated:YES completion:nil];
}

#pragma mark - BRPayAddressMoneyCellDelegate
- (void)payAddressMoneyCellAmount:(NSString *)amount {
    [self.view endEditing:YES];
    if(self.balanceModel.assetId.length == 0) {
        self.payAmount = [BRSafeUtils safeUintAmount:amount];
    } else {
        self.payAmount = [amount stringToUint64:self.balanceModel.multiple];
    }
}

#pragma mark - BRPayLockCellDelegate
- (void)payLockCellForSelectLock:(BOOL)isLock {
    [self.view endEditing:YES];
    self.isLock = isLock;
    self.isInstant = NO;
    if(self.isLock) {
        if([BRPeerManager sharedInstance].lastBlockHeight < TEST_START_SPOS_HEIGHT) {
            self.lockHeight = BLOCKS_PER_MONTH + 1 + (uint64_t)[BRPeerManager sharedInstance].lastBlockHeight;
        } else {
            self.lockHeight = BLOCKS_SPOS_PER_MONTH + 1 + (uint64_t)[BRPeerManager sharedInstance].lastBlockHeight;
        }
    } else {
        self.lockHeight = 0;
    }
}

- (void)payLockCellForSelectInstantPayment:(BOOL)isPay {
    [self.view endEditing:YES];
    self.isInstant = isPay;
    self.isLock = NO;
    self.lockHeight = 0;
}

- (void)payLockCellForSelectLockMonth:(NSString *)month {
    [self.view endEditing:YES];
    if ([BRPeerManager sharedInstance].lastBlockHeight < TEST_START_SPOS_HEIGHT) {
        self.lockHeight = [month integerValue] * BLOCKS_PER_MONTH + 1 + (uint64_t)[BRPeerManager sharedInstance].lastBlockHeight;
    } else {
        self.lockHeight = [month integerValue] * BLOCKS_SPOS_PER_MONTH + 1 + (uint64_t)[BRPeerManager sharedInstance].lastBlockHeight;
    }
    
}

#pragma mark - BRPaySendCellDelegatge
- (void)BRPaySendCellLoadSendClick {
    if(self.isLoadSendTx) return;
    self.isLoadSendTx = YES;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        self.isLoadSendTx = NO;
    });
    [self.view endEditing:YES];
    if([BRWalletManager sharedInstance].walletDisbled){
        [[BRWalletManager sharedInstance] userLockedOut];
        return;
    }
    
    if(self.payAddress.length == 0) {
        [AppTool showMessage:NSLocalizedString(@"Please enter the address", nil) showView:nil];
        return;
    }
    self.payAddress = self.payAddress.removeFirstAndEndSpace;
    if(![self.payAddress isValidDashAddress]) {
        [AppTool showMessage:[NSString stringWithFormat:@"%@:\n%@",
                              NSLocalizedString(@"not a valid dash address", nil),
                              self.payAddress] showView:self.view];
        return;
    }
    if(self.payAmount <= 0){
        [AppTool showMessage:NSLocalizedString(@"Please enter the transfer amount", nil) showView:self.view];
        return;
    }
    BRWalletManager *manager = [BRWalletManager sharedInstance];

    if (self.balanceModel.assetId.length == 0) {
        NSString *showStr = @"";
        NSInteger index;
        if(![[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name]) {
            index = 2;
        } else {
            index = [[[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name] integerValue];
        }
        if(index == 0 && self.payAmount < (TX_MIN_OUTPUT_AMOUNT * 10)) {
            showStr = [BRSafeUtils showSAFEAmount:TX_MIN_OUTPUT_AMOUNT * 10];
        } else if (index == 1 && self.payAmount < [[BRSafeUtils showSAFEAmount:TX_MIN_OUTPUT_AMOUNT * 10 + 100] stringToUint64:8]) {
            showStr = [BRSafeUtils showSAFEAmount:TX_MIN_OUTPUT_AMOUNT * 10 + 100];
        } else if (index == 2 && self.payAmount < 10000) {
            showStr = [BRSafeUtils showSAFEAmount:10000];
        } else if (index == 3 && self.payAmount < [[BRSafeUtils showSAFEAmount:TX_MIN_OUTPUT_AMOUNT * 10 + 1000] stringToUint64:5]) {
            showStr = [BRSafeUtils showSAFEAmount:TX_MIN_OUTPUT_AMOUNT * 10 + 1000];
        } else if (index == 4 && self.payAmount < [[BRSafeUtils showSAFEAmount:TX_MIN_OUTPUT_AMOUNT * 10 + 100] stringToUint64:2]) {
            showStr = [BRSafeUtils showSAFEAmount:TX_MIN_OUTPUT_AMOUNT * 10 + 100];
        }
        if(showStr.length != 0) {
            [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"dash payments can't be less than %@", nil),
                                  [NSString stringWithFormat:@"%@%@", showStr, [BRSafeUtils showSAFEUint].length > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"]] showView:self.view];
            return;
        }
    }
    if (self.isInstant && self.balanceModel.assetId.length == 0 && self.payAmount >= 1000 * pow(10, self.balanceModel.multiple)) {
        [AppTool showMessage:NSLocalizedString(@"The maximum amount of instant payment cannot be greater than 1000,please send it multiple times.", nil) showView:self.view];
        return;
    }
    if (self.balanceModel.assetId.length == 0 && self.payAmount > 37000000 * pow(10, self.balanceModel.multiple)) {
        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"The maximum transfer amount cannot exceed %@", nil), [NSString stringWithFormat:@"%@%@", [BRSafeUtils showSAFEAmount:37000000 * pow(10, self.balanceModel.multiple)], [BRSafeUtils showSAFEUint].length > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"]] showView:nil];
        return;
    }
    NSNumber *amountNumber;
    NSMutableData *reserveData = [NSMutableData data];
    if(self.balanceModel.assetId.length != 0) {
        amountNumber = @(self.payAmount);
        self.balanceModel.common.amount = self.payAmount;
        reserveData = [NSMutableData dataWithData:[BRSafeUtils generateTransferredAssetData:self.balanceModel]];
    } else {
        amountNumber = @(self.payAmount);
        [reserveData appendString:@"safe"];
    }
    NSMutableData *script = [NSMutableData data];
    [script appendScriptPubKeyForAddress:self.payAddress];
    if(!self.isLock) self.lockHeight = 0;
    BRTransaction *tx = [manager.wallet transactionForAmounts:@[amountNumber] toOutputScripts:@[script] withUnlockHeights:@[@(self.lockHeight)] withReserves:@[reserveData] withFee:YES isInstant:self.isInstant toShapeshiftAddress:nil BalanceModel:self.balanceModel];
    if(!tx) {
        if(self.isInstant && self.balanceModel.assetId.length == 0) { //
            if(![[BRWalletManager sharedInstance].wallet useisInstantTxBalance] && ([[BRWalletManager sharedInstance].wallet payUIUseBalance:self.balanceModel.assetId] >= self.payAmount + 100000 * [[BRWalletManager sharedInstance].wallet countUtxosNumber:self.balanceModel.assetId] || [[BRWalletManager sharedInstance].wallet payUIUseBalance:self.balanceModel.assetId] == self.payAmount)) {
                [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"Instant payment requires %d confirmations in the wallet , please try again later", nil), [BRWalletManager sharedInstance].wallet.isInstantConfirmHeight] showView:self.view];
            } else {
                if([[BRWalletManager sharedInstance].wallet payUIUseBalance:self.balanceModel.assetId] >= 1000 * (uint64_t)pow(10, 8)) {
                    [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"Instant payment does not support high-value input sources, input source exceeds %@%@", nil), [BRSafeUtils showSAFEAmount:(uint64_t)(1000 * pow(10, 8))], [[BRSafeUtils showSAFEUint] length] > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"] showView:self.view];
                } else {
                    [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"SAFE available balance is insufficient , still missing %@%@", nil), [BRSafeUtils showSAFEAmount:self.payAmount - [[BRWalletManager sharedInstance].wallet payUIUseBalance:self.balanceModel.assetId] + 100000 * [[BRWalletManager sharedInstance].wallet countUtxosNumber:self.balanceModel.assetId]], [[BRSafeUtils showSAFEUint] length] > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"] showView:self.view];
                }
//                if([[BRWalletManager sharedInstance].wallet useBalance:self.balanceModel.assetId] >= 1000 * (uint64_t)pow(10, 8)) {
//                    [AppTool showMessage:[NSString stringWithFormat:@"即使支付不支持高金额的输入来源，输入来源超过%@%@", [BRSafeUtils showSAFEAmount:(uint64_t)(1000 * pow(10, 8))], [[BRSafeUtils showSAFEUint] length] > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"] showView:self.view];
//                } else {
//                    [AppTool showMessage:[NSString stringWithFormat:@"SAFE可用余额不足,还缺少%@%@", [BRSafeUtils showSAFEAmount:self.payAmount - [[BRWalletManager sharedInstance].wallet useBalance:self.balanceModel.assetId] + 100000 * [[BRWalletManager sharedInstance].wallet countUtxosNumber]], [[BRSafeUtils showSAFEUint] length] > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"] showView:self.view];
//                }
            }
        } else {
            if(self.balanceModel.assetId.length == 0) {
                  [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"SAFE available balance is insufficient , still missing %@%@", nil), [BRSafeUtils showSAFEAmount:self.payAmount - [[BRWalletManager sharedInstance].wallet payUIUseBalance:self.balanceModel.assetId] + 10000], [[BRSafeUtils showSAFEUint] length] > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"] showView:self.view];
//                [AppTool showMessage:[NSString stringWithFormat:@"SAFE可用余额不足,还缺少%@%@", [BRSafeUtils showSAFEAmount:self.payAmount - [[BRWalletManager sharedInstance].wallet useBalance:self.balanceModel.assetId] + 10000], [[BRSafeUtils showSAFEUint] length] > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"] showView:self.view];
            } else {
                if([[BRWalletManager sharedInstance].wallet PublishAssetIsConfirm:self.balanceModel]) {
                    [AppTool showMessage:NSLocalizedString(@"The issue transaction has not been confirmed, please wait ...", nil) showView:self.view];
                } else {
                    if([[BRWalletManager sharedInstance].wallet useBalance:self.balanceModel.assetId] < self.payAmount) {
                        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"Available balance of asset (%@) is insufficient , still missing %@", nil), self.balanceModel.nameString, [BRSafeUtils amountForAssetAmount:self.payAmount - [[BRWalletManager sharedInstance].wallet useBalance:self.balanceModel.assetId] decimals:self.balanceModel.multiple]] showView:self.view];
                    } else {
                        BRBalanceModel *safeModel = [BRWalletManager sharedInstance].wallet.balanceArray.firstObject;
                        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"SAFE's available balance is insufficient , still missing %@%@, which is not enough to pay for the network.", nil), [BRSafeUtils showSAFEAmount:50000 - [[BRWalletManager sharedInstance].wallet payUIUseBalance:safeModel.assetId]], [[BRSafeUtils showSAFEUint] length] > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"] showView:self.view];

//                        [AppTool showMessage:[NSString stringWithFormat:@"SAFE可用余额不足还缺少%@%@,不足以支付网络费。", [BRSafeUtils showSAFEAmount:50000 - [[BRWalletManager sharedInstance].wallet useBalance:safeModel.assetId]], [[BRSafeUtils showSAFEUint] length] > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"] showView:self.view];
                    }
                }
            }
        }
        return;
    } else {
        if(![[BRWalletManager sharedInstance].wallet isSendTransaction:tx]) {
            [AppTool showMessage:NSLocalizedString(@"Operation is too frequent, please wait", nil) showView:self.view];
            return;
        } else if (tx.inputHashes.count > 200) {
            [AppTool showMessage:NSLocalizedString(@"Transaction failed and the transaction size exceeded the maximum.", nil) showView:self.view];
            return;
        }
    }
    uint64_t amount = [manager.wallet amountSentByTransaction:tx] - [manager.wallet amountReceivedFromTransaction:tx];
    uint64_t fee = [manager.wallet feeForTransaction:tx];
    NSString *prompt;
    if(self.balanceModel.assetId.length != 0) {
        prompt = [self promptAssetForAmount:(amount > fee ? amount : self.payAmount + fee) fee:fee address:self.payAddress];
    } else {
        prompt = [self promptForAmount:(amount > fee ? amount : self.payAmount + fee) fee:fee address:self.payAddress];
    }
    
    if(self.balanceModel.assetId.length == 0) {
        CFRunLoopPerformBlock([[NSRunLoop mainRunLoop] getCFRunLoop], kCFRunLoopCommonModes, ^{
            [self confirmTransaction:tx toAddress:self.payAddress withPrompt:@"" forAmount:(amount > fee ? amount : ((self.payAmount == [[BRWalletManager sharedInstance].wallet payUIUseBalance:self.balanceModel.assetId]) ? self.payAmount : self.payAmount + fee))];
        });
    } else {
        CFRunLoopPerformBlock([[NSRunLoop mainRunLoop] getCFRunLoop], kCFRunLoopCommonModes, ^{
            [self confirmTransaction:tx toAddress:self.payAddress withPrompt:@"" forAmount:fee];
        });
    }
}

- (void)confirmTransaction:(BRTransaction *)tx toAddress:(NSString*)address withPrompt:(NSString *)prompt forAmount:(uint64_t)amount
{
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    __block BOOL previouslyWasAuthenticated = manager.didAuthenticate;
     @weakify(self);
    [manager.wallet signTransaction:tx withPrompt:prompt amount:amount completion:^(BOOL signedTransaction) {
        @strongify(self);
        if (!signedTransaction) {
            UIAlertController * alert = [UIAlertController
                                         alertControllerWithTitle:NSLocalizedString(@"couldn't make payment", nil)
                                         message:NSLocalizedString(@"error signing dash transaction", nil)
                                         preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* okButton = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"ok", nil)
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
                                           
                                       }];
            [alert addAction:okButton];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            
            if (!previouslyWasAuthenticated) manager.didAuthenticate = NO;
            
            if (!tx.isSigned) { // double check
                return;
            }
            
            __block BOOL waiting = YES, sent = NO;
            @weakify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                [AppTool showHUDView:nil animated:YES];
                self.isHUDShow = YES;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    if(self.isHUDShow) {
                        self.view.window.userInteractionEnabled = true;
                        [AppTool hideHUDView:nil animated:YES];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                });
            });
            self.view.window.userInteractionEnabled = false;
            [[BRPeerManager sharedInstance] publishTransaction:tx completion:^(NSError *error) {
                @strongify(self);
                @weakify(self);
                if(!self) return;
                self.view.window.userInteractionEnabled = true;
                self.isHUDShow = NO;
//                dispatch_async(dispatch_get_main_queue(), ^{
                    [AppTool hideHUDView:nil animated:YES];
//                });
                if (error) {
                    if (! waiting && ! sent) {
                        UIAlertController * alert = [UIAlertController
                                                     alertControllerWithTitle:NSLocalizedString(@"couldn't make payment", nil)
                                                     message:error.localizedDescription
                                                     preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction* okButton = [UIAlertAction
                                                   actionWithTitle:NSLocalizedString(@"ok", nil)
                                                   style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * action) {
                                                       
                                                   }];
                        [alert addAction:okButton];
                        [self presentViewController:alert animated:YES completion:nil];
                    }
//                    [AppTool showMessage:[NSString stringWithFormat:@"%@", error] showView:nil];
                }
                else if (! sent) { //TODO: show full screen sent dialog with tx info, "you sent b10,000 to bob"
                    sent = YES;
                    tx.timestamp = [NSDate timeIntervalSinceReferenceDate];
                    [manager.wallet registerTransaction:tx];
                    [self.view addSubview:[[[BRBubbleView viewWithText:NSLocalizedString(@"sent!", nil)
                                                                center:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)] popIn]
                                           popOutAfterDelay:2.0]];
                    [self.navigationController popViewControllerAnimated:YES];
                }
                waiting = NO;
            }];
        }
    }];
}

- (NSString *)promptAssetForAmount:(uint64_t)amount fee:(uint64_t)fee address:(NSString *)address {
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSString *prompt = @"";
    prompt = [prompt stringByAppendingString:address];
    [prompt stringByAppendingFormat:@"\n\n"];
    NSNumberFormatter *dashFormat = [[NSNumberFormatter alloc] init];
    dashFormat.lenient = YES;
    dashFormat.numberStyle = NSNumberFormatterCurrencyStyle;
    dashFormat.generatesDecimalNumbers = YES;
    dashFormat.negativeFormat = [dashFormat.positiveFormat
                                 stringByReplacingCharactersInRange:[dashFormat.positiveFormat rangeOfString:@"#"]
                                 withString:@"-#"];
    dashFormat.currencyCode = self.balanceModel.nameString;
    dashFormat.currencySymbol = [self.balanceModel.nameString stringByAppendingString:NARROW_NBSP];
    dashFormat.maximumFractionDigits = self.balanceModel.multiple;
    dashFormat.minimumFractionDigits = 0; // iOS 8 bug, minimumFractionDigits now has to be set after currencySymbol
    dashFormat.maximum = @(MAX_MONEY/(int64_t)pow(10.0, dashFormat.maximumFractionDigits));
    prompt = [prompt stringByAppendingFormat:NSLocalizedString(@"\n\n     amount： %@", nil),
              [dashFormat stringFromNumber:[(id)[NSDecimalNumber numberWithLongLong:amount - fee]
                                            decimalNumberByMultiplyingByPowerOf10:-dashFormat.maximumFractionDigits]]];
    
    if (fee > 0) {
        prompt = [prompt stringByAppendingFormat:NSLocalizedString(@"\n        fee： +%@", nil),
                  [NSString stringWithFormat:@"%@%@", [BRSafeUtils showSAFEAmount:fee], [[BRSafeUtils showSAFEUint] length] > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"]];
        prompt = [prompt stringByAppendingFormat:NSLocalizedString(@"\n          total： %@", nil),
                  [NSString stringWithFormat:@"%@ + %@%@", [dashFormat stringFromNumber:[(id)[NSDecimalNumber numberWithLongLong:amount - fee]
                                                                                       decimalNumberByMultiplyingByPowerOf10:-dashFormat.maximumFractionDigits]], [BRSafeUtils showSAFEAmount:fee], [[BRSafeUtils showSAFEUint] length] > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"]];
    }
    return prompt;
}

- (NSString *)promptForAmount:(uint64_t)amount fee:(uint64_t)fee address:(NSString *)address
{
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSString *prompt = @"";
    prompt = [prompt stringByAppendingString:address];
    [prompt stringByAppendingFormat:@"\n\n"];
    prompt = [prompt stringByAppendingFormat:NSLocalizedString(@"\n\n     amount： %@", nil),
              [NSString stringWithFormat:@"%@ %@", [[BRSafeUtils showSAFEUint] length] > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE", [BRSafeUtils showSAFEAmount:amount - fee]]];
    
    if (fee > 0) {
        prompt = [prompt stringByAppendingFormat:NSLocalizedString(@"\n        fee： +%@", nil),
                  [NSString stringWithFormat:@"%@%@", [BRSafeUtils showSAFEAmount:fee], [[BRSafeUtils showSAFEUint] length] > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"]];
        prompt = [prompt stringByAppendingFormat:NSLocalizedString(@"\n          total： %@", nil),
                  [NSString stringWithFormat:@"%@ %@", [[BRSafeUtils showSAFEUint] length] > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE", [BRSafeUtils showSAFEAmount:amount]]];
    }
    return prompt;
} 

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate
// TODO: 扫描二维码结果
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects
       fromConnection:(AVCaptureConnection *)connection
{
    for (AVMetadataMachineReadableCodeObject *codeObject in metadataObjects) {
        if (! [codeObject.type isEqual:AVMetadataObjectTypeQRCode]) continue;
        
        [BREventManager saveEvent:@"send:scanned_qr"];
        
        NSString *addr = [codeObject.stringValue stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        BRPaymentRequest *request = [BRPaymentRequest requestWithString:addr];
//        if(request.amount > 0) {
        BOOL assetIsInstant = NO;
            if (self.balanceModel.assetId.length == 0) {
                if(request.assetName.length != 0) {
                    [self.navigationController dismissViewControllerAnimated:YES completion:^{
                        [self resetQRGuide];
                        self.payAddress = request.paymentAddress;
                        self.payAmount = 0;
                        self.isLock = NO;
                        self.isInstant = NO;
                        [self refreshCellBtnShow];
                        [self.tableView reloadData];
                        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"Transfer of assets (%@) and receiving assets (%@) are inconsistent", nil), @"SAFE", request.assetName] showView:self.view];
                    }];
                    return;
                }
            } else {
                if(request.assetName.length != 0) {
                    if(![request.assetName isEqualToString:self.balanceModel.nameString]) {
                        [self.navigationController dismissViewControllerAnimated:YES completion:^{
                            [self resetQRGuide];
                            self.payAddress = request.paymentAddress;
                            self.payAmount = 0;
                            self.isLock = NO;
                            self.isInstant = NO;
                            [self refreshCellBtnShow];
                            [self.tableView reloadData];
                            [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"Transfer of assets (%@) and receiving assets (%@) are inconsistent", nil), self.balanceModel.nameString, request.assetName.length > 0 ? request.assetName : @"SAFE"] showView:self.view];
                        }];
                        return;
                    }
                } else { // 资产扫SAFE
                    if(request.amount > 0) {
                        [self.navigationController dismissViewControllerAnimated:YES completion:^{
                            [self resetQRGuide];
                            self.payAddress = request.paymentAddress;
                            self.payAmount = 0;
                            self.isLock = NO;
                            self.isInstant = NO;
                            [self refreshCellBtnShow];
                            [self.tableView reloadData];
                            [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"Transfer of assets (%@) and receiving assets (%@) are inconsistent", nil), self.balanceModel.nameString, request.assetName.length > 0 ? request.assetName : @"SAFE"] showView:self.view];
                        }];
                        return;
                    }
                    assetIsInstant = YES;
                }
            }
//        }
        request = [[BRPaymentRequest alloc] init];
        request.balanceModel = self.balanceModel;
        request.string = addr;
        self.payRequest = request;
        if ((request.isValid) || [addr isValidBitcoinPrivateKey] || [addr isValidDashPrivateKey] || [addr isValidDashBIP38Key]) {
            self.scanController.cameraGuide.image = [UIImage imageNamed:@"cameraguide-green"];
            [self.scanController stop];
            
            [BREventManager saveEvent:@"send:valid_qr_scan"];
            
            if (request.r.length > 0) { // start fetching payment protocol request right away
                [BRPaymentRequest fetch:request.r scheme:request.scheme timeout:5.0
                             completion:^(BRPaymentProtocolRequest *req, NSError *error) {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     if (error) request.r = nil;
                                     
                                     if (error && ! request.isValid) {
                                         UIAlertController * alert = [UIAlertController
                                                                      alertControllerWithTitle:NSLocalizedString(@"couldn't make payment", nil)
                                                                      message:error.localizedDescription
                                                                      preferredStyle:UIAlertControllerStyleAlert];
                                         UIAlertAction* okButton = [UIAlertAction
                                                                    actionWithTitle:NSLocalizedString(@"ok", nil)
                                                                    style:UIAlertActionStyleCancel
                                                                    handler:^(UIAlertAction * action) {
                                                                    }];
                                         [alert addAction:okButton];
                                         [self presentViewController:alert animated:YES completion:nil];
                                     }
                                     
                                     [self.navigationController dismissViewControllerAnimated:YES completion:^{
                                         [self resetQRGuide];
                                     }];
                                     
                                     if (error) {
                                         [BREventManager saveEvent:@"send:unsuccessful_qr_payment_protocol_fetch"];
//                                         [AppTool showMessage:@"支付协议错误" showView:self.view];
                                     }
                                     else {
                                         [BREventManager saveEvent:@"send:successful_qr_payment_protocol_fetch"];
//                                         [AppTool showMessage:@"支付协议正确" showView:self.view];
                                     }
                                 });
                             }];
            }
            else { // standard non payment protocol request
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    [self resetQRGuide];
                    self.payAmount = request.amount;
                    self.payAddress = request.paymentAddress;
                    if(request.wantsInstant) {
                        self.isInstant = request.wantsInstant;
                        self.isLock = NO;
                    } else {
                        self.isLock = NO;
                        self.isInstant = NO;
                    }
                    if(assetIsInstant) self.isInstant = NO;
//                    if ([BRPeerManager sharedInstance].lastBlockHeight < TEST_START_SPOS_UNLOCK_HEIGHT && [BRPeerManager sharedInstance].lastBlockHeight >= TEST_START_SPOS_HEIGHT && self.isInstant) {
//                        self.isInstant = NO;
//                        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"This feature is enabled when the block height is % d", nil), TEST_START_SPOS_UNLOCK_HEIGHT] showView:nil];
//                    }
                    [self refreshCellBtnShow];
                    [self.tableView reloadData];
//                    [AppTool showMessage:@"支付协议正确" showView:self.view];
                }];
            }
        } else {
            [BRPaymentRequest fetch:request.r scheme:request.scheme timeout:5.0
                         completion:^(BRPaymentProtocolRequest *req, NSError *error) { // check to see if it's a BIP73 url
                             dispatch_async(dispatch_get_main_queue(), ^{
                                 [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(resetQRGuide) object:nil];
                                 
                                 if (req) {
                                     self.scanController.cameraGuide.image = [UIImage imageNamed:@"cameraguide-green"];
                                     [self.scanController stop];
                                     
                                     [self.navigationController dismissViewControllerAnimated:YES completion:^{
                                         [self resetQRGuide];
                                     }];
                                     
                                     [BREventManager saveEvent:@"send:successful_bip73"];
//                                     [AppTool showMessage:@"支付协议正确" showView:self.view];
                                 }
                                 else {
                                     self.scanController.cameraGuide.image = [UIImage imageNamed:@"cameraguide-red"];
                                     if (([request.scheme isEqual:@"safe"] && request.paymentAddress.length > 1) ||
                                         [request.paymentAddress hasPrefix:@"X"] || [request.paymentAddress hasPrefix:@"7"]) {
                                         self.scanController.message.text = [NSString stringWithFormat:@"%@:\n%@",
                                                                             NSLocalizedString(@"not a valid dash address", nil),
                                                                             request.paymentAddress];
                                     } else if (([request.scheme isEqual:@"bitcoin"] && request.paymentAddress.length > 1) ||
                                                [request.paymentAddress hasPrefix:@"1"] || [request.paymentAddress hasPrefix:@"3"]) {
                                         self.scanController.message.text = [NSString stringWithFormat:@"%@:\n%@",
                                                                             NSLocalizedString(@"not a valid bitcoin address", nil),
                                                                             request.paymentAddress];
                                     }
                                     else self.scanController.message.text = NSLocalizedString(@"not a dash or bitcoin QR code", nil);
                                     
                                     [self performSelector:@selector(resetQRGuide) withObject:nil afterDelay:0.35];
                                     [BREventManager saveEvent:@"send:unsuccessful_bip73"];
                                 }
                             });
                         }];
        }
        break;
    }
}

- (void)resetQRGuide
{
    self.scanController.message.text = nil;
    self.scanController.cameraGuide.image = [UIImage imageNamed:@"cameraguide"];
}

- (void) refreshCellBtnShow {
    BRPaySendCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    if(self.payAddress.length > 0 && self.payAmount > 0) {
        cell.sendBtn.enabled = YES;
        cell.sendBtn.backgroundColor = MAIN_COLOR;
    } else {
        cell.sendBtn.enabled = NO;
        cell.sendBtn.backgroundColor = ColorFromRGB(0x999999);
    }
}

- (void) payAddressCellNotificationClick:(NSNotification *)text {
    NSDictionary *dict = (NSDictionary *)text.userInfo;
    BRPaySendCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    if([[dict valueForKey:CellName] isEqualToString:@"BRPayAddressCell"]) {
        if([[dict valueForKey:StringLength] integerValue] > 0 && self.payAmount > 0) {
            cell.sendBtn.enabled = YES;
            cell.sendBtn.backgroundColor = MAIN_COLOR;
        } else {
            cell.sendBtn.enabled = NO;
            cell.sendBtn.backgroundColor = ColorFromRGB(0x999999);
        }
    } else {
        if([[dict valueForKey:StringLength] stringToUint64:self.balanceModel.multiple] > 0 && self.payAddress.length > 0) {
            cell.sendBtn.enabled = YES;
            cell.sendBtn.backgroundColor = MAIN_COLOR;
        } else {
            cell.sendBtn.enabled = NO;
            cell.sendBtn.backgroundColor = ColorFromRGB(0x999999);
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:payAddressCellNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:payAddressMoneyCellNotification object:nil];
}

@end
