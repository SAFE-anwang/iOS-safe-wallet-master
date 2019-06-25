//
//  BRTxWebViewController.m
//  dashwallet
//
//  Created by joker on 2018/7/19.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRTxWebViewController.h"
#import <WebKit/WebKit.h>

@interface BRTxWebViewController ()

@property (nonatomic, strong) WKWebView *webView;


@end

@implementation BRTxWebViewController

- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:[WKWebViewConfiguration new]];
    }
    return _webView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setup];
    [self loadData];
}

- (void)loadData {
    NSURL *url = [NSURL URLWithString:self.urlString];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [self.webView loadRequest:req];
}

- (void)setup {
    [self.view addSubview:self.webView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.toolbarHidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.toolbarHidden = YES;
}

@end
