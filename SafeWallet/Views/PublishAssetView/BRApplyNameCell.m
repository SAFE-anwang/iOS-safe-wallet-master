//
//  BRApplyNameCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/8.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRApplyNameCell.h"
#import "NSString+Utils.h"

#define FontColor [UIColor blackColor]

@interface BRApplyNameCell() <UITextFieldDelegate>

@end


@implementation BRApplyNameCell

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
        _title.text = @"应用名称:";
        _title.textAlignment = NSTextAlignmentRight;
        _title.textColor = FontColor;
        _title.font = [UIFont systemFontOfSize:13.0f];
    }
    return _title;
}

- (UIButton *) testingBtn {
    if(_testingBtn == nil) {
        _testingBtn = [[UIButton alloc] init];
        [_testingBtn setTitle:NSLocalizedString(@"Check for existence", nil) forState:UIControlStateNormal];
        _testingBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        _testingBtn.backgroundColor = ColorFromRGB(0x999999);
        _testingBtn.enabled = NO;
        _testingBtn.layer.cornerRadius = 3;
        _testingBtn.layer.masksToBounds = YES;
        [_testingBtn addTarget:self action:@selector(testingClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _testingBtn;
}

- (BRTextField *)textField {
    if(_textField == nil) {
        _textField = [[BRTextField alloc] init];
        _textField.font = [UIFont systemFontOfSize:13.0f];
        _textField.delegate = self;
        _textField.layer.borderWidth = 1;
        _textField.layer.borderColor = ColorFromRGB255(218, 218, 218).CGColor;
        _textField.returnKeyType = UIReturnKeyDone;
        _textField.layer.cornerRadius = 3;
        _textField.layer.masksToBounds = YES;
        [_textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}

- (void)textFieldDidChange:(UITextField *)textField {
    if (textField.text.removeFirstAndEndSpace.length) {
        self.testingBtn.enabled = YES;
        self.testingBtn.backgroundColor = MAIN_COLOR;
    } else {
        self.testingBtn.enabled = NO;
        self.testingBtn.backgroundColor = ColorFromRGB(0x999999);
    }
//    if(textField.text.length != 0)
}

- (void)setHolderText:(NSString *)holderText {
    _holderText = holderText;
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:holderText];
    [placeholder addAttribute:NSForegroundColorAttributeName
                        value:ColorFromRGB(0x999999)
                        range:NSMakeRange(0, holderText.length)];
    [placeholder addAttribute:NSFontAttributeName
                        value:[UIFont systemFontOfSize:14]
                        range:NSMakeRange(0, holderText.length)];
    self.textField.attributedPlaceholder = placeholder;
}

#pragma mark - UITextFieldDelege
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if([self.delegate respondsToSelector:@selector(applyNameCellWithString:)]) {
        [self.delegate applyNameCellWithString:self.textField.text];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    return YES;
}

-(BOOL)isNineKeyBoard:(NSString *)string
{
    NSString *other = @"➋➌➍➎➏➐➑➒";
    int len = (int)string.length;
    for(int i=0;i<len;i++)
    {
        if(!([other rangeOfString:string].location != NSNotFound))
            return NO;
    }
    return YES;
}

- (BOOL)hasEmoji:(NSString*)string;
{
    NSString *pattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", pattern];
    BOOL isMatch = [pred evaluateWithObject:string];
    return isMatch;
}

- (BOOL)stringContainsEmoji:(NSString *)string {
    
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
         
         const unichar hs = [substring characterAtIndex:0];
         // surrogate pair
         if (0xd800 <= hs && hs <= 0xdbff) {
             if (substring.length > 1) {
                 const unichar ls = [substring characterAtIndex:1];
                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                 if (0x1d000 <= uc && uc <= 0x1f77f) {
                     returnValue = YES;
                 }
             }
         } else if (substring.length > 1) {
             const unichar ls = [substring characterAtIndex:1];
             if (ls == 0x20e3) {
                 returnValue = YES;
             }
             
         } else {
             // non surrogate
             if (0x2100 <= hs && hs <= 0x27ff) {
                 returnValue = YES;
             } else if (0x2B05 <= hs && hs <= 0x2b07) {
                 returnValue = YES;
             } else if (0x2934 <= hs && hs <= 0x2935) {
                 returnValue = YES;
             } else if (0x3297 <= hs && hs <= 0x3299) {
                 returnValue = YES;
             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                 returnValue = YES;
             }
         }
     }];
    
    return returnValue;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if (string.length == 0) {
        return YES;
    }
    if(range.location == 0) {
        NSString *regex = @"[0-9\\s]*";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        if ([emailTest evaluateWithObject:string]) {
            return NO;
        }
    }

    //判断键盘是不是九宫格键盘
    if ([self isNineKeyBoard:string] ){
        return YES;
    } else {
        if ([self hasEmoji:string] || [self stringContainsEmoji:string] || [string stringContainsEmoji]){
            return NO;
        }
    }
    return YES;
}

#pragma mark - 创建UI
- (void) initUI {
    [self addSubview:self.testingBtn];
//    [self addSubview:self.title];
    [self addSubview:self.textField];
    
//    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.bottom.equalTo(self.mas_bottom).offset(-8);
//        make.left.equalTo(self.mas_left).offset(6);
//        make.width.equalTo(@(90));
//        make.height.equalTo(@(18));
//    }];
    
    [self.testingBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(0);
        make.right.equalTo(self.mas_right).offset(-12);
        make.width.equalTo(@(125));
        make.height.equalTo(@(40));
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom).offset(0);
        make.left.equalTo(self.mas_left).offset(12);
        make.right.equalTo(self.testingBtn.mas_left).offset(-8);
        make.height.equalTo(@(40));
    }];
}

