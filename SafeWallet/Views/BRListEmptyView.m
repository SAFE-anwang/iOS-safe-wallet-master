//
//  BRListEmptyView.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/30.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRListEmptyView.h"

@interface BRListEmptyView()

@end

@implementation BRListEmptyView

- (UILabel *)titleLabel {
    if(_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void) initUI {
    [self addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.equalTo(@(20));
        make.centerY.equalTo(self.mas_centerY).offset(-10);
    }];
}

@end
