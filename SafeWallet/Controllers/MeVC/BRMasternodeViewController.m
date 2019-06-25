//
//  BRMasternodeViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/27.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRMasternodeViewController.h"
#import <WebKit/WebKit.h>
#import "BRMasternodeCell.h"
#import "BRWKDelegateController.h"
#import "BRMasternodeEntiy+CoreDataProperties.h"
#import "BRMasternodeModel.h"
#import "BRCoreDataManager.h"
#import "MBProgressHUD.h"

//#define MASTERNODE_URL @"http://10.0.0.76/masterNodeApp" //@"http://testchain.anwang.com:8081/masterNodeApp" //  @"http://10.0.0.75/masterNodeApp"
#if SAFEWallet_TESTNET // 测试
#define MASTERNODE_URL @"http://106.12.144.124/masterNodeApp"
#else // 正式
#define MASTERNODE_URL @"http://chain.anwang.com/masterNodeApp"
#endif


//@interface BRMasternodeViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>
//
//@property (nonatomic,strong) UITableView *masternodeTableView;
//@property (nonatomic,strong) UILabel *showLable;
//@property (nonatomic,strong) UIView *alertView;
//@property (nonatomic,strong) UIView *detailMessageView;
//@property (nonatomic,strong) UIVisualEffectView *effectView;
//
//@end

@interface BRMasternodeViewController () <WKDelegate, WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic,strong) WKWebView *wkWebView;

@property (nonatomic,strong) WKUserContentController *userContentController;

@end

@implementation BRMasternodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"Masternode",nil);
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@""
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(returnClick)];
    [self creatUI];
//    [self initUI];
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveUpView:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backupView:) name:UIKeyboardWillHideNotification object:nil];
}

- (void) returnClick {
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) creatUI {
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];
    configuration.preferences = [[WKPreferences alloc] init];
    configuration.preferences.minimumFontSize = 10;
    configuration.preferences.javaScriptEnabled = YES;
    configuration.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    configuration.processPool = [[WKProcessPool alloc] init];
    
    self.userContentController = [[WKUserContentController alloc]init];
    configuration.userContentController = self.userContentController;
    
    self.wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds
                                        configuration:configuration];

    BRWKDelegateController * delegateController = [[BRWKDelegateController alloc]init];
    delegateController.delegate = self;
    self.wkWebView.UIDelegate = self;
    self.wkWebView.navigationDelegate = self;
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:MASTERNODE_URL]]];
    [self.view addSubview:self.wkWebView];
   
    
    //注册方法
    
    [self.userContentController addScriptMessageHandler:delegateController  name:@"iosDeleteFollowMasterNode"];
    [self.userContentController addScriptMessageHandler:delegateController  name:@"iosAddFollowMasterNode"];
    
    [self.userContentController addScriptMessageHandler:delegateController  name:@"iosInit"];
    
    
    
//    [self iOSCallJs];
}

- (void)dealloc{
    //这里需要注意，前面增加过的方法一定要remove掉。
    [self.userContentController removeScriptMessageHandlerForName:@"iosDeleteFollowMasterNode"];
    [self.userContentController removeScriptMessageHandlerForName:@"iosAddFollowMasterNode"];
    
    [self.userContentController removeScriptMessageHandlerForName:@"iosInit"];
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
//    BRLog(@"加载完成");
//    BRMasternodeModel *masternodeModel = [[BRMasternodeModel alloc] init];
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:masternodeModel.toDictionary options:0 error:nil];
//    NSString *json =  [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
//    NSString *jsStr = [NSString stringWithFormat:@"getIosFoloowMasterNodeList('%@')", json];
//    [self.wkWebView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//        //此处可以打印error.
////        BRLog(@"234232342343423423432adsadasd=========%@", error);
//    }];
}


- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
//    BRLog(@"messssssss  %@", message);
//    [AppTool showMessage:message showView:nil];
    completionHandler();
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    BRLog(@"name:%@\\\\n body:%@\\\\n frameInfo:%@\\\\n",message.name,message.body,message.frameInfo);
    NSData *data = [[NSString stringWithFormat:@"%@", message.body] dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    if([message.name isEqualToString:@"iosDeleteFollowMasterNode"]) {
        BRMasternodeModel *masternodeModel = [[BRMasternodeModel alloc] init];
        masternodeModel.ip = [dict objectForKey:@"ip"];
        masternodeModel.address = [dict objectForKey:@"address"];
        masternodeModel.status = [dict objectForKey:@"status"];
        
        NSArray *masternodeArray = [NSArray arrayWithArray:[[BRCoreDataManager sharedInstance] entity:@"BRMasternodeEntiy" objectsMatching:[NSPredicate predicateWithFormat:@"ip = %@", masternodeModel.ip]]];
        [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlock:^{
            [[BRCoreDataManager sharedInstance] deleteEntity:masternodeArray];
        }];
    } else if ([message.name isEqualToString:@"iosAddFollowMasterNode"]) {
        BRMasternodeModel *masternodeModel = [[BRMasternodeModel alloc] init];
        masternodeModel.ip = [dict objectForKey:@"ip"];
        masternodeModel.address = [dict objectForKey:@"address"];
        masternodeModel.status = [dict objectForKey:@"status"];
        [[BRCoreDataManager sharedInstance].contextForCurrentThread performBlock:^{
            BRMasternodeEntiy *masternodeEntity = (BRMasternodeEntiy *)[[BRCoreDataManager sharedInstance] createEntityNamedWith:@"BRMasternodeEntiy"];
            [masternodeEntity setAttributesFromMasternodeModel:masternodeModel];
        }];
    } else if ([message.name isEqualToString:@"iosInit"]) {
        BRMasternodeModel *masternodeModel = [[BRMasternodeModel alloc] init];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:masternodeModel.toDictionary options:0 error:nil];
        NSString *json =  [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *jsStr = [NSString stringWithFormat:@"getIosFoloowMasterNodeList('%@')", json];
        [self.wkWebView evaluateJavaScript:jsStr completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            //此处可以打印error.
//            BRLog(@"234232342343423423432adsadasd=========%@", error);
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self deleteWebCache];
}

- (void)deleteWebCache {
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 9.0) {
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        }];
    } else {
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
        NSError *errors;
        [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
    }
}

