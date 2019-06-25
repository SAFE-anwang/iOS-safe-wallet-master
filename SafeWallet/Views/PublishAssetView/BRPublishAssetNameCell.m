//
//  BRPublishAssetNameCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/16.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPublishAssetNameCell.h"

@implementation BRPublishAssetNameCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

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
        _title.textAlignment = NSTextAlignmentLeft;
        _title.textColor = [UIColor blackColor];
        _title.font = [UIFont systemFontOfSize:14.0f];
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
        make.bottom.equalTo(self.mas_bottom).offset(-10);
    }];
}

@end
