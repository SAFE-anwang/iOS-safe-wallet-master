//
//  BRAppDelegate.m
//  BreadWallet
//
//  Created by Aaron Voisine on 5/8/13.
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

#import "BRAppDelegate.h"
#import "BRPeerManager.h"
#import "BRWalletManager.h"
#import "BREventManager.h"
#import "DSShapeshiftManager.h"
#import "UIImage+Color.h"
#import <AVFoundation/AVFoundation.h>

#import "BRSafeUtils.h"
#import <Bugly/Bugly.h>
#import "BRCoreDataManager.h"
#if DASH_TESTNET
#pragma message "testnet build"
#endif

#if SNAPSHOT
#pragma message "snapshot build"
#endif

@interface BRAppDelegate ()

// the nsnotificationcenter observer for wallet balance
@property id balanceObserver;

// the most recent balance as received by notification
@property uint64_t balance;

@property (nonatomic, strong) AVAudioPlayer *player;

@end

@implementation BRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [UITabBar appearance].translucent = NO;
    [self setupBugluy];
    
    // use background fetch to stay synced with the blockchain
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];

    UIPageControl.appearance.pageIndicatorTintColor = [UIColor lightGrayColor];
    UIPageControl.appearance.currentPageIndicatorTintColor = [UIColor blueColor];
    
//    UIImage * tabBarImage = [[UIImage imageNamed:@"tab-bar-dash"]
//     resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
    
//    UIImage * tabBarImage = [[UIImage imageWithColor:MAIN_COLOR] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0) resizingMode:UIImageResizingModeStretch];
//    [[UINavigationBar appearance] setBackgroundImage:tabBarImage forBarMetrics:UIBarMetri csDefault];
    [[UINavigationBar appearance] setBarTintColor:MAIN_COLOR];

    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:@[[UINavigationBar class]]]
     setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18]}
     forState:UIControlStateNormal];
    UIFont * titleBarFont = [UIFont systemFontOfSize:19 weight:UIFontWeightSemibold];
    [[UINavigationBar appearance] setTitleTextAttributes:@{
                                                           NSFontAttributeName:titleBarFont,
                                                           NSForegroundColorAttributeName: [UIColor whiteColor],
                                                           }];

    if (launchOptions[UIApplicationLaunchOptionsURLKey]) {
        NSData *file = [NSData dataWithContentsOfURL:launchOptions[UIApplicationLaunchOptionsURLKey]];

        if (file.length > 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:BRFileNotification object:nil
             userInfo:@{@"file":file}];
        }
    }

    // start the event manager
    [[BREventManager sharedEventManager] up];
    [BRCoreDataManager sharedInstance];
    [BRPeerManager sharedInstance];
    [BRWalletManager sharedInstance];
   

    //TODO: bitcoin protocol/payment protocol over multipeer connectivity

    //TODO: accessibility for the visually impaired

    //TODO: fast wallet restore using webservice and/or utxo p2p message

    //TODO: ask user if they need to sweep to a new wallet when restoring because it was compromised

    //TODO: figure out deterministic builds/removing app sigs: http://www.afp548.com/2012/06/05/re-signining-ios-apps/

    //TODO: implement importing of private keys split with shamir's secret sharing:
    //      https://github.com/cetuscetus/btctool/blob/bip/bip-xxxx.mediawiki

    //TODO change
    //[DSShapeshiftManager sharedInstance];
    
    // observe balance and create notifications
    // 注释本地通知
//    [self setupBalanceNotification:application];
    [self setupPreferenceDefaults];

    // 计算为计算的糖果
    [BRSafeUtils AppStartUpCountCandyIsGet];
    
    self.window.backgroundColor = [UIColor whiteColor];
    return YES;
}

- (void)setupBugluy {
    
#ifdef DEBUG
    
#else
    [Bugly startWithAppId:kBuglyAppKey];
#endif
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self reopenApp];
    // 注释本地通知
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        if (self.balance == UINT64_MAX) self.balance = [BRWalletManager sharedInstance].wallet.balance;
//        // TODO: 修改接收金额通知
//        for(BRBalanceModel *balanceModel in [BRWalletManager sharedInstance].wallet.balanceArray) {
//            balanceModel.notificationBalance = balanceModel.balance;
//        }
//        [self registerForPushNotifications];
//    });
}

