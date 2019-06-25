//
//  追加发行 BRAdditionalDistributionAssetViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/9.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRAdditionalDistributionAssetViewController.h"
#import "BRDeveloperTypeCell.h"
#import "BRPublishAssetCell.h"
#import "BRPublishAssetDescribeCell.h"
#import "BRAdditionalDistributionAssetPromptCell.h"
#import "BRAdditionalDistributionAssetSubmitCell.h"
#import "BRSafeUtils.h"
#import "BRAdditionalDistributionAssetShowAssetCell.h"
#import "BRPublishIssueDataEnity+CoreDataProperties.h"
#import "BRCommonDataModel.h"
#import "BRPopoverPresentationView.h"
#import "AppTool.h"
#import "BRWalletManager.h"
#import "BRPeerManager.h"
#import "BRBubbleView.h"

#import "BRSafeUtils.h"
#import "NSString+Utils.h"
#import "BRPublishAssetNameCell.h"
#import "NSAttributedString+Attachments.h"
#import "BRCoreDataManager.h"
#import "BRAlertView.h"

@interface BRAdditionalDistributionAssetViewController () <UITableViewDelegate, UITableViewDataSource, BRAdditionalDistributionAssetSubmitCellDelegate, BRPublishAssetCellDelegate, BRPublishAssetDescribeCellDelegate, UIPopoverPresentationControllerDelegate, BRPopoverPresentationViewDelegate, BRAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic,strong) UIView *promptAlertView;

@property (nonatomic, strong) UIVisualEffectView *effectView;

@property (nonatomic, strong) NSArray *assetArray;

@property (nonatomic,strong) BRCommonDataModel *commonDataModel;

@property (nonatomic,strong) UIViewController *cardController;

@property (nonatomic,strong) BRTransaction *tx;

@property (nonatomic,assign) int selectIndex;

@property (nonatomic,assign) BOOL isHUDShow;

@property (nonatomic,assign) BOOL isLoadSendTx;

@end

@implementation BRAdditionalDistributionAssetViewController

- (NSArray *)assetArray {
    if(_assetArray == nil) {
        NSMutableArray *newAssetArray = [NSMutableArray array];
        BRCommonDataModel *commonDataModel = [[BRCommonDataModel alloc] init];
        commonDataModel.assetName = NSLocalizedString(@"Asset Name", nil);
        [newAssetArray addObject:commonDataModel];
        [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlockAndWait:^{
            NSArray *publishIssueDataArray = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] fetchEntity:@"BRPublishIssueDataEnity" withPredicate:nil]];
            for(BRPublishIssueDataEnity *publishIssueEnity in publishIssueDataArray) {
                uint64_t amount = 0;
                for(int i=0; i<[BRWalletManager sharedInstance].wallet.balanceArray.count; i++) {
                    BRBalanceModel *balanceModel = [BRWalletManager sharedInstance].wallet.balanceArray[i];
                    if([balanceModel.assetId isEqual:publishIssueEnity.assetId]) {
                        for(BRTransaction *tx in balanceModel.txArray) {
                            for(int j=0; j<tx.outputReserves.count; j++) {
                                if(![BRSafeUtils isSafeTransaction:tx.outputReserves[j]]) { // [tx.outputReserves[j] length] > 42
                                    NSNumber * l = 0;
                                    NSUInteger off = 0;
                                    NSData *d = [tx.outputReserves[j] dataAtOffset:off length:&l];
                                    if([d UInt16AtOffset:38] == 200) {
                                        NSError *error;
                                        IssueData *issueData = [[IssueData alloc] initWithData:[d subdataWithRange:NSMakeRange(42, d.length-42)] error:&error];
                                        amount += issueData.firstIssueAmount;
                                    } else if ([d UInt16AtOffset:38] == 201) {
                                        amount += [tx.outputAmounts[j] unsignedLongLongValue];
                                    }
                                }
                            }
                        }
                        break;
                    }
                }
                if([publishIssueEnity.totalAmount unsignedLongLongValue] > amount) {
                    BRCommonDataModel *commonDataModel = [[BRCommonDataModel alloc] init];
                    commonDataModel.assetName = publishIssueEnity.assetName;
                    commonDataModel.assetAmount = [publishIssueEnity.totalAmount unsignedLongLongValue] - amount;
                    commonDataModel.assetId = publishIssueEnity.assetId;
                    commonDataModel.address = publishIssueEnity.assetAddress;
                    commonDataModel.decimals = [publishIssueEnity.decimals integerValue];
                    [newAssetArray addObject:commonDataModel];
                }
            }
            _assetArray = [NSArray arrayWithArray:newAssetArray];
        }];
    }
    return _assetArray;
}