//
//- (void)initUI {
//
//    UILabel *messageLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 50 + SafeAreaViewHeight, SCREEN_WIDTH, 40)];
//    messageLable.text = NSLocalizedString(@"Please add monitoring masternode IP",nil);
//    messageLable.textColor = [UIColor blackColor];
//    messageLable.font = [UIFont systemFontOfSize:17.f];
//    messageLable.textAlignment = NSTextAlignmentCenter;
//    [self.view addSubview:messageLable];
//    self.showLable = messageLable;
//    
//    [self creatTableView];
//    
//    CGFloat width = 60;
//    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    addButton.frame = CGRectMake(SCREEN_WIDTH - 20 - width, SCREEN_HEIGHT - SafeAreaBottomHeight - 20 - width, width, width);
//    //[addButton setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//    [addButton setTitle:@"+" forState:UIControlStateNormal];
//    [addButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    addButton.titleLabel.font = [UIFont systemFontOfSize:50.f weight:UIFontWeightRegular];
//    [addButton setTitleEdgeInsets:UIEdgeInsetsMake(-3, 0, 0, 0)];
//    addButton.backgroundColor = MAIN_COLOR;
//    addButton.layer.cornerRadius = width * 0.5;
//    addButton.layer.shadowColor = [UIColor blackColor].CGColor;
//    addButton.layer.shadowOffset = CGSizeMake(0, 0);
//    addButton.layer.shadowRadius = width * 0.5;
//    addButton.layer.shadowOpacity = 0.5f;
//    [self.view addSubview:addButton];
//    [addButton addTarget:self action:@selector(showAlertView) forControlEvents:UIControlEventTouchUpInside];
//
//    //模糊背景
//    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
//    effectView.hidden = YES;
//    effectView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height);
//    effectView.alpha = 0.9f;
//    [self.view addSubview:effectView];
//    self.effectView = effectView;
//    
//    [self creatAlertView];
//    [self creatDetailView];
//}
//
//- (void)creatTableView {
//    
//    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height - SafeAreaBottomHeight) style:UITableViewStyleGrouped];
//    tableView.backgroundColor = [UIColor whiteColor];
//    tableView.delegate = self;
//    tableView.dataSource = self;
//    tableView.showsVerticalScrollIndicator = NO;
//    tableView.estimatedSectionHeaderHeight = 0;
//    tableView.estimatedSectionFooterHeight = 0;
//    tableView.estimatedRowHeight = 0;
//    tableView.hidden = YES;
//    tableView.separatorStyle = NO;
//    [self.view addSubview:tableView];
//    self.masternodeTableView = tableView;
//}
//
//- (void)creatAlertView {
//
//    CGFloat margin = 30;
//    CGFloat height = 130;
//    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(margin, 0, SCREEN_WIDTH - margin * 2, height)];
//    alertView.backgroundColor = [UIColor whiteColor];
//    alertView.center = self.view.center;
//    alertView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.4f].CGColor;
//    alertView.layer.borderWidth = 1.f;
//    alertView.layer.cornerRadius = 6.f;
//    alertView.clipsToBounds = YES;
//    alertView.hidden = YES;
//    [self.view addSubview:alertView];
//    self.alertView = alertView;
//
//    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 80, 30)];
//    lable.text = NSLocalizedString(@"Masternode IP",nil);
//    lable.textColor = ColorFromRGB(0x666666);
//    lable.font = [UIFont systemFontOfSize:15.f];
//    lable.textAlignment = NSTextAlignmentRight;
//    [alertView addSubview:lable];
//    
//    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(CGRectGetMaxX(lable.frame) + 10, 30, CGRectGetWidth(alertView.frame) - (CGRectGetMaxX(lable.frame) + 10) - 20, 30)];
//    textField.textAlignment = NSTextAlignmentLeft;
//    textField.textColor = [UIColor blackColor];
//    textField.delegate = self;
//    textField.font = [UIFont systemFontOfSize:15.f];
//    //textField.keyboardType = UIKeyboardTypeDecimalPad;
//    textField.returnKeyType = UIReturnKeyDone;
//    textField.layer.borderWidth = 1.f;
//    textField.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.4f].CGColor;
//    [alertView addSubview:textField];
//
//    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    cancelButton.frame = CGRectMake(0, 90, CGRectGetWidth(alertView.frame) * 0.5, 40);
//    cancelButton.backgroundColor = ColorFromRGB(0xf0f0f0);
//    [cancelButton setTitle:NSLocalizedString(@"Cancle",nil) forState:UIControlStateNormal];
//    [cancelButton setTitleColor:ColorFromRGB(0x555555) forState:UIControlStateNormal];
//    cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
//    cancelButton.layer.borderWidth = 1.f;
//    cancelButton.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.4f].CGColor;
//    [alertView addSubview:cancelButton];
//    [cancelButton addTarget:self action:@selector(hideAlertView) forControlEvents:UIControlEventTouchUpInside];
//
//    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    sureButton.frame = CGRectMake(CGRectGetWidth(alertView.frame) * 0.5, 90, CGRectGetWidth(alertView.frame) * 0.5, 40);
//    sureButton.backgroundColor = MAIN_COLOR;
//    [sureButton setTitle:NSLocalizedString(@"Confirm",nil) forState:UIControlStateNormal];
//    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    sureButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
//    [alertView addSubview:sureButton];
//    [sureButton addTarget:self action:@selector(showMasternode) forControlEvents:UIControlEventTouchUpInside];
//}
//
//- (void)creatDetailView {
//
//    UIView *detailView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, SCREEN_WIDTH - 40, 270)];
//    detailView.center = self.view.center;
//    detailView.hidden = YES;
//    detailView.backgroundColor = [UIColor whiteColor];
//    detailView.layer.cornerRadius = 6.f;
//    detailView.clipsToBounds = YES;
//    [self.view addSubview:detailView];
//    self.detailMessageView = detailView;
//
//    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetWidth(detailView.frame) - 30, 10, 20, 16)];
//    imageView.image = [UIImage imageNamed:@"x"];
//    [detailView addSubview:imageView];
//    
//    UIButton *hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    hideButton.frame = CGRectMake(CGRectGetWidth(detailView.frame) - 50, 10, 40, 40);
//    hideButton.backgroundColor = [UIColor clearColor];
//    [detailView addSubview:hideButton];
//    [hideButton addTarget:self action:@selector(hideDetailMessageView) forControlEvents:UIControlEventTouchUpInside];
//
//    CGFloat width = (SCREEN_WIDTH - 40) * 0.5;
//    UILabel *aliasLable = [self lableWithText:NSLocalizedString(@"Alias:",nil)];
//    UILabel *addressLable = [self lableWithText:NSLocalizedString(@"Address:",nil)];
//    UILabel *protocolLable = [self lableWithText:NSLocalizedString(@"Protocol:",nil)];
//    UILabel *statusLable = [self lableWithText:NSLocalizedString(@"Status:",nil)];
//    UILabel *activeLable = [self lableWithText:NSLocalizedString(@"Active:",nil)];
//    UILabel *payeeLable = [self lableWithText:NSLocalizedString(@"Payee:",nil)];
//    UILabel *lastTimeLable = [self lableWithText:NSLocalizedString(@"Last online time:",nil)];
//
//    UILabel *rightAliasLable = [self rightLableWithText:@"SAFE"];
//    UILabel *rightAddressLable = [self rightLableWithText:@"108.192.355.512"];
//    UILabel *rightProtocolLable = [self rightLableWithText:@"TCP"];
//    UILabel *rightStatusLable = [self rightLableWithText:@"未激活"];
//    UILabel *rightActiveLable = [self rightLableWithText:@"激活"];
//    UILabel *rightPayeeLable = [self rightLableWithText:@"XXX"];
//    UILabel *rightLastTimeLable = [self rightLableWithText:@"2018/03/28 10:40"];
//
//    aliasLable.frame = CGRectMake(0, 30, width, 20);
//    addressLable.frame = CGRectMake(0, CGRectGetMaxY(aliasLable.frame) + 5, width, 20);
//    protocolLable.frame = CGRectMake(0, CGRectGetMaxY(addressLable.frame) + 5, width, 20);
//    statusLable.frame = CGRectMake(0, CGRectGetMaxY(protocolLable.frame) + 5, width, 20);
//    activeLable.frame = CGRectMake(0, CGRectGetMaxY(statusLable.frame) + 5, width, 20);
//    payeeLable.frame = CGRectMake(0, CGRectGetMaxY(activeLable.frame) + 5, width, 20);
//    lastTimeLable.frame = CGRectMake(0, CGRectGetMaxY(payeeLable.frame) + 5, width, 20);
//
//    rightAliasLable.frame = CGRectMake(width, 30, width - 10, 20);
//    rightAddressLable.frame = CGRectMake(width, CGRectGetMaxY(rightAliasLable.frame) + 5, width - 10, 20);
//    rightProtocolLable.frame = CGRectMake(width, CGRectGetMaxY(rightAddressLable.frame) + 5, width - 10, 20);
//    rightStatusLable.frame = CGRectMake(width, CGRectGetMaxY(rightProtocolLable.frame) + 5, width - 10, 20);
//    rightActiveLable.frame = CGRectMake(width, CGRectGetMaxY(rightStatusLable.frame) + 5, width - 10, 20);
//    rightPayeeLable.frame = CGRectMake(width, CGRectGetMaxY(rightActiveLable.frame) + 5, width - 10, 20);
//    rightLastTimeLable.frame = CGRectMake(width, CGRectGetMaxY(rightPayeeLable.frame) + 5, width - 10, 20);
//
//    [detailView addSubview:aliasLable];
//    [detailView addSubview:addressLable];
//    [detailView addSubview:protocolLable];
//    [detailView addSubview:statusLable];
//    [detailView addSubview:activeLable];
//    [detailView addSubview:payeeLable];
//    [detailView addSubview:lastTimeLable];
//
//    [detailView addSubview:rightAliasLable];
//    [detailView addSubview:rightAddressLable];
//    [detailView addSubview:rightProtocolLable];
//    [detailView addSubview:rightStatusLable];
//    [detailView addSubview:rightActiveLable];
//    [detailView addSubview:rightPayeeLable];
//    [detailView addSubview:rightLastTimeLable];
//
//    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//    button.backgroundColor = MAIN_COLOR;
//    button.frame = CGRectMake(0, CGRectGetHeight(detailView.frame) - 40, CGRectGetWidth(detailView.frame), 40);
//    [button setTitle:NSLocalizedString(@"Close",nil) forState:UIControlStateNormal];
//    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    button.titleLabel.font = [UIFont systemFontOfSize:15.f];
//    [detailView addSubview:button];
//    [button addTarget:self action:@selector(hideDetailMessageView) forControlEvents:UIControlEventTouchUpInside];
//}
//
//- (UILabel *)lableWithText:(NSString *)string {
//
//    UILabel *lable = [[UILabel alloc] init];
//    lable.backgroundColor = [UIColor clearColor];
//    lable.text = string;
//    lable.textColor = ColorFromRGB(0x555555);
//    lable.font = [UIFont systemFontOfSize:15.f];
//    lable.textAlignment = NSTextAlignmentRight;
//    return lable;
//}
//
//- (UILabel *)rightLableWithText:(NSString *)string {
//
//    UILabel *lable = [[UILabel alloc] init];
//    lable.backgroundColor = [UIColor clearColor];
//    lable.text = string;
//    lable.textColor = ColorFromRGB(0x555555);
//    lable.font = [UIFont systemFontOfSize:15.f];
//    return lable;
//}
//
//#pragma mark -- MARK:添加按钮点击事件
//- (void)showAlertView {
//    
//    if (self.alertView.hidden == YES) {
//        self.effectView.hidden = NO;
//        self.alertView.hidden = NO;
//        self.alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity,CGFLOAT_MIN, CGFLOAT_MIN);
//        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:8.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//            self.alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
//        } completion:^(BOOL finished) {
//            self.alertView.transform = CGAffineTransformIdentity;
//        }];
//    }
//}
//
//#pragma mark -- MARK:取消按钮点击事件
//- (void)hideAlertView {
//    
//    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        self.alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
//    } completion:^(BOOL finished) {
//
//        [UIView animateWithDuration:0.3
//                         animations:^{
//                             self.alertView.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.001, 0.001);
//                         }
//                         completion:^(BOOL finished) {
//                             self.alertView.hidden = YES;
//                             [self.view endEditing:YES];
//                             self.effectView.hidden = YES;
//        }];
//    }];
//}
//
//#pragma mark -- MARK:确认按钮点击事件
//- (void)showMasternode {
//    [self hideAlertView];
//    self.showLable.hidden = YES;
//    self.masternodeTableView.hidden = NO;
//}
//
//- (void)showDetailMessageView:(UIButton *)sender {
//
//    if (self.detailMessageView.hidden == YES) {
//        self.effectView.hidden = NO;
//        self.detailMessageView.hidden = NO;
//        self.detailMessageView.transform = CGAffineTransformScale(CGAffineTransformIdentity,CGFLOAT_MIN, CGFLOAT_MIN);
//        [UIView animateWithDuration:0.8 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:8.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//            self.detailMessageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
//        } completion:^(BOOL finished) {
//            self.detailMessageView.transform = CGAffineTransformIdentity;
//        }];
//    }
//    
//}
//
//- (void)hideDetailMessageView {
//
//    [UIView animateWithDuration:1.0 delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        self.detailMessageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
//    } completion:^(BOOL finished) {
//
//        [UIView animateWithDuration:0.3
//                         animations:^{
//                             self.detailMessageView.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.001, 0.001);
//                         }
//                         completion:^(BOOL finished) {
//                             self.detailMessageView.hidden = YES;
//                             [self.view endEditing:YES];
//                             self.effectView.hidden = YES;
//                         }];
//    }];
//}
//
//#pragma mark -- MARK:键盘弹出通知
//- (void)moveUpView:(NSNotification *)notification {
//
//    CGFloat keyboardHeight = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
//    CGFloat halfHeight = self.view.frame.size.height * 0.5;
//    CGFloat hideHeight = 0.f;
//    if (keyboardHeight > halfHeight) {
//        hideHeight = keyboardHeight - halfHeight + CGRectGetHeight(self.alertView.frame) * 0.5;
//    } else {
//        if (keyboardHeight > halfHeight - CGRectGetHeight(self.alertView.frame) * 0.5) {
//            hideHeight = halfHeight - keyboardHeight;
//        }
//    }
//
//    if (hideHeight > 0) {
//        [UIView animateWithDuration:0.4f animations:^{
//
//            self.view.frame = CGRectMake(0, - hideHeight - 12, SCREEN_WIDTH, SCREEN_HEIGHT - SafeAreaViewHeight - SafeAreaBottomHeight);
//            [self.view layoutIfNeeded];
//        }];
//    }
//}
//
//#pragma mark -- MARK:键盘退出通知
//- (void)backupView:(NSNotification *)notification {
//
//    [UIView animateWithDuration:0.4f animations:^{
//
//        self.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - SafeAreaBottomHeight);
//        [self.view layoutIfNeeded];
//    }];
//}
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 5;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 1;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    static NSString *identifier = @"BRMasternodeCell";
//    BRMasternodeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
//    if (cell == nil) {
//        cell = [[BRMasternodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
//    }
//    [cell.aliasButton addTarget:self action:@selector(showDetailMessageView:) forControlEvents:UIControlEventTouchUpInside];
//    return cell;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 115;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    return 20;
//}
//
//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    NSInteger count = tableView.numberOfSections;
//    if (section == count - 1) {
//        return 90;
//    } else {
//        return 0.0001;
//    }
//}
//
//#pragma mark -- MARK:UITextfieldDelegate
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//    if ([string isEqualToString:@"\n"]){
//        [textField resignFirstResponder];
//        return NO;
//    }
//    return YES;
//}
//
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
//    [self.view endEditing:YES];
//}
//
//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
//}
//
//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

@end
