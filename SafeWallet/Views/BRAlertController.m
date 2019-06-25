//
//  BRAlertController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/26.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRAlertController.h"
#import "BRNavigationController.h"
#import "BRAmountViewController.h"

@interface BRAlertController ()

@end

@implementation BRAlertController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}


//- (void)setup {
//
//    CGFloat width = self.view.frame.size.width;
//    CGFloat height = self.view.frame.size.height;
//    self.view.frame = CGRectMake((SCREEN_WIDTH - self.view.frame.size.width) / 2, SCREEN_HEIGHT * 0.18, width, height);
//}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    BOOL iphonePlus = SCREEN_HEIGHT > 667;
//    if (!iphonePlus) {
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow) name:UIKeyboardWillShowNotification object:nil];
//    }
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationResingNoti:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
}

- (void)keyboardShow {
    
//    [self setup];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)willDealloc {
    return NO;
}

//- (void)applicationResingNoti:(NSNotification *)noti {
//    [self dismissViewControllerAnimated:YES completion:nil];
//    
//}


@end
