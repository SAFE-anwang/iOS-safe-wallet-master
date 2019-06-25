//
//  BRPublishCandyViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/23.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPublishCandyViewController.h"
#import "BRDeveloperTypeCell.h"
#import "BRPublishAssetEditCandyProportionCell.h"
#import "BRPublishAssetSliderCell.h"
#import "BRPublishAssetEditTimeCell.h"
#import "BRPublishAssetDescribeCell.h"
#import "BRPublishIssueDataEnity+CoreDataProperties.h"
#import "BRPopoverPresentationView.h"
#import "BRPutCandyModel.h"
#import "AppTool.h"
#import "BRPeerManager.h"
#import "BRWalletManager.h"
#import "BRBubbleView.h"
#import "BRAdditionalDistributionAssetShowAssetCell.h"
#import "BRCoreDataManager.h"
#import "NSString+Utils.h"
#import "BRPublishAssetNameCell.h"
#import "BRSafeUtils.h"
#import "BRPublishCandySliderCell.h"
#import "NSAttributedString+Attachments.h"
#import "BRPutCandyEntity+CoreDataProperties.h"
#import "BRAlertView.h"

@interface BRPublishCandyViewController ()<UITableViewDelegate, UITableViewDataSource, BRPublishAssetEditCandyProportionCellDelegate, BRPublishCandySliderCellDelegate, BRPublishAssetEditTimeCellDelegate, BRPublishAssetDescribeCellDelegate, BRPopoverPresentationViewDelegate, BRAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic,strong) NSArray *assetArray;

@property (nonatomic,strong) BRPutCandyModel *putCandyModel;

@property (nonatomic,assign) int selectIndex;

@property (nonatomic,assign) BOOL isHUDShow;

@property (nonatomic,assign) BOOL isLoadSendTx;

@end

@implementation BRPublishCandyViewController

- (NSArray *)assetArray {
    if(_assetArray == nil) {
        NSArray *publishIssueDataArray = [[BRCoreDataManager sharedInstance] fetchEntity:@"BRPublishIssueDataEnity" withPredicate:nil];
        NSMutableArray *newPutCandyArray = [NSMutableArray array];
        BRPutCandyModel *putCandyModel = [[BRPutCandyModel alloc] init];
        putCandyModel.assetName = NSLocalizedString(@"Asset Name", nil);
        [newPutCandyArray addObject:putCandyModel];
        for(BRPublishIssueDataEnity *publishIssueDataEnity in publishIssueDataArray) {
            BRPutCandyModel *putCandyModel = [[BRPutCandyModel alloc] init];
            putCandyModel.assetId = publishIssueDataEnity.assetId;
            for(BRBalanceModel *balanceModel in [BRWalletManager sharedInstance].wallet.balanceArray) {
                if([balanceModel.assetId isEqual:putCandyModel.assetId]) {
                    putCandyModel.actualAmount = balanceModel.balance;
                    int candyCount = 0;
                    for(int i=0; i<balanceModel.txArray.count; i++) {
                        BRTransaction *tx = balanceModel.txArray[i];
                        for(NSData *reserve in tx.outputReserves) {
                            if(![BRSafeUtils isSafeTransaction:reserve]) {
                                NSNumber * l = 0;
                                NSUInteger off = 0;
                                NSData *d = [reserve dataAtOffset:off length:&l];
                                if([d UInt16AtOffset:38] == 205) {
                                    candyCount += 1;
                                    break;
                                }
                            }
                        }
                    }
                    putCandyModel.publishCandyNumber = candyCount;
                    break;
                }
            }
//            putCandyModel.actualAmount = [[BRWalletManager sharedInstance].wallet assetManagerAddressAmount:putCandyModel.assetId  address:publishIssueDataEnity.assetAddress];
            if(putCandyModel.actualAmount == 0) continue;
            putCandyModel.assetUnit = publishIssueDataEnity.assetUnit;
            putCandyModel.address = publishIssueDataEnity.assetAddress;
            putCandyModel.decimals = [publishIssueDataEnity.decimals integerValue];
            putCandyModel.totalAmount = [publishIssueDataEnity.totalAmount unsignedLongLongValue];
            putCandyModel.assetName = publishIssueDataEnity.assetName;
            [newPutCandyArray addObject:putCandyModel];
        }
        _assetArray = [NSArray arrayWithArray:newPutCandyArray];
    }
    return _assetArray;
}