- (void)reopenApp {
    //获取保存的语言
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"CurrentLanguage"];
    //BRLog(@"language = %@",language);
    //获取当前系统语言
    NSArray *appLanguages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString *languageName = [appLanguages objectAtIndex:0];
    //BRLog(@"languageName = %@",languageName);
    
    if (language.length > 0) {
        if (![language isEqualToString:languageName]) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Message", nil) message:NSLocalizedString(@"You need to restart your App after you change the language.", nil) preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *action = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [UIView animateWithDuration:1.0f animations:^{
                    self.window.alpha = 0;
                    self.window.frame = CGRectMake(0, self.window.bounds.size.width, 0, 0);
                } completion:^(BOOL finished) {
                    [[NSUserDefaults standardUserDefaults] setObject:languageName forKey:@"CurrentLanguage"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    exit(0);
                }];
            }];
            [alert addAction:action];
            [self.window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:languageName forKey:@"CurrentLanguage"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
//    BRAPIClient *client = [BRAPIClient sharedClient];
//    [client.kv sync:^(NSError *err) {
//        BRLog(@"Finished syncing. err=%@", err);
//    }];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
//    [self updatePlatformOnComplete:^{
//        BRLog(@"[BRAppDelegate] updatePlatform completed!");
//    }];
    
    if(_player) {
        [_player stop];
    }
}

// Applications may reject specific types of extensions based on the extension point identifier.
// Constants representing common extension point identifiers are provided further down.
// If unimplemented, the default behavior is to allow the extension point identifier.
- (BOOL)application:(UIApplication *)application
shouldAllowExtensionPointIdentifier:(NSString *)extensionPointIdentifier
{
    return NO; // disable extensions such as custom keyboards for security purposes
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
annotation:(id)annotation
{
    if (! [url.scheme isEqual:@"safe"] && ! [url.scheme isEqual:@"safewallet"]) {
        UIAlertController * alert = [UIAlertController
                                     alertControllerWithTitle:@"Not a safe URL"
                                     message:url.absoluteString
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* okButton = [UIAlertAction
                                       actionWithTitle:NSLocalizedString(@"ok", nil)
                                       style:UIAlertActionStyleCancel
                                       handler:^(UIAlertAction * action) {
                                       }];

        [alert addAction:okButton];
        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert animated:YES completion:nil];
        
        return NO;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC/10), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:BRURLNotification object:nil userInfo:@{@"url":url}];
    });
    
    return YES;
}

- (void)application:(UIApplication *)application
performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    __block id protectedObserver = nil, syncFinishedObserver = nil, syncFailedObserver = nil;
    __block void (^completion)(UIBackgroundFetchResult) = completionHandler;
    void (^cleanup)(void) = ^() {
        completion = nil;
        if (protectedObserver) [[NSNotificationCenter defaultCenter] removeObserver:protectedObserver];
        if (syncFinishedObserver) [[NSNotificationCenter defaultCenter] removeObserver:syncFinishedObserver];
        if (syncFailedObserver) [[NSNotificationCenter defaultCenter] removeObserver:syncFailedObserver];
        protectedObserver = syncFinishedObserver = syncFailedObserver = nil;
    };

    if ([BRPeerManager sharedInstance].syncProgress >= 1.0) {
        //BRLog(@"background fetch already synced");
        if (completion) completion(UIBackgroundFetchResultNoData);
        return;
    }

    // timeout after 25 seconds
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 25*NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (completion) {
            //BRLog(@"background fetch timeout with progress: %f", [BRPeerManager sharedInstance].syncProgress);
            completion(([BRPeerManager sharedInstance].syncProgress > 0.1) ? UIBackgroundFetchResultNewData :
                       UIBackgroundFetchResultFailed);
            cleanup();
        }
        //TODO: disconnect
    });

    protectedObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationProtectedDataDidBecomeAvailable object:nil
        queue:nil usingBlock:^(NSNotification *note) {
            //BRLog(@"background fetch protected data available");
            [[BRPeerManager sharedInstance] connect];
        }];

    syncFinishedObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncFinishedNotification object:nil
        queue:nil usingBlock:^(NSNotification *note) {
            //BRLog(@"background fetch sync finished");
            if (completion) completion(UIBackgroundFetchResultNewData);
            cleanup();
        }];

    syncFailedObserver =
        [[NSNotificationCenter defaultCenter] addObserverForName:BRPeerManagerSyncFailedNotification object:nil
        queue:nil usingBlock:^(NSNotification *note) {
            //BRLog(@"background fetch sync failed");
            if (completion) completion(UIBackgroundFetchResultFailed);
            cleanup();
        }];

    //BRLog(@"background fetch starting");
    [[BRPeerManager sharedInstance] connect];

    // sync events to the server
    [[BREventManager sharedEventManager] sync];
    
