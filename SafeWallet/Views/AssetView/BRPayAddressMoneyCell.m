//
//  BRPayAddressMoneyCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/17.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPayAddressMoneyCell.h"
#import "BRWalletManager.h"
#import "NSString+Dash.h"
#import "BRSafeUtils.h"
#import "UIImage+Utils.h"
#import "BRIssueDataEnity+CoreDataProperties.h"

@interface BRPayAddressMoneyCell() <UITextFieldDelegate>

@property (nonatomic,strong) UIView *showView;

@property (nonatomic,strong) UIImageView *showImageView;

@property (nonatomic,assign) BOOL isHaveDian;

@property (nonatomic,strong) UILabel *showUint;

@end

@implementation BRPayAddressMoneyCell

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
        [self.textField addTarget:self action:@selector(RestrictTextFieldLength:) forControlEvents:UIControlEventEditingChanged];
    }
    
    return self;
}

- (UIImageView *)showImageView {
    if(_showImageView == nil) {
        _showImageView = [[UIImageView alloc] init];
        _showImageView.image = [[UIImage imageNamed:@"Dash-Light"] imageWithTintColor:MAIN_COLOR];
    }
    return _showImageView;
}

- (UIView *)showView {
    if(_showView == nil) {
        _showView = [[UIView alloc] init];
        _showView.layer.borderWidth = 1;
        _showView.layer.borderColor = ColorFromRGB255(218, 218, 218).CGColor;
        _showView.layer.masksToBounds = YES;
        _showView.layer.cornerRadius = 3;
    }
    return _showView;
}

- (UILabel *)titleLabel {
    if(_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
        _titleLabel.text = NSLocalizedString(@"Amount to be paid", nil);
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (UILabel *)showUint {
    if(_showUint == nil) {
        _showUint = [[UILabel alloc] init];
        _showUint.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
        if([[[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name] integerValue] == 3) {
            _showUint.text = @"m";
        } else if ([[[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name] integerValue] == 4) {
            _showUint.text = @"μ";
        } else {
            _showUint.text = @"";
        }
        _showUint.textColor = ColorFromRGB(0x999999);
    }
    return _showUint;
}

- (BRAmountTextField *)textField {
    if(_textField == nil) {
        _textField = [[BRAmountTextField alloc] init];
        _textField.keyboardType = UIKeyboardTypeDecimalPad;
        _textField.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
        _textField.placeholder = @"0";
        _textField.delegate = self;
    }
    return _textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if([self.delegate respondsToSelector:@selector(payAddressMoneyCellAmount:)]) {
        [self.delegate payAddressMoneyCellAmount:self.textField.text];
    }
}

- (void)setBalanceModel:(BRBalanceModel *)balanceModel {
    _balanceModel = balanceModel;
    if(balanceModel.assetId.length != 0) {
        self.showUint.hidden = YES;
        self.showImageView.hidden = YES;
        [self.showUint mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(0));
            make.left.equalTo(self.showView.mas_left).offset(0);
        }];
        
        [self.textField mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.showView.mas_left).offset(6);
        }];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /*
     * 不能输入.0-9以外的字符。
     * 设置输入框输入的内容格式
     * 只能有一个小数点
     * 小数点后最多能输入两位
     * 如果第一位是.则前面加上0.
     * 如果第一位是0则后面必须输入点，否则不能输入。
     */
    // 判断是否有小数点
    
    
    if ([textField.text containsString:@"."]) {
        self.isHaveDian = YES;
    }else{
        self.isHaveDian = NO;
    }
    
    if (string.length > 0) {
        //当前输入的字符
        unichar single = [string characterAtIndex:0];
        // 不能输入.0-9以外的字符
        if (!((single >= '0' && single <= '9') || single == '.')) {
            return NO;
        }
        
        // 只能有一个小数点
        if (self.isHaveDian && single == '.') {
            return NO;
        }
        
        // 如果第一位是.则前面加上0.
        if ((textField.text.length == 0) && (single == '.')) {
//            textField.text = @"0";
            return NO;
        }
        
        if (range.location == 0 && (single == '0') && (textField.text.length != 0 && ![textField.text hasPrefix:@"."])) {
            return NO;
        }
        
        // 如果第一位是0则后面必须输入点，否则不能输入。
        if ([textField.text hasPrefix:@"0"]) {
            if (textField.text.length > 1) {
                NSString *secondStr = [textField.text substringWithRange:NSMakeRange(1, 1)];
                if (![secondStr isEqualToString:@"."]) {
                    return NO;
                } else if ([secondStr isEqualToString:@"."] && range.location == 1) {
                    return NO;
                }
            } else {
                if (![string isEqualToString:@"."]) {
                    return NO;
                }
            }
        }
        
        // 小数点后最多能输入两位
        if (self.isHaveDian) {
            NSRange ran = [textField.text rangeOfString:@"."];
            // 由于range.location是NSUInteger类型的，所以这里不能通过(range.location - ran.location)>2来判断
            if (range.location > ran.location) {
                if(self.balanceModel.assetId.length == 0) {
                    if(textField.text.length - ran.location > [BRSafeUtils limitSafeDecimal]) {
                        return NO;
                    }
//                    if ([textField.text pathExtension].length > [BRSafeUtils limitSafeDecimal] - 1) {
//                        return NO;
//                    }
                } else {
                    if (textField.text.length - ran.location > self.balanceModel.multiple) {
                        return NO;
                    }
                }
            } else {
                if(self.issueList.count != 0) {
                    BRIssueDataEnity *issueData = self.issueList.firstObject;
                    if(ran.location > ([NSString stringWithFormat:@"%@", issueData.totalAmount].length - self.balanceModel.multiple-1)) {
                        return NO;
                    }
                } else {
                    int bit = 0;
                    NSInteger index;
                    if(![[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name]) {
                        index = 2;
                    } else {
                        index = [[[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name] integerValue];
                    }
                    if(index == 0) {
                        bit = 0;
                    } else if (index == 1) {
                        bit = 0;
                    } else if (index == 2) {
                        bit = 0;
                    } else if (index == 3) {
                        bit = 3;
                    } else {
                        bit = 6;
                    }
                    if(ran.location > 7 + bit) {
                        return NO;
                    }
                }
            }
        } else {
            if(self.issueList.count != 0) {
                BRIssueDataEnity *issueData = self.issueList.firstObject;
                if(textField.text.length > ([NSString stringWithFormat:@"%@", issueData.totalAmount].length - self.balanceModel.multiple - 1) && (single != '.')) {
                    return NO;
                }
            } else {
                int bit = 0;
                NSInteger index;
                if(![[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name]) {
                    index = 2;
                } else {
                    index = [[[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name] integerValue];
                }
                if(index == 0) {
                    bit = 0;
                } else if (index == 1) {
                    bit = 0;
                } else if (index == 2) {
                    bit = 0;
                } else if (index == 3) {
                    bit = 3;
                } else {
                    bit = 6;
                }
                if(textField.text.length > 7 + bit && (single != '.')) {
                    return NO;
                }
            }
        }
    }
    
    return YES;
}

- (void)setup {
    [self addSubview:self.showImageView];
    [self addSubview:self.showView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.textField];
    [self addSubview:self.showUint];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(24);
        make.left.equalTo(self.mas_left).offset(12);
        make.right.equalTo(self.mas_right).offset(-12);
        make.height.equalTo(@(20));
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.showImageView.mas_right).offset(-2);
        make.right.equalTo(self.showView.mas_right);
        make.top.equalTo(self.showView.mas_top);
        make.bottom.equalTo(self.showView.mas_bottom);
    }];
    
    [self.showUint mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.showImageView.mas_left);
        make.top.equalTo(self.showView.mas_top).offset(4);
        make.bottom.equalTo(self.showView.mas_bottom);
    }];
    
    [self.showImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.showView.mas_left).offset(11);
        make.centerY.equalTo(self.showView.mas_centerY).offset(2);
        make.height.equalTo(@(12));
        make.width.equalTo(@(12));
    }];
    
    [self.showView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
        make.left.equalTo(self.mas_left).offset(12);
        make.right.equalTo(self.mas_right).offset(-12);
        make.height.equalTo(@(40));
    }];
}