- (BRCommonDataModel *)commonDataModel {
    if(_commonDataModel == nil) {
        _commonDataModel = [[BRCommonDataModel alloc] init];
    }
    return _commonDataModel;
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
#warning Language International
    self.navigationItem.title = NSLocalizedString(@"Additional issue", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    [self creatUI];
//    [self creatEffectView];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnClick)];
    
    self.commonDataModel.assetName = NSLocalizedString(@"Asset Name", nil);
    self.selectIndex = 0;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishAssetCellNotificationClick:) name:publishAssetCellNotification object:nil];
}

- (void) returnClick {
    [self.navigationController popViewControllerAnimated:YES];
}

//#pragma mark - 创建模糊背景
//- (void)creatEffectView {
//
//    //模糊背景
//    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
//    effectView.hidden = YES;
//    effectView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height);
//    effectView.alpha = 0.3f;
//    [self.view addSubview:effectView];
//    self.effectView = effectView;
//}

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

#pragma mark - UITableViewDataSource UITableViewDelegate
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
#warning Language International
        cell.name.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Asset Name", nil)];
        cell.title.text = self.commonDataModel.assetName;
//        cell.delegate = self;
        return cell;
    } else if (indexPath.row == 1) {
        static NSString *additionalDistributionAssetShowAssetCellName = @"BRAdditionalDistributionAssetShowAssetCell";
        BRAdditionalDistributionAssetShowAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:additionalDistributionAssetShowAssetCellName];
        if(cell == nil) {
            cell = [[BRAdditionalDistributionAssetShowAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:additionalDistributionAssetShowAssetCellName];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        if(self.selectIndex == 0) {
            cell.title.text = @"";
        } else {
            cell.title.text = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"Additional assets:", nil), [BRSafeUtils amountForAssetAmount:self.commonDataModel.assetAmount decimals:self.commonDataModel.decimals]];
        }
        return cell;
    } else if (indexPath.row == 2) {
        static NSString *publishAssetNameStr = @"BRPublishAssetNameCell";
        BRPublishAssetNameCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetNameStr];
        if(cell == nil) {
            cell = [[BRPublishAssetNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetNameStr];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.title.attributedText = [NSAttributedString importantAttributeStringWithString:NSLocalizedString(@"Total assets added", nil)];
        return cell;
    } else if (indexPath.row == 3) {
        static NSString *publishAssetString = @"BRPublishAssetCell";
        BRPublishAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetString];
        if(cell == nil) {
            cell = [[BRPublishAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.type = BRPublishAssetCellTypeAddPublishAsset;
        }
        cell.indexPath = indexPath;
//        cell.holderText = self.commonDataModel.assetAmount > 0 ? [NSString stringWithFormat:@"最大%@",[BRSafeUtils amountForAssetAmount:self.commonDataModel.assetAmount decimals:self.commonDataModel.decimals]] : [NSString stringWithFormat:@"最大%ld", MAX_ASSETS];
        cell.holderText = NSLocalizedString(@"The maximum cannot exceed the total amount of additional assets", nil);
        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        cell.delegate = self;
        cell.textField.text =  self.commonDataModel.amount;
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
        cell.textView.text = self.commonDataModel.remarks;
        return cell;
    } else {
        static NSString *additionalDistributionAssetSubmitString = @"BRAdditionalDistributionAssetSubmitCell";
        BRAdditionalDistributionAssetSubmitCell *cell = [tableView dequeueReusableCellWithIdentifier:additionalDistributionAssetSubmitString];
        if(cell == nil) {
            cell = [[BRAdditionalDistributionAssetSubmitCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:additionalDistributionAssetSubmitString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        if(self.selectIndex != 0 && [self.commonDataModel.amount stringToUint64:self.commonDataModel.decimals] > 0) {
            cell.submitBtn.enabled = YES;
            cell.submitBtn.backgroundColor = MAIN_COLOR;
        } else {
            cell.submitBtn.enabled = NO;
            cell.submitBtn.backgroundColor = ColorFromRGB(0x999999);
        }
        [cell.submitBtn setTitle:NSLocalizedString(@"Issue", nil) forState:UIControlStateNormal];
        return cell;
    }
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
//    if(cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    }
//    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        return 51;
    } else if (indexPath.row == 1) {
        if(self.selectIndex == 0) {
            return 10;
        } else {
            return 25;
        }
    } else if (indexPath.row == 2) {
        return 35;
    } else if (indexPath.row == 3) {
        return 40;
    } else if(indexPath.row == 4) {
        return 35;
    } else if (indexPath.row == 5) {
        return 91;
    } else {
        return 70;
    }
}

#pragma mark - BRDeveloperTypeCellDelegate
- (void)developerTypeCellLoadTypeView {
    [self.view endEditing:YES];
    if(self.assetArray.count == 0) return;
    CGFloat height = self.assetArray.count > 4 ? 160 : self.assetArray.count * 40;
    CGFloat width = SCREEN_WIDTH * 0.7;
    CGFloat x = (SCREEN_WIDTH - width) * 0.5;
    BRPopoverPresentationView *popView = [[BRPopoverPresentationView alloc] initWithShowRegion:CGSizeMake(width, height) type:BRPopoverPresentationViewTypePublishAsset];
    popView.delegate = self;
    popView.dataSoure = [self.assetArray copy];
    popView.selectModel = self.assetArray[self.selectIndex];
    [popView show];
}

#pragma mark - BRPopoverPresentationViewDelegate
- (void)popoverPresentationViewForIndexPath:(NSInteger)index {
    self.selectIndex = index;
    BRCommonDataModel *model = self.assetArray[index];
    self.commonDataModel.assetName = model.assetName;
    self.commonDataModel.assetAmount = model.assetAmount;
    self.commonDataModel.version = model.version;             // uint16_t
    self.commonDataModel.assetId = model.assetId;         // uint256
    self.commonDataModel.decimals = model.decimals;
    self.commonDataModel.address = model.address;
    [self.tableView reloadData];
    BRAdditionalDistributionAssetSubmitCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
    if(self.selectIndex != 0 && [self.commonDataModel.amount stringToUint64:self.commonDataModel.decimals] > 0) {
        cell.submitBtn.enabled = YES;
        cell.submitBtn.backgroundColor = MAIN_COLOR;
    } else {
        cell.submitBtn.enabled = NO;
        cell.submitBtn.backgroundColor = ColorFromRGB(0x999999);
    }
}

#pragma mark - BRPublishAssetCellDelegate
- (void)publishAssetCellWithContent:(NSString *)contentString andIndexPath:(NSIndexPath *)path {
    self.commonDataModel.amount = contentString;
}

#pragma mark - BRPublishAssetDescribeCellDelegate
- (void)publishAssetDescribeCellWithContent:(NSString *)contentString {
    self.commonDataModel.remarks = contentString;
}

#pragma mark - BRAdditionalDistributionAssetSubmitCellDelegate
- (void)additionalDistributionAssetSubmitCellLoadSubmintClick {
    if(self.isLoadSendTx) return;
    self.isLoadSendTx = YES;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        self.isLoadSendTx = NO;
    });
#warning Language International
    [self.view endEditing:YES];
    if([BRPeerManager sharedInstance].syncProgress < 1) {
        [AppTool showMessage:NSLocalizedString(@"Syncing block data, please wait ...", nil) showView:self.view];
        return;
    }
    if([BRWalletManager sharedInstance].walletDisbled){
        [[BRWalletManager sharedInstance] userLockedOut];
        return;
    }
    if(self.selectIndex == 0) {
        [AppTool showMessage:NSLocalizedString(@"Please select an asset", nil) showView:self.view];
        return;
    }
//    if([self.commonDataModel.amount stringToUint64:self.commonDataModel.decimals] < 1 * pow(10, self.commonDataModel.decimals)) {
//        [AppTool showMessage:@"追加资产总量不能小于1" showView:self.view];
//        return;
//    }
    if([self.commonDataModel.amount hasSuffix:@"."]) {
        [AppTool showMessage:NSLocalizedString(@"The total amount of additional assets does not match the number of decimal places", nil) showView:self.view];
        return;
    }
    if(self.commonDataModel.amount.getDecimal > self.commonDataModel.decimals) {
        [AppTool showMessage:NSLocalizedString(@"The total amount of additional assets does not match the number of decimal places", nil) showView:self.view];
        return;
    }
//    if(self.commonDataModel.amount.stringToInteger + self.commonDataModel.decimals > 19) {
//        [AppTool showMessage:@"(追加资产总量+小数位)不能超过19位" showView:self.view];
//        return;
//    }
    BRLog(@"%llu %@", [self.commonDataModel.amount stringToUint64:self.commonDataModel.decimals], self.commonDataModel.amount);
    if([self.commonDataModel.amount stringToUint64:self.commonDataModel.decimals] > self.commonDataModel.assetAmount) {
//        [AppTool showMessage:[NSString stringWithFormat:@"发行资产不能大于%@", [BRSafeUtils amountForAssetAmount:self.commonDataModel.assetAmount decimals:self.commonDataModel.decimals]] showView:self.view];
        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"The total amount of additional assets greater than the additional assets %@", nil), [BRSafeUtils amountForAssetAmount:self.commonDataModel.assetAmount decimals:self.commonDataModel.decimals]] showView:self.view];
        return;
    }
    self.tx = [[BRWalletManager sharedInstance].wallet transactionForAssetAmount:@([self.commonDataModel.amount stringToUint64:self.commonDataModel.decimals]) assetReserve:self.commonDataModel.toCommonData assetId:self.commonDataModel.assetId address:self.commonDataModel.address];
    if(!self.tx) {
        NSString *subTitle = [NSString stringWithFormat:NSLocalizedString(@"Please transfer %@ address to at least %@%@.", nil), self.commonDataModel.address, [BRSafeUtils showSAFEAmount:1000000], [[BRSafeUtils showSAFEUint] length] > 0 ? [BRSafeUtils showSAFEUint] : @"SAFE"];
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
                                       pasteboard.string = self.commonDataModel.address;
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
//        [AppTool showMessage:[NSString stringWithFormat:@"请给%@地址转入至少0.01SAFE。", self.commonDataModel.address] showView:self.view];
        return;
    } else {
        if(![[BRWalletManager sharedInstance].wallet isSendTransaction:self.tx]) {
            [AppTool showMessage:NSLocalizedString(@"Operation is too frequent, please wait", nil) showView:self.view];
            return;
        } else if (self.tx.inputHashes.count > 200) {
            [AppTool showMessage:NSLocalizedString(@"Transaction failed and the transaction size exceeded the maximum.", nil) showView:self.view];
            return;
        }
    }
