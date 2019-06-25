//
//  BRAddressBookViewController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/7.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRAddressBookViewController.h"
#import "BRAddressBookCell.h"

@interface BRAddressBookViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton *sendAddressBtn;

@property (nonatomic, strong) UIButton *walletAddressBtn;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) UIView *editAddressAlertView;

@property (nonatomic, strong) UIVisualEffectView *effectView;

@property (nonatomic, strong) UIView *deleteAlertView;

@property (nonatomic, strong) UIView *checkBox;

@property (nonatomic, strong) UIView *sendAddressCheckBox;

@end

@implementation BRAddressBookViewController

#warning Language International
- (UIButton *)sendAddressBtn {
    if(_sendAddressBtn == nil) {
        _sendAddressBtn = [[UIButton alloc] init];
        [_sendAddressBtn setTitle:@"发送的地址" forState:UIControlStateNormal];
        _sendAddressBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_sendAddressBtn setTitleColor:ColorFromRGB255(106, 106, 106) forState:UIControlStateNormal];
        _sendAddressBtn.backgroundColor = ColorFromRGB255(205, 205, 205);
        _sendAddressBtn.layer.cornerRadius = 3;
        _sendAddressBtn.layer.masksToBounds = YES;
        [_sendAddressBtn addTarget:self action:@selector(loadSendAddressData) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sendAddressBtn;
}

- (UIButton *)walletAddressBtn {
    if(_walletAddressBtn == nil) {
        _walletAddressBtn = [[UIButton alloc] init];
        [_walletAddressBtn setTitle:@"您的钱包地址" forState:UIControlStateNormal];
        _walletAddressBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_walletAddressBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _walletAddressBtn.backgroundColor = MAIN_COLOR;
        _walletAddressBtn.layer.cornerRadius = 3;
        _walletAddressBtn.layer.masksToBounds = YES;
        [_walletAddressBtn addTarget:self action:@selector(loadWalletAddressData) forControlEvents:UIControlEventTouchUpInside];
    }
    return _walletAddressBtn;
}

- (UITableView *)tableView {
    if(_tableView == nil) {
        _tableView = [[UITableView alloc] init];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.separatorStyle = NO;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
#warning Language International
    self.navigationItem.title = @"地址簿";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self creadUI];
    
    [self creatEffectView];
}

#pragma mark - 创建UI
- (void) creadUI {
    
    [self.view addSubview:self.sendAddressBtn];
    [self.view addSubview:self.walletAddressBtn];
    [self.view addSubview:self.tableView];
    
    
    [self.walletAddressBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(27 + SafeAreaViewHeight);
        make.left.equalTo(self.view.mas_left).offset(30);
        make.right.equalTo(self.sendAddressBtn.mas_left).offset(-25);
        make.width.equalTo(self.sendAddressBtn.mas_width);
        make.height.equalTo(@(30));
    }];
    
    [self.sendAddressBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(27 + SafeAreaViewHeight);
        make.left.equalTo(self.walletAddressBtn.mas_right).offset(25);
        make.right.equalTo(self.view.mas_right).offset(-30);
        make.width.equalTo(self.walletAddressBtn.mas_width);
        make.height.equalTo(@(30));
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.walletAddressBtn.mas_bottom).offset(15);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom).offset(SafeAreaBottomHeight);
    }];
    
}

#pragma mark - 创建模糊背景
- (void)creatEffectView {
    
    //模糊背景
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.hidden = YES;
    effectView.frame = CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height);
    effectView.alpha = 0.3f;
    [self.view addSubview:effectView];
    self.effectView = effectView;
}


#pragma mark - 钱包地址数据
- (void) loadWalletAddressData {
    [self.sendAddressBtn setTitleColor:ColorFromRGB255(106, 106, 106) forState:UIControlStateNormal];
    self.sendAddressBtn.backgroundColor = ColorFromRGB255(205, 205, 205);
    [self.walletAddressBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.walletAddressBtn.backgroundColor = MAIN_COLOR;
}

#pragma mark - 发送的地址数据
- (void) loadSendAddressData {
    [self.walletAddressBtn setTitleColor:ColorFromRGB255(106, 106, 106) forState:UIControlStateNormal];
    self.walletAddressBtn.backgroundColor = ColorFromRGB255(205, 205, 205);
    [self.sendAddressBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.sendAddressBtn.backgroundColor = MAIN_COLOR;
}

#pragma mark - UITableViewDelegate UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *addressBookString = @"BRAddressBookCell";
    BRAddressBookCell *cell = [tableView dequeueReusableCellWithIdentifier:addressBookString];
    if(cell == nil) {
        cell = [[BRAddressBookCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:addressBookString];
    }
#warning Language International
    cell.title.text = @"标签";
    cell.subTitle.text = @"地址";
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    [self showCheckBox];
//    [self showDeleteAlertView];
    
    [self showSendAddressCheckBox];
}

#pragma mark - 编辑地址弹框
- (void) showEditAlertView {
    [self creatAlertView];
    self.effectView.hidden = NO;
    self.editAddressAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN,  CGFLOAT_MIN);
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.editAddressAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:^(BOOL finished) {
        self.editAddressAlertView.transform = CGAffineTransformIdentity;
    }];
}

