//
//  BRGetCandyCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/24.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRGetCandyCell.h"

@interface BRGetCandyCell()

@end


@implementation BRGetCandyCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(5, 5, SCREEN_WIDTH - 10, 85)];
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.cornerRadius = 5.f;
    backView.layer.shadowColor = [UIColor grayColor].CGColor;
    backView.layer.shadowOffset = CGSizeMake(3, 3);
    backView.layer.shadowRadius = 5.f;
    backView.layer.shadowOpacity = 0.3f;
    [self.contentView addSubview:backView];
    
    self.assetNameLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 30 - 120 - 10, 30)];
//    self.assetNameLable.backgroundColor = UIColor.redColor;
    self.assetNameLable.text = @"SAFE";
    self.assetNameLable.textColor = [UIColor blackColor];
    self.assetNameLable.font = [UIFont systemFontOfSize:15.f];
    [self addSubview:self.assetNameLable];
    
    self.timeLable = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 120 - 15, 15, 125, 30)];
//    self.timeLable.backgroundColor = UIColor.yellowColor;

    self.timeLable.text = @"2018/12/12 13:12";
    self.timeLable.textColor = ColorFromRGB(0x666666);
    self.timeLable.font = [UIFont systemFontOfSize:14.f];
    self.timeLable.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.timeLable];
    
    self.amountLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 50, SCREEN_WIDTH - 60 - 30 - 10, 30)];
    
//    self.amountLable.backgroundColor = UIColor.cyanColor;
    self.amountLable.text = @"150000";
    self.amountLable.textColor = ColorFromRGB(0x333333);
    self.amountLable.font = [UIFont systemFontOfSize:13.f weight:UIFontWeightBold];
    [self addSubview:self.amountLable];
    
    self.getButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.getButton.frame = CGRectMake(SCREEN_WIDTH - 75, 50, 60, 30);
    self.getButton.backgroundColor = MAIN_COLOR;
    [self.getButton setTitle:NSLocalizedString(@"Get", nil) forState:UIControlStateNormal];
    [self.getButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.getButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    self.getButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.getButton.layer.cornerRadius = 3.f;
    [self.getButton addTarget:self action:@selector(getClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.getButton];
}

- (void) getClicked {
    if([self.delegate respondsToSelector:@selector(getCandyCellIndex:)]) {
        [self.delegate getCandyCellIndex:self.indexPath];
    }
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
