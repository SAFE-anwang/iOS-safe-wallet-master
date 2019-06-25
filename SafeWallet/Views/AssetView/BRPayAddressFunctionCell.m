//
//  BRPayAddressFunctionCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/17.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPayAddressFunctionCell.h"

@interface BRPayAddressFunctionCell()

@property (nonatomic,strong) UIButton *pasteBtn;

@property (nonatomic,strong) UIButton *codeBtn;

@end

@implementation BRPayAddressFunctionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setup];
    }
    
    return self;
}

- (UIButton *)pasteBtn {
    if(_pasteBtn == nil) {
        _pasteBtn = [[UIButton alloc] init];
        [_pasteBtn addTarget:self action:@selector(loadPasteClick) forControlEvents:UIControlEventTouchUpInside];
        _pasteBtn.backgroundColor = MAIN_COLOR;
        _pasteBtn.layer.masksToBounds = YES;
        _pasteBtn.layer.cornerRadius = 3;
        [_pasteBtn setTitle:NSLocalizedString(@"Paste address", nil) forState:UIControlStateNormal];
        _pasteBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_pasteBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _pasteBtn;
}

- (UIButton *)codeBtn {
    if(_codeBtn == nil) {
        _codeBtn = [[UIButton alloc] init];
        [_codeBtn addTarget:self action:@selector(loadCodeClick) forControlEvents:UIControlEventTouchUpInside];
        _codeBtn.backgroundColor = MAIN_COLOR;
        _codeBtn.layer.masksToBounds = YES;
        _codeBtn.layer.cornerRadius = 3;
        [_codeBtn setTitle:NSLocalizedString(@"Scan QR Code", nil) forState:UIControlStateNormal];
        _codeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_codeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _codeBtn;
}

- (void) loadPasteClick {
    if([self.delegate respondsToSelector:@selector(payAddressFunctionCellLoadPasteClick)]) {
        [self.delegate payAddressFunctionCellLoadPasteClick];
    }
}

- (void) loadCodeClick {
    if([self.delegate respondsToSelector:@selector(payAddressFunctionCellLoadCodeClick)]) {
        [self.delegate payAddressFunctionCellLoadCodeClick];
    }
}

- (void)setup {
    [self addSubview:self.pasteBtn];
    [self addSubview:self.codeBtn];
    
    [self.pasteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(14);
        make.left.equalTo(self.mas_left).offset(12);
        make.right.equalTo(self.codeBtn.mas_left).offset(-30);
        make.bottom.equalTo(self.mas_bottom);
        make.width.equalTo(self.codeBtn.mas_width);
    }];
    
    
    [self.codeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(14);
        make.left.equalTo(self.pasteBtn.mas_right).offset(30);
        make.right.equalTo(self.mas_right).offset(-12);
        make.bottom.equalTo(self.mas_bottom);
        make.width.equalTo(self.pasteBtn.mas_width);
    }];
}

@end
