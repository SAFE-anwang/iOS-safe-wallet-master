//
//  BRCandyHistoryDetailController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/24.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRCandyHistoryDetailController.h"
#import "BRCandyHistoryDetailCell.h"
#import <Photos/Photos.h>
#import "MBProgressHUD.h"

@interface BRCandyHistoryDetailController ()<UITableViewDelegate,UITableViewDataSource,BRCandyHistoryDetailCellDelegate>

@property (nonatomic,strong) UITableView *detailTableView;

@end

@implementation BRCandyHistoryDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.title = NSLocalizedString(@"Got Details", nil);
    self.view.backgroundColor = [UIColor whiteColor];
    [self initUI];
}

- (void)initUI {
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.view.frame.size.height - SafeAreaBottomHeight) style:UITableViewStyleGrouped];
    tableView.backgroundColor = [UIColor whiteColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.showsVerticalScrollIndicator = NO;
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    tableView.estimatedRowHeight = 0;
    tableView.separatorStyle = NO;
    [self.view addSubview:tableView];
    self.detailTableView = tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *identifier = @"BRCandyHistoryDetailCell";
    BRCandyHistoryDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[BRCandyHistoryDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 492;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.0001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0001;
}

- (void)qrcodeLongpress:(UIImage *)longpressImage {
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Save photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self loadImageFinished:longpressImage];
    }];
    UIAlertAction *jumpAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Check transaction", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        NSString *string = [NSString stringWithFormat:@"http://10.0.0.249:3001/tx/%@",self.txId];
//        SFSafariViewController * safariViewController = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:string]];
//        [self presentViewController:safariViewController animated:YES completion:nil];
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancle",nil) style:UIAlertActionStyleCancel handler:nil];
    [alertVc addAction:saveAction];
    [alertVc addAction:jumpAction];
    [alertVc addAction:cancleAction];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (void)loadImageFinished:(UIImage *)image
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        //写入图片到相册
        PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        //NSLog(@"success = %d, error = %@", success, error);
        if (success) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.label.text = NSLocalizedString(@"Saved photo", nil);
            hud.label.numberOfLines = 0;
            hud.label.textColor = [UIColor blackColor];
            hud.label.font = [UIFont systemFontOfSize:17.0];
            hud.userInteractionEnabled= NO;
            hud.bezelView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];   //背景颜色
            hud.mode = MBProgressHUDModeText;
            // 隐藏时候从父控件中移除
            hud.removeFromSuperViewOnHide = YES;
            // 2秒之后再消失
            [hud hideAnimated:YES afterDelay:2.f];
        } else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.label.text = NSLocalizedString(@"Saved failure", nil);
            hud.label.numberOfLines = 0;
            hud.label.textColor = [UIColor blackColor];
            hud.label.font = [UIFont systemFontOfSize:17.0];
            hud.userInteractionEnabled= NO;
            hud.bezelView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];   //背景颜色
            hud.mode = MBProgressHUDModeText;
            // 隐藏时候从父控件中移除
            hud.removeFromSuperViewOnHide = YES;
            // 2秒之后再消失
            [hud hideAnimated:YES afterDelay:2.f];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
