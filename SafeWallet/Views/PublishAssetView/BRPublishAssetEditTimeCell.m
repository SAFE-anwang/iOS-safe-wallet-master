//
//  BRPublishAssetEditTimeCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/9.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPublishAssetEditTimeCell.h"

#define FontColor [UIColor blackColor]

@interface BRPublishAssetEditTimeCell() <UITextFieldDelegate>

@property (nonatomic,strong) UILabel *valueLable;

@property (nonatomic,strong) UILabel *number_title;

@property (nonatomic,strong) UILabel *number_subtitle;



@end

@implementation BRPublishAssetEditTimeCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
        [self.textField addTarget:self action:@selector(RestrictTextFieldLength:) forControlEvents:UIControlEventEditingChanged];
    }
    return self;
}

- (UILabel *)title {
    if(_title == nil) {
        _title = [[UILabel alloc] init];
        _title.textAlignment = NSTextAlignmentRight;
        _title.textColor = FontColor;
        _title.text = [NSString stringWithFormat:@"%@:", NSLocalizedString(@"Candy expiration time", nil)];
        _title.font = [UIFont systemFontOfSize:14.0f];
    }
    return _title;
}

- (UITextField *)textField {
    if(_textField == nil) {
        _textField = [[BRTextField alloc] init];
        _textField.delegate = self;
        _textField.font = [UIFont systemFontOfSize:14.0f];
        _textField.textColor = FontColor;
        _textField.layer.borderWidth = 1;
        _textField.layer.borderColor = ColorFromRGB255(218, 218, 218).CGColor;
        _textField.layer.cornerRadius = 3;
        _textField.layer.masksToBounds = YES;
        NSString *holderText = NSLocalizedString(@"Minimum 1 month, maximum 3 months", nil);
        NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:holderText];
        [placeholder addAttribute:NSForegroundColorAttributeName
                            value:ColorFromRGB(0x999999)
                            range:NSMakeRange(0, holderText.length)];
        [placeholder addAttribute:NSFontAttributeName
                            value:[UIFont systemFontOfSize:14]
                            range:NSMakeRange(0, holderText.length)];
        self.textField.attributedPlaceholder = placeholder;
        _textField.returnKeyType = UIReturnKeyDone;
    }
    return _textField;
}



#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if([self.delegate respondsToSelector:@selector(publishAssetEditTimeWithTime:)]) {
        [self.delegate publishAssetEditTimeWithTime:self.textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *temp = [NSString stringWithFormat:@"%@%@", self.textField.text, string];
    if (textField == self.textField) {
        //这里的if时候为了获取删除操作,如果没有次if会造成当达到字数限制后删除键也不能使用的后果.
        if (range.length == 1 && string.length == 0) {
            return YES;
        }
        //so easy
        else if ([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 1) {
            while(1){
                if ([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] <= 1) {
                    break;
                }else {
                    temp = [temp substringToIndex:temp.length-1];
                }
            }
            self.textField.text = temp;
            return NO;
        }
    }
    return YES;
}

#pragma mark - 创建UI
- (void) initUI {
//    [self addSubview:self.title];
    [self addSubview:self.textField];
    
//    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_top).offset(8);
//        make.left.equalTo(self.mas_left).offset(6);
//        make.width.equalTo(@(90));
//        make.height.equalTo(@(18));
//    }];
//
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right).offset(-12);
        make.left.equalTo(self.mas_left).offset(12);
        make.top.equalTo(self.mas_top);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)RestrictTextFieldLength:(id)sender {
    UITextField *textField = (UITextField *)sender;
    NSString *temp = textField.text;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@([temp length]) forKey:StringLength];
    [dict setValue:@"BRPublishAssetEditTimeCell" forKey:CellName];
    NSNotification *notification = [NSNotification notificationWithName:publishAssetEditTimeCellNotification object:nil userInfo:dict];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
