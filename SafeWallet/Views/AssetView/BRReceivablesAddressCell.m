//
//  BRReceivablesAddressCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/19.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRReceivablesAddressCell.h"

@interface BRReceivablesAddressCell()

@end

@implementation BRReceivablesAddressCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    
    return self;
}

- (UILabel *)titleLabel {
    if(_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14.0];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (void) setup {
    [self addSubview:self.titleLabel];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(20);
        make.left.equalTo(self.mas_left).offset(12);
        make.right.equalTo(self.mas_right).offset(-12);
        make.height.equalTo(@(20));
    }];
}

@end
