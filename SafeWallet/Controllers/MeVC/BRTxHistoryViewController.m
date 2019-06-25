//
//  BRTxHistoryViewController.m
//  BreadWallet
//
//  Created by Aaron Voisine on 6/11/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import "BRTxHistoryViewController.h"
#import "BRSettingsViewController.h"
#import "BREventManager.h"
#import "BREventConfirmView.h"
#import "BRCandyViewController.h"
#import "BRMasternodeViewController.h"
#import "BRRegisterViewController.h"
#import "BRAddressBookViewController.h"
#import "BRNetWatcherViewController.h"
#import "BRGetCandyHistoryViewController.h"
#import "BRAboutViewController.h"

#define TRANSACTION_CELL_HEIGHT 75

@interface BRTxHistoryViewController ()

@end

@implementation BRTxHistoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.title = NSLocalizedString(@"SAFE wallet", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    self.tableView.estimatedRowHeight = 0;
}

-(UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)setBackgroundForCell:(UITableViewCell *)cell tableView:(UITableView *)tableView indexPath:(NSIndexPath *)path
{    
    [cell viewWithTag:100].hidden = (path.row > 0);
    [cell viewWithTag:101].hidden = (path.row + 1 < [self tableView:tableView numberOfRowsInSection:path.section]);
}

