//
//  BRAboutViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/8/2.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRAboutViewController.h"

@interface BRAboutViewController ()

@property (nonatomic,strong) UILabel *versionLabel;

@property (nonatomic,strong) UILabel *versionDetailsLabel;

@property (nonatomic,strong) UIView *versionLine;

@property (nonatomic,strong) UILabel *webLabel;

@property (nonatomic,strong) UILabel *webDetailsLabel;

@property (nonatomic,strong) UIView *webLine;

@property (nonatomic,strong) UILabel *copyrightLabel;

@property (nonatomic,strong) UILabel *copyrightDetailsLabel;

@property (nonatomic,strong) UIView *copyrightLine;

@property (nonatomic,strong) UIButton *loadWebBtn;


@end

@implementation BRAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"About us", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self initUI];
}

- (void) initUI {
    self.versionLabel = [[UILabel alloc] init];
    self.versionLabel.text = NSLocalizedString(@"Version", nil);
    self.versionLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    self.versionLabel.textColor = [UIColor blackColor];
    [self.view addSubview:self.versionLabel];
    [self.versionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20 + SafeAreaViewHeight);
        make.left.equalTo(self.view.mas_left).offset(12);
        make.right.equalTo(self.view.mas_right).offset(-12);
        make.height.equalTo(@(20));
    }];
    
    self.versionDetailsLabel = [[UILabel alloc] init];
    self.versionDetailsLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    self.versionDetailsLabel.font = [UIFont systemFontOfSize:14];
    self.versionDetailsLabel.textColor = ColorFromRGB(0x999999);
    [self.view addSubview:self.versionDetailsLabel];
    [self.versionDetailsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.versionLabel.mas_bottom).offset(6);
        make.left.equalTo(self.view.mas_left).offset(12);
        make.right.equalTo(self.view.mas_right).offset(-12);
        make.height.equalTo(@(16));
    }];

    self.versionLine = [[UIView alloc] init];
    self.versionLine.backgroundColor = ColorFromRGB255(218, 218, 218);
    [self.view addSubview:self.versionLine];
    [self.versionLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.versionDetailsLabel.mas_bottom).offset(12);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@(1));
    }];
    
    self.webLabel = [[UILabel alloc] init];
    self.webLabel.text = NSLocalizedString(@"SAFE official website", nil);
    self.webLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    self.webLabel.textColor = [UIColor blackColor];
    [self.view addSubview:self.webLabel];
    [self.webLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.versionLine.mas_top).offset(16);
        make.left.equalTo(self.view.mas_left).offset(12);
        make.right.equalTo(self.view.mas_right).offset(-12);
        make.height.equalTo(@(20));
    }];
    
    self.webDetailsLabel = [[UILabel alloc] init];
    self.webDetailsLabel.text = @"https://www.anwang.com";
    self.webDetailsLabel.font = [UIFont systemFontOfSize:14];
    self.webDetailsLabel.textColor = ColorFromRGB(0x999999);
    [self.view addSubview:self.webDetailsLabel];
    [self.webDetailsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.webLabel.mas_bottom).offset(6);
        make.left.equalTo(self.view.mas_left).offset(12);
        make.right.equalTo(self.view.mas_right).offset(-12);
        make.height.equalTo(@(16));
    }];
    
    self.webLine = [[UIView alloc] init];
    self.webLine.backgroundColor = ColorFromRGB255(218, 218, 218);
    [self.view addSubview:self.webLine];
    [self.webLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.webDetailsLabel.mas_bottom).offset(12);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@(1));
    }];
    
    self.loadWebBtn = [[UIButton alloc] init];
    [self.view addSubview:self.loadWebBtn];
    [self.loadWebBtn addTarget:self action:@selector(loadWebClick) forControlEvents:UIControlEventTouchUpInside];
    [self.loadWebBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.versionLine.mas_bottom);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.webLine.mas_top);
    }];
    
    self.copyrightLabel = [[UILabel alloc] init];
    self.copyrightLabel.text = @"Copyright";
    self.copyrightLabel.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
    self.copyrightLabel.textColor = [UIColor blackColor];
    [self.view addSubview:self.copyrightLabel];
    [self.copyrightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.webLine.mas_top).offset(16);
        make.left.equalTo(self.view.mas_left).offset(12);
        make.right.equalTo(self.view.mas_right).offset(-12);
        make.height.equalTo(@(20));
    }];
    
    self.copyrightDetailsLabel = [[UILabel alloc] init];
    self.copyrightDetailsLabel.text = NSLocalizedString(@"©2014-2017, Dash Core Developers \n©2018-2018, SAFE Core Developers", nil);
    self.copyrightDetailsLabel.numberOfLines = 0;
    self.copyrightDetailsLabel.font = [UIFont systemFontOfSize:14];
    self.copyrightDetailsLabel.textColor = ColorFromRGB(0x999999);
    [self.view addSubview:self.copyrightDetailsLabel];
    [self.copyrightDetailsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.copyrightLabel.mas_bottom).offset(6);
        make.left.equalTo(self.view.mas_left).offset(12);
        make.right.equalTo(self.view.mas_right).offset(-12);
        make.height.equalTo(@(40));
    }];
    
    self.copyrightLine = [[UIView alloc] init];
    self.copyrightLine.backgroundColor = ColorFromRGB255(218, 218, 218);
    [self.view addSubview:self.copyrightLine];
    [self.copyrightLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.copyrightDetailsLabel.mas_bottom).offset(12);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.height.equalTo(@(1));
    }];
}

- (void) loadWebClick {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.anwang.com"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
