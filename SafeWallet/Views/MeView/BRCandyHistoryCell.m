//
//  BRCandyHistoryCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/24.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRCandyHistoryCell.h"
#import "BRGetCandyEntity+CoreDataProperties.h"
#import "BRSafeUtils.h"

@interface BRCandyHistoryCell()

@property (nonatomic,strong) UIView *lineView;



@end


@implementation BRCandyHistoryCell

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
    [self addSubview:self.lineView];

    
    [self.assetNameLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(10);
        make.left.equalTo(self.mas_left).offset(15);
        make.right.equalTo(self.amountLable.mas_left).offset(-10);
        make.height.equalTo(@(18));
    }];
    
    [self.amountLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(10);
        make.left.equalTo(self.assetNameLable.mas_right).offset(10);
        make.right.equalTo(self.mas_right).offset(-15);
        make.height.equalTo(@(18));
    }];
    // 设置显示优先级
    [self.amountLable setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];

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

//- (void)initUI {
//
//    UILabel *assetNameLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 80, 30)];
//    assetNameLable.backgroundColor = [UIColor clearColor];
//    assetNameLable.text = @"SAFE";
//    assetNameLable.textColor = [UIColor blackColor];
//    assetNameLable.font = [UIFont systemFontOfSize:16.f];
//    [self.contentView addSubview:assetNameLable];
//
//    UILabel *amountLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(assetNameLable.frame) + 20, 10, SCREEN_WIDTH - 130, 30)];
//    amountLable.backgroundColor = [UIColor clearColor];
//    amountLable.text = @"+ 1500000000000000000";
//    amountLable.textColor = ColorFromRGB(0x333333);
//    amountLable.textAlignment = NSTextAlignmentRight;
//    amountLable.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightBold];
//    [self.contentView addSubview:amountLable];
//
//    UILabel *addressLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, SCREEN_WIDTH - 30, 30)];
//    addressLable.backgroundColor = [UIColor clearColor];
//    addressLable.text = @"XgxrGRC8AC3Fsw8RoMi89xtn11AMqQ3gNB";
//    addressLable.textColor = ColorFromRGB(0x666666);
//    addressLable.font = [UIFont systemFontOfSize:16.f];
//    [self.contentView addSubview:addressLable];
//}

- (void)setCandy:(BRGetCandyEntity *)candy {
    _candy = candy;
    self.assetNameLable.text = candy.assetName;
    self.amountLable.text = [BRSafeUtils amountForAssetAmount:[candy.candyAmount unsignedLongLongValue] decimals:[candy.decimals integerValue]];
    self.addressLable.text = candy.address;
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
