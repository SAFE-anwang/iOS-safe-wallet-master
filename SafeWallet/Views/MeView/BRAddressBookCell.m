//
//  BRAddressBookCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/7.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRAddressBookCell.h"

@interface BRAddressBookCell()

@property (nonatomic, strong) UIView *line;

@end

@implementation BRAddressBookCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (UILabel *)title {
    if(_title == nil) {
        _title = [[UILabel alloc] init];
        _title.font = [UIFont systemFontOfSize:15.0f];
        _title.textColor = [UIColor blackColor];
    }
    return _title;
}

- (UILabel *)subTitle {
    if(_subTitle == nil) {
        _subTitle = [[UILabel alloc] init];
        _subTitle.font = [UIFont systemFontOfSize:15.0f];
        _subTitle.textColor = [UIColor blackColor];
    }
    return _subTitle;
}

- (UIView *)line {
    if(_line == nil) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = ColorFromRGB255(232, 232, 232);
    }
    return _line;
}

- (void)initUI {
    [self addSubview:self.title];
    [self addSubview:self.subTitle];
    [self addSubview:self.line];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right);
        make.height.equalTo(@(1));
    }];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(30);
        make.width.equalTo(@(80));
        make.height.equalTo(@(20));
        make.centerY.equalTo(self.mas_centerY);
    }];
    
    [self.subTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.title.mas_right).offset(10);
        make.right.equalTo(self.mas_right);
        make.height.equalTo(@(20));
        make.centerY.equalTo(self.mas_centerY);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

   
}

@end
