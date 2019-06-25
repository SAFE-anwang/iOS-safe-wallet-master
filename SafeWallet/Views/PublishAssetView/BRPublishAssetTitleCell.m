
//
//  BRPublishAssetTitleCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/11.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPublishAssetTitleCell.h"

@implementation BRPublishAssetTitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self creatUI];
        
    }
    return self;
}

#pragma mark - creatUI
- (void) creatUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.contentView.backgroundColor = [UIColor clearColor];
    
    UIView *backView = [[UIView alloc] initWithFrame:CGRectMake(20, 20, SCREEN_WIDTH - 40, 80)];
    backView.backgroundColor = [UIColor whiteColor];
    backView.layer.cornerRadius = 10.f;
    backView.layer.shadowColor = [UIColor grayColor].CGColor;
    backView.layer.shadowOffset = CGSizeMake(4, 4);
    backView.layer.shadowRadius = 8.f;
    backView.layer.shadowOpacity = 0.5f;
    [self.contentView addSubview:backView];
    
    self.title = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH - 40, 20)];
    self.title.backgroundColor = [UIColor clearColor];
    self.title.textColor = [UIColor blackColor];
    self.title.textAlignment = NSTextAlignmentCenter;
    self.title.font = [UIFont systemFontOfSize:16.f];
    [backView addSubview:self.title];
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
