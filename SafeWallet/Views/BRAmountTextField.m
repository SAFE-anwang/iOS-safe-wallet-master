//
//  BR 金额 BRAmountTextField.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/25.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRAmountTextField.h"

@implementation BRAmountTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    if (menuController) {
        [UIMenuController sharedMenuController].menuVisible = NO;
    }
    return NO;
}

@end