//    [self showPromptAlertView];
    BRAlertView *alertView = [[BRAlertView alloc] initWithMessage:NSLocalizedString(@"Are you sure to issue additional assets?", nil) messageType:NSTextAlignmentCenter delegate:self];
    [alertView show];
}

- (void)loadSendTxRequest {
    self.view.window.userInteractionEnabled = false;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.view.window.userInteractionEnabled = true;
    });
    [self publishAssetBuildTx];
}

//#pragma mark - 编辑地址弹框
//- (void) showPromptAlertView {
//    [self creatAlertView];
//    self.effectView.hidden = NO;
//    self.promptAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN,  CGFLOAT_MIN);
//    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//        self.promptAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
//    } completion:^(BOOL finished) {
//        self.promptAlertView.transform = CGAffineTransformIdentity;
//    }];
//}
//
//- (void)creatAlertView {
//
//    CGFloat margin = 40;
//    CGFloat height = 184;
//    CGFloat lableHeight = 120;
//    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(margin, 0, SCREEN_WIDTH - margin * 2, height)];
//    alertView.backgroundColor = [UIColor whiteColor];
//    alertView.center = self.view.center;
//    alertView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.4f].CGColor;
//    alertView.layer.borderWidth = 1.f;
//    alertView.layer.cornerRadius = 6.f;
//    alertView.clipsToBounds = YES;
//    [self.view addSubview:alertView];
//    self.promptAlertView = alertView;
//
//    CGFloat lableWidth = 20;
//    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(lableWidth, 14, SCREEN_WIDTH - margin * 2 - lableWidth * 2, 14 + 7 + 13 + 36 + 16 + 42)];
//    lable.text = @"确定追加发行资产吗？";
//    lable.numberOfLines = 0;
//    lable.textColor = [UIColor blackColor];
//    lable.font = [UIFont systemFontOfSize:16.f];
//    lable.textAlignment = NSTextAlignmentCenter;
//    [alertView addSubview:lable];
//
//    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    sureButton.frame = CGRectMake((SCREEN_WIDTH - margin * 2) / 2 + 12, 14 + 7 + 13 + 36 + 16 + 42 + 10, 70, 30);
//    sureButton.backgroundColor = MAIN_COLOR;
//    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
//    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    sureButton.layer.cornerRadius = 3;
//    sureButton.layer.masksToBounds = YES;
//    sureButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
//    [alertView addSubview:sureButton];
//    [sureButton addTarget:self action:@selector(publishAssetSubmit) forControlEvents:UIControlEventTouchUpInside];
//
//    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    cancelButton.frame = CGRectMake((SCREEN_WIDTH - margin * 2) / 2 - 12 - 70, 14 + 7 + 13 + 36 + 16 + 42 + 10, 70, 30);
//    cancelButton.backgroundColor = [UIColor whiteColor];
//    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
//    cancelButton.layer.borderWidth = 1;
//    cancelButton.layer.cornerRadius = 3;
//    cancelButton.layer.masksToBounds = YES;
//    cancelButton.layer.borderColor = ColorFromRGB255(232, 232, 232).CGColor;
//    [cancelButton setTitleColor:ColorFromRGB255(183, 183, 183) forState:UIControlStateNormal];
//    cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
//    [alertView addSubview:cancelButton];
//    [cancelButton addTarget:self action:@selector(hidePromptAlertView) forControlEvents:UIControlEventTouchUpInside];
//}
//
//#pragma mark - 发行资产
//- (void) publishAssetSubmit{
//    [UIView animateWithDuration:0.1 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        self.promptAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
//    } completion:^(BOOL finished) {
//
//        [UIView animateWithDuration:0.3
//                         animations:^{
//                             self.promptAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.001, 0.001);
//                         }
//                         completion:^(BOOL finished) {
//                             [self.promptAlertView removeFromSuperview];
//                             self.effectView.hidden = YES;
//
//                             [self publishAssetBuildTx];
//                         }];
//    }];
//}

