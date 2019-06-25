//
//  BRPublishAssetEditCandyProportionCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/9.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPublishAssetEditCandyProportionCell.h"

@interface BRPublishAssetEditCandyProportionCell()

@end

@implementation BRPublishAssetEditCandyProportionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (UIButton *)confirmBtn {
    if(_confirmBtn == nil) {
        _confirmBtn = [[UIButton alloc] init];
#warning Language International
        [_confirmBtn setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
        [_confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _confirmBtn.backgroundColor = ColorFromRGB(0x999999);
        [_confirmBtn addTarget:self action:@selector(loadSubmitInfo) forControlEvents:UIControlEventTouchUpInside];
        _confirmBtn.layer.cornerRadius = 3;
        _confirmBtn.layer.masksToBounds = YES;
        _confirmBtn.enabled = NO;
    }
    return _confirmBtn;
}

#pragma mark - 加载提交
- (void) loadSubmitInfo {
    if([self.delegate respondsToSelector:@selector(publishAssetEditCandyProportionCellLoadSubmintClick)]) {
        [self.delegate publishAssetEditCandyProportionCellLoadSubmintClick];
    }
}

#pragma mark - 创建UI
- (void) initUI {
    [self addSubview:self.confirmBtn];

    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(30);
        make.right.equalTo(self.mas_right).offset(-30);
        make.bottom.equalTo(self.mas_bottom).offset(-20);
        make.height.equalTo(@(40));
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
 
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