//    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"has_alerted_buy_dash"] == NO &&
//        [WKWebView class] && [[BRAPIClient sharedClient] featureEnabled:BRFeatureFlagsBuyDash] &&
//        [UIApplication sharedApplication].applicationIconBadgeNumber == 0) {
//        [UIApplication sharedApplication].applicationIconBadgeNumber = 1;
//    }
}

- (void)setupBalanceNotification:(UIApplication *)application
{
//    BRWalletManager *manager = [BRWalletManager sharedInstance];
//
//    self.balance = UINT64_MAX; // this gets set in applicationDidBecomActive:
//
//    self.balanceObserver =
//        [[NSNotificationCenter defaultCenter] addObserverForName:BRWalletBalanceChangedNotification object:nil queue:nil
//        usingBlock:^(NSNotification * _Nonnull note) {
//            // TODO: 修改收到金额通知
//            for(int i=[BRWalletManager sharedInstance].wallet.balanceArray.count-1; i>=0; i--) {
//                BRBalanceModel *balanceModel = [BRWalletManager sharedInstance].wallet.balanceArray[i];
//                if(balanceModel.notificationBalance < balanceModel.balance) {
//                    BOOL send = [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_LOCAL_NOTIFICATIONS_KEY];
//                    //                NSString *noteText = [NSString stringWithFormat:NSLocalizedString(@"received %@ (%@)", nil),
//                    //                                      [manager stringForDashAmount:manager.wallet.balance - self.balance],
//                    //                                      [manager localCurrencyStringForDashAmount:manager.wallet.balance - self.balance]];
//
//                    NSString *noteText;
//                    if(balanceModel.assetId.length == 0) {
//                        noteText = [NSString stringWithFormat:NSLocalizedString(@"received %@", nil),
//                                          [manager stringForDashAmount:balanceModel.balance - balanceModel.notificationBalance]];
//                    } else {
//                        noteText = [NSString stringWithFormat:NSLocalizedString(@"received %@", nil),
//                                    [BRSafeUtils amountForAssetAmount:balanceModel.balance - balanceModel.notificationBalance decimals: balanceModel.multiple name:balanceModel.nameString]];
//                    }
//
//                    //BRLog(@"local notifications enabled=%d", send);
//
//                    // send a local notification if in the background
////                    if (application.applicationState == UIApplicationStateBackground ||
////                        application.applicationState == UIApplicationStateInactive) {
//
//                        if (send) {
//                            UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
//                            [application registerUserNotificationSettings:settings];
//
//                            UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//                            content.body = noteText;
//                            content.sound = [UNNotificationSound soundNamed:@"coinflip"];
//
//                            // 4. update application icon badge number
//                            content.badge = [NSNumber numberWithInteger:([UIApplication sharedApplication].applicationIconBadgeNumber + 1)];
//                            // Deliver the notification in five seconds.
//                            UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
//                                                                          triggerWithTimeInterval:1.0f
//                                                                          repeats:NO];
//                            UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Now"
//                                                                                                  content:content
//                                                                                                  trigger:trigger];
//                            /// 3. schedule localNotification
//                            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//                            [center requestAuthorizationWithOptions:(UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert) completionHandler:^(BOOL granted, NSError * _Nullable error) {
//
//                            }];
//
//                            [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//                                if (!error) {
//                                    BRLog(@"收到通知");
//                                }
//                            }];
//                        }
////                    }
//                    balanceModel.notificationBalance = balanceModel.balance;
//                    break;
//                }
//            }
//            if (self.balance < manager.wallet.balance) {
//                BOOL send = [[NSUserDefaults standardUserDefaults] boolForKey:USER_DEFAULTS_LOCAL_NOTIFICATIONS_KEY];
////                NSString *noteText = [NSString stringWithFormat:NSLocalizedString(@"received %@ (%@)", nil),
////                                      [manager stringForDashAmount:manager.wallet.balance - self.balance],
////                                      [manager localCurrencyStringForDashAmount:manager.wallet.balance - self.balance]];
//
//                NSString *noteText = [NSString stringWithFormat:NSLocalizedString(@"received %@", nil),
//                                      [manager stringForDashAmount:manager.wallet.balance - self.balance]];
//
//                //BRLog(@"local notifications enabled=%d", send);
//
//                // send a local notification if in the background
//                if (application.applicationState == UIApplicationStateBackground ||
//                    application.applicationState == UIApplicationStateInactive) {
//
//                    if (send) {
//                        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
//                        content.body = noteText;
//                        content.sound = [UNNotificationSound soundNamed:@"coinflip"];
//
//                        // 4. update application icon badge number
//                        content.badge = [NSNumber numberWithInteger:([UIApplication sharedApplication].applicationIconBadgeNumber + 1)];
//                        // Deliver the notification in five seconds.
//                        UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger
//                                                                      triggerWithTimeInterval:1.0f
//                                                                      repeats:NO];
//                        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"Now"
//                                                                                              content:content
//                                                                                              trigger:trigger];
//                        /// 3. schedule localNotification
//                        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
//                        [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
//                            if (!error) {
//                                //BRLog(@"sent local notification %@", note);
//                            }
//                        }];
//                    }
//                }
//
//            }
//
//            self.balance = manager.wallet.balance;
//        }];
} 

