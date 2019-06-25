//
//  BRForumViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/20.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRForumViewController.h"
#import <WebKit/WebKit.h>
#import "MBProgressHUD.h"

@interface BRForumViewController ()<WKNavigationDelegate>

@property (nonatomic,strong) UIView *bvgView;

@property (nonatomic, strong) UIView *statusBar;

@end

@implementation BRForumViewController

- (UIView *)statusBar {
    if (!_statusBar) {
        _statusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
        _statusBar.backgroundColor = [UIColor whiteColor];//ColorFromRGB255(41, 93, 144);
    }
    return _statusBar;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
//    self.navigationController.navigationBar.hidden = YES;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationItem.title = NSLocalizedString(@"Forum", nil);
    [self creatFailUI];
    [self initWebView];
    [self.view addSubview:self.statusBar];
    [self.view bringSubviewToFront:self.statusBar];
    
}

- (void)initWebView {
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_HEIGHT - 49 - 20)];
    webView.navigationDelegate = self;
    [webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://anwang.org"]]];
    [self.view addSubview:webView];
}

- (void)creatFailUI {
    
    CGFloat width = 300;
    CGFloat height = 200;
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    bgView.hidden = YES;
    bgView.center = self.view.center;
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.layer.cornerRadius = 10.f;
    bgView.layer.shadowRadius = 4.f;
    bgView.layer.shadowColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.8f].CGColor;
    bgView.layer.shadowOffset = CGSizeMake(4, 4);
    bgView.layer.shadowOpacity = 0.6f;
    [self.view addSubview:bgView];
    self.bvgView = bgView;
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, width - 40, 20)];
    lable.text = NSLocalizedString(@"Message", nil);
    lable.textColor = ColorFromRGB(0x555555);
    lable.font = [UIFont systemFontOfSize:17.f];
    lable.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:lable];
    
    UILabel *messageLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, width - 40, 60)];
    messageLable.numberOfLines = 0;
    messageLable.text = NSLocalizedString(@"Error loading content, please check your network Settings and reload.", nil);
    messageLable.textColor = [UIColor blackColor];
    messageLable.font = [UIFont systemFontOfSize:17.f];
    messageLable.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:messageLable];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake((width - 120) * 0.5, 140, 120, 40);
    [button setTitle:NSLocalizedString(@"Reload", nil) forState:UIControlStateNormal];
    [button setTitleColor:ColorFromRGB(0x333333) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15.f];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    button.layer.borderWidth = 1.f;
    button.layer.borderColor = ColorFromRGB(0x999999).CGColor;
    button.layer.cornerRadius = 6.f;
    [bgView addSubview:button];
    [button addTarget:self action:@selector(loadAgain) forControlEvents:UIControlEventTouchUpInside];
}

- (void)loadAgain {
    self.bvgView.hidden = YES;
    [self initWebView];
}

#pragma mark - WKNavigationDelegate
// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
}

// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation{
   
}

// 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    self.bvgView.hidden = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
