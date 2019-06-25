//
//  BRPublishAssetRegisterCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/8.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPublishAssetRegisterCell.h"

@interface BRPublishAssetRegisterCell()

@property (nonatomic, strong) UIButton *registerApplicationBtn;

@property (nonatomic, strong) UIButton *byRegisterBtn;

@end

@implementation BRPublishAssetRegisterCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (UIButton *)registerApplicationBtn {
    if(_registerApplicationBtn == nil) {
        _registerApplicationBtn = [[UIButton alloc] init];
#warning Language International
        [_registerApplicationBtn setTitle:@"注册应用" forState:UIControlStateNormal];
        _registerApplicationBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _registerApplicationBtn.backgroundColor = MAIN_COLOR;
        [_registerApplicationBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_registerApplicationBtn addTarget:self action:@selector(subminRegisterApplication) forControlEvents:UIControlEventTouchUpInside];
        _registerApplicationBtn.layer.cornerRadius = 3;
        _registerApplicationBtn.layer.masksToBounds = YES;
    }
    return _registerApplicationBtn;
}

- (UIButton *)byRegisterBtn {
    if(_byRegisterBtn == nil) {
        _byRegisterBtn = [[UIButton alloc] init];
#warning Language International
        [_byRegisterBtn setTitle:@"我已注册" forState:UIControlStateNormal];
        _byRegisterBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        _byRegisterBtn.backgroundColor = MAIN_COLOR;
        [_byRegisterBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_byRegisterBtn addTarget:self action:@selector(loadIssueAsset) forControlEvents:UIControlEventTouchUpInside];
        _byRegisterBtn.layer.cornerRadius = 3;
        _byRegisterBtn.layer.masksToBounds = YES;
    }
    return _byRegisterBtn;
}

#pragma mark - 加载发行资产
- (void) loadIssueAsset {
    if([self.delegate respondsToSelector:@selector(publishAssetRegisterCellLoadIssueAsset)]) {
        [self.delegate publishAssetRegisterCellLoadIssueAsset];
    }
}

#pragma mark - 提交注册应用
- (void) subminRegisterApplication {
    if([self.delegate respondsToSelector:@selector(publishAssetRegisterCellLoadRegisterApplication)]) {
        [self.delegate publishAssetRegisterCellLoadRegisterApplication];
    }
}

#pragma mark - 创建UI
- (void) initUI {
    [self addSubview:self.registerApplicationBtn];
    [self addSubview:self.byRegisterBtn];
    
    [self.registerApplicationBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(24);
        make.left.equalTo(self.mas_left).offset(30);
        make.right.equalTo(self.mas_right).offset(-30);
        make.height.equalTo(@(40));
    }];
    
    [self.byRegisterBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.registerApplicationBtn.mas_bottom).offset(10);
        make.left.equalTo(self.mas_left).offset(30);
        make.right.equalTo(self.mas_right).offset(-30);
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
