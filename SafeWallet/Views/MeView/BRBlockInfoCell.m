//
//  BRBlockInfoCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/8.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRBlockInfoCell.h"

#define FontColor [UIColor blackColor]

@interface BRBlockInfoCell()

@property (nonatomic, strong) UIView *line;

@end

@implementation BRBlockInfoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (UIView *)line {
    if(_line == nil) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = ColorFromRGB255(232, 232, 232);
    }
    return _line;
}

- (UILabel *)blockNumber {
    if(_blockNumber == nil) {
        _blockNumber = [[UILabel alloc] init];
        _blockNumber.font = [UIFont systemFontOfSize:15.0f];
        _blockNumber.textColor = FontColor;
        _blockNumber.textAlignment = NSTextAlignmentLeft;
    }
    return _blockNumber;
}

- (UILabel *)time {
    if(_time == nil) {
        _time = [[UILabel alloc] init];
        _time.font = [UIFont systemFontOfSize:15.0f];
        _time.textColor = FontColor;
        _time.textAlignment = NSTextAlignmentRight;
    }
    return _time;
}

- (UILabel *)block_1 {
    if(_block_1 == nil) {
        _block_1 = [[UILabel alloc] init];
        _block_1.font = [UIFont systemFontOfSize:15.0f];
        _block_1.textColor = FontColor;
        _block_1.textAlignment = NSTextAlignmentLeft;
    }
    return _block_1;
}

- (UILabel *)block_2 {
    if(_block_2 == nil) {
        _block_2 = [[UILabel alloc] init];
        _block_2.font = [UIFont systemFontOfSize:15.0f];
        _block_2.textColor = FontColor;
        _block_2.textAlignment = NSTextAlignmentLeft;
    }
    return _block_2;
}

- (UILabel *)block_3 {
    if(_block_3 == nil) {
        _block_3 = [[UILabel alloc] init];
        _block_3.font = [UIFont systemFontOfSize:15.0f];
        _block_3.textColor = FontColor;
        _block_3.textAlignment = NSTextAlignmentLeft;
    }
    return _block_3;
}

- (UILabel *)block_4 {
    if(_block_4 == nil) {
        _block_4 = [[UILabel alloc] init];
        _block_4.font = [UIFont systemFontOfSize:15.0f];
        _block_4.textColor = FontColor;
        _block_4.textAlignment = NSTextAlignmentLeft;
    }
    return _block_4;
}

- (UILabel *)block_5 {
    if(_block_5 == nil) {
        _block_5 = [[UILabel alloc] init];
        _block_5.font = [UIFont systemFontOfSize:15.0f];
        _block_5.textColor = FontColor;
        _block_5.textAlignment = NSTextAlignmentLeft;
    }
    return _block_5;
}

- (UILabel *)block_6 {
    if(_block_6 == nil) {
        _block_6 = [[UILabel alloc] init];
        _block_6.font = [UIFont systemFontOfSize:15.0f];
        _block_6.textColor = FontColor;
        _block_6.textAlignment = NSTextAlignmentLeft;
    }
    return _block_6;
}

-(UILabel *)block_7 {
    if(_block_7 == nil) {
        _block_7 = [[UILabel alloc] init];
        _block_7.font = [UIFont systemFontOfSize:15.0f];
        _block_7.textColor = FontColor;
        _block_7.textAlignment = NSTextAlignmentLeft;
    }
    return _block_7;
}

- (UILabel *)block_8 {
    if(_block_8 == nil) {
        _block_8 = [[UILabel alloc] init];
        _block_8.font = [UIFont systemFontOfSize:15.0f];
        _block_8.textColor = FontColor;
        _block_8.textAlignment = NSTextAlignmentLeft;
    }
    return _block_8;
}

#pragma mark - 创建UI
- (void) initUI {
    [self addSubview:self.line];
    [self addSubview:self.blockNumber];
    [self addSubview:self.time];
    [self addSubview:self.block_1];
    [self addSubview:self.block_2];
    [self addSubview:self.block_3];
    [self addSubview:self.block_4];
    [self addSubview:self.block_5];
    [self addSubview:self.block_6];
    [self addSubview:self.block_7];
    [self addSubview:self.block_8];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right);
        make.height.equalTo(@(1));
    }];
    
    [self.blockNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(30);
        make.right.equalTo(self.time.mas_left).offset(-10);
        make.top.equalTo(self.mas_top).offset(10);
        make.height.equalTo(@(18));
    }];
    
    [self.time mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-30);
        make.top.equalTo(self.mas_top).offset(10);
        make.height.equalTo(@(18));
        make.width.mas_lessThanOrEqualTo(@(130));
    }];
    
    [self.block_1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(30));
        make.top.equalTo(self.blockNumber.mas_bottom).offset(4);
        make.right.equalTo(self.block_2.mas_left).offset(-10);
        make.height.equalTo(@(18));
        make.width.equalTo(self.block_2.mas_width);
    }];
    
    [self.block_2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.block_1.mas_right).offset(10);
        make.top.equalTo(self.blockNumber.mas_bottom).offset(4);
        make.right.equalTo(self.block_3.mas_left).offset(-10);
        make.height.equalTo(@(18));
        make.width.equalTo(self.block_1.mas_width);
    }];
    
    [self.block_3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.block_2.mas_right).offset(10);
        make.top.equalTo(self.blockNumber.mas_bottom).offset(4);
        make.right.equalTo(self.block_4.mas_left).offset(-10);
        make.height.equalTo(@(18));
        make.width.equalTo(self.block_1.mas_width);
    }];
    
    [self.block_4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.block_3.mas_right).offset(10);
        make.top.equalTo(self.blockNumber.mas_bottom).offset(4);
        make.right.equalTo(self.mas_right).offset(-30);
        make.height.equalTo(@(18));
        make.width.equalTo(self.block_1.mas_width);
    }];
    
    [self.block_5 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(30);
        make.right.equalTo(self.block_6.mas_left).offset(-10);
        make.top.equalTo(self.block_1.mas_bottom).offset(4);
        make.height.equalTo(@(18));
        make.width.equalTo(self.block_6.mas_width);
    }];
    
    [self.block_6 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.block_5.mas_right).offset(10);
        make.right.equalTo(self.block_7.mas_left).offset(-10);
        make.top.equalTo(self.block_1.mas_bottom).offset(4);
        make.height.equalTo(@(18));
        make.width.equalTo(self.block_5.mas_width);
    }];

    [self.block_7 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.block_6.mas_right).offset(10);
        make.right.equalTo(self.block_8.mas_left).offset(-10);
        make.top.equalTo(self.block_1.mas_bottom).offset(4);
        make.height.equalTo(@(18));
        make.width.equalTo(self.block_5.mas_width);
    }];

    [self.block_8 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.block_7.mas_right).offset(10);
        make.right.equalTo(self.mas_right).offset(-30);
        make.top.equalTo(self.block_1.mas_bottom).offset(4);
        make.height.equalTo(@(18));
        make.width.equalTo(self.block_5.mas_width);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