#pragma mark - 构建追加发行资产交易
- (void) publishAssetBuildTx {
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    uint64_t amount = [self.commonDataModel.amount stringToUint64:self.commonDataModel.decimals];
    uint64_t fee = [manager.wallet feeForPublishAssetTransaction:self.tx];
    NSString *prompt = [self promptAssetForAmount:amount + fee fee:fee];
    CFRunLoopPerformBlock([[NSRunLoop mainRunLoop] getCFRunLoop], kCFRunLoopCommonModes, ^{
        [self confirmTransaction:self.tx withPrompt:@"" forAmount:fee];
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
    dashFormat.currencyCode = self.commonDataModel.assetName;
    dashFormat.currencySymbol = [self.commonDataModel.assetName stringByAppendingString:NARROW_NBSP];
    int pwoNumber = self.commonDataModel.decimals;
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
                        [self returnClick];
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
//                        if (tx.associatedShapeshift) {
//                            [self startObservingShapeshift:tx.associatedShapeshift];
//
//                        }
                    sent = YES;
                    tx.timestamp = [NSDate timeIntervalSinceReferenceDate];
                    [manager.wallet registerTransaction:tx];
//                    [self.view addSubview:[[[BRBubbleView viewWithText:NSLocalizedString(@"sent!", nil)
//                                                                center:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)] popIn]
//                                           popOutAfterDelay:2.0]];
                    [AppTool showMessage:NSLocalizedString(@"success", nil) showView:nil];
                    [self returnClick];
//                        [(id)self.parentViewController.parentViewController.parentViewController stopActivityWithSuccess:YES];
//                        [(id)self.parentViewController.parentViewController.parentViewController ping];
                }
                
                waiting = NO;
            }];
        }
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self developerTypeCellLoadTypeView];
    }
}

#pragma mark - 隐藏提示框弹框
- (void)hidePromptAlertView {
    [UIView animateWithDuration:0.1 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.promptAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.promptAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.001, 0.001);
                         }
                         completion:^(BOOL finished) {
                             [self.promptAlertView removeFromSuperview];
                             self.effectView.hidden = YES;
                         }];
    }];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) publishAssetCellNotificationClick:(NSNotification *)text {
    NSDictionary *dict = (NSDictionary *)text.userInfo;
    BRAdditionalDistributionAssetSubmitCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:6 inSection:0]];
    if([[dict valueForKey:CellName] isEqualToString:@"BRPublishAssetCell"]) {
        if([[dict valueForKey:StringLength] stringToUint64:10] > 0 && self.selectIndex != 0) {
            cell.submitBtn.enabled = YES;
            cell.submitBtn.backgroundColor = MAIN_COLOR;
        } else {
            cell.submitBtn.enabled = NO;
            cell.submitBtn.backgroundColor = ColorFromRGB(0x999999);
        }
    }
}

- (void)dealloc {
    BRLog(@"%s", __func__);
    [[NSNotificationCenter defaultCenter] removeObserver:self name:publishAssetCellNotification object:nil];
}


@end
