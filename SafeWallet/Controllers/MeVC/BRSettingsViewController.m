//
//  BRSettingsViewController.m
//  BreadWallet
//
//  Created by Aaron Voisine on 12/3/14.
//  Copyright (c) 2014 Aaron Voisine <voisine@gmail.com>
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

#import "BRSettingsViewController.h"
#import "BRSeedViewController.h"
#import "BRWalletManager.h"
#import "BRBubbleView.h"
#import "BRPeerManager.h"
#import "BREventManager.h"
#import "BRUserDefaultsSwitchCell.h"
#import <SafariServices/SafariServices.h>
#import <asl.h>
#import <sys/socket.h>
#import <netdb.h>
#import <arpa/inet.h>
#import "BRAddressViewController.h"
#import "BRSafeUtils.h"
#import "BRPrecisionTableViewController.h"

@interface BRSettingsViewController ()

@property (nonatomic, assign) BOOL touchId;
@property (nonatomic, strong) UITableViewController *selectorController;
@property (nonatomic, strong) NSArray *selectorOptions;
@property (nonatomic, strong) NSString *selectedOption, *noOptionsText;
@property (nonatomic, assign) NSUInteger selectorType;
@property (nonatomic, strong) UISwipeGestureRecognizer *navBarSwipe;
@property (nonatomic, strong) id balanceObserver, txStatusObserver;

@property (nonatomic,assign) BOOL isLoadKeyboard;

@property (nonatomic,assign) BOOL isLoadPasswordBoard;

@end


@implementation BRSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.touchId = [BRWalletManager sharedInstance].touchIdEnabled;
    self.view.backgroundColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
 
    BRWalletManager *manager = [BRWalletManager sharedInstance];

    if (self.navBarSwipe) [self.navigationController.navigationBar removeGestureRecognizer:self.navBarSwipe];
    self.navBarSwipe = nil;

    // observe the balance change notification to update the balance display
    @weakify(self);
    if (! self.balanceObserver) {
        self.balanceObserver =
            [[NSNotificationCenter defaultCenter] addObserverForName:BRWalletBalanceChangedNotification object:nil
            queue:nil usingBlock:^(NSNotification *note) {
                @strongify(self);
                if (self.selectorType == 0) {
                    self.selectorController.title =
                        [NSString stringWithFormat:@"%@ = %@",
                         [manager localCurrencyStringForDashAmount:DUFFS/manager.localCurrencyDashPrice.doubleValue],
                         [manager stringForDashAmount:DUFFS/manager.localCurrencyDashPrice.doubleValue]];
                }
            }];
    }
    
    if (! self.txStatusObserver) {
        self.txStatusObserver =
            [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerTxStatusNotification object:nil
            queue:nil usingBlock:^(NSNotification *note) {
                @strongify(self);
                //[(id)[self.navigationController.topViewController.view viewWithTag:412] setText:self.stats];
                [(id)[self.navigationController.topViewController.view viewWithTag:412] setTitle:self.stats
                 forState:UIControlStateNormal];
            }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //[self.eaController preload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.isMovingFromParentViewController || self.navigationController.isBeingDismissed) {
        if (self.balanceObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.balanceObserver];
        self.balanceObserver = nil;
        if (self.txStatusObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.txStatusObserver];
        self.txStatusObserver = nil;
    }
    
    [super viewWillDisappear:animated];
}

- (void)dealloc
{
    if (self.balanceObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.balanceObserver];
    if (self.txStatusObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.txStatusObserver];
    BRLogFunc;
}

- (UITableViewController *)selectorController
{
    if (_selectorController) return _selectorController;
    _selectorController = [[UITableViewController alloc] initWithStyle:UITableViewStylePlain];
    _selectorController.tableView.dataSource = self;
    _selectorController.tableView.delegate = self;
    _selectorController.tableView.backgroundColor = [UIColor whiteColor];
    return _selectorController;
}