- (void)creatAlertView {
    
    CGFloat margin = 20;
    CGFloat height = 184;
    CGFloat lableHeight = 120;
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(margin, 0, SCREEN_WIDTH - margin * 2, height)];
    alertView.backgroundColor = [UIColor whiteColor];
    alertView.center = self.view.center;
    alertView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.4f].CGColor;
    alertView.layer.borderWidth = 1.f;
    alertView.layer.cornerRadius = 6.f;
    alertView.clipsToBounds = YES;
    [self.view addSubview:alertView];
    self.editAddressAlertView = alertView;
#warning Language International
    CGFloat lableWidth = 15;
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(lableWidth, 14, SCREEN_WIDTH - margin * 2 - lableWidth * 2, 16)];
    lable.text = @"地址";
    lable.numberOfLines = 0;
    lable.textColor = [UIColor blackColor];
    lable.font = [UIFont systemFontOfSize:16.f];
    lable.textAlignment = NSTextAlignmentLeft;
    [alertView addSubview:lable];
    
    UILabel *addressLable = [[UILabel alloc] initWithFrame:CGRectMake(lableWidth, 14 + 7 + 16, SCREEN_WIDTH - margin * 2 - lableWidth * 2, 20)];
    addressLable.text = @"SDASDSDADSdssadfsfasfa";
    addressLable.numberOfLines = 0;
    addressLable.textColor = [UIColor blackColor];
    addressLable.font = [UIFont systemFontOfSize:16.f];
    addressLable.textAlignment = NSTextAlignmentLeft;
    [alertView addSubview:addressLable];
#warning Language International
    UILabel *subLable = [[UILabel alloc] initWithFrame:CGRectMake(lableWidth, 14 + 7 + 13 + 36, SCREEN_WIDTH - margin * 2 - lableWidth * 2, 16)];
    subLable.text = @"名称";
    subLable.numberOfLines = 0;
    subLable.textColor = [UIColor blackColor];
    subLable.font = [UIFont systemFontOfSize:16.f];
    subLable.textAlignment = NSTextAlignmentLeft;
    [alertView addSubview:subLable];
    
    UITextField *nameTextField = [[UITextField alloc] initWithFrame:CGRectMake(lableWidth, 14 + 7 + 13 + 36 + 16 + 8, SCREEN_WIDTH - margin * 2 - lableWidth * 2, 30)];
    nameTextField.layer.borderWidth = 1;
    nameTextField.layer.borderColor = ColorFromRGB255(232, 232, 232).CGColor;
    [alertView addSubview:nameTextField];
#warning Language International
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sureButton.frame = CGRectMake((SCREEN_WIDTH - margin * 2) / 2 + 12, 14 + 7 + 13 + 36 + 16 + 42 + 10, 70, 30);
    sureButton.backgroundColor = MAIN_COLOR;
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sureButton.layer.cornerRadius = 3;
    sureButton.layer.masksToBounds = YES;
    sureButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [alertView addSubview:sureButton];
    [sureButton addTarget:self action:@selector(editAddressName) forControlEvents:UIControlEventTouchUpInside];
#warning Language International
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake((SCREEN_WIDTH - margin * 2) / 2 - 12 - 70, 14 + 7 + 13 + 36 + 16 + 42 + 10, 70, 30);
    cancelButton.backgroundColor = [UIColor whiteColor];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.layer.borderWidth = 1;
    cancelButton.layer.cornerRadius = 3;
    cancelButton.layer.masksToBounds = YES;
    cancelButton.layer.borderColor = ColorFromRGB255(232, 232, 232).CGColor;
    [cancelButton setTitleColor:ColorFromRGB255(183, 183, 183) forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [alertView addSubview:cancelButton];
    [cancelButton addTarget:self action:@selector(hideAlertView) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 编辑地址名称
- (void) editAddressName {
    
}

#pragma mark - 隐藏编辑弹框
- (void)hideAlertView {
    
    [UIView animateWithDuration:0.1 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.editAddressAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.editAddressAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.001, 0.001);
                         }
                         completion:^(BOOL finished) {
                             [self.editAddressAlertView removeFromSuperview];
                             self.effectView.hidden = YES;
                         }];
    }];
}



#pragma mark - 创建删除弹框
- (void) showDeleteAlertView {
    
    [self creatDeleteAlertView];
    
    self.effectView.hidden = NO;
    self.deleteAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN,  CGFLOAT_MIN);
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.deleteAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:^(BOOL finished) {
        self.deleteAlertView.transform = CGAffineTransformIdentity;
    }];
}