- (void)RestrictTextFieldLength:(id)sender {
    UITextField *textField = (UITextField *)sender;
    NSString *temp = textField.text;
 
    if(temp.length >= 2) {
        while ([temp hasPrefix:@"0"]) {
            if(temp.length >= 2) {
                NSString *next = [temp substringWithRange:NSMakeRange(1, 1)];
                if(![next isEqualToString:@"0"]) {
                    if(![next isEqualToString:@"."]) {
                        temp = [temp substringFromIndex:1];
                    }
                    break;
                }
            }
            temp = [temp substringFromIndex:1];
        }
        if([temp rangeOfString:@"."].location == NSNotFound) {
            if(self.balanceModel.assetId.length != 0) {
                 BRIssueDataEnity *issueData = self.issueList.firstObject;
                if(temp.length > ([NSString stringWithFormat:@"%@", issueData.totalAmount].length - self.balanceModel.multiple)) {
                    temp = [temp substringWithRange:NSMakeRange(0, ([NSString stringWithFormat:@"%@", issueData.totalAmount].length - self.balanceModel.multiple))];
                }
            } else {
                int bit = 0;
                NSInteger index;
                if(![[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name]) {
                    index = 2;
                } else {
                    index = [[[NSUserDefaults standardUserDefaults] objectForKey:BRPrecision_Name] integerValue];
                }
                if(index == 0) {
                    bit = 0;
                } else if (index == 1) {
                    bit = 0;
                } else if (index == 2) {
                    bit = 0;
                } else if (index == 3) {
                    bit = 3;
                } else {
                    bit = 6;
                }
                if(temp.length > 8 + bit) {
                    temp = [temp substringWithRange:NSMakeRange(0, 8 + bit)];
                }
            }
        } else {
            if([temp hasPrefix:@"."]) {
                temp = [NSString stringWithFormat:@"0%@", temp];
            } else {
                NSRange ran = [temp rangeOfString:@"."];
                if(self.balanceModel.assetId.length != 0) {
                    if(temp.length - ran.location > self.balanceModel.multiple) {
                       temp = [temp substringWithRange:NSMakeRange(0, ran.location + self.balanceModel.multiple + 1)];
                    }
                } else {
                    if(temp.length - ran.location > [BRSafeUtils limitSafeDecimal]) {
                       temp = [temp substringWithRange:NSMakeRange(0, ran.location + [BRSafeUtils limitSafeDecimal] + 1)];
                    }
                }
            }
        }
        textField.text = temp;
    } else {
        if ([temp hasPrefix:@"."]) {
            textField.text = @"";
            temp = @"";
        }
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:temp forKey:StringLength];
    [dict setValue:@"BRPayAddressMoneyCell" forKey:CellName];
    NSNotification *notification = [NSNotification notificationWithName:payAddressMoneyCellNotification object:nil userInfo:dict];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}


@end
