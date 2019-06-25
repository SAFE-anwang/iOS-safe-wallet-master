//
//  BRRegisterRecordCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/28.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRRegisterRecordCell.h"

@implementation BRRegisterRecordCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    CGFloat width = SCREEN_WIDTH - 30;
    
    UILabel *timeLable = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, width * 0.5, 20)];
    timeLable.text = @"2018/03/28 11:23";
    timeLable.textColor = [UIColor blackColor];
    timeLable.font = [UIFont systemFontOfSize:15.f];
    [self.contentView addSubview:timeLable];
    
    UILabel *appID = [[UILabel alloc] initWithFrame:CGRectMake(15 + width * 0.5, 10, width * 0.5, 20)];
    appID.text = @"应用ID：10010";
    appID.textColor = [UIColor blackColor];
    appID.font = [UIFont systemFontOfSize:15.f];
    appID.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:appID];
    
    UILabel *addressLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(timeLable.frame) + 5, width, 60)];
    addressLable.text = @"管理员地址：\nXgxrGRC8AC3Fsw8RoMi89xtn11AMqQ3gNB";
    addressLable.textColor = ColorFromRGB(0x555555);
    addressLable.font = [UIFont systemFontOfSize:15.f];
    addressLable.numberOfLines = 0;
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
