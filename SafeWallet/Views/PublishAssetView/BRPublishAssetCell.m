//
//  BRPublishAssetCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/8.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPublishAssetCell.h"
#import "NSString+Utils.h"

#define FontColor [UIColor blackColor]

@interface BRPublishAssetCell() <UITextFieldDelegate>

@end

@implementation BRPublishAssetCell

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
        _title.font = [UIFont systemFontOfSize:13.0f];
    }
    return _title;
}

- (BRTextField *)textField {
    if(_textField == nil) {
        _textField = [[BRTextField alloc] init];
        _textField.delegate = self;
        _textField.font = [UIFont systemFontOfSize:14.0f];
        _textField.textColor = FontColor;
        _textField.layer.borderWidth = 1;
        _textField.layer.borderColor = ColorFromRGB255(218, 218, 218).CGColor;
        _textField.layer.cornerRadius = 3;
        _textField.layer.masksToBounds = YES;
        _textField.returnKeyType = UIReturnKeyDone;
    }
    return _textField;
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

#pragma mark - UITextFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if([self.delegate respondsToSelector:@selector(publishAssetCellWithContent:andIndexPath:)]) {
        [self.delegate publishAssetCellWithContent:self.textField.text andIndexPath:self.indexPath];
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
        if (string.length == 0) {
            return YES;
        }
        //so easy
        else if (self.type == BRPublishAssetCellTypePublishAsset && (self.indexPath.row == 8 || self.indexPath.row == 10)) {
            // 判断是否有小数点
            BOOL isHaveDian;
            if ([textField.text containsString:@"."]) {
                isHaveDian = YES;
            }else{
                isHaveDian = NO;
            }
            if (string.length > 0) {
                //当前输入的字符
                unichar single = [string characterAtIndex:0];
                // 不能输入.0-9以外的字符
                if (!((single >= '0' && single <= '9') || single == '.')) {
                    return NO;
                }
                
                // 只能有一个小数点
                if (isHaveDian && single == '.') {
                    return NO;
                }
                
                // 如果第一位是.则前面加上0.
                if (range.location == 0 && (single == '.')) {
                    return NO;
                }
                
                if (range.location == 0 && (single == '0')) {
                    return NO;
                }
                
                // 小数点后最多能输入两位
                if (isHaveDian) {
                    NSRange ran = [textField.text rangeOfString:@"."];
                    // 由于range.location是NSUInteger类型的，所以这里不能通过(range.location - ran.location)>2来判断
                    if (range.location > ran.location) {
                        if (textField.text.length - ran.location > 10) {
                            return NO;
                        }
                    } else {
                        if(ran.location > 14) {
                            return NO;
                        }
                    }
                } else {
                    if(textField.text.length > 14 && (single != '.')) {
                        return NO;
                    }
                }
            }
//            NSArray *strArray = [temp componentsSeparatedByString:@"."];
//            if(strArray.count > 1) {
//                if(strArray.count > 2) {
//                    temp = [temp substringToIndex:temp.length-1];
//                    self.textField.text = temp;
//                    return NO;
//                } else {
//                    NSString *tempOne = strArray.firstObject;
//                    if(tempOne.isEmpty) {
//                        self.textField.text = @"";
//                        return NO;
//                    }
//                    NSString *tempTwo = strArray.lastObject;
//                    if ([tempTwo lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 10) {
//                        while(1){
//                            if ([tempTwo lengthOfBytesUsingEncoding:NSUTF8StringEncoding] <= 10) {
//                                break;
//                            }else {
//                                tempTwo = [tempTwo substringToIndex:tempTwo.length-1];
//                            }
//                        }
//                        self.textField.text = [strArray.firstObject stringByAppendingFormat:@".%@", tempTwo];
//                        return NO;
//                    }
//                }
//            } else {
//                if ([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 15) {
//                    while(1){
//                        if ([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] <= 15) {
//                            break;
//                        }else {
//                            temp = [temp substringToIndex:temp.length-1];
//                        }
//                    }
//                    self.textField.text = temp;
//                    return NO;
//                } else if ([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 1 && temp.longLongValue == 0) {
//                    self.textField.text = @"";
//                    return NO;
//                }
//            }
        } else if (self.type == BRPublishAssetCellTypePublishAsset && self.indexPath.row == 4) {
            if(range.location == 0) {
                NSString *regex = @"[0-9]*";
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
        } else if (self.type == BRPublishAssetCellTypeAddPublishAsset && self.indexPath.row == 3) {
            // 判断是否有小数点
            BOOL isHaveDian;
            if ([textField.text containsString:@"."]) {
                isHaveDian = YES;
            }else{
                isHaveDian = NO;
            }
            
            if (string.length > 0) {
                //当前输入的字符
                unichar single = [string characterAtIndex:0];
                // 不能输入.0-9以外的字符
                if (!((single >= '0' && single <= '9') || single == '.')) {
                    return NO;
                }
                
                // 只能有一个小数点
                if (isHaveDian && single == '.') {
                    return NO;
                }
                
                // 如果第一位是.则前面加上0.
                if (range.location == 0 && (single == '.')) {
                    return NO;
                }
                
                if (range.location == 0 && (single == '0') && textField.text.length != 0) {
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
                if (isHaveDian) {
                    NSRange ran = [textField.text rangeOfString:@"."];
                    // 由于range.location是NSUInteger类型的，所以这里不能通过(range.location - ran.location)>2来判断
                    if (range.location > ran.location) {
                        if (textField.text.length - ran.location > 10) {
                            return NO;
                        }
                    } else {
                        if(ran.location > 14) {
                            return NO;
                        }
                    }
                } else {
                    if(textField.text.length > 14 && (single != '.')) {
                        return NO;
                    }
                }
            }
//            NSArray *strArray = [temp componentsSeparatedByString:@"."];
//            if(strArray.count > 1) {
//                if(strArray.count > 2) {
//                    temp = [temp substringToIndex:temp.length-1];
//                    self.textField.text = temp;
//                    return NO;
//                } else {
//                    NSString *tempOne = strArray.firstObject;
//                    if(tempOne.isEmpty) {
//                        self.textField.text = @"";
//                        return NO;
//                    }
//                    NSString *tempTwo = strArray.lastObject;
//                    if ([tempTwo lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 10) {
//                        while(1){
//                            if ([tempTwo lengthOfBytesUsingEncoding:NSUTF8StringEncoding] <= 10) {
//                                break;
//                            }else {
//                                tempTwo = [tempTwo substringToIndex:tempTwo.length-1];
//                            }
//                        }
//                        self.textField.text = [strArray.firstObject stringByAppendingFormat:@".%@", tempTwo];
//                        return NO;
//                    }
//                }
//            } else {
//                if ([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > 15) {
//                    while(1){
//                        if ([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] <= 15) {
//                            break;
//                        }else {
//                            temp = [temp substringToIndex:temp.length-1];
//                        }
//                    }
//                    self.textField.text = temp;
//                    return NO;
//                } else if ([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] == 1 && temp.longLongValue == 0) {
//                    self.textField.text = @"";
//                    return NO;
//                }
//            }
        } else if (self.type == BRPublishAssetCellTypePublishAsset && self.indexPath.row == 12) {
            if (range.location == 0 && ([string  isEqual: @"0"])) {
                return NO;
            }
        } else if (self.type == BRPublishAssetCellTypePublishAsset &&  self.indexPath.row == 6 ) {
            //判断键盘是不是九宫格键盘
            if ([self isNineKeyBoard:string] ){
                return YES;
            } else {
                if ([self hasEmoji:string] || [self stringContainsEmoji:string] || [string stringContainsEmoji]){
                    return NO;
                }
            }
        }
    }
   
    return YES;
}

#pragma mark - 创建UI
- (void) initUI {
//    [self addSubview:self.title];
    [self addSubview:self.textField];
    
//    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_top).offset(19);
//        make.left.equalTo(self.mas_left).offset(6);
//        make.width.equalTo(@(90));
//        make.height.equalTo(@(18));
//    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.mas_bottom);
        make.right.equalTo(self.mas_right).offset(-12);
        make.left.equalTo(self.mas_left).offset(12);
        make.height.equalTo(@(40));
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

- (void)RestrictTextFieldLength:(id)sender {
    
    UITextField *textField = (UITextField *)sender;
    NSString *temp = textField.text;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.type == BRPublishAssetCellTypeAddPublishAsset && self.indexPath.row == 3) {
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
            if([temp rangeOfString:@"."].location == NSNotFound && temp.length > 15) {
                temp = [temp substringWithRange:NSMakeRange(0, 15)];
            } else {
                if([temp hasPrefix:@"."]) {
                    temp = [NSString stringWithFormat:@"0%@", temp];
                } else if ([temp rangeOfString:@"."].location != NSNotFound) {
                    NSRange ran = [temp rangeOfString:@"."];
                    if(temp.length - ran.location > 10) {
                        temp = [temp substringWithRange:NSMakeRange(0, ran.location + 10 + 1)];
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
        [dict setValue:temp forKey:StringLength];
    } else {
        if(self.type == BRPublishAssetCellTypePublishAsset && (self.indexPath.row == 6 || self.indexPath.row == 4)) {
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
        }
        [dict setValue:@([temp length]) forKey:StringLength];
    }
    [dict setValue:@"BRPublishAssetCell" forKey:CellName];
    [dict setValue:@(self.type) forKey:publishAssetCellType];
    [dict setValue:self.indexPath forKey:publishAssetCellIndexPath];
    NSNotification *notification = [NSNotification notificationWithName:publishAssetCellNotification object:nil userInfo:dict];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    if (self.type == BRPublishAssetCellTypeAddPublishAsset && self.indexPath.row == 3) return;
    if (self.type == BRPublishAssetCellTypePublishAsset && (self.indexPath.row == 8 || self.indexPath.row == 10)) {
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
            if([temp rangeOfString:@"."].location == NSNotFound && temp.length > 15) {
                temp = [temp substringWithRange:NSMakeRange(0, 15)];
            } else {
                if([temp hasPrefix:@"."]) {
                    temp = [temp substringWithRange:NSMakeRange(1, temp.length - 1)];
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
                } else if ([temp rangeOfString:@"."].location != NSNotFound) {
                    NSRange ran = [temp rangeOfString:@"."];
                    if(temp.length - ran.location > 10) {
                        temp = [temp substringWithRange:NSMakeRange(0, ran.location + 10 + 1)];
                    }
                }
            }
            textField.text = temp;
        } else {
            if ([temp hasPrefix:@"."]) {
                textField.text = @"";
            }
        }
        return;
    }
    BRLog(@"text = %@", self.textField.text);
    
    if (textField.markedTextRange == nil) {
        if([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] <= self.stringLength) {
            
            if (self.type == BRPublishAssetCellTypePublishAsset && self.indexPath.row == 4) {
                BOOL isYes = NO;
                NSString *regex = @"^[a-zA-Z0-9\\u4e00-\\u9fa5]+$";
                NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
                while (![emailTest evaluateWithObject:temp] && temp.length > 0) {
                    temp = [temp substringToIndex:temp.length-1];
                    isYes = YES;
                }
                if(isYes) {
                    textField.text = temp;
                }
            } else if (self.type == BRPublishAssetCellTypePublishAsset && self.indexPath.row == 6) {
                BOOL isYes = NO;
                NSString *regex = @"^[a-zA-Z\\u4e00-\\u9fa5]+$";
                NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
                while (![emailTest evaluateWithObject:temp] && temp.length > 0) {
                    temp = [temp substringToIndex:temp.length-1];
                    isYes = YES;
                }
                if(isYes) {
                    textField.text = temp;
                }
            } else if(self.type == BRPublishAssetCellTypePublishAsset && self.indexPath.row == 12) {
                if([temp integerValue] > 10) {
                    textField.text = @"10";
                } else {
                    for(int i=0; i<temp.length; i++) {
                        int charStr = [temp characterAtIndex:i];
                        if(!(charStr >= '0' && charStr <= '9')) {
                            textField.text = [temp substringToIndex:i];
                            break;
                        }
                    }
                }
            }
            return;
        }
        while (1) {
            NSData *data = [temp dataUsingEncoding:NSUTF8StringEncoding];
            if (data.length <= self.stringLength) {
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
        if (self.type == BRPublishAssetCellTypePublishAsset && self.indexPath.row == 4) {
            NSString *regex = @"^[a-zA-Z0-9\\u4e00-\\u9fa5]+$";
            NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            while (![emailTest evaluateWithObject:temp] && temp.length > 0) {
                temp = [temp substringToIndex:temp.length-1];
            }
        } else if (self.type == BRPublishAssetCellTypePublishAsset && self.indexPath.row == 6) {
            NSString *regex = @"^[a-zA-Z\\u4e00-\\u9fa5]+$";
            NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
            while (![emailTest evaluateWithObject:temp] && temp.length > 0) {
                temp = [temp substringToIndex:temp.length-1];
            }
        } else if(self.type == BRPublishAssetCellTypePublishAsset && self.indexPath.row == 12) {
            if([temp integerValue] > 10) {
                temp = @"10";
            } else {
                for(int i=0; i<temp.length; i++) {
                    int charStr = [temp characterAtIndex:i];
                    if(!(charStr >= '0' && charStr <= '9')) {
                        temp = [temp substringToIndex:i];
                        break;
                    }
                }
            }
        }
        textField.text = temp;
    }
}

@end
