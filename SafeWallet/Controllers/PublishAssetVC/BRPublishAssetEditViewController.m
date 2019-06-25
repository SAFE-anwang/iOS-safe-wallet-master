//
//  BRPublishAssetEditViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/9.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPublishAssetEditViewController.h"
#import "BRApplyNameCell.h"
#import "BRPublishAssetCell.h"
#import "BRPublishAssetEditDescribeCell.h"
#import "BRPublishAssetEditTimeCell.h"
#import "BRPublishAssetEditCheckboxCell.h"
#import "BRPublishAssetEditCandyProportionCell.h"
#import "BRPublishAssetSliderCell.h"
#import "Safe.pbobjc.h"
#import "NSMutableData+Bitcoin.h"
#import "BRIssueDataEnity+CoreDataClass.h"
#import "BRIssueAssetModel.h"
#import "AppTool.h"
#import "BRCoreDataManager.h"
#import "BRBalanceModel.h"
#import "BRWalletManager.h"
#import "BRSafeUtils.h"
#import "BRPeerManager.h"

#import "BRTransaction.h"
#import "BRBubbleView.h"

#import "NSString+Utils.h"
#import "BRPublishAssetNameCell.h"
#import "NSAttributedString+Attachments.h"
#import "NSString+Utils.h"
#import "BRAlertView.h"

@interface BRPublishAssetEditViewController () <UITableViewDelegate, UITableViewDataSource, BRApplyNameCellDelegate, BRPublishAssetCellDelegate, BRPublishAssetEditDescribeCellDelegate, BRPublishAssetEditCheckboxCellDelegate, BRPublishAssetEditCandyProportionCellDelegate, BRPublishAssetEditTimeCellDelegate, BRPublishAssetSliderCellDelegate, BRAlertViewDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic,strong) UIView *promptAlertView;

@property (nonatomic, strong) UIVisualEffectView *effectView;

@property (nonatomic, strong) BRIssueAssetModel *issueAssetModel;

@property (nonatomic, strong) BRTransaction *tx;

@property (nonatomic,assign) BOOL isHUDShow;

@property (nonatomic,assign) BOOL isLoadSendTx;

@end

@implementation BRPublishAssetEditViewController

- (BRIssueAssetModel *)issueAssetModel {
    if(_issueAssetModel == nil) {
        _issueAssetModel = [[BRIssueAssetModel alloc] init];
        _issueAssetModel.assetName = @"";
        _issueAssetModel.shortName = @"";
        _issueAssetModel.assetUnit = @"";
        _issueAssetModel.totalAmount = @"";
        _issueAssetModel.firstIssueAmount = @"";
        _issueAssetModel.decimals = @"";
        _issueAssetModel.assetDesc = @"";
        _issueAssetModel.remarks = @"";
        _issueAssetModel.candyExpired = @"";
    }
    return _issueAssetModel;
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
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
#warning Language International
    self.navigationItem.title = NSLocalizedString(@"Asset issuance", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self creatUI];
    
//    [self creatEffectView];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnClick)];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishAssetCellNotificationClick:) name:publishAssetCellNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishAssetCellNotificationClick:) name:applyNameCellNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishAssetCellNotificationClick:) name:publishAssetEditTimeCellNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(publishAssetCellNotificationClick:) name:publishAssetEditDescribeCellNotification object:nil];
}

