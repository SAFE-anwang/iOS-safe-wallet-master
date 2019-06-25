//
//  BRPublishAssetEditCheckboxCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/9.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPublishAssetEditCheckboxCell.h"
#import "UIImage+Color.h"

@interface BRPublishAssetEditCheckboxCell()

@property (nonatomic,strong) UIButton *destroyBtn;

@property (nonatomic,strong) UILabel *destroyLabel;

@property (nonatomic,strong) UIButton *candyBtn;

@property (nonatomic,strong) UILabel *candyLabel;


@end

@implementation BRPublishAssetEditCheckboxCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

//UIImageView *imageV = [[UIImageView alloc] initWithImage:[UIImage roudImageWithColor:MAIN_COLOR size:100]];
//imageV.center = CGPointMake(SCREEN_WIDTH * 0.5, SCREEN_HEIGHT * 0.5);
//[[UIApplication sharedApplication].keyWindow addSubview:imageV];

- (UIButton *)destroyBtn {
    if(_destroyBtn == nil) {
        _destroyBtn = [[UIButton alloc] init];
//        _destroyBtn.layer.cornerRadius = 10.0;
//        _destroyBtn.layer.masksToBounds = YES;
//        _destroyBtn.layer.borderWidth = 1;
//        _destroyBtn.layer.borderColor = ColorFromRGB(0x999999).CGColor;
        
        [_destroyBtn setTitle:NSLocalizedString(@"Can be destroyed?", nil) forState:(UIControlStateNormal)];
        [_destroyBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        _destroyBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        
        [_destroyBtn setImage:[UIImage ImageWithColor:MAIN_COLOR size:18 round:NO] forState:(UIControlStateSelected)];
        [_destroyBtn setImage:[UIImage ImageWithColor:[UIColor whiteColor] size:18 round:NO] forState:(UIControlStateNormal)];
        _destroyBtn.imageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        _destroyBtn.imageView.layer.borderWidth = 1;
        _destroyBtn.imageView.layer.cornerRadius = 9;
        [_destroyBtn sizeToFit];
        
        [_destroyBtn addTarget:self action:@selector(loadIsDestroyBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _destroyBtn;
}

- (UILabel *)destroyLabel {
    if(_destroyLabel == nil) {
        _destroyLabel = [[UILabel alloc] init];
//        _destroyLabel.text = NSLocalizedString(@"Can be destroyed?", nil);
        _destroyLabel.font = [UIFont systemFontOfSize:14.0f];
        _destroyLabel.textColor = [UIColor blackColor];
    }
    return _destroyLabel;
}

- (UIButton *)candyBtn {
    if(_candyBtn == nil) {
    
        _candyBtn = [[UIButton alloc] init];
        [_candyBtn setTitle:NSLocalizedString(@"Do you distribute candy?", nil) forState:(UIControlStateNormal)]; // NSLocalizedString(@"Whether to distribute candy", nil)
        [_candyBtn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
        _candyBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        
        [_candyBtn setImage:[UIImage ImageWithColor:MAIN_COLOR size:18 round:NO] forState:(UIControlStateSelected)];
        [_candyBtn setImage:[UIImage ImageWithColor:[UIColor whiteColor] size:18 round:NO] forState:(UIControlStateNormal)];
        _candyBtn.imageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
        _candyBtn.imageView.layer.borderWidth = 1;
        _candyBtn.imageView.layer.cornerRadius = 9;
        [_candyBtn sizeToFit];
        [_candyBtn addTarget:self action:@selector(loadIsCandy:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _candyBtn;
}

- (void)setIsDestroy:(BOOL)isDestroy {
    _isDestroy = isDestroy;
    self.destroyBtn.selected = isDestroy;
    [self selectBtn:self.destroyBtn];
    
//    if(_isDestroy) {
//        self.destroyBtn.layer.borderWidth = 0;
//        self.destroyBtn.layer.borderColor = [UIColor clearColor].CGColor;
//        self.destroyBtn.backgroundColor = MAIN_COLOR;
//    } else {
//        self.destroyBtn.layer.borderWidth = 1;
//        self.destroyBtn.layer.borderColor = ColorFromRGB(0x999999).CGColor;
//        self.destroyBtn.backgroundColor = [UIColor clearColor];
//    }
}

- (void)selectBtn:(UIButton *)btn {
    if (btn.selected) {
        btn.imageView.layer.borderColor = MAIN_COLOR.CGColor;
    } else {
        btn.imageView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    }
}

#pragma mark - 加载是否销毁
- (void) loadIsDestroyBtn:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.isDestroy = sender.selected;
//    if(self.isDestroy) {
//        self.destroyBtn.layer.borderWidth = 0;
//        self.destroyBtn.layer.borderColor = [UIColor clearColor].CGColor;
//        self.destroyBtn.backgroundColor = MAIN_COLOR;
//    } else {
//        self.destroyBtn.layer.borderWidth = 1;
//        self.destroyBtn.layer.borderColor = ColorFromRGB(0x999999).CGColor;
//        self.destroyBtn.backgroundColor = [UIColor clearColor];
//    }
    if([self.delegate respondsToSelector:@selector(publishAssetEditCheckboxCellWithIsDestroy:)]) {
        [self.delegate publishAssetEditCheckboxCellWithIsDestroy:self.isDestroy];
    }
}

- (void)setIsCandy:(BOOL)isCandy {
    _isCandy = isCandy;
    self.candyBtn.selected = isCandy;
    [self selectBtn:self.candyBtn];
//    if(_isCandy) {
//        self.candyBtn.layer.borderWidth = 0;
//        self.candyBtn.layer.borderColor = [UIColor clearColor].CGColor;
//        self.candyBtn.backgroundColor = MAIN_COLOR;
//    } else {
//        self.candyBtn.layer.borderWidth = 1;
//        self.candyBtn.layer.borderColor = ColorFromRGB(0x999999).CGColor;
//        self.candyBtn.backgroundColor = [UIColor clearColor];
//    }
}

#pragma mark - 加载是否发糖果
- (void) loadIsCandy:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    self.isCandy = sender.selected;
//    if(self.isCandy) {
//        self.candyBtn.layer.borderWidth = 0;
//        self.candyBtn.layer.borderColor = [UIColor clearColor].CGColor;
//        self.candyBtn.backgroundColor = MAIN_COLOR;
//    } else {
//        self.candyBtn.layer.borderWidth = 1;
//        self.candyBtn.layer.borderColor = ColorFromRGB(0x999999).CGColor;
//        self.candyBtn.backgroundColor = [UIColor clearColor];
//    }
    if([self.delegate respondsToSelector:@selector(publishAssetEditCheckboxCellWithIsCandy:)]) {
        [self.delegate publishAssetEditCheckboxCellWithIsCandy:self.isCandy];
    }
}

- (UILabel *)candyLabel {
    if(_candyLabel == nil) {
        _candyLabel = [[UILabel alloc] init];
        _candyLabel.text = NSLocalizedString(@"Do you distribute candy?", nil);
        _candyLabel.font = [UIFont systemFontOfSize:14.0f];
        _candyLabel.textColor = [UIColor blackColor];
    }
    return _candyLabel;
}

#pragma mark - 创建UI
- (void) initUI {
    [self addSubview:self.destroyBtn];
//    [self addSubview:self.destroyLabel];
    [self addSubview:self.candyBtn];
//    [self addSubview:self.candyLabel];
    
    [self.destroyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(12);
        make.right.equalTo(self.candyBtn.mas_left).offset(-6);
        make.width.equalTo(self.candyBtn.mas_width);
        make.centerY.equalTo(self);
    }];
    
//    [self.destroyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.destroyBtn.mas_centerY);
//        make.height.equalTo(@(13));
//        make.right.equalTo(self.mas_centerX).offset(-20);
//    }];
    
    [self.candyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.destroyBtn.mas_right).offset(6);
        make.right.equalTo(self.mas_right).offset(-12);
        make.width.equalTo(self.candyBtn.mas_width);
        make.centerY.equalTo(self);
    }];
    
//    [self.candyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.candyBtn.mas_right).offset(6);
//        make.centerY.equalTo(self.candyBtn.mas_centerY);
//        make.height.equalTo(@(13));
//        make.right.equalTo(self.mas_right).offset(-12);
//    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

@end