- (void)setBackgroundForCell:(UITableViewCell *)cell tableView:(UITableView *)tableView indexPath:(NSIndexPath *)path
{    
    [cell viewWithTag:100].hidden = (path.row > 0);
    [cell viewWithTag:101].hidden = (path.row + 1 < [self tableView:tableView numberOfRowsInSection:path.section]);
}

- (NSString *)stats
{
    static NSDateFormatter *fmt = nil;
    BRWalletManager *manager = [BRWalletManager sharedInstance];

    if (! fmt) {
        fmt = [NSDateFormatter new];
        fmt.dateFormat = [NSDateFormatter dateFormatFromTemplate:@"Mdjma" options:0 locale:[NSLocale currentLocale]];
    }

   return [NSString stringWithFormat:NSLocalizedString(@"rate: %@ = %@\nupdated: %@\nblock #%d of %d\n"
                                                       "connected peers: %d\ndl peer: %@", NULL),
           [manager localCurrencyStringForDashAmount:DUFFS/manager.localCurrencyDashPrice.doubleValue],
           [manager stringForDashAmount:DUFFS/manager.localCurrencyDashPrice.doubleValue],
           [fmt stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:manager.secureTime]].lowercaseString,
           [BRPeerManager sharedInstance].lastBlockHeight,
           [BRPeerManager sharedInstance].estimatedBlockHeight,
           [BRPeerManager sharedInstance].peerCount,
           [BRPeerManager sharedInstance].downloadPeerName];
}

// MARK: - IBAction

- (IBAction)done:(id)sender
{
    [BREventManager saveEvent:@"settings:dismiss"];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    //UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    //UITabBarController *tabbarVc = [storyboard instantiateViewControllerWithIdentifier:@"tabbarController"];
    //tabbarVc.delegate = self;
    //[tabbarVc setSelectedIndex:0];
    
    //[self.navigationController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)about:(id)sender
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *anwangAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"SAFE Website",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        SFSafariViewController * safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://www.anwang.com"]];
//        [self presentViewController:safariViewController animated:YES completion:nil];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.anwang.com"]];
    }];
    UIAlertAction *companyAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"BANKLEDGER Website",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        SFSafariViewController * safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://www.bankledger.com"]];
