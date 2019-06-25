//
//  BRLabel.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/4.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRLabel.h"

@implementation BRLabel

- (instancetype)init {
    if (self = [super init]) {
        _textInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _textInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (void)drawTextInRect:(CGRect)rect {
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, _textInsets)];
}

@end
