//
//  BRAdditionalDistributionAssetSubmitCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/11.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRAdditionalDistributionAssetSubmitCell.h"

@interface BRAdditionalDistributionAssetSubmitCell()

//@property (nonatomic,strong) UILabel *title;
//
//@property (nonatomic,strong) UIButton *selectBtn;

@end

@implementation BRAdditionalDistributionAssetSubmitCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self creatUI];
        
    }
    return self;
}

//- (UILabel *)title {
//    if(_title == nil) {
//        _title = [[UILabel alloc] init];
//        _title.font = [UIFont systemFontOfSize:13.0f];
//        _title.textColor = [UIColor blackColor];
//        _title.layer.borderWidth = 1;
//        _title.layer.borderColor = ColorFromRGB255(218, 218, 218).CGColor;
//    }
//    return _title;
//}

- (UIButton *)submitBtn {
    if(_submitBtn == nil) {
        _submitBtn = [[UIButton alloc] init];
#warning Language International
        [_submitBtn setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
        _submitBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _submitBtn.backgroundColor = ColorFromRGB(0x999999);
        [_submitBtn addTarget:self action:@selector(loadSubmitInfo) forControlEvents:UIControlEventTouchUpInside];
        _submitBtn.layer.cornerRadius = 3;
        _submitBtn.enabled = YES;
        _submitBtn.layer.masksToBounds = YES;
    }
    return _submitBtn;
}

#pragma mark -加载提交信息
- (void) loadSubmitInfo {
    if([self.delegate respondsToSelector:@selector(additionalDistributionAssetSubmitCellLoadSubmintClick)]) {
        [self.delegate additionalDistributionAssetSubmitCellLoadSubmintClick];
    }
}

//- (UIButton *)selectBtn {
//    if(_selectBtn == nil) {
//        _selectBtn = [[UIButton alloc] init];
//        [_selectBtn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
//        [_selectBtn addTarget:self action:@selector(loadSelectType) forControlEvents:UIControlEventTouchDragInside];
//    }
//    return _selectBtn;
//}

//#pragma mark -加载选择内容
//- (void) loadSelectType {
//    if([self.delegate respondsToSelector:@selector(additionalDistributionAssetSubmitCellLoadSelectContentClick)]) {
//        [self.delegate additionalDistributionAssetSubmitCellLoadSelectContentClick];
//    }
//}

#pragma mark -创建UI
- (void) creatUI {
//    [self addSubview:self.title];
//    [self addSubview:self.selectBtn];
    [self addSubview:self.submitBtn];
    
//    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.mas_left).offset(30);
//        make.right.equalTo(self.mas_right).offset(-12);
//        make.height.equalTo(@(30));
//        make.top.equalTo(self.mas_top).offset(16);
//    }];
//
//    [self.selectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_top).offset(16);
//        make.right.equalTo(self.mas_right).offset(-12);
//        make.width.equalTo(@(30));
//        make.height.equalTo(@(30));
//    }];
    
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(30));
        make.right.equalTo(@(-30));
        make.bottom.equalTo(self.mas_bottom);
        make.height.equalTo(@(40));
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
