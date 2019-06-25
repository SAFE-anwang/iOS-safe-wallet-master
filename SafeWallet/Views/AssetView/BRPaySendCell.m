//
//  BRPaySendCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/17.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPaySendCell.h"
#import "UIImage+Utils.h"

@interface BRPaySendCell()

@end

@implementation BRPaySendCell

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

- (UIButton *)sendBtn {
    if(_sendBtn == nil) {
        _sendBtn = [[UIButton alloc] init];
        _sendBtn.backgroundColor = ColorFromRGB(0x999999);
        _sendBtn.enabled = NO;
        _sendBtn.layer.masksToBounds = YES;
        _sendBtn.layer.cornerRadius = 3;
        [_sendBtn addTarget:self action:@selector(loadSendClick) forControlEvents:UIControlEventTouchUpInside];
        [_sendBtn setTitle:NSLocalizedString(@"send", nil) forState:UIControlStateNormal];
        _sendBtn.titleLabel.font = kFont(14);
    }
    return _sendBtn;
}

- (void) loadSendClick {
    if([self.delegate respondsToSelector:@selector(BRPaySendCellLoadSendClick)]) {
        [self.delegate BRPaySendCellLoadSendClick];
    }
}

- (void)setup {
    [self addSubview:self.sendBtn];
    
    [self.sendBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(20);
        make.right.equalTo(self.mas_right).offset(-20);
        make.height.equalTo(@(40));
        make.bottom.equalTo(self.mas_bottom);
    }];
}

@end
