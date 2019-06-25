//
//  BRWKDelegateController.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/8.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRWKDelegateController.h"

@interface BRWKDelegateController ()

@end

@implementation BRWKDelegateController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
  
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([self.delegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
        [self.delegate userContentController:userContentController didReceiveScriptMessage:message];
    }
}

@end
