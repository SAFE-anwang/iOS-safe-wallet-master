//
//  BRMasternodeCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/27.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRMasternodeCell.h"

@implementation BRMasternodeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH - 30, 115)];
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.cornerRadius = 10.f;
    backView.layer.shadowColor = [UIColor blackColor].CGColor;
    backView.layer.shadowOffset = CGSizeMake(2, 2);
    backView.layer.shadowRadius = 10.f;
    backView.layer.shadowOpacity = 0.4f;
    [self.contentView addSubview:backView];
    
    UIView *addressView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, CGRectGetWidth(backView.frame) - 20, 40)];
    addressView.layer.cornerRadius = 4.f;
    addressView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.4].CGColor;
    addressView.layer.borderWidth = 1.f;
    [backView addSubview:addressView];
    
    UILabel *addressLable = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CGRectGetWidth(addressView.frame) - 20, 40)];
    addressLable.text = @"XwabEed84gKDJuv3exr8XzRSFXnEQ51dCD";
    addressLable.textColor = ColorFromRGB(0x555555);
    addressLable.font = [UIFont systemFontOfSize:15.f];
    addressLable.textAlignment = NSTextAlignmentLeft;
    addressLable.numberOfLines = 0;
    addressLable.backgroundColor = [UIColor clearColor];
    [addressView addSubview:addressLable];
    
    UIButton *aliasButton = [UIButton buttonWithType:UIButtonTypeCustom];
    aliasButton.frame = CGRectMake(CGRectGetWidth(backView.frame) - 10 - 100, CGRectGetMaxY(addressView.frame) + 10, 100, 45);
    aliasButton.backgroundColor = MAIN_COLOR;
    [aliasButton setTitle:@"别名:\nSAFE" forState:UIControlStateNormal];
    [aliasButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    aliasButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    aliasButton.titleLabel.numberOfLines = 0;
    aliasButton.layer.cornerRadius = 6.f;
    [backView addSubview:aliasButton];
    self.aliasButton = aliasButton;
    
    UILabel *ipLable = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(addressView.frame) + 10, CGRectGetWidth(backView.frame) - 20 - 110, 20)];
    ipLable.text = @"IP地址：108.192.246.521";
    ipLable.textColor = ColorFromRGB(0x555555);
    ipLable.font = [UIFont systemFontOfSize:15.f];
    [backView addSubview:ipLable];
    
    UILabel *statusLable = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(ipLable.frame) + 5, 120, 20)];
    statusLable.text = @"状   态：未激活";
    statusLable.textColor = ColorFromRGB(0x555555);
    statusLable.numberOfLines = 0;
    statusLable.textAlignment = NSTextAlignmentLeft;
    statusLable.font = [UIFont systemFontOfSize:15.f];
    [backView addSubview:statusLable];
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