//        [self presentViewController:safariViewController animated:YES completion:nil];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.bankledger.com/index"]];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancle",nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //BRLog(@"cancel");
    }];
    [alertController addAction:anwangAction];
    [alertController addAction:companyAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#if DEBUG
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (IBAction)copyLogs:(id)sender
{
    [BREventManager saveEvent:@"settings:copy_logs"];
    aslmsg q = asl_new(ASL_TYPE_QUERY), m;
    aslresponse r = asl_search(NULL, q);
    NSMutableString *s = [NSMutableString string];
    time_t t;
    struct tm tm;

    while ((m = asl_next(r))) {
        t = strtol(asl_get(m, ASL_KEY_TIME), NULL, 10);
        localtime_r(&t, &tm);
        [s appendFormat:@"%d-%02d-%02d %02d:%02d:%02d %s: %s\n", tm.tm_year + 1900, tm.tm_mon, tm.tm_mday, tm.tm_hour,
         tm.tm_min, tm.tm_sec, asl_get(m, ASL_KEY_SENDER), asl_get(m, ASL_KEY_MSG)];
    }

    asl_free(r);
    [UIPasteboard generalPasteboard].string = (s.length < 8000000) ? s : [s substringFromIndex:s.length - 8000000];
    
    [self.navigationController.topViewController.view
     addSubview:[[[BRBubbleView viewWithText:NSLocalizedString(@"Successful copy", nil)
     center:CGPointMake(self.view.bounds.size.width/2.0, self.view.bounds.size.height/2.0)] popIn]
     popOutAfterDelay:2.0]];
}
#pragma GCC diagnostic pop
#endif

- (IBAction)fixedPeer:(id)sender
{
    if (! [[NSUserDefaults standardUserDefaults] stringForKey:SETTINGS_FIXED_PEER_KEY]) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:nil
                                     message:NSLocalizedString(@"set a trusted node", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = @"node ip";
            textField.textColor = [UIColor darkTextColor];
            textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            textField.borderStyle = UITextBorderStyleRoundedRect;
        }];
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"cancel", nil)
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
                                           [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
                                       }];
        UIAlertAction* trustButton = [UIAlertAction
                                     actionWithTitle:NSLocalizedString(@"trust", nil)
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action) {
                                         NSArray * textfields = alert.textFields;
                                         UITextField * ipField = textfields[0];
                                         NSString *fixedPeer = ipField.text;
                                         NSArray *pair = [fixedPeer componentsSeparatedByString:@":"];
                                         NSString *host = pair.firstObject;
                                         NSString *service = (pair.count > 1) ? pair[1] : @(DASH_STANDARD_PORT).stringValue;
                                         struct addrinfo hints = { 0, AF_UNSPEC, SOCK_STREAM, 0, 0, 0, NULL, NULL }, *servinfo, *p;
                                         UInt128 addr = { .u32 = { 0, 0, CFSwapInt32HostToBig(0xffff), 0 } };
                                         
                                         //BRLog(@"DNS lookup %@", host);
                                         
                                         if (getaddrinfo(host.UTF8String, service.UTF8String, &hints, &servinfo) == 0) {
                                             for (p = servinfo; p != NULL; p = p->ai_next) {
                                                 if (p->ai_family == AF_INET) {
                                                     addr.u64[0] = 0;
                                                     addr.u32[2] = CFSwapInt32HostToBig(0xffff);
                                                     addr.u32[3] = ((struct sockaddr_in *)p->ai_addr)->sin_addr.s_addr;
                                                 }
                                                 //                else if (p->ai_family == AF_INET6) {
                                                 //                    addr = *(UInt128 *)&((struct sockaddr_in6 *)p->ai_addr)->sin6_addr;
                                                 //                }
                                                 else continue;
                                                 
                                                 uint16_t port = CFSwapInt16BigToHost(((struct sockaddr_in *)p->ai_addr)->sin_port);
                                                 char s[INET6_ADDRSTRLEN];
                                                 
                                                 if (addr.u64[0] == 0 && addr.u32[2] == CFSwapInt32HostToBig(0xffff)) {
                                                     host = @(inet_ntop(AF_INET, &addr.u32[3], s, sizeof(s)));
                                                 }
                                                 else host = @(inet_ntop(AF_INET6, &addr, s, sizeof(s)));
                                                 
                                                 [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@:%d", host, port]
                                                                                           forKey:SETTINGS_FIXED_PEER_KEY];
                                                 [[BRPeerManager sharedInstance] disconnect];
                                                 [[BRPeerManager sharedInstance] connect];
                                                 break;
                                             }
                                             
                                             freeaddrinfo(servinfo);
                                         }
                                     }];
        [alert addAction:trustButton];
        [alert addAction:cancelButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:nil
                                     message:NSLocalizedString(@"clear trusted node?", nil)
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelButton = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"cancel", nil)
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
                                           [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
                                       }];
        UIAlertAction* clearButton = [UIAlertAction
                                      actionWithTitle:NSLocalizedString(@"clear", nil)
                                      style:UIAlertActionStyleDestructive
                                      handler:^(UIAlertAction * action) {
                                          [[NSUserDefaults standardUserDefaults] removeObjectForKey:SETTINGS_FIXED_PEER_KEY];
                                          [[BRPeerManager sharedInstance] disconnect];
                                          [[BRPeerManager sharedInstance] connect];
                                      }];
        [alert addAction:clearButton];
        [alert addAction:cancelButton];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)touchIdLimit:(id)sender
{
    [BREventManager saveEvent:@"settings:touch_id_limit"];
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    @weakify(self);
    [manager authenticateWithPrompt:nil andTouchId:NO alertIfLockout:YES completion:^(BOOL authenticated,BOOL cancelled) {
        @strongify(self);
        if (authenticated) {
            self.selectorType = 1;
            self.selectorOptions =
            @[NSLocalizedString(@"Passcode unlocked", nil), NSLocalizedString(@"Fingerprint unlock (SAFE amount is no more than 10)", nil), NSLocalizedString(@"Fingerprint unlock (SAFE amount is no more than 100)", nil),  NSLocalizedString(@"Fingerprint unlock (SAFE amount is no more than 1,000)", nil)];
            
//            @[NSLocalizedString(@"always require passcode", nil),
//              [NSString stringWithFormat:@"%@      ", [manager stringForDashAmount:DUFFS/0.1]],
//              [NSString stringWithFormat:@"%@   ", [manager stringForDashAmount:DUFFS*100]],
//               [NSString stringWithFormat:@"%@ ", [manager stringForDashAmount:DUFFS*1000]]];
//            if(manager.spendingLimit == 0) manager.spendingLimit == DUFFS;
            //self.selectedOption = self.selectorOptions[(log10(manager.spendingLimit) < 6) ? 0 :(NSUInteger)log10(manager.spendingLimit) - 6];
            
            NSInteger row = log10(manager.spendingLimit == 0 ? DUFFS : manager.spendingLimit) - 8;
            self.selectedOption = self.selectorOptions[row];
            
            self.noOptionsText = nil;
            self.selectorController.title = NSLocalizedString(@"Expense limit unlock", nil);  // NSLocalizedString(@"touch id spending limit", nil);
            [self.navigationController pushViewController:self.selectorController animated:YES];
            [self.selectorController.tableView reloadData];
        } else {
            [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
        }
    }];
}

- (IBAction)navBarSwipe:(id)sender
{
    [BREventManager saveEvent:@"settings:nav_bar_swipe"];
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSUInteger digits = (((manager.dashFormat.maximumFractionDigits - 2)/3 + 1) % 3)*3 + 2;
    
    manager.dashFormat.currencySymbol = [NSString stringWithFormat:@"%@%@" NARROW_NBSP, (digits == 5) ? @"m" : @"",
                                     (digits == 2) ? DITS : SAFE];
    manager.dashFormat.maximumFractionDigits = digits;
    manager.dashFormat.maximum = @(MAX_MONEY/(int64_t)pow(10.0, manager.dashFormat.maximumFractionDigits));
    [[NSUserDefaults standardUserDefaults] setInteger:digits forKey:SETTINGS_MAX_DIGITS_KEY];
    manager.localCurrencyCode = manager.localCurrencyCode; // force balance notification
    self.selectorController.title = [NSString stringWithFormat:@"%@ = %@",
                                     [manager localCurrencyStringForDashAmount:DUFFS/manager.localCurrencyDashPrice.doubleValue],
                                     [manager stringForDashAmount:DUFFS/manager.localCurrencyDashPrice.doubleValue]];
    [self.tableView reloadData];
}

// MARK: - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.selectorController.tableView) return 1;
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.selectorController.tableView) return self.selectorOptions.count;
    
    switch (section) {
        case 0: return 1;
        //case 1: return (self.touchId) ? 3 : 2;
//        case 1: return (self.touchId) ? 2 : 1;
        case 1: return (self.touchId) ? 1 : 0;
        case 2: return 4;
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *disclosureIdent = @"DisclosureCell", *restoreIdent = @"RestoreCell", *actionIdent = @"ActionCell",
                    *selectorIdent = @"SelectorCell", *selectorOptionCell = @"SelectorOptionCell";
    UITableViewCell *cell = nil;
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    
    if (tableView == self.selectorController.tableView) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:selectorOptionCell];
        [self setBackgroundForCell:cell tableView:tableView indexPath:indexPath];
        cell.textLabel.text = self.selectorOptions[indexPath.row];
        
        if ([self.selectedOption isEqual:self.selectorOptions[indexPath.row]]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
        else cell.accessoryType = UITableViewCellAccessoryNone;
        
        return cell;
    }
    
    switch (indexPath.section) {
        case 0:
            cell = [tableView dequeueReusableCellWithIdentifier:disclosureIdent];
            
            switch (indexPath.row) {
//                case 0:
//                    cell.textLabel.text = NSLocalizedString(@"about", nil);
//                    break;
                    
                case 0:
                    cell.textLabel.text = NSLocalizedString(@"recovery phrase", nil);
                    break;
            }
            
            break;
            
        case 1:
            switch (indexPath.row) {

//                case 0:
//                    cell = [tableView dequeueReusableCellWithIdentifier:disclosureIdent];
//                    cell.textLabel.text = @"地址簿";
//                    break;
                    
                case 0:
                    if (self.touchId) {
                        cell = [tableView dequeueReusableCellWithIdentifier:selectorIdent];
                        cell.textLabel.text = NSLocalizedString(@"Expense limit unlock", nil); //NSLocalizedString(@"touch id limit", nil);
                        if (manager.spendingLimit >= DUFFS*10) {
                            cell.detailTextLabel.text = NSLocalizedString(@"Fingerprint unlock", nil); //[manager stringForDashAmount:manager.spendingLimit];
                        } else {
                            cell.detailTextLabel.text = NSLocalizedString(@"Passcode unlocked", nil); // @"SAFE 0";
                        }
                        
                    } else {
                        goto _switch_cell;
                    }
                    break;
                case 1:
                {
_switch_cell:
                    cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
                    BRUserDefaultsSwitchCell *switchCell = (BRUserDefaultsSwitchCell *)cell;
                    switchCell.titleLabel.text = NSLocalizedString(@"enable receive notifications", nil);
                    [switchCell setUserDefaultsKey:USER_DEFAULTS_LOCAL_NOTIFICATIONS_KEY];
                    break;
                }
                    
            }
            
            break;
            
        case 2:
            switch (indexPath.row) {
                case 0:
                    cell = [tableView dequeueReusableCellWithIdentifier:actionIdent];
                    cell.textLabel.text = NSLocalizedString(@"change passcode", nil);
                    break;
                    
                case 1:
                    cell = [tableView dequeueReusableCellWithIdentifier:restoreIdent];
                    break;
                    
                case 2:
                    cell = [tableView dequeueReusableCellWithIdentifier:actionIdent];
                    cell.textLabel.text = NSLocalizedString(@"Reset blockchain", nil);
                    break;
                case 3:
                    cell = [tableView dequeueReusableCellWithIdentifier:actionIdent];
                    cell.textLabel.text = NSLocalizedString(@"Denomination and precision", nil);
                    break;
            }
            break;
            
    }
    
    [self setBackgroundForCell:cell tableView:tableView indexPath:indexPath];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.selectorController.tableView && self.selectorOptions.count == 0) return self.noOptionsText;
    
    switch (section) {
        case 0:
            return nil;
            
        case 1:
            return nil;
            
        case 2:
            return nil;
            
        case 3:
            return NSLocalizedString(@"rescan blockchain if you think you may have missing transactions, "
                                     "or are having trouble sending (rescanning can take several minutes)", nil);
    }
    
    return nil;
}

