//
//  BRTXHistoryListCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/27.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRTXHistoryListCell.h"

@interface BRTXHistoryListCell()

@property (nonatomic,strong) UIView *lineView;


@end

@implementation BRTXHistoryListCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (UILabel *)assetNameLable {
    if(_assetNameLable == nil) {
        _assetNameLable = [[UILabel alloc] init];
        _assetNameLable.textColor = [UIColor blackColor];
        _assetNameLable.text = @"ewrqwerqwreqwrqwrwqrqwrwqrqwrwrqwer";
        _assetNameLable.font = [UIFont systemFontOfSize:14.f];
    }
    return _assetNameLable;
}

- (UILabel *)amountLable {
    if(_amountLable == nil) {
        _amountLable = [[UILabel alloc] init];
        _amountLable.textColor = ColorFromRGB(0x333333);
        _amountLable.text = @"+ 1500000000000000000";
        _amountLable.textAlignment = NSTextAlignmentRight;
        _amountLable.font = [UIFont systemFontOfSize:14.f weight:UIFontWeightBold];
    }
    return _amountLable;
}

- (UILabel *)lockMonthLabel {
    if(_lockMonthLabel == nil) {
        _lockMonthLabel = [[UILabel alloc] init];
        _lockMonthLabel.textColor = ColorFromRGB(0x666666);
        _lockMonthLabel.font = [UIFont systemFontOfSize:14.f];
        _lockMonthLabel.text = @"XgxrGRC8AC3Fsw8RoMi89xtn11AMqQ3gNB";
    }
    return _lockMonthLabel;
}

- (UILabel *)lockHeightLabel {
    if(_lockHeightLabel == nil) {
        _lockHeightLabel = [[UILabel alloc] init];
        _lockHeightLabel.textColor = ColorFromRGB(0x666666);
        _lockHeightLabel.font = [UIFont systemFontOfSize:14.f];
        _lockHeightLabel.text = @"XgxrGRC8AC3Fsw8RoMi89xtn11AMqQ3gNB";
        _lockHeightLabel.textAlignment = NSTextAlignmentRight;
    }
    return _lockHeightLabel;
}

- (UIImageView *)lockImageView {
    if(_lockImageView == nil) {
        _lockImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"assetLock"]];
    }
    return _lockImageView;
}

- (UILabel *)addressLable {
    if(_addressLable == nil) {
        _addressLable = [[UILabel alloc] init];
        _addressLable.textColor = ColorFromRGB(0x666666);
        _addressLable.font = [UIFont systemFontOfSize:14.f];
        _addressLable.text = @"XgxrGRC8AC3Fsw8RoMi89xtn11AMqQ3gNB";
    }
    return _addressLable;
}

- (UIView *)lineView {
    if(_lineView == nil) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = ColorFromRGB255(218, 218, 218);
    }
    return _lineView;
}




- (void) initUI {
    [self addSubview:self.assetNameLable];
    [self addSubview:self.amountLable];
    [self addSubview:self.addressLable];
    [self addSubview:self.lockMonthLabel];
    [self addSubview:self.lockHeightLabel];
    [self addSubview:self.lockImageView];
    [self addSubview:self.lineView];
    
    
    [self.assetNameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(10);
        make.left.equalTo(self.mas_left).offset(15);
        make.right.equalTo(self.amountLable.mas_left).offset(-20);
        make.height.equalTo(@(18));
    }];
    
    [self.amountLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(10);
        make.left.equalTo(self.assetNameLable.mas_right).offset(20);
        make.right.equalTo(self.mas_right).offset(-15);
        make.height.equalTo(@(18));
    }];
    // 设置显示优先级
    [self.amountLable setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.lockImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(10);
        make.width.height.equalTo(@(20));
        make.right.equalTo(self.amountLable.mas_left);
    }];
    
    [self.lockMonthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.amountLable.mas_bottom).offset(6);
        make.left.equalTo(self.mas_left).offset(15);
        make.right.equalTo(self.lockHeightLabel.mas_left).offset(-10);
        make.height.equalTo(@(18));
        make.width.equalTo(self.lockHeightLabel.mas_width);
    }];
    
    [self.lockHeightLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.amountLable.mas_bottom).offset(6);
        make.left.equalTo(self.lockMonthLabel.mas_right).offset(10);
        make.right.equalTo(self.mas_right).offset(-15);
        make.height.equalTo(@(18));
        make.width.equalTo(self.lockMonthLabel.mas_width);
    }];
    
    [self.addressLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(15);
        make.right.equalTo(self.mas_right).offset(-15);
        make.height.equalTo(@(20));
        make.bottom.equalTo(self.mas_bottom).offset(-10);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(@(1));
    }];
}

@end
