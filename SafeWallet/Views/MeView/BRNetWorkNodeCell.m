//
//  BRNetWorkNodeCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/8.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRNetWorkNodeCell.h"

#define FontColor [UIColor blackColor]

@interface BRNetWorkNodeCell()

@property (nonatomic,strong) UIView *line;

@property (nonatomic,strong) UIImageView *speedImageView;

@end

@implementation BRNetWorkNodeCell

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

- (UILabel *)iPAddress {
    if(_iPAddress == nil) {
        _iPAddress = [[UILabel alloc] init];
        _iPAddress.font = [UIFont systemFontOfSize:15.0f];
        _iPAddress.textColor = FontColor;
        _iPAddress.textAlignment = NSTextAlignmentLeft;
    }
    return _iPAddress;
}

- (UILabel *)coinName {
    if(_coinName == nil) {
        _coinName = [[UILabel alloc] init];
        _coinName.font = [UIFont systemFontOfSize:15.0f];
        _coinName.textColor = FontColor;
        _coinName.textAlignment = NSTextAlignmentLeft;
    }
    return _coinName;
}

- (UILabel *)protocolName {
    if(_protocolName == nil) {
        _protocolName = [[UILabel alloc] init];
        _protocolName.font = [UIFont systemFontOfSize:15.0f];
        _protocolName.textColor = FontColor;
        _protocolName.textAlignment = NSTextAlignmentLeft;
    }
    return _protocolName;
}

- (UILabel *)blockNumber {
    if(_blockNumber == nil) {
        _blockNumber = [[UILabel alloc] init];
        _blockNumber.font = [UIFont systemFontOfSize:15.0f];
        _blockNumber.textColor = FontColor;
        _blockNumber.textAlignment = NSTextAlignmentRight;
    }
    return _blockNumber;
}

- (UILabel *)speed {
    if(_speed == nil) {
        _speed = [[UILabel alloc] init];
        _speed.font = [UIFont systemFontOfSize:15.0f];
        _speed.textColor = FontColor;
        _speed.textAlignment = NSTextAlignmentRight;
    }
    return _speed;
}

- (UIImageView *)speedImageView {
    if(_speedImageView == nil) {
        _speedImageView = [[UIImageView alloc] init];
        _speedImageView.image = [UIImage imageNamed:@""];
    }
    return _speedImageView;
}

#pragma mark - 创建UI
- (void) initUI {
    [self addSubview:self.line];
    [self addSubview:self.speedImageView];
    [self addSubview:self.iPAddress];
    [self addSubview:self.coinName];
    [self addSubview:self.protocolName];
    [self addSubview:self.blockNumber];
    [self addSubview:self.speed];
    
    [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right);
        make.height.equalTo(@(1));
    }];
    
    [self.iPAddress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(30);
        make.right.equalTo(self.mas_right).offset(30);
        make.top.equalTo(self.mas_top).offset(10);
        make.height.equalTo(@(15));
    }];
    
    [self.blockNumber mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-30);
        make.top.equalTo(self.iPAddress.mas_bottom).offset(5);
        make.height.equalTo(@(18));
        make.width.mas_lessThanOrEqualTo(@(100));
    }];
    
    [self.coinName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(30);
        make.top.equalTo(self.iPAddress.mas_bottom).offset(5);
        make.right.equalTo(self.blockNumber.mas_left).offset(-10);
        make.height.equalTo(@(18));
    }];
    
    [self.speed mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-30);
        make.top.equalTo(self.blockNumber.mas_bottom).offset(5);
        make.height.equalTo(@(18));
        make.width.lessThanOrEqualTo(@(100));
    }];
    
    [self.speedImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.speed.mas_left).offset(-4);
        make.top.equalTo(self.blockNumber.mas_bottom).offset(8);
        make.width.equalTo(@(10));
        make.height.equalTo(@(10));
    }];
    
    [self.protocolName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(30);
        make.top.equalTo(self.coinName.mas_bottom).offset(5);
        make.right.equalTo(self.speedImageView.mas_left).offset(-6);
        make.height.equalTo(@(18));
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
