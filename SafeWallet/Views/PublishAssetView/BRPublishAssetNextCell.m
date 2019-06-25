//
//  BRPublishAssetNextCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/9.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPublishAssetNextCell.h"

@interface BRPublishAssetNextCell()

@property (nonatomic,strong) UIButton *nextBtn;

@end

@implementation BRPublishAssetNextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (UIButton *)nextBtn {
    if(_nextBtn == nil) {
        _nextBtn = [[UIButton alloc] init];
        [_nextBtn setTitle:@"下一步" forState:UIControlStateNormal];
        _nextBtn.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _nextBtn.backgroundColor = MAIN_COLOR;
        [_nextBtn addTarget:self action:@selector(loadNextOperation) forControlEvents:UIControlEventTouchUpInside];
        _nextBtn.layer.cornerRadius = 3;
        _nextBtn.layer.masksToBounds = YES;
    }
    return _nextBtn;
}

#pragma mark - 加载下一步
- (void) loadNextOperation {
    if([self.delegate respondsToSelector:@selector(publishAssetNextCellLoadPublishDetails)]) {
        [self.delegate publishAssetNextCellLoadPublishDetails];
    }
}

#pragma mark - 创建UI
- (void) initUI {
    [self addSubview:self.nextBtn];
    
    [self.nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(30);
        make.right.equalTo(self.mas_right).offset(-30);
        make.bottom.equalTo(self.mas_bottom);
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
