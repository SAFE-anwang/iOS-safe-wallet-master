//
//  BRCandyHistoryCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/24.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRCandyHistoryCell.h"

@implementation BRCandyHistoryCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    UILabel *assetNameLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 80, 30)];
    assetNameLable.backgroundColor = [UIColor clearColor];
    assetNameLable.text = @"SAFE";
    assetNameLable.textColor = [UIColor blackColor];
    assetNameLable.font = [UIFont systemFontOfSize:16.f];
    [self.contentView addSubview:assetNameLable];
    
    UILabel *amountLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(assetNameLable.frame) + 20, 10, SCREEN_WIDTH - 130, 30)];
    amountLable.backgroundColor = [UIColor clearColor];
    amountLable.text = @"+ 150000";
    amountLable.textColor = ColorFromRGB(0x333333);
    amountLable.textAlignment = NSTextAlignmentRight;
    amountLable.font = [UIFont systemFontOfSize:16.f weight:UIFontWeightBold];
    [self.contentView addSubview:amountLable];
    
    UILabel *addressLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 40, SCREEN_WIDTH - 30, 30)];
    addressLable.backgroundColor = [UIColor clearColor];
    addressLable.text = @"XgxrGRC8AC3Fsw8RoMi89xtn11AMqQ3gNB";
    addressLable.textColor = ColorFromRGB(0x666666);
    addressLable.font = [UIFont systemFontOfSize:16.f];
    [self.contentView addSubview:addressLable];
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