- (void)creatDeleteAlertView {
    
    CGFloat margin = 15;
    CGFloat height = 100;
    CGFloat lableHeight = 120;
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(margin, 0, 200, height)];
    alertView.backgroundColor = [UIColor whiteColor];
    alertView.center = self.view.center;
    alertView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.4f].CGColor;
    alertView.layer.borderWidth = 1.f;
    alertView.layer.cornerRadius = 6.f;
    alertView.clipsToBounds = YES;
    [self.view addSubview:alertView];
    self.deleteAlertView = alertView;
#warning Language International
    CGFloat lableWidth = 15;
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, 200, 16)];
    lable.text = @"确定删除该地址吗？";
    lable.numberOfLines = 0;
    lable.textColor = [UIColor blackColor];
    lable.font = [UIFont systemFontOfSize:16.f];
    lable.textAlignment = NSTextAlignmentCenter;
    [alertView addSubview:lable];
#warning Language International
    UIButton *sureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    sureButton.frame = CGRectMake(200 / 2 + 5, 56, 70, 30);
    sureButton.backgroundColor = MAIN_COLOR;
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sureButton.layer.cornerRadius = 3;
    sureButton.layer.masksToBounds = YES;
    sureButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [alertView addSubview:sureButton];
    [sureButton addTarget:self action:@selector(deleteAddressData) forControlEvents:UIControlEventTouchUpInside];
#warning Language International
    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake(200  / 2 - 5 - 70, 56, 70, 30);
    cancelButton.backgroundColor = [UIColor whiteColor];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.layer.borderWidth = 1;
    cancelButton.layer.cornerRadius = 3;
    cancelButton.layer.masksToBounds = YES;
    cancelButton.layer.borderColor = ColorFromRGB255(232, 232, 232).CGColor;
    [cancelButton setTitleColor:ColorFromRGB255(183, 183, 183) forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [alertView addSubview:cancelButton];
    [cancelButton addTarget:self action:@selector(hideDeleteAlertView) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 删除地址数据
- (void) deleteAddressData {
    
    
}

#pragma mark - 隐藏删除弹框
- (void)hideDeleteAlertView {
    [UIView animateWithDuration:0.1 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.deleteAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.deleteAlertView.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.001, 0.001);
                         }
                         completion:^(BOOL finished) {
                             [self.deleteAlertView removeFromSuperview];
                             self.effectView.hidden = YES;
                         }];
    }];
}

#pragma mark - 显示复选框
- (void) showCheckBox {
    [self creatCheckBoxUI];
    
    self.effectView.hidden = NO;
    self.checkBox.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN,  CGFLOAT_MIN);
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.checkBox.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:^(BOOL finished) {
        self.checkBox.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - 创建复选框UI
- (void) creatCheckBoxUI {
    CGFloat margin = 20;
    CGFloat width = 140;
    CGFloat lableHeight = 120;
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(margin, 0, width, 80)];
    alertView.backgroundColor = [UIColor whiteColor];
    alertView.center = self.view.center;
    alertView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.4f].CGColor;
    alertView.layer.borderWidth = 1.f;
    alertView.layer.cornerRadius = 6.f;
    alertView.clipsToBounds = YES;
    [self.view addSubview:alertView];
    self.checkBox = alertView;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 40, width, 1)];
    line.backgroundColor = ColorFromRGB255(232, 232, 232);
    [alertView addSubview:line];
#warning Language International
    UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn setTitleColor:ColorFromRGB255(78, 78, 78) forState:UIControlStateNormal];
    editBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [alertView addSubview:editBtn];
    [editBtn addTarget:self action:@selector(walletEditAddress) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *copyAddressBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, width, 39)];
    [copyAddressBtn setTitle:@"复制地址" forState:UIControlStateNormal];
    [copyAddressBtn setTitleColor:ColorFromRGB255(78, 78, 78) forState:UIControlStateNormal];
    copyAddressBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [alertView addSubview:copyAddressBtn];
    [copyAddressBtn addTarget:self action:@selector(walletCopyAddress) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 钱包编辑地址
- (void) walletEditAddress {
    [UIView animateWithDuration:0.1 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.checkBox.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.checkBox.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.001, 0.001);
                         }
                         completion:^(BOOL finished) {
                             [self.checkBox removeFromSuperview];
                             
                             [self showEditAlertView];
                         }];
    }];
}

#pragma mark - 钱包地址复制
- (void) walletCopyAddress {
    UIPasteboard * pastboard = [UIPasteboard generalPasteboard];
#warning Language International
    pastboard.string = @"地址";
    [self hideCheckBox];
}

