//
//  BRAssetViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/21.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRAssetViewController.h"
#import "BRAssetHeaderView.h"
#import "BRHistoryViewController.h"

#import "BRRootViewController.h"
#import "BRPaymentRequest.h"
#import "BRWalletManager.h"
#import "BRPeerManager.h"
#import "BRTransaction.h"
#import "BRBubbleView.h"
#import "BRAppGroupConstants.h"
#import "UIImage+Utils.h"
#import "BREventManager.h"
#import "BRWalletManager.h"


@interface BRAssetViewController ()<UITableViewDelegate,UITableViewDataSource,BRAssetHeaderViewDelegate, UINavigationControllerDelegate >

@property (nonatomic,strong) UITableView *assetTableView;
@property (nonatomic,strong) BRAssetHeaderView *headerView;

@property (nonatomic, strong) UIImage *qrImage;
@property (nonatomic, strong) BRBubbleView *tipView;
@property (nonatomic, assign) BOOL showTips;
//@property (nonatomic, strong) NSUserDefaults *groupDefs;
@property (nonatomic, strong) id balanceObserver, txStatusObserver;

@end

@implementation BRAssetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"SAFE Instant-Privacy-Security", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
    
    if (!self.balanceObserver) {
        self.balanceObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRWalletBalanceChangedNotification
                                                          object:nil queue:nil usingBlock:^(NSNotification *note) {
                                                              [self checkRequestStatus];
                                                              [self.assetTableView reloadData];
                                                          }];
    }
    
    if (!self.txStatusObserver) {
        self.txStatusObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerTxStatusNotification
                                                          object:nil queue:nil usingBlock:^(NSNotification *note) {
                                                              [self checkRequestStatus];
                                                          }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (void)dealloc
{
    if (self.balanceObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.balanceObserver];
    if (self.txStatusObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.txStatusObserver];
}

- (BRAssetHeaderView *)headerView {
    
    if (_headerView == nil) {
        _headerView = [[BRAssetHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 280)];
        _headerView.delegate = self;
    }
    return _headerView;
}

- (void)initUI {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [self.view addSubview:tableView];
    self.assetTableView = tableView;
    
    self.assetTableView.tableHeaderView = self.headerView;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"AssetCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier];
    }
    cell.imageView.image = [UIImage imageNamed:@"84x84logo"];
    cell.textLabel.text = @"SAFE";
    cell.textLabel.font = [UIFont systemFontOfSize:17.f];
    cell.textLabel.textColor = [UIColor blackColor];
    cell.detailTextLabel.textColor = [UIColor blackColor];
    
    uint64_t tempBalance = [BRWalletManager sharedInstance].wallet.balance;
    NSString *stringA = [NSString stringWithFormat:@"%.4f",(double)tempBalance];
    NSString *stringB = [NSString stringWithFormat:@"100000000.0000"];
    NSDecimalNumber *totalBalance = [NSDecimalNumber decimalNumberWithString:stringA];
    NSDecimalNumber *actualBalance = [NSDecimalNumber decimalNumberWithString:stringB];
    NSDecimalNumber *finalBalance = [totalBalance decimalNumberByDividingBy:actualBalance];
    cell.detailTextLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Total balance: %@", nil),finalBalance];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:17.f];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    BRHistoryViewController *historyVc = [[BRHistoryViewController alloc] init];
    historyVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:historyVc animated:YES];
}

#pragma mark -- MARK:BRAssetHeaderViewDelegate
- (void)sendAddress:(NSInteger)btnTag {
    
    if (btnTag == 111111) {
        
        //复制
        //NSLog(@"复制");
        
    } else {
        
        //生成新地址
        //NSLog(@"新地址");
        [self updateAddress];
    }
}

