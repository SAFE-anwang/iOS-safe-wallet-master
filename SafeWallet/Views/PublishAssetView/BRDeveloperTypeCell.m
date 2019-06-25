//
//  BRDeveloperTypeCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/8.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRDeveloperTypeCell.h"

#define FontColor [UIColor blackColor]

@interface BRDeveloperTypeCell()

//@property (nonatomic, strong) UIButton *selectBtn;

@property (nonatomic, strong) UIView *frameView;

@property (nonatomic, strong) UIImageView *indecatorImg;

@end

@implementation BRDeveloperTypeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (UIView *)frameView {
    if(_frameView == nil) {
        _frameView = [[UIView alloc] init];
        _frameView.layer.borderWidth = 1;
        _frameView.layer.borderColor = ColorFromRGB255(218, 218, 218).CGColor;
        _frameView.layer.cornerRadius = 3;
        _frameView.layer.masksToBounds = YES;
    }
    return _frameView;
}

- (UILabel *)name {
    if(_name == nil) {
        _name = [[UILabel alloc] init];
#warning Language International
        _name.text = @"开发者类型:";
        _name.textAlignment = NSTextAlignmentRight;
        _name.textColor = FontColor;
        _name.font = [UIFont systemFontOfSize:14.0f];
    }
    return _name;
}

- (BRLabel *)title {
    if(_title == nil) {
        _title = [[BRLabel alloc] init];
        _title.textColor = FontColor;
        _title.font = [UIFont systemFontOfSize:14.0f];
        _title.textInsets = UIEdgeInsetsMake(0, 4, 0, 0);
    }
    return _title;
}

- (UIImageView *)indecatorImg {
    if (!_indecatorImg) {
        _indecatorImg = [[UIImageView alloc] initWithImage: [UIImage imageNamed:@"triangle"]];
    }
    return _indecatorImg;
}

//-(UIButton *)selectBtn {
//    if(_selectBtn == nil) {
//        _selectBtn = [[UIButton alloc] init];
//        [_selectBtn setImage:[UIImage imageNamed:@"triangle"] forState:UIControlStateNormal];
//        [_selectBtn addTarget:self action:@selector(loadSelectType) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _selectBtn;
//}

#pragma mark - 加载选择类型
- (void) loadSelectType {
//    if([self.delegate respondsToSelector:@selector(developerTypeCellLoadTypeView)]) {
//        [self.delegate developerTypeCellLoadTypeView];
//    }
}

#pragma mark - 创建UI
- (void) initUI {
    [self addSubview:self.frameView];
    [self addSubview:self.title];
//    [self addSubview:self.name];
    [self addSubview:self.indecatorImg];
    
//    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_top).offset(19);
//        make.left.equalTo(self.mas_left).offset(6);
//        make.width.equalTo(@(90));
//        make.height.equalTo(@(18));
//    }];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(11);
        make.right.equalTo(self.mas_right).offset(-50);
        make.left.equalTo(self.mas_left).offset(12);
        make.height.equalTo(@(40));
    }];
    
    [self.frameView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(11);
        make.right.equalTo(self.mas_right).offset(-12);
        make.left.equalTo(self.mas_left).offset(12);
        make.height.equalTo(@(40));
    }];

    [self.indecatorImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-18);
        make.height.equalTo(@(10));
        make.width.equalTo(@(16));
        make.centerY.equalTo(self.title);
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
