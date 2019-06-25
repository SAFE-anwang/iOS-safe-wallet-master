//
//  AppTool.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/30.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "AppTool.h"
#import "MBProgressHUD.h"

@implementation AppTool

+ (void) showMessage:(NSString *) message showView:(UIView *) showView {
    if (!showView) {
        showView = [UIApplication sharedApplication].keyWindow;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:showView animated:YES ];
    hud.label.text = message;
    hud.label.numberOfLines = 0;
    hud.label.textColor = [UIColor blackColor];
    hud.label.font = [UIFont systemFontOfSize:15.0];
    hud.userInteractionEnabled = YES;
    hud.bezelView.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5f];   //背景颜色
    hud.mode = MBProgressHUDModeText;
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // 1秒之后再消失
    [hud hideAnimated:YES afterDelay:2];
}

+ (void) showHUDView:(UIView *) showView animated:(BOOL) animated  {
    if(!showView) {
        showView = [UIApplication sharedApplication].keyWindow;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:showView animated:animated];
    hud.userInteractionEnabled = YES;
}

+ (void) hideHUDView:(UIView *) showView animated:(BOOL) animated  {
    if(!showView) {
        showView = [UIApplication sharedApplication].keyWindow;
    }
    [MBProgressHUD hideHUDForView:showView animated:animated];
}

+ (double) getAssetMultiple:(NSInteger) integer {
    if(integer <= 8) {
        return pow(10, 8 - integer);
    } else if (integer == 9) {
        return 0.1;
    } else if (integer == 10) {
        return 0.01;
    }
    return 1;
}


@end
