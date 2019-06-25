//
//  BRAdditionalDistributionAssetPromptCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/11.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRAdditionalDistributionAssetPromptCell.h"

@implementation BRAdditionalDistributionAssetPromptCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self creatUI];
        
    }
    return self;
}

- (UILabel *)title {
    if(_title == nil) {
        _title = [[UILabel alloc] init];
        _title.textColor = [UIColor blackColor];
        _title.font = [UIFont systemFontOfSize:13.0f];
        _title.numberOfLines = 0;
        _title.text = @"您发行资产时用到了以下地址，因此追加发行也必须用这些地址中的一个，请选择一个地址，并保证该地址上有至少1个SAFE";
    }
    return _title;
}

#pragma mark -创建UI
- (void) creatUI {
    [self addSubview:self.title];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(25);
        make.left.equalTo(self.mas_left).offset(30);
        make.right.equalTo(self.mas_right).offset(-12);
        make.bottom.equalTo(self.mas_bottom);
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