#pragma mark - 点击检测事件处理
- (void) testingClick {
    [self.textField resignFirstResponder];
    if([self.delegate respondsToSelector:@selector(applyNameCellLoadTestingRequest:)]) {
        [self.delegate applyNameCellLoadTestingRequest:self.textField.text];
    }
}

- (void)RestrictTextFieldLength:(id)sender {
    UITextField *textField = (UITextField *)sender;
    NSString *temp = textField.text;
    
    while ([self hasEmoji:temp] || [self stringContainsEmoji:temp] || [temp stringContainsEmoji]){
        temp = [temp substringToIndex:temp.length - 2];
        while (1) {
            NSData *textData = [temp dataUsingEncoding:NSUTF8StringEncoding];
            if (textData) {
                break;
            } else {
                temp = [temp substringToIndex:temp.length - 1];
            }
        }
        textField.text = temp;
    }
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@([temp length]) forKey:StringLength];
    [dict setValue:@"BRApplyNameCell" forKey:CellName];
    NSNotification *notification = [NSNotification notificationWithName:applyNameCellNotification object:nil userInfo:dict];

    if (textField.markedTextRange == nil) {
        if([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] <= 20) {
            BOOL isYes = NO;
            NSString *regex = @"^[a-zA-Z0-9\\u4e00-\\u9fa5\\s]+$";
            NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            while (![emailTest evaluateWithObject:temp] && temp.length > 0) {
                temp = [temp substringToIndex:temp.length-1];
                isYes = YES;
            }
            if(isYes) {
                textField.text = temp;
            }
            return;
        }
        while (1) {
            NSData *data = [temp dataUsingEncoding:NSUTF8StringEncoding];
            if (data.length <= 20) {
                break;
            } else {
                NSString *text = [temp substringToIndex:temp.length - 1];
                while (1) {
                    NSData *textData = [text dataUsingEncoding:NSUTF8StringEncoding];
                    if (textData) {
                        break;
                    } else {
                        text = [temp substringToIndex:text.length - 1];
                    }
                }
                temp = text;
            }
        }
        NSString *regex = @"^[a-zA-Z0-9\\u4e00-\\u9fa5\\s]+$";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        while (![emailTest evaluateWithObject:temp] && temp.length > 0) {
            temp = [temp substringToIndex:temp.length-1];
        }
        textField.text = temp;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
