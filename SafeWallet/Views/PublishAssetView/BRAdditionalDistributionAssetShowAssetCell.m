//
//  BRAdditionalDistributionAssetShowAssetCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/4.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRAdditionalDistributionAssetShowAssetCell.h"

@interface BRAdditionalDistributionAssetShowAssetCell()

@end

@implementation BRAdditionalDistributionAssetShowAssetCell

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
        _title.textAlignment = NSTextAlignmentRight;
        _title.textColor = ColorFromRGB(0x999999);
        _title.font = [UIFont systemFontOfSize:13.0f];
    }
    return _title;
}

#pragma mark - 创建UI
- (void) creatUI {
    [self addSubview:self.title];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(12);
        make.right.equalTo(self.mas_right).offset(-12);
        make.height.equalTo(@(16));
        make.top.equalTo(self.mas_top).offset(6);
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