- (void)setupPreferenceDefaults {
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    // 保存App版本号
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    BRLog(@"%@", appCurVersionNum);
    BRLog(@"%@", [defs valueForKey:SAFE_APP_VERSION]);
    [defs setValue:appCurVersionNum forKey:SAFE_APP_VERSION];
    
    // turn on local notifications by default
    if (! [defs boolForKey:USER_DEFAULTS_LOCAL_NOTIFICATIONS_SWITCH_KEY]) {
        //BRLog(@"enabling local notifications by default");
        [defs setBool:true forKey:USER_DEFAULTS_LOCAL_NOTIFICATIONS_SWITCH_KEY];
        [defs setBool:true forKey:USER_DEFAULTS_LOCAL_NOTIFICATIONS_KEY];
    }
}

- (void)registerForPushNotifications {
//    BOOL hasNotification = [UNNotificationSettings class] != nil;
//    NSString *userDefaultsKey = @"has_asked_for_push";
//    BOOL hasAskedForPushNotification = [[NSUserDefaults standardUserDefaults] boolForKey:userDefaultsKey];
//
//    if (hasAskedForPushNotification && hasNotification) {
//        UNAuthorizationOptions options = (UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert);
//        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error) {
//
//        }];
//    }
}


- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)(void))completionHandler
{
    //BRLog(@"Handle events for background url session; identifier=%@", identifier);
}

- (void)dealloc
{
    
    if (self.balanceObserver) [[NSNotificationCenter defaultCenter] removeObserver:self.balanceObserver];
}

//-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
//
//    completionHandler(UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionSound);
//
//}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [self startBgTask];
    /** 播放声音 */
    [self.player play];
}

- (AVAudioPlayer *)player{
    if (!_player){
        NSURL *url=[[NSBundle mainBundle]URLForResource:@"coinflip.aiff" withExtension:nil];
        _player = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        [_player prepareToPlay];
        //一直循环播放
        _player.numberOfLoops = -1;
        _player.volume = 0;
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayback error:nil];
        
        [session setActive:YES error:nil];
    }
    return _player;
}


- (void)startBgTask{
    UIApplication *application = [UIApplication sharedApplication];
    __block    UIBackgroundTaskIdentifier bgTask;
    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
        //这里延迟的系统时间结束
        [application endBackgroundTask:bgTask];
        BRLog(@"%f",application.backgroundTimeRemaining);
    }];
    
}


@end