#pragma mark - 隐藏复选框
- (void) hideCheckBox {
    [UIView animateWithDuration:0.1 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.checkBox.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.checkBox.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.001, 0.001);
                         }
                         completion:^(BOOL finished) {
                             [self.checkBox removeFromSuperview];
                             self.effectView.hidden = YES;
                         }];
    }];
}

#pragma mark - 发送地址单选框
- (void) showSendAddressCheckBox {
    [self creatSendAddressCheckBoxUI];
    
    self.effectView.hidden = NO;
    self.sendAddressCheckBox.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN,  CGFLOAT_MIN);
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.sendAddressCheckBox.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
    } completion:^(BOOL finished) {
        self.sendAddressCheckBox.transform = CGAffineTransformIdentity;
    }];
}

#pragma mark - 创建发送地址单选框
- (void) creatSendAddressCheckBoxUI {
    CGFloat margin = 20;
    CGFloat width = 140;
    CGFloat lableHeight = 120;
    UIView *alertView = [[UIView alloc] initWithFrame:CGRectMake(margin, 0, width, 160)];
    alertView.backgroundColor = [UIColor whiteColor];
    alertView.center = self.view.center;
    alertView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.4f].CGColor;
    alertView.layer.borderWidth = 1.f;
    alertView.layer.cornerRadius = 6.f;
    alertView.clipsToBounds = YES;
    [self.view addSubview:alertView];
    self.sendAddressCheckBox = alertView;
    
    for (int  i=1; i<=3; i++) {
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, i * 40, width, 1)];
        line.backgroundColor = ColorFromRGB255(232, 232, 232);
        [alertView addSubview:line];
    }
    
#warning Language International
    UIButton *editBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, 40)];
    [editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [editBtn setTitleColor:ColorFromRGB255(78, 78, 78) forState:UIControlStateNormal];
    editBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [alertView addSubview:editBtn];
    [editBtn addTarget:self action:@selector(sendEditAddress) forControlEvents:UIControlEventTouchUpInside];
#warning Language International
    UIButton *deleteBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 40, width, 40)];
    [deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [deleteBtn setTitleColor:ColorFromRGB255(78, 78, 78) forState:UIControlStateNormal];
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [alertView addSubview:deleteBtn];
    [deleteBtn addTarget:self action:@selector(sendDeleteAddress) forControlEvents:UIControlEventTouchUpInside];
#warning Language International
    UIButton *sendBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 80, width, 40)];
    [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
    [sendBtn setTitleColor:ColorFromRGB255(78, 78, 78) forState:UIControlStateNormal];
    sendBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [alertView addSubview:sendBtn];
    [sendBtn addTarget:self action:@selector(sendAddress) forControlEvents:UIControlEventTouchUpInside];
#warning Language International
    UIButton *copyAddressBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 120, width, 39)];
    [copyAddressBtn setTitle:@"复制地址" forState:UIControlStateNormal];
    [copyAddressBtn setTitleColor:ColorFromRGB255(78, 78, 78) forState:UIControlStateNormal];
    copyAddressBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
    [alertView addSubview:copyAddressBtn];
    [copyAddressBtn addTarget:self action:@selector(sendCopyAddress) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 发送地址编辑
- (void) sendEditAddress {
    [UIView animateWithDuration:0.1 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.sendAddressCheckBox.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.sendAddressCheckBox.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.001, 0.001);
                         }
                         completion:^(BOOL finished) {
                             [self.sendAddressCheckBox removeFromSuperview];
                             self.effectView.hidden = YES;
                             [self showEditAlertView];
                         }];
    }];
}

#pragma mark - 删除发送地址
- (void) sendDeleteAddress {
    [UIView animateWithDuration:0.1 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.sendAddressCheckBox.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.sendAddressCheckBox.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.001, 0.001);
                         }
                         completion:^(BOOL finished) {
                             [self.sendAddressCheckBox removeFromSuperview];
                             self.effectView.hidden = YES;
                             [self showDeleteAlertView];
                         }];
    }];
}

#pragma mark - 发送发送地址
- (void) sendAddress {
    [self hideSendAddressCheckBox];
}

#pragma mark - 复制发送地址
- (void) sendCopyAddress {
    UIPasteboard * pastboard = [UIPasteboard generalPasteboard];
    pastboard.string = @"地址";
    [self hideSendAddressCheckBox];
}

#pragma mark - 隐藏复选框
- (void) hideSendAddressCheckBox {
    [UIView animateWithDuration:0.1 delay:0 usingSpringWithDamping:0.75 initialSpringVelocity:5.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.sendAddressCheckBox.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.05, 1.05);
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.sendAddressCheckBox.transform = CGAffineTransformScale(CGAffineTransformIdentity,0.001, 0.001);
                         }
                         completion:^(BOOL finished) {
                             [self.sendAddressCheckBox removeFromSuperview];
                             self.effectView.hidden = YES;
                         }];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}


@end
