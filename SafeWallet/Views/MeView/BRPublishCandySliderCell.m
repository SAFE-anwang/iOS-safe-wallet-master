//
//  BRPublishCandySliderCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/16.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPublishCandySliderCell.h"
#import "UIImage+Color.h"

@interface BRPublishCandySliderCell()

@property (nonatomic,strong) UILabel *number_title;

@property (nonatomic,strong) UILabel *number_subtitle;

@property (nonatomic,strong) UILabel *title;

@property (nonatomic,strong) UISlider *sliderView;

@end

@implementation BRPublishCandySliderCell

- (UILabel *)title {
    if(_title == nil) {
        _title = [[UILabel alloc] init];
        _title.textAlignment = NSTextAlignmentRight;
        _title.textColor = [UIColor blackColor];
        _title.text = NSLocalizedString(@"Candy ratio:", nil);
        _title.font = [UIFont systemFontOfSize:14.0f];
    }
    return _title;
}

- (UISlider *)sliderView {
    if(_sliderView == nil) {
        _sliderView = [[UISlider alloc] init];
        _sliderView.maximumValue = 100.0;
        _sliderView.minimumValue = 1;
        _sliderView.minimumTrackTintColor = MAIN_COLOR;
        
        [_sliderView setThumbImage:[[UIImage imageNamed:@"circle"] renderingColor:MAIN_COLOR] forState:(UIControlStateNormal)];
        
        [_sliderView addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _sliderView;
}

- (UILabel *)number_title {
    if(_number_title == nil) {
        _number_title = [[UILabel alloc] init];
        _number_title.textAlignment = NSTextAlignmentRight;
        _number_title.textColor = ColorFromRGB(0x999999);
        _number_title.text = NSLocalizedString(@"One thousandth", nil);
        _number_title.font = [UIFont systemFontOfSize:14.0f];
    }
    return _number_title;
}

- (UILabel *)number_subtitle {
    if(_number_subtitle == nil) {
        _number_subtitle = [[UILabel alloc] init];
        _number_subtitle.textAlignment = NSTextAlignmentRight;
        _number_subtitle.textColor = ColorFromRGB(0x999999);
        _number_subtitle.text = NSLocalizedString(@"Ten percent", nil);
        _number_subtitle.font = [UIFont systemFontOfSize:14.0f];
        _number_subtitle.textAlignment = NSTextAlignmentCenter;
    }
    return _number_subtitle;
}

- (void)setSliderValue:(double)sliderValue {
    _sliderValue = sliderValue;
    self.sliderView.value = sliderValue;
}

#pragma mark - slider显示数据
- (void)sliderValueChanged:(UISlider *)slider {
    if([self.delegate respondsToSelector:@selector(publishCandySliderValue:)]) {
        [self.delegate publishCandySliderValue:slider.value];
    }
}

- (UILabel *)valueLable {
    if(_valueLable == nil) {
        _valueLable = [[UILabel alloc] init];
        _valueLable.backgroundColor = [UIColor clearColor];
        _valueLable.textColor = ColorFromRGB(0x999999);
        _valueLable.font = [UIFont systemFontOfSize:13.f];
        _valueLable.textAlignment = NSTextAlignmentCenter;
    }
    return _valueLable;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

#pragma mark - 创建UI
- (void) initUI {
    [self addSubview:self.sliderView];
    [self addSubview:self.title];
    [self addSubview:self.number_title];
    [self addSubview:self.number_subtitle];
    [self addSubview:self.valueLable];
    
    [self.valueLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(13));
        make.left.equalTo(self.title.mas_right).offset(24);
        make.right.equalTo(self.mas_right).offset(-12);
        make.top.equalTo(self.mas_top).offset(8);
    }];
    
    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(26);
        make.left.equalTo(self.mas_left).offset(12);
//        make.width.equalTo(@(80));
        make.height.equalTo(@(18));
    }];
    [self.title setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.title.mas_right).offset(4);
        make.right.equalTo(self.mas_right).offset(-12);
        make.height.equalTo(@(30));
        make.top.equalTo(self.mas_top).offset(20);
    }];
    
    [self.number_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.title.mas_right).offset(4);
        make.height.equalTo(@(15));
        make.top.equalTo(self.sliderView.mas_bottom).offset(8);
    }];
    
    [self.number_subtitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(-12);
        make.top.equalTo(self.sliderView.mas_bottom).offset(8);
        make.height.equalTo(@(15));
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