// MARK: - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *actionIdent = @"ActionCell",
                    *disclosureIdent = @"DisclosureCell";
    UITableViewCell *cell = nil;

    cell = [tableView dequeueReusableCellWithIdentifier:actionIdent];
    switch (indexPath.row) {
            
        case 0:
//            cell.textLabel.text = NSLocalizedString(@"Candy", nil);
            cell.textLabel.text = NSLocalizedString(@"Candy record", nil);
            cell.textLabel.textColor = [UIColor blackColor];
            cell.imageView.image = [UIImage imageNamed:@"tg"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
//            cell.textLabel.text = NSLocalizedString(@"Registration Application Record", nil);
//            cell.textLabel.textColor = [UIColor blackColor];
//            cell.imageView.image = [UIImage imageNamed:@"zcyyjlX"];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1:
            cell.textLabel.text = NSLocalizedString(@"Masternode",nil);
            cell.textLabel.textColor = [UIColor blackColor];
            cell.imageView.image = [UIImage imageNamed:@"zjdX"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            cell.textLabel.text = NSLocalizedString(@"Masternode", nil);
//            cell.textLabel.textColor = [UIColor blackColor];
//            cell.imageView.image = [UIImage imageNamed:@"zjdX"];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
            
        case 2:
            cell.textLabel.text = NSLocalizedString(@"Settings", nil);
            cell.textLabel.textColor = [UIColor blackColor];
            cell.imageView.image = [UIImage imageNamed:@"sz"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            cell.textLabel.text = @"网络监视器";
//            cell.textLabel.textColor = [UIColor blackColor];
//            cell.imageView.image = [UIImage imageNamed:@"wljyq"];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            cell.textLabel.text = NSLocalizedString(@"Candy", nil);
//            cell.textLabel.textColor = [UIColor blackColor];
//            cell.imageView.image = [UIImage imageNamed:@"tg"];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;

        case 3:
            cell.textLabel.text = NSLocalizedString(@"About us", nil);
            cell.textLabel.textColor = [UIColor blackColor];
            cell.imageView.image = [UIImage imageNamed:@"gywm"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
#warning Language International
//            cell.textLabel.text = @"安全";
//            cell.textLabel.textColor = [UIColor blackColor];
//            cell.imageView.image = [UIImage imageNamed:@"aq"];
//            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
//            cell = [tableView dequeueReusableCellWithIdentifier:disclosureIdent];
//            cell.textLabel.text = NSLocalizedString(@"Settings", nil);
//            cell.textLabel.textColor = [UIColor blackColor];
//            cell.imageView.image = [UIImage imageNamed:@"sz"];
            break;
            
        case 4:
            cell.textLabel.text = NSLocalizedString(@"Settings", nil);
            cell.textLabel.textColor = [UIColor blackColor];
            cell.imageView.image = [UIImage imageNamed:@"sz"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            break;
            
        case 5:
#warning Language International
            cell.textLabel.text = @"报告问题";
            cell.textLabel.textColor = [UIColor blackColor];
            cell.imageView.image = [UIImage imageNamed:@"bgwt"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            break;
            
        case 6:
#warning Language International
            cell.textLabel.text = @"关于我们";
            cell.textLabel.textColor = [UIColor blackColor];
            cell.imageView.image = [UIImage imageNamed:@"gywm"];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;

    }
    [self setBackgroundForCell:cell tableView:tableView indexPath:indexPath];
    return cell;
}

// MARK: - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0001;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //TODO: include an option to generate a new wallet and sweep old balance if backup may have been compromized
    UIViewController *destinationController = nil;

    if (indexPath.row == 0) {
        BRGetCandyHistoryViewController *historyVc = [[BRGetCandyHistoryViewController alloc] init];
        historyVc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:historyVc animated:YES];
//        BRCandyViewController *candyVc = [[BRCandyViewController alloc] init];
//        candyVc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:candyVc animated:YES];
//        BRRegisterViewController *registerVc = [[BRRegisterViewController alloc] init];
//        registerVc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:registerVc animated:YES];
    } else if (indexPath.row == 1) {
        BRMasternodeViewController *masternodeViewVC = [[BRMasternodeViewController alloc] init];
        masternodeViewVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:masternodeViewVC animated:YES];
//        BRAddressBookViewController *addressBookVC = [[BRAddressBookViewController alloc] init];
//        addressBookVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:addressBookVC animated:YES];
//        BRMasternodeViewController *masternodeVc = [[BRMasternodeViewController alloc] init];
//        masternodeVc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:masternodeVc animated:YES];
    } else if (indexPath.row == 2) {
        [BREventManager saveEvent:@"tx_history:settings"];
        destinationController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        destinationController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:destinationController animated:YES];
//        BRNetWatcherViewController *netWatcherVC = [[BRNetWatcherViewController alloc] init];
//        netWatcherVC.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:netWatcherVC animated:YES];
//        BRCandyViewController *candyVc = [[BRCandyViewController alloc] init];
//        candyVc.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:candyVc animated:YES];
    } else if (indexPath.row == 3) {
        BRAboutViewController *aboutViewController = [[BRAboutViewController alloc] init];
        aboutViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:aboutViewController animated:YES];
//        [BREventManager saveEvent:@"tx_history:settings"];
//        destinationController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
//        destinationController.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:destinationController animated:YES];
    } else if (indexPath.row == 4) {
//        [BREventManager saveEvent:@"tx_history:settings"];
//        destinationController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
//        destinationController.hidesBottomBarWhenPushed = YES;
//        [self.navigationController pushViewController:destinationController animated:YES];
    } else if (indexPath.row == 5) {
        
    } else if (indexPath.row == 6) {
        
    }
}

// MARK: - UIViewControllerAnimatedTransitioning

// This is used for percent driven interactive transitions, as well as for container controllers that have companion
// animations that might need to synchronize with the main animation.
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.35;
}

// This method can only be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIView *containerView = transitionContext.containerView;
    UIViewController *to = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey],
                     *from = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    BOOL pop = (to == self || (from != self && [to isKindOfClass:[BRSettingsViewController class]])) ? YES : NO;

    to.view.center = CGPointMake(containerView.frame.size.width*(pop ? -1 : 3)/2, to.view.center.y);
    [containerView addSubview:to.view];

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.8
    initialSpringVelocity:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        to.view.center = from.view.center;
        from.view.center = CGPointMake(containerView.frame.size.width*(pop ? 3 : -1)/2, from.view.center.y);
        
    } completion:^(BOOL finished) {
        if (pop) [from.view removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

// MARK: - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC
toViewController:(UIViewController *)toVC
{
    return self;
}

// MARK: - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self;
}

@end