- (UITableView *)tableView {
    if(_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        
        UITableViewController *tvc = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
        [self addChildViewController:tvc];
        _tableView = tvc.tableView;
        _tableView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.estimatedRowHeight = 100;
        _tableView.rowHeight = UITableViewAutomaticDimension;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"Issuing candy", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnClick)];
    [self creatUI];
    
    self.putCandyModel = [[BRPutCandyModel alloc] init];
    self.selectIndex = 0;
    self.putCandyModel.assetName = NSLocalizedString(@"Asset Name", nil);;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishAssetEditTimeCellNotificationClick:) name:publishAssetEditTimeCellNotification object:nil];
}

- (void) returnClick {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 创建UI
- (void) creatUI {
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.top.equalTo(self.view.mas_top);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}

#pragma mark - UITableViewDelegate UITableViewDataSoure
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        static NSString *developerTypeString = @"BRDeveloperTypeCell";
        BRDeveloperTypeCell *cell = [tableView dequeueReusableCellWithIdentifier:developerTypeString];
        if(cell == nil) {
            cell = [[BRDeveloperTypeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:developerTypeString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
//        cell.delegate = self;
        cell.title.text = self.putCandyModel.assetName;
        return cell;
    } else if (indexPath.row == 1) {
        static NSString *publishAssetNameStr = @"BRPublishAssetNameCell";
        BRPublishAssetNameCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetNameStr];
        if(cell == nil) {
            cell = [[BRPublishAssetNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetNameStr];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.title.attributedText =  [NSAttributedString importantAttributeStringWithString:NSLocalizedString(@"Candy expiration time", nil)];
        return cell;
    } else if (indexPath.row == 2) {
        static NSString *publishAssetTimeString = @"BRPublishAssetEditTimeCell";
        BRPublishAssetEditTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetTimeString];
        if(cell == nil) {
            cell = [[BRPublishAssetEditTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetTimeString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        cell.textField.text = self.putCandyModel.expired;
        return cell;
    } else if (indexPath.row == 3) {
        static NSString *publishCandySliderString = @"BRPublishCandySliderCell";
        BRPublishCandySliderCell *cell = [tableView dequeueReusableCellWithIdentifier:publishCandySliderString];
        if(cell == nil) {
            cell = [[BRPublishCandySliderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishCandySliderString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        cell.sliderValue = self.putCandyModel.sliderValue;
        cell.valueLable.text = [BRSafeUtils amountForAssetAmount:[self.putCandyModel getCandy] decimals:self.putCandyModel.decimals];
        cell.valueLable.hidden = !self.putCandyModel.decimals;
        return cell;
    } else if (indexPath.row == 4) {
        static NSString *publishAssetNameStr = @"BRPublishAssetNameCell";
        BRPublishAssetNameCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetNameStr];
        if(cell == nil) {
            cell = [[BRPublishAssetNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetNameStr];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.title.text =  NSLocalizedString(@"Remarks", nil);
        return cell;
    } else if (indexPath.row == 5) {
        static NSString *publishAssetDescribeString = @"BRPublishAssetDescribeCell";
        BRPublishAssetDescribeCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetDescribeString];
        if(cell == nil) {
            cell = [[BRPublishAssetDescribeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetDescribeString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.textView.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Maximum %d characters", nil), 500];
        cell.textLength = 500;
        cell.delegate = self;
        cell.textView.text = self.putCandyModel.remarks;
        return cell;
    } else {
        static NSString *publishAssetEditCandyProportionString = @"cell";
        BRPublishAssetEditCandyProportionCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetEditCandyProportionString];
        if(cell == nil) {
            cell = [[BRPublishAssetEditCandyProportionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetEditCandyProportionString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        if(self.putCandyModel.expired.length > 0 && self.selectIndex != 0) {
            cell.confirmBtn.enabled = YES;
            cell.confirmBtn.backgroundColor = MAIN_COLOR;
        } else {
            cell.confirmBtn.enabled = NO;
            cell.confirmBtn.backgroundColor = ColorFromRGB(0x999999);
        }
        [cell.confirmBtn setTitle:NSLocalizedString(@"Issue ", nil) forState:UIControlStateNormal];
        return cell;
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        return 51;
    } else if (indexPath.row == 1) {
        return 35;
    } else if (indexPath.row == 2) {
        return 40;
    } else if (indexPath.row == 3) {
        return 80;
    } else if (indexPath.row == 4) {
        return 35;
    } else if (indexPath.row == 5) {
        return 91;
    } else {
        return 90;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self.view endEditing:YES];
        [self developerTypeCellLoadTypeView];
    }
}

#pragma mark - BRDeveloperTypeCellDelegate
- (void)developerTypeCellLoadTypeView {
    [self.view endEditing:YES];
    if(self.assetArray.count == 0) return;
    CGFloat height = self.assetArray.count > 4 ? 160 : self.assetArray.count * 40;
    CGFloat width = SCREEN_WIDTH * 0.7;
    CGFloat x = (SCREEN_WIDTH - width) * 0.5;
    BRPopoverPresentationView *popView = [[BRPopoverPresentationView alloc] initWithShowRegion:CGSizeMake(width, height) type:BRPopoverPresentationViewTypePutCandy];
    popView.delegate = self;
    popView.dataSoure = [self.assetArray copy];
    popView.selectCandy = self.assetArray[self.selectIndex];
    [popView show];
}

#pragma mark - BRPopoverPresentationViewDelegate
- (void)popoverPresentationViewForIndexPath:(NSInteger)index {
    self.selectIndex = index;
    BRPutCandyModel *model = self.assetArray[index];
    self.putCandyModel.publishCandyNumber = model.publishCandyNumber;
    self.putCandyModel.assetUnit = model.assetUnit;
    self.putCandyModel.assetId = model.assetId;
    self.putCandyModel.address = model.address;
    self.putCandyModel.decimals = model.decimals;
    self.putCandyModel.actualAmount = model.actualAmount;
    self.putCandyModel.totalAmount = model.totalAmount;
    self.putCandyModel.assetName = model.assetName;
    [self.tableView reloadData];
    BRPublishAssetEditCandyProportionCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
    if(self.putCandyModel.expired.length > 0 && self.selectIndex != 0) {
        cell.confirmBtn.enabled = YES;
        cell.confirmBtn.backgroundColor = MAIN_COLOR;
    } else {
        cell.confirmBtn.enabled = NO;
        cell.confirmBtn.backgroundColor = ColorFromRGB(0x999999);
    }
}

#pragma mark - BRPublishAssetEditTimeCellDelegate
- (void)publishAssetEditTimeWithTime:(NSString *)time {
    self.putCandyModel.expired = time;
}

#pragma mark - BRPublishCandy'SliderCellDelegate
- (void)publishCandySliderValue:(double)sliderValue {
    self.putCandyModel.sliderValue = sliderValue;
    [self.tableView reloadData];
}

#pragma mark - BRPublishAssetDescribeCellDelegate
- (void)publishAssetDescribeCellWithContent:(NSString *)contentString {
    self.putCandyModel.remarks = contentString;
}

#pragma mark - BRPublishAssetEditCandyProportionCellDelegate
- (void)publishAssetEditCandyProportionCellLoadSubmintClick {
    if(self.isLoadSendTx) return;
    self.isLoadSendTx = YES;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        self.isLoadSendTx = NO;
    });
    [self.view endEditing:YES];
    if([BRPeerManager sharedInstance].syncProgress < 1) {
        [AppTool showMessage:NSLocalizedString(@"Syncing block data, please wait ...", nil) showView:self.view];
        return;
    }
    if([BRWalletManager sharedInstance].walletDisbled){
        [[BRWalletManager sharedInstance] userLockedOut];
        return;
    }
    if([self.putCandyModel isEqual:self.assetArray.firstObject]) {
        [AppTool showMessage:NSLocalizedString(@"Please select an asset", nil) showView:self.view];
        return;
    }
    if(self.putCandyModel.publishCandyNumber >= 5) {
        [AppTool showMessage:NSLocalizedString(@"Candy issurance chance has been used up", nil) showView:self.view];
        return;
    }
    if(self.putCandyModel.expired.length == 0) {
        [AppTool showMessage:NSLocalizedString(@"Candy expiration time is empty", nil) showView:self.view];
        return;
    }
    if(self.putCandyModel.expired.integerValue < 1 || self.putCandyModel.expired.integerValue > 3) {
        [AppTool showMessage:NSLocalizedString(@"Candy expiration time cannot be less than 1 or greater than 3", nil) showView:self.view];
        return;
    }
//    if([self.putCandyModel getCandy] > self.putCandyModel.actualAmount) {
//        [AppTool showMessage:[NSString stringWithFormat:@"发放糖果数量不能大于%@,请调整再发放", [BRSafeUtils amountForAssetAmount:self.putCandyModel.actualAmount decimals:self.putCandyModel.decimals]] showView:self.view];
//        return;
//    }
    if([self.putCandyModel getCandy] > [[BRWalletManager sharedInstance].wallet assetManagerAddressAmount:self.putCandyModel.assetId address:self.putCandyModel.address]) {
//        [AppTool showMessage:[NSString stringWithFormat:@"%@管理员地址中余额为%@,不足以发放%@糖果。", self.putCandyModel.address, [BRSafeUtils amountForAssetAmount:[[BRWalletManager sharedInstance].wallet assetManagerAddressAmount:self.putCandyModel.assetId  address:self.putCandyModel.address] decimals:self.putCandyModel.decimals], [BRSafeUtils amountForAssetAmount:[self.putCandyModel getCandy] decimals:self.putCandyModel.decimals]] showView:self.view];
        NSString *subTitle = [NSString stringWithFormat:NSLocalizedString(@"The %@ admin address has a balance of %@%@, which is not enough to issue %@%@ candy.", nil), self.putCandyModel.assetName, [BRSafeUtils amountForAssetAmount:[[BRWalletManager sharedInstance].wallet assetManagerAddressAmount:self.putCandyModel.assetId  address:self.putCandyModel.address] decimals:self.putCandyModel.decimals], self.putCandyModel.assetUnit, [BRSafeUtils amountForAssetAmount:[self.putCandyModel getCandy] decimals:self.putCandyModel.decimals], self.putCandyModel.assetUnit];
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
                                   actionWithTitle:NSLocalizedString(@"cancel", nil)
                                   style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {
                                   }];
        UIAlertAction* copyButton = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"Copy address", nil)
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                                         pasteboard.string = self.putCandyModel.address;
                                     }];
        [alert addAction:copyButton];
        [alert addAction:okButton];
        UIView *subView1 = alert.view.subviews[0];
        UIView *subView2 = subView1.subviews[0];
        UIView *subView3 = subView2.subviews[0];
        UIView *subView4 = subView3.subviews[0];
        UIView *subView5 = subView4.subviews[0];
        UILabel *title = subView5.subviews[0];
        NSString *version= [UIDevice currentDevice].systemVersion;
        
        if(version.doubleValue >= 12.0) {
            UILabel *message = subView5.subviews[2];
            message.lineBreakMode = NSLineBreakByCharWrapping;
        } else {
            UILabel *message = subView5.subviews[1];
            message.lineBreakMode = NSLineBreakByCharWrapping;
        }
        
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
        return;
    }
    BRAlertView *alertView = [[BRAlertView alloc] initWithMessage:[NSString stringWithFormat:NSLocalizedString(@"Candy can be issued up to 5 times and can be issued %d times. \n Are you sure to issue %@ candy?", nil), 5 - self.putCandyModel.publishCandyNumber, [BRSafeUtils amountForAssetAmount:[self.putCandyModel getCandy] decimals:self.putCandyModel.decimals]] messageType:NSTextAlignmentLeft delegate:self];
    [alertView show];
}

#pragma mark - BRAlertViewDelegate
- (void)loadSendTxRequest {
    self.view.window.userInteractionEnabled = false;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.view.window.userInteractionEnabled = true;
    });
    [self publishAssetBuildTx];
}

#pragma mark - 构建发放糖果交易
- (void) publishAssetBuildTx {
    BRBalanceModel *balanceModel;
    for(int i=0; i<[BRWalletManager sharedInstance].wallet.balanceArray.count; i++) {
        balanceModel = [BRWalletManager sharedInstance].wallet.balanceArray[i];
        if([balanceModel.assetId isEqual:self.putCandyModel.assetId]) {
            break;
        } else {
            balanceModel = nil;
        }
    }
    BRTransaction *tx = [[BRWalletManager sharedInstance].wallet transactionForCandyAmount:self.putCandyModel balanceModel:balanceModel];
    if(!tx) {
        BRBalanceModel *safeModel = [BRWalletManager sharedInstance].wallet.balanceArray.firstObject;
        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"Available balance of SAFE is insufficient , still missing %@%@. Unable to distribute candy.", nil), [BRSafeUtils showSAFEAmount:[[BRWalletManager sharedInstance].wallet getFeeAmountTransactionForCandyAmount:self.putCandyModel balanceModel:balanceModel] - [[BRWalletManager sharedInstance].wallet useBalance:safeModel.assetId] + 10000], [[BRSafeUtils showSAFEUint] length] > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"] showView:self.view];
        return;
    }  else {
        if(![[BRWalletManager sharedInstance].wallet isSendTransaction:tx]) {
            [AppTool showMessage:NSLocalizedString(@"Operation is too frequent, please wait", nil) showView:self.view];
            return;
        } else if (tx.inputHashes.count > 200) {
            [AppTool showMessage:NSLocalizedString(@"Transaction failed and the transaction size exceeded the maximum.", nil) showView:self.view];
            return;
        }
    }
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    uint64_t amount = [self.putCandyModel getCandy];
    uint64_t fee = [manager.wallet feeForTransaction:tx];
    NSString *prompt = [self promptAssetForAmount:amount + fee fee:fee];
    CFRunLoopPerformBlock([[NSRunLoop mainRunLoop] getCFRunLoop], kCFRunLoopCommonModes, ^{
        [self confirmTransaction:tx withPrompt:@"" forAmount:fee];
    });
}

- (NSString *)promptAssetForAmount:(uint64_t)amount fee:(uint64_t)fee{
    
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSString *prompt = @"";
    NSNumberFormatter *dashFormat = [[NSNumberFormatter alloc] init];
    dashFormat.lenient = YES;
    dashFormat.numberStyle = NSNumberFormatterCurrencyStyle;
    dashFormat.generatesDecimalNumbers = YES;
    dashFormat.negativeFormat = [dashFormat.positiveFormat
                                 stringByReplacingCharactersInRange:[dashFormat.positiveFormat rangeOfString:@"#"]
                                 withString:@"-#"];
    dashFormat.currencyCode = self.putCandyModel.assetName;
    dashFormat.currencySymbol = [self.putCandyModel.assetName stringByAppendingString:NARROW_NBSP];
    int pwoNumber = self.putCandyModel.decimals;
    dashFormat.maximumFractionDigits = pwoNumber;
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

- (void)confirmTransaction:(BRTransaction *)tx withPrompt:(NSString *)prompt forAmount:(uint64_t)amount
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
                        self.isHUDShow = NO;
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
                self.isHUDShow = NO;
                self.view.window.userInteractionEnabled = true;
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
//                    [self.view addSubview:[[[BRBubbleView viewWithText:NSLocalizedString(@"sent!", nil)
//                                                                center:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)] popIn]
//                                           popOutAfterDelay:2.0]];
                    [AppTool showMessage:NSLocalizedString(@"success", nil) showView:nil];
                    [self returnClick];
                }
                
                waiting = NO;
            }];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) publishAssetEditTimeCellNotificationClick:(NSNotification *)text {
    NSDictionary *dict = (NSDictionary *)text.userInfo;
    BRPublishAssetEditCandyProportionCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
    if([[dict valueForKey:CellName] isEqualToString:@"BRPublishAssetEditTimeCell"]) {
        if([[dict valueForKey:StringLength] integerValue] > 0 && self.selectIndex != 0) {
            cell.confirmBtn.enabled = YES;
            cell.confirmBtn.backgroundColor = MAIN_COLOR;
        } else {
            cell.confirmBtn.enabled = NO;
            cell.confirmBtn.backgroundColor = ColorFromRGB(0x999999);
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:publishAssetEditTimeCellNotification object:nil];
}

@end