- (void)updateAddress
{
    //small hack to deal with bounds
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self updateAddress];
        });
        return;
    }
    __block CGSize qrViewBounds = (self.headerView.qrImageView ? self.headerView.qrImageView.bounds.size : CGSizeMake(120.0, 120.0));
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BRWalletManager *manager = [BRWalletManager sharedInstance];
        BRPaymentRequest *req = self.paymentRequest;
        UIImage *image = nil;
        
        //        if ([req.data isEqual:[self.groupDefs objectForKey:APP_GROUP_REQUEST_DATA_KEY]]) {
        //            image = [UIImage imageWithData:[self.groupDefs objectForKey:APP_GROUP_QR_IMAGE_KEY]];
        //        }
        
        if (! image && req.data) {
            image = [UIImage imageWithQRCodeData:req.data color:[CIColor colorWithRed:0.0 green:0.0 blue:0.0]];
        }
        
        self.qrImage = [image resize:qrViewBounds withInterpolationQuality:kCGInterpolationNone];
        
        if (req.amount == 0) {
            if (req.isValid) {
                //                [self.groupDefs setObject:UIImagePNGRepresentation(image) forKey:APP_GROUP_QR_IMAGE_KEY];
                image = [UIImage imageWithQRCodeData:req.data color:[CIColor colorWithRed:1.0 green:1.0 blue:1.0]];
                //                [self.groupDefs setObject:UIImagePNGRepresentation(image) forKey:APP_GROUP_QR_INV_IMAGE_KEY];
                //                [self.groupDefs setObject:self.paymentAddress forKey:APP_GROUP_RECEIVE_ADDRESS_KEY];
                //                [self.groupDefs setObject:req.data forKey:APP_GROUP_REQUEST_DATA_KEY];
            }
            else {
                //                [self.groupDefs removeObjectForKey:APP_GROUP_REQUEST_DATA_KEY];
                //                [self.groupDefs removeObjectForKey:APP_GROUP_RECEIVE_ADDRESS_KEY];
                //                [self.groupDefs removeObjectForKey:APP_GROUP_QR_IMAGE_KEY];
                //                [self.groupDefs removeObjectForKey:APP_GROUP_QR_INV_IMAGE_KEY];
            }
            
            //[self.groupDefs synchronize];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            self.headerView.qrImageView.image = self.qrImage;
            self.headerView.addressLable.text = self.paymentAddress;
            
            if (req.amount > 0) {
//                BRWalletManager *manager = [BRWalletManager sharedInstance];
//                NSMutableAttributedString * attributedDashString = [[manager attributedStringForDashAmount:req.amount withTintColor:[UIColor darkTextColor] useSignificantDigits:FALSE] mutableCopy];
//                self.label.attributedText = attributedDashString;
            }
        });
    });
}

- (void)checkRequestStatus
{
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    BRPaymentRequest *req = self.paymentRequest;
    uint64_t total = 0, fuzz = [manager amountForLocalCurrencyString:[manager localCurrencyStringForDashAmount:1]]*2;
    
    if (! [manager.wallet addressIsUsed:self.paymentAddress]) return;
    
    for (BRTransaction *tx in manager.wallet.allTransactions) {
        if ([tx.outputAddresses containsObject:self.paymentAddress]) continue;
        if (tx.blockHeight == TX_UNCONFIRMED &&
            [[BRPeerManager sharedInstance] relayCountForTransaction:tx.txHash] < PEER_MAX_CONNECTIONS) continue;
        total += [manager.wallet amountReceivedFromTransaction:tx];
        
        if (total + fuzz >= req.amount) {
            UIView *view = self.navigationController.presentingViewController.view;
            
            //[self done:nil];
            [view addSubview:[[[BRBubbleView viewWithText:[NSString
                                                           stringWithFormat:NSLocalizedString(@"received %@", nil), [manager stringForDashAmount:total]]
                                                   center:CGPointMake(view.bounds.size.width/2, view.bounds.size.height/2)] popIn] popOutAfterDelay:3.0]];
            break;
        }
    }
}

- (BRPaymentRequest *)paymentRequest
{
    if (_paymentRequest) return _paymentRequest;
    return [BRPaymentRequest requestWithString:self.paymentAddress];
}

- (NSString *)paymentAddress
{
    if (_paymentRequest) return _paymentRequest.paymentAddress;
    return [BRWalletManager sharedInstance].wallet.receiveAddress;
}

// MARK: - UIViewControllerAnimatedTransitioning

// This is used for percent driven interactive transitions, as well as for container controllers that have companion
// animations that might need to synchronize with the main animation.
//- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
//{
//    return 0.35;
//}

// This method can only be a nop if the transition is interactive and not a percentDriven interactive transition.
//- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
//{
//    UIView *containerView = transitionContext.containerView;
//    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey],
//    *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//
//    [containerView addSubview:to.view];
//
//    [UIView transitionFromView:from.view toView:to.view duration:[self transitionDuration:transitionContext]
//                       options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
//                           [from.view removeFromSuperview];
//                           [transitionContext completeTransition:YES];
//                       }];
//}

// MARK: - UINavigationControllerDelegate

//- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
//                                  animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC
//                                                 toViewController:(UIViewController *)toVC
//{
//    return self;
//}

// MARK: - UIViewControllerTransitioningDelegate

//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
//                                                                  presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
//{
//    return self;
//}

//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
//{
//    return self;
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
