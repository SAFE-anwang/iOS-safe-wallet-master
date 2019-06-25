//
//  BRAssetCell.m
//  dashwallet
//
//  Created by joker on 2018/6/19.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRAssetCell.h"
#import <Masonry.h>
#import "BRBalanceModel.h"
#import "BRSafeUtils.h"

@interface BRAssetCell()

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UIImageView *logoImg;

@property (nonatomic, strong) UILabel *numLabel;

@end

@implementation BRAssetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    
    return self;
}

- (void)setBalance:(BRBalanceModel *)balance {
    _balance = balance;
    self.nameLabel.text = balance.nameString;
    if(balance.assetId.length == 0) {
        self.numLabel.text = [BRSafeUtils showSAFEAmount:balance.balance]; // balance.balance
    } else {
        self.numLabel.text = [BRSafeUtils amountForAssetAmount:balance.balance decimals:balance.multiple];
    }
}

- (void)setup {
    // 资产 logo
    self.logoImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"84x84logo"]];
    [self addSubview:self.logoImg];
    [self.logoImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(42);
        make.left.mas_equalTo(self).with.offset(10);
        make.centerY.mas_equalTo(self);
    }];
    // 资产名字
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.font = kFont(13);
    self.nameLabel.numberOfLines = 3;
    
    [self addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerY.mas_equalTo(self);
        make.left.mas_equalTo(self.logoImg.mas_right).with.offset(10);
//        make.width.mas_equalTo(self).multipliedBy(0.25);
    }];
    
    // 总余额数
    self.numLabel = [[UILabel alloc] init];
    self.numLabel.textColor = [UIColor grayColor];
    self.numLabel.font = kFont(12);
    self.numLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.numLabel];
    
    // 总余额
    UILabel *totalLabel = [[UILabel alloc] init];
    totalLabel.font = kFont(13);
    totalLabel.text = NSLocalizedString(@"Total", nil);
    [self addSubview:totalLabel];
    [totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).with.offset(15);
        make.right.mas_equalTo(self).offset(-15);
    }];
    
    [self.numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(totalLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.nameLabel.mas_right).offset(10);
        make.right.mas_equalTo(self).offset(-15);
    }];
    [self.numLabel setContentCompressionResistancePriority:(UILayoutPriorityRequired) forAxis:(UILayoutConstraintAxisHorizontal)];
}

@end