// MARK: - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if(section == 1 && !self.touchId) return 0;
    if (sectionTitle.length == 0) return 22.0;
    
    CGRect textRect = [sectionTitle boundingRectWithSize:CGSizeMake(self.view.frame.size.width - 20.0, CGFLOAT_MAX)
                options:NSStringDrawingUsesLineFragmentOrigin
                attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil];
    
    return textRect.size.height + 22.0 + 10.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width,
                                                         [self tableView:tableView heightForHeaderInSection:section])];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 0.0, sectionHeader.frame.size.width - 20.0,
                                                           sectionHeader.frame.size.height - 22.0)];
    
    titleLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.shadowColor = [UIColor whiteColor];
    titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
    titleLabel.numberOfLines = 0;
    sectionHeader.backgroundColor = [UIColor clearColor];
    [sectionHeader addSubview:titleLabel];
    
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return (section + 1 == [self numberOfSectionsInTableView:tableView]) ? 22.0 : 0.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *sectionFooter = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width,
                                                         [self tableView:tableView heightForFooterInSection:section])];
    sectionFooter.backgroundColor = [UIColor clearColor];
    return sectionFooter;
}

- (void)showAbout
{
    [BREventManager saveEvent:@"settings:show_about"];
    UIViewController *c = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutViewController"];
    UILabel *l = (id)[c.view viewWithTag:411];
    NSMutableAttributedString *s = [[NSMutableAttributedString alloc] initWithAttributedString:l.attributedText];
    UIButton *b = nil;
    
#if DASH_TESTNET
    [s replaceCharactersInRange:[s.string rangeOfString:@"%net%" options:NSCaseInsensitiveSearch] withString:@"%net% (testnet)"];
#endif
    [s replaceCharactersInRange:[s.string rangeOfString:@"%ver%" options:NSCaseInsensitiveSearch]
     withString:[NSString stringWithFormat:@"%@.%@",
                 NSBundle.mainBundle.infoDictionary[@"CFBundleShortVersionString"],
                 NSBundle.mainBundle.infoDictionary[@"CFBundleVersion"]]];
    [s replaceCharactersInRange:[s.string rangeOfString:@"%net%" options:NSCaseInsensitiveSearch] withString:@""];
    l.attributedText = s;
    [l.superview.gestureRecognizers.firstObject addTarget:self action:@selector(about:)];
#if DEBUG
    {
        b = (id)[c.view viewWithTag:413];
        [b addTarget:self action:@selector(copyLogs:) forControlEvents:UIControlEventTouchUpInside];
        b.hidden = NO;
    }
#endif

    b = (id)[c.view viewWithTag:412];
    [b setTitle:self.stats forState:UIControlStateNormal];
    [b addTarget:self action:@selector(fixedPeer:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.navigationController pushViewController:c animated:YES];
}

- (void)showRecoveryPhrase
{
    [BREventManager saveEvent:@"settings:show_recovery_phrase"];
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:NSLocalizedString(@"WARNING", nil)
                                 message:[NSString stringWithFormat:@"\n%@\n\n%@\n\n%@\n",
                                          [NSLocalizedString(@"\nDO NOT let anyone see your recovery\n"
                                                             "phrase or they can spend your dash.\n", nil)
                                           stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]],
                                          [NSLocalizedString(@"\nNEVER type your recovery phrase into\n"
                                                             "password managers or elsewhere.\n"
                                                             "Other devices may be infected.\n", nil)
                                           stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]],
                                          [NSLocalizedString(@"\nDO NOT take a screenshot.\n"
                                                             "Screenshots are visible to other apps\n"
                                                             "and devices.\n", nil)
                                           stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]]
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancelButton = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"cancel", nil)
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction * action) {
                                       [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
                                   }];
    UIAlertAction* showButton = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"show", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:^(UIAlertAction * action) {
                                     BRWalletManager *manager = [BRWalletManager sharedInstance];
                                     @weakify(self);
                                     [manager seedPhraseAfterAuthentication:^(NSString * _Nullable seedPhrase) {
                                         @strongify(self);
                                         if (seedPhrase.length > 0) {
                                             BRSeedViewController *seedController = [self.storyboard instantiateViewControllerWithIdentifier:@"SeedViewController"];
                                             seedController.seedPhrase = seedPhrase;
                                             [self.navigationController pushViewController:seedController animated:YES];
                                         } else {
                                             [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
                                         }
                                     }];
                                 }];
    [alert addAction:showButton];
    [alert addAction:cancelButton];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showCurrencySelector
{
    [BREventManager saveEvent:@"settings:show_currency_selector"];
    NSUInteger currencyCodeIndex = 0;
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    double localPrice = manager.localCurrencyDashPrice.doubleValue;
    NSMutableArray *options;
    self.selectorType = 0;
    options = [NSMutableArray array];
    
    for (NSString *code in manager.currencyCodes) {
        [options addObject:[NSString stringWithFormat:@"%@ - %@", code, manager.currencyNames[currencyCodeIndex++]]];
    }
    
    self.selectorOptions = options;
    currencyCodeIndex = [manager.currencyCodes indexOfObject:manager.localCurrencyCode];
    if (currencyCodeIndex < options.count) self.selectedOption = options[currencyCodeIndex];
    self.noOptionsText = NSLocalizedString(@"no exchange rate data", nil);
    self.selectorController.title =
        [NSString stringWithFormat:@"%@ = %@",
         [manager localCurrencyStringForDashAmount:(localPrice > DBL_EPSILON) ? DUFFS/localPrice : 0],
         [manager stringForDashAmount:(localPrice > DBL_EPSILON) ? DUFFS/localPrice : 0]];
    [self.navigationController pushViewController:self.selectorController animated:YES];
    [self.selectorController.tableView reloadData];
    
    if (currencyCodeIndex < options.count) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.selectorController.tableView
             scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currencyCodeIndex inSection:0]
             atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            
            if (! self.navBarSwipe) {
                self.navBarSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(navBarSwipe:)];
                self.navBarSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
                [self.navigationController.navigationBar addGestureRecognizer:self.navBarSwipe];
            }
        });
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //TODO: include an option to generate a new wallet and sweep old balance if backup may have been compromized
    BRWalletManager *manager = [BRWalletManager sharedInstance];
    NSUInteger currencyCodeIndex = 0;
    
    // if we are showing the local currency selector
    if (tableView == self.selectorController.tableView) {
        currencyCodeIndex = [self.selectorOptions indexOfObject:self.selectedOption];
        if (indexPath.row < self.selectorOptions.count) self.selectedOption = self.selectorOptions[indexPath.row];

        if (self.selectorType == 0) {
            if (indexPath.row < manager.currencyCodes.count) {
                manager.localCurrencyCode = manager.currencyCodes[indexPath.row];
            }
        }
        else  {
            manager.spendingLimit = (indexPath.row > 0) ? pow(10, indexPath.row + 8) : 0;
        }

        if (currencyCodeIndex < self.selectorOptions.count && currencyCodeIndex != indexPath.row) {
            [tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:currencyCodeIndex inSection:0], indexPath]
             withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.tableView reloadData];
        return;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
