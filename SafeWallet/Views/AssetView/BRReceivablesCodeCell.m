//
//  BRReceivablesCodeCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/19.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRReceivablesCodeCell.h"

@interface BRReceivablesCodeCell()

@property (nonatomic,strong) UIButton *urlBtn;

@property (nonatomic,strong) UIButton *btn;

@end


@implementation BRReceivablesCodeCell

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

- (UIImageView *)showCodeImageView {
    if(_showCodeImageView == nil) {
        _showCodeImageView = [[UIImageView alloc] init];
    }
    return _showCodeImageView;
}

- (UIButton *)urlBtn {
    if(_urlBtn == nil) {
        _urlBtn = [[UIButton alloc] init];
        _urlBtn.backgroundColor = MAIN_COLOR;
        [_urlBtn setTitle:NSLocalizedString(@"Copy URI", nil) forState:UIControlStateNormal];
        _urlBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_urlBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_urlBtn addTarget:self action:@selector(loadCopyURIClick) forControlEvents:UIControlEventTouchUpInside];
        _urlBtn.layer.masksToBounds = YES;
        _urlBtn.layer.cornerRadius = 3;
    }
    return _urlBtn;
}

- (void) loadCopyURIClick {
    if([self.delegate respondsToSelector:@selector(receivablesCodeCellLoadCopyURLClick)]) {
        [self.delegate receivablesCodeCellLoadCopyURLClick];
    }
}

- (UIButton *)btn {
    if(_btn == nil) {
        _btn = [[UIButton alloc] init];
        [_btn setTitle:NSLocalizedString(@"Copy address", nil) forState:UIControlStateNormal];
        [_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _btn.backgroundColor = MAIN_COLOR;
        _btn.layer.masksToBounds = YES;
        _btn.layer.cornerRadius = 3;
        _btn.titleLabel.font = [UIFont systemFontOfSize:15.0];
        [_btn addTarget:self action:@selector(loadCopyClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btn;
}
- (void) loadCopyClick {
    if([self.delegate respondsToSelector:@selector(receivablesCodeCellLoadCopyAddressClick)]) {
        [self.delegate receivablesCodeCellLoadCopyAddressClick];
    }
}

- (void) setup {
    [self addSubview:self.btn];
    [self addSubview:self.urlBtn];
    [self addSubview:self.showCodeImageView];
    
    [self.urlBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.showCodeImageView.mas_bottom).offset(10);
        make.centerX.equalTo(self.mas_centerX).offset(-70);
        make.height.equalTo(@(40));
        make.width.equalTo(@(120));
    }];
    
    [self.btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.showCodeImageView.mas_bottom).offset(10);
        make.centerX.equalTo(self.mas_centerX).offset(70);
        make.height.equalTo(@(40));
        make.width.equalTo(@(120));
    }];
    
    [self.showCodeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(12);
        make.centerX.equalTo(self.mas_centerX);
        make.width.equalTo(@(200));
        make.height.equalTo(@(200));
    }];
}

@end
