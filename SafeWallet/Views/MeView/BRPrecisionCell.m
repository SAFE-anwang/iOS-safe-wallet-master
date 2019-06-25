//
//  BRPrecisionCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/26.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPrecisionCell.h"

@interface BRPrecisionCell()

@property (nonatomic,strong) UIView *lineView;

@end

@implementation BRPrecisionCell

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

- (UIView *)lineView {
    if(_lineView == nil) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = ColorFromRGB255(218, 218, 218);
    }
    return _lineView;
}

- (void) initUI {
    [self addSubview:self.lineView];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
        make.height.equalTo(@(1));
    }];
}

@end