//                case 0: // about
//                    [self showAbout];
//                    break;
                    
                case 0: // recovery phrase
                    [self showRecoveryPhrase];
                    break;
            }
            
            break;
            
        case 1:
            if (indexPath.row == 0) {
                
                if (self.touchId) {
                    if(self.isLoadKeyboard) return;
                    self.isLoadKeyboard = YES;
                    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
                    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                        self.isLoadKeyboard = NO;
                    });
                    [self performSelector:@selector(touchIdLimit:) withObject:nil afterDelay:0.0];
                } else {
                    goto _deselect_switch;
                }
                
            } else {
            _deselect_switch:
                {
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                }
            }
//            if (indexPath.row == 0) {
//                [tableView deselectRowAtIndexPath:indexPath animated:YES];
//                BRAddressViewController *addressVc = [[BRAddressViewController alloc] init];
//                [self.navigationController pushViewController:addressVc animated:YES];
//
//            } else if (indexPath.row == 1) {
//
//                if (self.touchId) {
//                    [self performSelector:@selector(touchIdLimit:) withObject:nil afterDelay:0.0];
//                } else {
//                    goto _deselect_switch;
//                }
//
//            } else {
//_deselect_switch:
//                {
//                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//                }
//            }
            
//            switch (indexPath.row) {
//                case 0:
//
//                    break;
//
//                case 1: // touch id spending limit
//                    if (self.touchId) {
//                        [self performSelector:@selector(touchIdLimit:) withObject:nil afterDelay:0.0];
//                        break;
//                    } else {
//                        goto _deselect_switch;
//                    }
//                    break;
//
//                case 2:
//_deselect_switch:
//                    {
//                        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//                    }
//                    break;
//            }
            
            break;
            
        case 2:
            switch (indexPath.row) {
                case 0: // change passcode
                {    if(self.isLoadPasswordBoard) return;
                    self.isLoadPasswordBoard = YES;
                    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC));
                    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                        self.isLoadPasswordBoard = NO;
                    });
                    [BREventManager saveEvent:@"settings:change_pin"];
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    [manager performSelector:@selector(setPinWithCompletion:) withObject:nil afterDelay:0.0];
                    break;
                }

                case 1: // start/recover another wallet (handled by storyboard)
                    [BREventManager saveEvent:@"settings:recover"];
                    break;
                    
                case 2: // rescan blockchain
                {
                    [tableView deselectRowAtIndexPath:indexPath animated:YES];
                    NSString *title = [NSString stringWithFormat:@"\n%@", NSLocalizedString(@"Do you want to reset the blockchain?", nil)];
                    NSString *subTitle = [NSString stringWithFormat:@"\n\n%@", NSLocalizedString(@"Doing so will temporarily hide your wallet balance and transaction history. The blockchain will be restored after synchronization. Make sure you are connected to a reliable network.", nil)];
                    NSMutableParagraphStyle *centerP = [[NSMutableParagraphStyle alloc] init];
                    centerP.alignment = NSTextAlignmentCenter;
                    NSAttributedString *attrTitle = [[NSAttributedString alloc] initWithString:title attributes:@{NSParagraphStyleAttributeName : centerP}];
                    NSMutableParagraphStyle *leftP = [[NSMutableParagraphStyle alloc] init];
                    leftP.alignment = NSTextAlignmentLeft;
                    NSAttributedString *attSubTitle = [[NSAttributedString alloc] initWithString:subTitle attributes:@{NSParagraphStyleAttributeName : leftP}];
                    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] init];
                    [attrString appendAttributedString:attrTitle];
                    [attrString appendAttributedString:attSubTitle];
                    [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attrString.length)];
                    
                    UIAlertController * alert = [UIAlertController
                                                 alertControllerWithTitle:NSLocalizedString(@"Reset blockchain", nil)
                                                 message:attrString.string
                                                 preferredStyle:UIAlertControllerStyleAlert];
                    [alert setValue:attrString forKey:@"attributedMessage"];
                    
                    UIAlertAction* okButton = [UIAlertAction
                                               actionWithTitle:NSLocalizedString(@"Reset", nil)
                                               style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * action) {
                                                   [[BRPeerManager sharedInstance] disconnect];
                                                   [AppTool showHUDView:nil animated:YES];
                                                   dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
                                                   dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                                                       @weakify(self);
                                                       dispatch_async(dispatch_queue_create("deleteLocalCoreDataData", NULL), ^{
                                                           @strongify(self);
                                                           [self deleteLocalCoreDataData];
                                                           @weakify(self);
                                                           dispatch_async(dispatch_get_main_queue(), ^{
                                                               @strongify(self);
                                                               [AppTool hideHUDView:nil animated:NO];
                                                               [[BRPeerManager sharedInstance] connect];
                                                               [BREventManager saveEvent:@"settings:rescan"];
                                                               [self done:nil];
                                                           });
                                                       });
                                                   });
                                               }];
                    UIAlertAction* copyButton = [UIAlertAction
                                                 actionWithTitle:NSLocalizedString(@"cancel", nil)
                                                 style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction * action) {
                                                 }];
                    [alert addAction:copyButton];
                    [alert addAction:okButton];
                    [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
                    break;
                }
                case 3: {
                    BRPrecisionTableViewController *precisionVC = [[BRPrecisionTableViewController alloc] init];
                    [self.navigationController pushViewController:precisionVC animated:YES];
                    break;
                }
            }
            
            break;
    }
}

#pragma mark - 添加删除本地数据
- (void) deleteLocalCoreDataData {
    [BRSafeUtils deleteCoreDataData:YES];
}

// MARK: - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result
error:(NSError *)error
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

@end

