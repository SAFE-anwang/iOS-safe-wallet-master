//
//  BRAssetHeaderView.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/21.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRAssetHeaderView.h"

@implementation BRAssetHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self creatUI];
    }
    return self;
}

- (void)creatUI {
    
    self.backgroundColor = [UIColor whiteColor];
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 15, SCREEN_WIDTH, 40)];
    lable.numberOfLines = 0;
    lable.textColor = ColorFromRGB(0x666666);
    lable.font = kFont(13);//[UIFont systemFontOfSize:15.f];
    lable.textAlignment = NSTextAlignmentCenter;
    [self addSubview:lable];
    self.addressLable = lable;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 120) * 0.5, CGRectGetMaxY(lable.frame) + 15, 120, 120)];
    [self addSubview:imageView];
    self.qrImageView = imageView;
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(imageView.frame) + 20, SCREEN_WIDTH, 30)];
    [self addSubview:bottomView];
    
    CGFloat btnWidth = 120.f;
    CGFloat btnHeight = 40.f;
    CGFloat margin = (SCREEN_WIDTH - btnWidth * 2) / 3;
    
    UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    sendBtn.frame = CGRectMake(margin, 0, btnWidth, btnHeight);
    sendBtn.backgroundColor = MAIN_COLOR;
    sendBtn.tag = 111111;
    [sendBtn setTitle:NSLocalizedString(@"Copy", nil) forState:UIControlStateNormal];
    [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sendBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    sendBtn.titleLabel.font = kFont(14);//[UIFont systemFontOfSize:15.f];
    sendBtn.layer.cornerRadius = 6.f;
    [bottomView addSubview:sendBtn];
    [sendBtn addTarget:self action:@selector(sendAddressToOthers:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *getMoneyBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    getMoneyBtn.frame = CGRectMake(margin * 2 + btnWidth, 0, btnWidth, btnHeight);
    getMoneyBtn.backgroundColor = MAIN_COLOR;
    getMoneyBtn.tag = 222222;
    [getMoneyBtn setTitle:NSLocalizedString(@"New Address", nil) forState:UIControlStateNormal];
    [getMoneyBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    getMoneyBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    getMoneyBtn.titleLabel.font = kFont(14);//[UIFont systemFontOfSize:15.f];
    getMoneyBtn.layer.cornerRadius = 6.f;
    [bottomView addSubview:getMoneyBtn];
    [getMoneyBtn addTarget:self action:@selector(sendAddressToOthers:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)sendAddressToOthers:(UIButton *)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(sendAddress:)]) {
        [self.delegate sendAddress:sender.tag];
    }
}


@end