- (void) returnClick {
    [self.view endEditing:YES];
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

#pragma mark - UITableViewDelegate UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  self.issueAssetModel.payCandy ? 13 + 9 : 11 + 8;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        static NSString *cellString = @"cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellString];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        return cell;
    } else if (indexPath.row == 1) {
        static NSString *publishAssetNameStr = @"BRPublishAssetNameCell";
        BRPublishAssetNameCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetNameStr];
        if(cell == nil) {
            cell = [[BRPublishAssetNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetNameStr];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.title.attributedText =  [NSAttributedString importantAttributeStringWithString:NSLocalizedString(@"Asset Name", nil)];
        return cell;
    } else if(indexPath.row == 2) {
        static NSString *applyNameString = @"BRApplyNameCell";
        BRApplyNameCell *cell = [tableView dequeueReusableCellWithIdentifier:applyNameString];
        if(cell == nil) {
            cell = [[BRApplyNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:applyNameString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.holderText = [NSString stringWithFormat:NSLocalizedString(@"Maximum %d characters", nil), 20];
        cell.textField.text = self.issueAssetModel.assetName;
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        cell.delegate = self;
        return cell;
    } else if (indexPath.row == 3) {
        static NSString *publishAssetNameStr = @"BRPublishAssetNameCell";
        BRPublishAssetNameCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetNameStr];
        if(cell == nil) {
            cell = [[BRPublishAssetNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetNameStr];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.title.attributedText = [NSAttributedString importantAttributeStringWithString:NSLocalizedString(@"Asset short name", nil)];
        return cell;
    } else if (indexPath.row == 4) {
        static NSString *publishAssetString = @"BRPublishAssetCell";
        BRPublishAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetString];
        if(cell == nil) {
            cell = [[BRPublishAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.type = BRPublishAssetCellTypePublishAsset;
        }
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.holderText = [NSString stringWithFormat:NSLocalizedString(@"Maximum %d characters", nil), 20];
        cell.textField.text = self.issueAssetModel.shortName;
        cell.stringLength = 20;
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        return cell;
    } else if (indexPath.row == 5) {
        static NSString *publishAssetNameStr = @"BRPublishAssetNameCell";
        BRPublishAssetNameCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetNameStr];
        if(cell == nil) {
            cell = [[BRPublishAssetNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetNameStr];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.title.attributedText = [NSAttributedString importantAttributeStringWithString:NSLocalizedString(@"Asset unit", nil)];
        return cell;
    } else if (indexPath.row == 6) {
        static NSString *publishAssetString = @"BRPublishAssetCell";
        BRPublishAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetString];
        if(cell == nil) {
            cell = [[BRPublishAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.type = BRPublishAssetCellTypePublishAsset;
        }
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.holderText = [NSString stringWithFormat:NSLocalizedString(@"Maximum %d characters", nil), 10];
        cell.textField.text = self.issueAssetModel.assetUnit;
        cell.stringLength = 10;
        cell.textField.keyboardType = UIKeyboardTypeDefault;
        return cell;
    } else if (indexPath.row == 7) {
        static NSString *publishAssetNameStr = @"BRPublishAssetNameCell";
        BRPublishAssetNameCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetNameStr];
        if(cell == nil) {
            cell = [[BRPublishAssetNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetNameStr];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.title.attributedText = [NSAttributedString importantAttributeStringWithString:NSLocalizedString(@"Total assets", nil)];
        return cell;
    } else if (indexPath.row == 8) {
        static NSString *publishAssetString = @"BRPublishAssetCell";
        BRPublishAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetString];
        if(cell == nil) {
            cell = [[BRPublishAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.type = BRPublishAssetCellTypePublishAsset;
        }
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.holderText = NSLocalizedString(@"Between 100~200000000000000", nil);
        cell.textField.text = self.issueAssetModel.totalAmount;
        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        return cell;
    } else if (indexPath.row == 9) {
        static NSString *publishAssetNameStr = @"BRPublishAssetNameCell";
        BRPublishAssetNameCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetNameStr];
        if(cell == nil) {
            cell = [[BRPublishAssetNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetNameStr];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.title.attributedText = [NSAttributedString importantAttributeStringWithString:NSLocalizedString(@"Total initial issuarance", nil)];
        return cell;
    } else if (indexPath.row == 10) {
        static NSString *publishAssetString = @"BRPublishAssetCell";
        BRPublishAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetString];
        if(cell == nil) {
            cell = [[BRPublishAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.type = BRPublishAssetCellTypePublishAsset;
        }
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.holderText = NSLocalizedString(@"Cannot exceed the total amount of assets", nil);
        cell.textField.text = self.issueAssetModel.firstIssueAmount;
        cell.textField.keyboardType = UIKeyboardTypeDecimalPad;
        return cell;
    } else if (indexPath.row == 11) {
        static NSString *publishAssetNameStr = @"BRPublishAssetNameCell";
        BRPublishAssetNameCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetNameStr];
        if(cell == nil) {
            cell = [[BRPublishAssetNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetNameStr];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.title.attributedText = [NSAttributedString importantAttributeStringWithString:NSLocalizedString(@"Decimal point", nil)];
        return cell;
    } else if (indexPath.row == 12) {
        static NSString *publishAssetString = @"BRPublishAssetCell";
        BRPublishAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetString];
        if(cell == nil) {
            cell = [[BRPublishAssetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.type = BRPublishAssetCellTypePublishAsset;
        }
        cell.indexPath = indexPath;
        cell.delegate = self;
        cell.holderText = NSLocalizedString(@"Between 4 and 10", nil);
        cell.textField.text = self.issueAssetModel.decimals;
        cell.stringLength = 2;
        cell.textField.keyboardType = UIKeyboardTypeNumberPad;
        return cell;
    } else if(indexPath.row == 13) {
        static NSString *publishAssetNameStr = @"BRPublishAssetNameCell";
        BRPublishAssetNameCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetNameStr];
        if(cell == nil) {
            cell = [[BRPublishAssetNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetNameStr];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.title.attributedText = [NSAttributedString importantAttributeStringWithString:NSLocalizedString(@"Asset description", nil)];
        return cell;
    } else if (indexPath.row == 14) {
        static NSString *publishAssetEidtDescribeString = @"BRPublishAssetEditDescribeCell";
        BRPublishAssetEditDescribeCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetEidtDescribeString];
        if(cell == nil) {
            cell = [[BRPublishAssetEditDescribeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetEidtDescribeString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        cell.indexPath = indexPath;
        cell.textView.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Maximum %d characters", nil), 300];
        cell.textView.text = self.issueAssetModel.assetDesc;
        cell.textLength = 300;
        cell.textView.keyboardType = UIKeyboardTypeDefault;
        return cell;
    } else if(indexPath.row == 15) {
        static NSString *publishAssetNameStr = @"BRPublishAssetNameCell";
        BRPublishAssetNameCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetNameStr];
        if(cell == nil) {
            cell = [[BRPublishAssetNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetNameStr];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.title.text = NSLocalizedString(@"Remarks", nil);
        return cell;
    } else if (indexPath.row == 16) {
        static NSString *publishAssetEidtDescribeString = @"BRPublishAssetEditDescribeCell";
        BRPublishAssetEditDescribeCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetEidtDescribeString];
        if(cell == nil) {
            cell = [[BRPublishAssetEditDescribeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetEidtDescribeString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.delegate = self;
        cell.indexPath = indexPath;
        cell.textView.placeholder = [NSString stringWithFormat:NSLocalizedString(@"Maximum %d characters", nil), 500];
        cell.textView.text = self.issueAssetModel.remarks;
        cell.textLength = 500;
        cell.textView.keyboardType = UIKeyboardTypeDefault;
        return cell;
    } else if (indexPath.row == 17) {
        static NSString *publishAssetEditCheckboxString = @"BRPublishAssetEditCheckboxCell";
        BRPublishAssetEditCheckboxCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetEditCheckboxString];
        if(cell == nil) {
            cell = [[BRPublishAssetEditCheckboxCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetEditCheckboxString];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        cell.isCandy = self.issueAssetModel.payCandy;
        cell.isDestroy = self.issueAssetModel.destory;
        cell.delegate = self;
        return cell;
    } else {
        if(self.issueAssetModel.payCandy) {
            if(indexPath.row == 18) {
                static NSString *publishAssetNameStr = @"BRPublishAssetNameCell";
                BRPublishAssetNameCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetNameStr];
                if(cell == nil) {
                    cell = [[BRPublishAssetNameCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetNameStr];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.title.attributedText = [NSAttributedString importantAttributeStringWithString:NSLocalizedString(@"Candy expiration time", nil)];
                return cell;
            } else if(indexPath.row == 19) {
                static NSString *publishAssetTimeString = @"BRPublishAssetEditTimeCell";
                BRPublishAssetEditTimeCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetTimeString];
                if(cell == nil) {
                    cell = [[BRPublishAssetEditTimeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetTimeString];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                cell.delegate = self;
                cell.textField.text = self.issueAssetModel.candyExpired;
                cell.textField.keyboardType = UIKeyboardTypeNumberPad;
                return cell;
            } else if(indexPath.row == 20) {
                static NSString *publishAssetSliderString = @"BRPublishAssetSliderCell";
                BRPublishAssetSliderCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetSliderString];
                if(cell == nil) {
                    cell = [[BRPublishAssetSliderCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetSliderString];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                
                cell.sliderValue = self.issueAssetModel.candyAmount;
                cell.delegate = self;
                cell.valueLable.text =  [self showCandyNumberString]; // [BRSafeUtils amountForAssetAmount:[self.issueAssetModel getCandyAmount] decimals:[self.issueAssetModel.decimals integerValue]];
                cell.valueLable.hidden = [self.issueAssetModel getCandyAmount] == 0;
                if(self.issueAssetModel.totalAmount.length > 0) {
                    cell.valueLable.hidden = NO;
                }
                return cell;
            } else {
                static NSString *publishAssetEditCandyProportionString = @"BRPublishAssetEditCandyProportionCell";
                BRPublishAssetEditCandyProportionCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetEditCandyProportionString];
                if(cell == nil) {
                    cell = [[BRPublishAssetEditCandyProportionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetEditCandyProportionString];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                }
                [cell.confirmBtn setTitle:NSLocalizedString(@"Issue", nil) forState:UIControlStateNormal];
                cell.delegate = self;
//                if(self.issueAssetModel.assetName.length > 0 && self.issueAssetModel.shortName.length > 0 && self.issueAssetModel.assetUnit.length > 0 && self.issueAssetModel.totalAmount.length > 0 && self.issueAssetModel.firstIssueAmount.length > 0 && self.issueAssetModel.decimals.length > 0 && self.issueAssetModel.assetDesc.length > 0 && self.issueAssetModel.candyExpired.length > 0) {
                    cell.confirmBtn.enabled = YES;
                    cell.confirmBtn.backgroundColor = MAIN_COLOR;
//                } else {
//                    cell.confirmBtn.enabled = NO;
//                    cell.confirmBtn.backgroundColor = ColorFromRGB(0x999999);
//                }
                return cell;
            }
        } else {
            static NSString *publishAssetEditCandyProportionString = @"BRPublishAssetEditCandyProportionCell";
            BRPublishAssetEditCandyProportionCell *cell = [tableView dequeueReusableCellWithIdentifier:publishAssetEditCandyProportionString];
            if(cell == nil) {
                cell = [[BRPublishAssetEditCandyProportionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:publishAssetEditCandyProportionString];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            [cell.confirmBtn setTitle:NSLocalizedString(@"Issue", nil) forState:UIControlStateNormal];
            cell.delegate = self;
//            if(self.issueAssetModel.assetName.length > 0 && self.issueAssetModel.shortName.length > 0 && self.issueAssetModel.assetUnit.length > 0 && self.issueAssetModel.totalAmount.length > 0 && self.issueAssetModel.firstIssueAmount.length > 0 && self.issueAssetModel.decimals.length > 0 && self.issueAssetModel.assetDesc.length > 0) {
                cell.confirmBtn.enabled = YES;
                cell.confirmBtn.backgroundColor = MAIN_COLOR;
//            } else {
//                cell.confirmBtn.enabled = NO;
//                cell.confirmBtn.backgroundColor = ColorFromRGB(0x999999);
//            }
            return cell;
        }
    }
    return nil;
}

- (NSString *) showCandyNumberString {
//    NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%g", (0.001 +  (int)(self.issueAssetModel.candyAmount) / 100.0 * (0.1 - 0.001))]];
    int currentCandy = (int)(self.issueAssetModel.candyAmount);
    if(currentCandy == 0) currentCandy = 1;
    NSDecimalNumber *num1 = [NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%d", currentCandy]];
    
    
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler
                                       decimalNumberHandlerWithRoundingMode:NSRoundDown
                                       scale:0
                                       raiseOnExactness:NO
                                       raiseOnOverflow:NO
                                       raiseOnUnderflow:NO
                                       raiseOnDivideByZero:NO];
    NSString *totalAmountStr = self.issueAssetModel.totalAmount;
    int decimalsBit = [self.issueAssetModel.totalAmount getDecimal];
    if(decimalsBit <= self.issueAssetModel.decimals.integerValue) {
        for(int i=0; i<self.issueAssetModel.decimals.integerValue - decimalsBit; i++) {
            totalAmountStr = [NSString stringWithFormat:@"%@0", totalAmountStr];
        }
    } else {
        totalAmountStr = [totalAmountStr substringToIndex:totalAmountStr.length - (decimalsBit - self.issueAssetModel.decimals.integerValue)];
    }
    if(totalAmountStr.length == 0) totalAmountStr = @"0";
    totalAmountStr = [totalAmountStr stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSDecimalNumber *number = [NSDecimalNumber decimalNumberWithString:totalAmountStr];
    number = [number decimalNumberByMultiplyingBy:num1 withBehavior:roundUp];
    number = [number decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"] withBehavior:roundUp];
    
    
    NSNumberFormatter *dashFormat = [[NSNumberFormatter alloc] init];
    dashFormat.lenient = YES;
    dashFormat.numberStyle = NSNumberFormatterCurrencyStyle;
    dashFormat.generatesDecimalNumbers = YES;
    dashFormat.negativeFormat = [dashFormat.positiveFormat
                                 stringByReplacingCharactersInRange:[dashFormat.positiveFormat rangeOfString:@"#"]
                                 withString:@"-#"];
    dashFormat.currencyCode = @"";
    dashFormat.currencySymbol = @"";
    dashFormat.maximumFractionDigits = [self.issueAssetModel.decimals integerValue];
    dashFormat.minimumFractionDigits = [self.issueAssetModel.decimals integerValue];
    return [dashFormat stringFromNumber:[(id)[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%@", number]]
                                               decimalNumberByMultiplyingByPowerOf10:-dashFormat.maximumFractionDigits]];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0) {
        return 10;
    } else if (indexPath.row >= 1 && indexPath.row <= 13) {
        if(indexPath.row % 2) {
            return 35;
        } else {
            return 40;
        }
    } else if (indexPath.row == 14) {
        return 91;
    } else if (indexPath.row == 15) {
        return 35;
    } else if (indexPath.row == 16) {
        return 91;
    } else if (indexPath.row == 17) {
        return 50;
    } else {
        if(self.issueAssetModel.payCandy) {
            if(indexPath.row == 18) {
                return 35;
            } else if(indexPath.row == 19) {
                return 40;
            } else if (indexPath.row == 20) {
                return 90;
            }
            return 70;
        } else {
            return 80;
        }
    }
}

#pragma mark - BRApplyNameCellDelegate
- (void)applyNameCellLoadTestingRequest:(NSString *)title {
#warning Language International
    if([BRPeerManager sharedInstance].syncProgress < 1) {
        [AppTool showMessage:NSLocalizedString(@"Syncing block data, please wait ...", nil) showView:self.view];
        return;
    }
    self.issueAssetModel.isTesting = YES;
    if(title.isEmpty || title.removeFirstAndEndSpace.isEmpty) {
        [AppTool showMessage:NSLocalizedString(@"Asset name is empty", nil) showView:self.view];
        return;
    }
    NSString *assetNameFM = [BRSafeUtils fuzzyMatchingPublishAssetWithText:self.issueAssetModel.assetName.removeFirstAndEndSpace];
    if([assetNameFM length] != 0) {
        [AppTool showMessage:NSLocalizedString(@"The entered asset name is an internal reserved word and is not allowed.", nil) showView:self.view];
        return;
    }
    NSString *assetNameM = [BRSafeUtils matchingPublishAssetWithText:self.issueAssetModel.assetName.removeFirstAndEndSpace];
    if(assetNameM.length != 0) {
        [AppTool showMessage:NSLocalizedString(@"The entered asset name is an internal reserved word and is not allowed.", nil) showView:self.view];
        return;
    }
    if(![self isAssetNameExistence:self.issueAssetModel.assetName.removeFirstAndEndSpace]) {
        [AppTool showMessage:NSLocalizedString(@"Asset name available", nil) showView:self.view];
        self.issueAssetModel.isPublishAsset = YES;
    } else {
        [AppTool showMessage:NSLocalizedString(@"Asset name already exists", nil) showView:self.view];
        self.issueAssetModel.isPublishAsset = NO;
    }
}

- (void)applyNameCellWithString:(NSString *)title {
    if (self.issueAssetModel.isTesting && ![self.issueAssetModel.assetName isEqualToString:title]) {
        self.issueAssetModel.isTesting = NO;
    }
    self.issueAssetModel.assetName = title;
}

#pragma mark - BRPublishAssetCellDelegate
- (void)publishAssetCellWithContent:(NSString *)contentString andIndexPath:(NSIndexPath *)path {
    if(path.row == 4) {
        self.issueAssetModel.shortName = contentString;
    } else if(path.row == 6) {
        self.issueAssetModel.assetUnit = contentString;
    } else if (path.row == 8) {
        self.issueAssetModel.totalAmount = contentString;
        if(self.issueAssetModel.payCandy) {
            [self.tableView reloadData];
        }
    } else if (path.row == 10) {
        self.issueAssetModel.firstIssueAmount = contentString;
    } else if (path.row == 12) {
        self.issueAssetModel.decimals = contentString;
        if(self.issueAssetModel.payCandy) {
            [self.tableView reloadData];
        }
    }
    [self.tableView reloadData];
}

#pragma mark - BRPublishAssetEditDescribeCellDelegate
- (void)publishAssetEditDescribeCellWithContent:(NSString *)contentString andIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 14) {
        self.issueAssetModel.assetDesc = contentString;
    } else if (indexPath.row == 16) {
        self.issueAssetModel.remarks = contentString;
    }
}

#pragma mark - BRPublishAssetEditCheckboxCellDelegate
- (void)publishAssetEditCheckboxCellWithIsCandy:(BOOL)isCandy {
    self.issueAssetModel.payCandy = isCandy;
    [self.tableView reloadData];
}

- (void)publishAssetEditCheckboxCellWithIsDestroy:(BOOL)isDestroy {
    self.issueAssetModel.destory = isDestroy;
}

#pragma makr - BRPublishAssetEditTimeCellDelegate
- (void)publishAssetEditTimeWithTime:(NSString *)time {
    self.issueAssetModel.candyExpired = time;
}

#pragma mark - BRPublishAssetSliderCellDelegate
- (void)publishAssetSliderCellSliderValue:(double)sliderValue {
    self.issueAssetModel.candyAmount = sliderValue;
    [self.tableView reloadData];
}

- (BOOL) isShortNameExistence:(NSString *) shortName {
    NSArray *shortNameList = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] fetchEntity:@"BRIssueDataEnity" withPredicate:nil]];
    for(int i=0; i<shortNameList.count; i++) {
        BRIssueDataEnity *e = shortNameList[i];
        if([[shortName lowercaseString] isEqualToString:[e.shortName lowercaseString]]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) isAssetNameExistence:(NSString *) assetName {
    NSArray *shortNameList = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] fetchEntity:@"BRIssueDataEnity" withPredicate:nil]];
    for(int i=0; i<shortNameList.count; i++) {
        BRIssueDataEnity *e = shortNameList[i];
        if([[assetName lowercaseString] isEqualToString:[e.assetName lowercaseString]]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - BRPublishAssetEditCandyProportionCellDelegate
- (void)publishAssetEditCandyProportionCellLoadSubmintClick {
    if(self.isLoadSendTx) return;
    self.isLoadSendTx = YES;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        self.isLoadSendTx = NO;
    });
#warning Language International
    if([BRPeerManager sharedInstance].syncProgress < 1) {
        [AppTool showMessage:NSLocalizedString(@"Syncing block data, please wait ...", nil) showView:self.view];
        return;
    }
    if([BRWalletManager sharedInstance].walletDisbled){
        [[BRWalletManager sharedInstance] userLockedOut];
        return;
    }
    if(self.issueAssetModel.assetName.isEmpty || self.issueAssetModel.assetName.removeFirstAndEndSpace.isEmpty) {
        [AppTool showMessage:NSLocalizedString(@"Asset name is empty", nil) showView:self.view];
        return;
    }
    NSString *assetNameFM = [BRSafeUtils fuzzyMatchingPublishAssetWithText:self.issueAssetModel.assetName.removeFirstAndEndSpace];
    if([assetNameFM length] != 0) {
        [AppTool showMessage:NSLocalizedString(@"The entered asset name is an internal reserved word and is not allowed.", nil) showView:self.view];
        return;
    }
    NSString *assetNameM = [BRSafeUtils matchingPublishAssetWithText:self.issueAssetModel.assetName.removeFirstAndEndSpace];
    if(assetNameM.length != 0) {
        [AppTool showMessage:NSLocalizedString(@"The entered asset name is an internal reserved word and is not allowed.", nil) showView:self.view];
        return;
    }
    if([self isAssetNameExistence:self.issueAssetModel.assetName.removeFirstAndEndSpace]) {
        [AppTool showMessage:NSLocalizedString(@"Asset name already exists", nil) showView:self.view];
        self.issueAssetModel.isPublishAsset = NO;
        return;
    }
    if(self.issueAssetModel.shortName.isEmpty || self.issueAssetModel.shortName.removeFirstAndEndSpace.isEmpty) {
        [AppTool showMessage:NSLocalizedString(@"Asset short name is empty", nil) showView:self.view];
        return;
    }

    if([self isShortNameExistence:self.issueAssetModel.shortName.removeFirstAndEndSpace]) {
        [AppTool showMessage:NSLocalizedString(@"Asset short name already exists", nil) showView:self.view];
        return;
    }
    NSString *shortNameFM = [BRSafeUtils fuzzyMatchingPublishAssetWithText:self.issueAssetModel.shortName.removeFirstAndEndSpace];
    if([shortNameFM length] != 0) {
        [AppTool showMessage:NSLocalizedString(@"The entered asset short name is internal reserved word and is not allowed.", nil) showView:self.view];
        return;
    }
    NSString *shortNameM = [BRSafeUtils matchingPublishAssetWithText:self.issueAssetModel.shortName.removeFirstAndEndSpace];
    if(shortNameM.length != 0) {
        [AppTool showMessage:NSLocalizedString(@"The entered asset short name is internal reserved word and is not allowed.", nil) showView:self.view];
        return;
    }
    if([self.issueAssetModel.shortName rangeOfString:@" "].location != NSNotFound) {
        [AppTool showMessage:NSLocalizedString(@"Asset short name cannot contain spaces", nil) showView:self.view];
        return;
    }
    if(self.issueAssetModel.assetUnit.isEmpty || self.issueAssetModel.assetUnit.removeFirstAndEndSpace.isEmpty) {
        [AppTool showMessage:NSLocalizedString(@"Asset unit is empty", nil) showView:self.view];
        return;
    }
    NSString *regex = @"^[a-zA-Z\\u4e00-\\u9fa5]+$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if (![emailTest evaluateWithObject:self.issueAssetModel.assetUnit]) {
        [AppTool showMessage:NSLocalizedString(@"Asset units can only be Chinese and English", nil) showView:self.view];
        return;
    }
    if([self.issueAssetModel.assetUnit rangeOfString:@" "].location != NSNotFound) {
        [AppTool showMessage:NSLocalizedString(@"Asset units cannot contain spaces", nil) showView:self.view];
        return;
    }
//    NSArray *assetUnitArray = [BRIssueDataEnity objectsMatching:@"assetUnit = %@", self.issueAssetModel.assetUnit];
//    if(assetUnitArray.count > 0) {
//        [AppTool showMessage:@"资产单位已存在" showView:self.view];
//        return;
//    }
    NSString *assetUnitFM = [BRSafeUtils fuzzyMatchingPublishAssetWithText:self.issueAssetModel.assetUnit];
    if([assetUnitFM length] != 0) {
        [AppTool showMessage:NSLocalizedString(@"The asset unit entered is an internal reserved word and is not allowed.", nil) showView:self.view];
        return;
    }
    NSString *assetUnitM = [BRSafeUtils matchingPublishAssetWithText:self.issueAssetModel.assetUnit];
    if(assetUnitM.length != 0) {
        [AppTool showMessage:NSLocalizedString(@"The asset unit entered is an internal reserved word and is not allowed.", nil) showView:self.view];
        return;
    }
    if(self.issueAssetModel.totalAmount.isEmpty) {
        [AppTool showMessage:NSLocalizedString(@"The total amount of assets is empty", nil) showView:self.view];
        return;
    }
    if(self.issueAssetModel.firstIssueAmount.isEmpty) {
        [AppTool showMessage:NSLocalizedString(@"The total amount of initial issuance is empty", nil) showView:self.view];
        return;
    }
    if(self.issueAssetModel.decimals.isEmpty) {
        [AppTool showMessage:NSLocalizedString(@"The decimal point is empty", nil) showView:self.view];
        return;
    }
    if(self.issueAssetModel.decimals.integerValue < 4 || self.issueAssetModel.decimals.integerValue > 10) {
        [AppTool showMessage:NSLocalizedString(@"The number of decimal places cannot be less than 4 or greater than 10", nil) showView:self.view];
        return;
    }
    if(self.issueAssetModel.assetDesc.isEmpty || self.issueAssetModel.assetDesc.removeFirstAndEndSpace.isEmpty) {
        [AppTool showMessage:NSLocalizedString(@"Asset description is empty", nil) showView:self.view];
        return;
    }
    if(self.issueAssetModel.payCandy) {
        if(self.issueAssetModel.candyExpired.isEmpty) {
            [AppTool showMessage:NSLocalizedString(@"Candy expiration time is empty", nil) showView:self.view];
            return;
        }
        if(self.issueAssetModel.candyExpired.integerValue < 1 || self.issueAssetModel.candyExpired.integerValue > 3) {
            [AppTool showMessage:NSLocalizedString(@"Candy expiration time cannot be less than 1 or greater than 3", nil) showView:self.view];
            return;
        }
    }

    // 处理数据
    if([self.issueAssetModel.totalAmount hasSuffix:@"."]) {
        [AppTool showMessage:NSLocalizedString(@"Total assets do not match the number of decimal places", nil) showView:self.view];
        return;
    }
    if(self.issueAssetModel.totalAmount.getDecimal > self.issueAssetModel.decimals.integerValue) {
        [AppTool showMessage:NSLocalizedString(@"Total assets do not match the number of decimal places", nil) showView:self.view];
        return;
    }
    if([self.issueAssetModel.firstIssueAmount hasSuffix:@"."]) {
        [AppTool showMessage:NSLocalizedString(@"The total amount of initial release does not match the number of decimal places", nil) showView:self.view];
        return;
    }
    if(self.issueAssetModel.firstIssueAmount.getDecimal > self.issueAssetModel.decimals.integerValue) {
        [AppTool showMessage:NSLocalizedString(@"The total amount of initial release does not match the number of decimal places", nil) showView:self.view];
        return;
    }
    if(self.issueAssetModel.totalAmount.stringToInteger + self.issueAssetModel.decimals.integerValue > 19) {
        [AppTool showMessage:NSLocalizedString(@"The total number of assets ( including the number of decimal places ) cannot exceed 19 digits.", nil) showView:self.view];
        return;
    }
//    if(self.issueAssetModel.totalAmount.stringToInteger + self.issueAssetModel.decimals.integerValue > 19) {
//        [AppTool showMessage:@"(首次发行总量+小数位)不能超过19位" showView:self.view];
//        return;
//    }
    if([self.issueAssetModel.totalAmount stringToUint64:self.issueAssetModel.decimals.integerValue] == 0) {
        [AppTool showMessage:NSLocalizedString(@"The total amount of assets cannot be 0", nil) showView:self.view];
        return;
    }
    if([self.issueAssetModel.totalAmount stringToUint64:self.issueAssetModel.decimals.integerValue] < 100 * pow(10, self.issueAssetModel.decimals.integerValue)) {
        [AppTool showMessage:NSLocalizedString(@"The total amount of assets cannot be less than 100", nil) showView:self.view];
        return;
    }
    if([self.issueAssetModel.totalAmount stringToUint64:self.issueAssetModel.decimals.integerValue] > MAX_ASSETS) {
        [AppTool showMessage:NSLocalizedString(@"After the total amount of assets is expanded to an integer, it exceeds the maximum value of 2*10^(18)", nil) showView:self.view];
        return;
    }
    if([self.issueAssetModel.firstIssueAmount stringToUint64:self.issueAssetModel.decimals.integerValue] == 0) {
        [AppTool showMessage:NSLocalizedString(@"The total amount of initial issuance cannot be 0.", nil) showView:self.view];
        return;
    }
//    if([self.issueAssetModel.firstIssueAmount stringToUint64:self.issueAssetModel.decimals.integerValue] < 100 * pow(10, self.issueAssetModel.decimals.integerValue)) {
//        [AppTool showMessage:@"首次发行总量不能小于100" showView:self.view];
//        return;
//    }
//    if([self.issueAssetModel.firstIssueAmount stringToUint64:self.issueAssetModel.decimals.integerValue] > MAX_ASSETS) {
//        [AppTool showMessage:@"首次发行总量不能超过最大值" showView:self.view];
//        return;
//    }
    if([self.issueAssetModel.firstIssueAmount stringToUint64:self.issueAssetModel.decimals.integerValue] > [self.issueAssetModel.totalAmount stringToUint64:self.issueAssetModel.decimals.integerValue]) {
        [AppTool showMessage:NSLocalizedString(@"The total amount of initial issuance must be less than or equal to the total amount", nil) showView:self.view];
        return;
    }
    if([self.issueAssetModel.firstIssueAmount stringToUint64:self.issueAssetModel.decimals.integerValue] < [self.issueAssetModel getCandyAmount]) {
        [AppTool showMessage:NSLocalizedString(@"The amount of candy cannot be greater than or equal to the total amount of the initial issue", nil) showView:self.view];
        return;
    }
    if(self.issueAssetModel.getFirstActualAmount < 100 * pow(10, self.issueAssetModel.decimals.integerValue)) {
        [AppTool showMessage:NSLocalizedString(@"The total amount of actual initial issuance (the total amount of initial issuance - the number of candy) has to be at least 100", nil) showView:self.view];
        return;
    }

    self.tx = [[BRWalletManager sharedInstance].wallet transactionForAssetAmount:@(self.issueAssetModel.getFirstActualAmount) assetReserve:self.issueAssetModel.toIssueAssetData candyAmount:@(self.issueAssetModel.getCandyAmount) candyReserve:self.issueAssetModel.toCandyAssetData safeAmount:@([BRSafeUtils publishAssetConsumeSafe])];
//    [BRSafeUtils logTransaction:self.tx];
    if(!self.tx) {
        uint64_t reservefee = [BRSafeUtils feeReserve:self.issueAssetModel.toCandyAssetData.length];
        reservefee += [BRSafeUtils feeReserve:self.issueAssetModel.toCandyAssetData.length];
        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"Your available SAFE is less than %@%@ and cannot issue assets", nil), [BRSafeUtils showSAFEAmount:([BRSafeUtils publishAssetConsumeSafe] + 1000000 + reservefee)], [BRSafeUtils showSAFEUint]] showView:self.view];
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
    NSString *messageStr = @"";
    if([[BRSafeUtils showSAFEUint] length] != 0) {
        if(self.issueAssetModel.payCandy) {
            messageStr = [NSString stringWithFormat:NSLocalizedString(@"Candy is issued up to 5 times and can be issued %d more times. \nIssuance of assets will consume %@%@ , are you sure you want to issue it?", nil), 5, [BRSafeUtils showSAFEAmount:[BRSafeUtils publishAssetConsumeSafe]], [BRSafeUtils showSAFEUint]];
        } else {
            messageStr = [NSString stringWithFormat:NSLocalizedString(@"Issuing assets will consume %@%@ , are you sure you want to issue them?", nil), [BRSafeUtils showSAFEAmount:[BRSafeUtils publishAssetConsumeSafe]], [BRSafeUtils showSAFEUint]];
        }
    } else {
        if(self.issueAssetModel.payCandy) {
            messageStr = [NSString stringWithFormat:NSLocalizedString(@"Candy is issued up to 5 times and can be issued %d more times. \nIssuance of assets will consume %@%@ , are you sure you want to issue it?", nil), 5,  [BRSafeUtils showSAFEAmount:[BRSafeUtils publishAssetConsumeSafe]], @"SAFE"];
        } else {
            messageStr = [NSString stringWithFormat:NSLocalizedString(@"Issuing assets will consume %@%@ , are you sure you want to issue them?", nil), [BRSafeUtils showSAFEAmount:[BRSafeUtils publishAssetConsumeSafe]], @"SAFE"];
        }
    }
    BRAlertView *alertView = [[BRAlertView alloc] initWithMessage:messageStr messageType:NSTextAlignmentLeft delegate:self];
    [alertView show];
}
#pragma mark- BRAlertViewDelegate
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
//#warning Language International
//    CGFloat lableWidth = 20;
//    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(lableWidth, 14, SCREEN_WIDTH - margin * 2 - lableWidth * 2, 14 + 7 + 13 + 36 + 16 + 42)];
//    ;
//    if([[BRSafeUtils showSAFEUint] length] != 0) {
//        lable.text = [NSString stringWithFormat:@"发行资产将要消耗%@个%@，确定发行吗?", [BRSafeUtils showSAFEAmount:[BRSafeUtils publishAssetConsumeSafe]], [BRSafeUtils showSAFEUint]];
//    } else {
//        lable.text = [NSString stringWithFormat:@"发行资产将要消耗%@个SAFE，确定发行吗?", [BRSafeUtils showSAFEAmount:[BRSafeUtils publishAssetConsumeSafe]]];
//    }
//    lable.numberOfLines = 0;
//    lable.textColor = [UIColor blackColor];
//    lable.font = [UIFont systemFontOfSize:16.f];
//    lable.textAlignment = NSTextAlignmentCenter;
//    [alertView addSubview:lable];
//#warning Language International
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
//#warning Language International
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
//    __weak typeof(self) weakSelf = self;
//    [UIView animateWithDuration:0.1 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        weakSelf.promptAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
//    } completion:^(BOOL finished) {
//
//        [UIView animateWithDuration:0.3
//                         animations:^{
//                             weakSelf.promptAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.001, 0.001);
//                         }
//                         completion:^(BOOL finished) {
//                             [weakSelf.promptAlertView removeFromSuperview];
//                             weakSelf.effectView.hidden = YES;
//                             [weakSelf publishAssetBuildTx];
//                         }];
//    }];
//}

#pragma mark - 构建发行资产交易
- (void) publishAssetBuildTx {
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    uint64_t amount = self.issueAssetModel.getFirstActualAmount;
    uint64_t fee = [manager.wallet feeForPublishAssetTransaction:self.tx];
    NSString *prompt = [self promptAssetForAmount:amount + fee fee:fee];
    CFRunLoopPerformBlock([[NSRunLoop mainRunLoop] getCFRunLoop], kCFRunLoopCommonModes, ^{
        [self confirmTransaction:self.tx withPrompt:@"" forAmount:[BRSafeUtils publishAssetConsumeSafe] + fee];
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
    dashFormat.currencyCode = self.issueAssetModel.assetName;
    dashFormat.currencySymbol = [self.issueAssetModel.assetName stringByAppendingString:NARROW_NBSP];
    int pwoNumber = [self.issueAssetModel.decimals integerValue];
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
//                    dispatch_async(dispatch_get_main_queue(), ^{
                        [AppTool hideHUDView:nil animated:YES];
//                    });
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
//                        [AppTool showMessage:[NSString stringWithFormat:@"%@", error] showView:nil];
                    }
                    else if (! sent) { //TODO: show full screen sent dialog with tx info, "you sent b10,000 to bob"
//                        if (tx.associatedShapeshift) {
//                            [self startObservingShapeshift:tx.associatedShapeshift];
//                            
//                        }
                        sent = YES;
                        tx.timestamp = [NSDate timeIntervalSinceReferenceDate];
                        [manager.wallet registerTransaction:tx];
//                        [self.view addSubview:[[[BRBubbleView viewWithText:NSLocalizedString(@"sent!", nil)
//                                                                    center:CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2)] popIn]
//                                               popOutAfterDelay:2.0]];
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

#pragma mark - 隐藏提示框弹框
- (void)hidePromptAlertView {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.1 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        weakSelf.promptAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             weakSelf.promptAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.001, 0.001);
                         }
                         completion:^(BOOL finished) {
                             [weakSelf.promptAlertView removeFromSuperview];
                             weakSelf.effectView.hidden = YES;
                         }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

//- (void) publishAssetCellNotificationClick:(NSNotification *)text {
//    NSDictionary *dict = (NSDictionary *)text.userInfo;
//
//    if([[dict valueForKey:CellName] isEqualToString:@"BRApplyNameCell"]) {
//        if(self.issueAssetModel.payCandy) {
//            BRPublishAssetEditCandyProportionCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:21 inSection:0]];
//            if([[dict valueForKey:StringLength] integerValue] > 0 && [self isConfirmBtnEnabled:2]) {
//                cell.confirmBtn.enabled = YES;
//                cell.confirmBtn.backgroundColor = MAIN_COLOR;
//            } else {
//                cell.confirmBtn.enabled = NO;
//                cell.confirmBtn.backgroundColor = ColorFromRGB(0x999999);
//            }
//        } else {
//            BRPublishAssetEditCandyProportionCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:18 inSection:0]];
//            if([[dict valueForKey:StringLength] integerValue] > 0 && [self isConfirmBtnEnabled:2]) {
//                cell.confirmBtn.enabled = YES;
//                cell.confirmBtn.backgroundColor = MAIN_COLOR;
//            } else {
//                cell.confirmBtn.enabled = NO;
//                cell.confirmBtn.backgroundColor = ColorFromRGB(0x999999);
//            }
//        }
//    } else if ([[dict valueForKey:CellName] isEqualToString:@"BRPublishAssetCell"]) {
//        if(self.issueAssetModel.payCandy) {
//            BRPublishAssetEditCandyProportionCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:21 inSection:0]];
//            NSIndexPath *indexpath = [dict valueForKey:publishAssetCellIndexPath];
//            if([[dict valueForKey:StringLength] integerValue] > 0 && [self isConfirmBtnEnabled:indexpath.row]) {
//                cell.confirmBtn.enabled = YES;
//                cell.confirmBtn.backgroundColor = MAIN_COLOR;
//            } else {
//                cell.confirmBtn.enabled = NO;
//                cell.confirmBtn.backgroundColor = ColorFromRGB(0x999999);
//            }
//        } else {
//            BRPublishAssetEditCandyProportionCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:18 inSection:0]];
//            NSIndexPath *indexpath = [dict valueForKey:publishAssetCellIndexPath];
//            if([[dict valueForKey:StringLength] integerValue] > 0 && [self isConfirmBtnEnabled:indexpath.row]) {
//                cell.confirmBtn.enabled = YES;
//                cell.confirmBtn.backgroundColor = MAIN_COLOR;
//            } else {
//                cell.confirmBtn.enabled = NO;
//                cell.confirmBtn.backgroundColor = ColorFromRGB(0x999999);
//            }
//        }
//    } else if ([[dict valueForKey:CellName] isEqualToString:@"BRPublishAssetEditTimeCell"]) {
//        if(self.issueAssetModel.payCandy) {
//            BRPublishAssetEditCandyProportionCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:21 inSection:0]];
//            if([[dict valueForKey:StringLength] integerValue] > 0 && [self isConfirmBtnEnabled:19]) {
//                cell.confirmBtn.enabled = YES;
//                cell.confirmBtn.backgroundColor = MAIN_COLOR;
//            } else {
//                cell.confirmBtn.enabled = NO;
//                cell.confirmBtn.backgroundColor = ColorFromRGB(0x999999);
//            }
//        }
//    } else if ([[dict valueForKey:CellName] isEqualToString:@"BRPublishAssetEditDescribeCell"]) {
//        NSIndexPath *indexpath = [dict valueForKey:publishAssetEditDescribeCellNSIndexPath];
//        if(indexpath.row == 14) {
//            if(self.issueAssetModel.payCandy) {
//                BRPublishAssetEditCandyProportionCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:21 inSection:0]];
//                if([[dict valueForKey:StringLength] integerValue] > 0 && [self isConfirmBtnEnabled:indexpath.row]) {
//                    cell.confirmBtn.enabled = YES;
//                    cell.confirmBtn.backgroundColor = MAIN_COLOR;
//                } else {
//                    cell.confirmBtn.enabled = NO;
//                    cell.confirmBtn.backgroundColor = ColorFromRGB(0x999999);
//                }
//            } else {
//                BRPublishAssetEditCandyProportionCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:18 inSection:0]];
//                if([[dict valueForKey:StringLength] integerValue] > 0 && [self isConfirmBtnEnabled:indexpath.row]) {
//                    cell.confirmBtn.enabled = YES;
//                    cell.confirmBtn.backgroundColor = MAIN_COLOR;
//                } else {
//                    cell.confirmBtn.enabled = NO;
//                    cell.confirmBtn.backgroundColor = ColorFromRGB(0x999999);
//                }
//            }
//        }
//    }
//}
//
//- (BOOL) isConfirmBtnEnabled:(NSInteger) index {
//    if(self.issueAssetModel.payCandy) {
//        if(index == 2) {
//            if(self.issueAssetModel.shortName.length > 0 && self.issueAssetModel.assetUnit.length > 0 && self.issueAssetModel.totalAmount.length > 0 && self.issueAssetModel.firstIssueAmount.length > 0 && self.issueAssetModel.decimals.length > 0 && self.issueAssetModel.assetDesc.length > 0 && self.issueAssetModel.candyExpired.length > 0) {
//                return YES;
//            } else {
//                return NO;
//            }
//        } else if (index == 4) {
//            if(self.issueAssetModel.assetName.length > 0 && self.issueAssetModel.assetUnit.length > 0 && self.issueAssetModel.totalAmount.length > 0 && self.issueAssetModel.firstIssueAmount.length > 0 && self.issueAssetModel.decimals.length > 0 && self.issueAssetModel.assetDesc.length > 0 && self.issueAssetModel.candyExpired.length > 0) {
//                return YES;
//            } else {
//                return NO;
//            }
//        } else if (index == 6) {
//            if(self.issueAssetModel.assetName.length > 0 && self.issueAssetModel.shortName.length > 0 && self.issueAssetModel.totalAmount.length > 0 && self.issueAssetModel.firstIssueAmount.length > 0 && self.issueAssetModel.decimals.length > 0 && self.issueAssetModel.assetDesc.length > 0 && self.issueAssetModel.candyExpired.length > 0) {
//                return YES;
//            } else {
//                return NO;
//            }
//        } else if (index == 8) {
//            if(self.issueAssetModel.assetName.length > 0 && self.issueAssetModel.shortName.length > 0 && self.issueAssetModel.assetUnit.length > 0 && self.issueAssetModel.firstIssueAmount.length > 0 && self.issueAssetModel.decimals.length > 0 && self.issueAssetModel.assetDesc.length > 0 && self.issueAssetModel.candyExpired.length > 0) {
//                return YES;
//            } else {
//                return NO;
//            }
//        } else if (index == 10) {
//            if(self.issueAssetModel.assetName.length > 0 && self.issueAssetModel.shortName.length > 0 && self.issueAssetModel.assetUnit.length > 0 && self.issueAssetModel.totalAmount.length > 0 && self.issueAssetModel.decimals.length > 0 && self.issueAssetModel.assetDesc.length > 0 && self.issueAssetModel.candyExpired.length > 0) {
//                return YES;
//            } else {
//                return NO;
//            }
//        } else if (index == 12) {
//            if(self.issueAssetModel.assetName.length > 0 && self.issueAssetModel.shortName.length > 0 && self.issueAssetModel.assetUnit.length > 0 && self.issueAssetModel.totalAmount.length > 0 && self.issueAssetModel.firstIssueAmount.length > 0 && self.issueAssetModel.assetDesc.length > 0 && self.issueAssetModel.candyExpired.length > 0) {
//                return YES;
//            } else {
//                return NO;
//            }
//        } else if (index == 14) {
//            if(self.issueAssetModel.assetName.length > 0 && self.issueAssetModel.shortName.length > 0 && self.issueAssetModel.assetUnit.length > 0 && self.issueAssetModel.totalAmount.length > 0 && self.issueAssetModel.firstIssueAmount.length > 0 && self.issueAssetModel.decimals.length > 0 && self.issueAssetModel.candyExpired.length > 0) {
//                return YES;
//            } else {
//                return NO;
//            }
//        } else if (index == 19) {
//            if(self.issueAssetModel.assetName.length > 0 && self.issueAssetModel.shortName.length > 0 && self.issueAssetModel.assetUnit.length > 0 && self.issueAssetModel.totalAmount.length > 0 && self.issueAssetModel.firstIssueAmount.length > 0 && self.issueAssetModel.decimals.length > 0 && self.issueAssetModel.assetDesc.length > 0) {
//                return YES;
//            } else {
//                return NO;
//            }
//        } else {
//            return NO;
//        }
//    } else {
//        if(index == 2) {
//            if(self.issueAssetModel.shortName.length > 0 && self.issueAssetModel.assetUnit.length > 0 && self.issueAssetModel.totalAmount.length > 0 && self.issueAssetModel.firstIssueAmount.length > 0 && self.issueAssetModel.decimals.length > 0 && self.issueAssetModel.assetDesc.length > 0) {
//                return YES;
//            } else {
//                return NO;
//            }
//        } else if (index == 4) {
//            if(self.issueAssetModel.assetName.length > 0 && self.issueAssetModel.assetUnit.length > 0 && self.issueAssetModel.totalAmount.length > 0 && self.issueAssetModel.firstIssueAmount.length > 0 && self.issueAssetModel.decimals.length > 0 && self.issueAssetModel.assetDesc.length > 0) {
//                return YES;
//            } else {
//                return NO;
//            }
//        } else if (index == 6) {
//            if(self.issueAssetModel.assetName.length > 0 && self.issueAssetModel.shortName.length > 0 && self.issueAssetModel.totalAmount.length > 0 && self.issueAssetModel.firstIssueAmount.length > 0 && self.issueAssetModel.decimals.length > 0 && self.issueAssetModel.assetDesc.length > 0) {
//                return YES;
//            } else {
//                return NO;
//            }
//        } else if (index == 8) {
//            if(self.issueAssetModel.assetName.length > 0 && self.issueAssetModel.shortName.length > 0 && self.issueAssetModel.assetUnit.length > 0 && self.issueAssetModel.firstIssueAmount.length > 0 && self.issueAssetModel.decimals.length > 0 && self.issueAssetModel.assetDesc.length > 0) {
//                return YES;
//            } else {
//                return NO;
//            }
//        } else if (index == 10) {
//            if(self.issueAssetModel.assetName.length > 0 && self.issueAssetModel.shortName.length > 0 && self.issueAssetModel.assetUnit.length > 0 && self.issueAssetModel.totalAmount.length > 0 && self.issueAssetModel.decimals.length > 0 && self.issueAssetModel.assetDesc.length > 0) {
//                return YES;
//            } else {
//                return NO;
//            }
//        } else if (index == 12) {
//            if(self.issueAssetModel.assetName.length > 0 && self.issueAssetModel.shortName.length > 0 && self.issueAssetModel.assetUnit.length > 0 && self.issueAssetModel.totalAmount.length > 0 && self.issueAssetModel.firstIssueAmount.length > 0 && self.issueAssetModel.assetDesc.length > 0) {
//                return YES;
//            } else {
//                return NO;
//            }
//        } else if (index == 14) {
//            if(self.issueAssetModel.assetName.length > 0 && self.issueAssetModel.shortName.length > 0 && self.issueAssetModel.assetUnit.length > 0 && self.issueAssetModel.totalAmount.length > 0 && self.issueAssetModel.firstIssueAmount.length > 0 && self.issueAssetModel.decimals.length > 0) {
//                return YES;
//            } else {
//                return NO;
//            }
//        } else {
//            return NO;
//        }
//    }
//}
//
//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:publishAssetCellNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:applyNameCellNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:publishAssetEditTimeCellNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:publishAssetEditDescribeCellNotification object:nil];
//}

@end
