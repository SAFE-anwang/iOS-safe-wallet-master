//
//  BRPublishAssetDescribeCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/8.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPublishAssetDescribeCell.h"
#import "NSString+Utils.h"
#define FontColor [UIColor blackColor]

@interface BRPublishAssetDescribeCell() <UITextViewDelegate>



@end

@implementation BRPublishAssetDescribeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewDidEdite:) name:UITextViewTextDidChangeNotification object:self.textView];

    }
    return self;
}

- (UILabel *)title {
    if(_title == nil) {
        _title = [[UILabel alloc] init];
#warning Language International
        _title.text = @"应用描述:";
        _title.textAlignment = NSTextAlignmentRight;
        _title.textColor = FontColor;
        _title.font = [UIFont systemFontOfSize:14.0f];
    }
    return _title;
}

- (PlaceholderTextView *)textView {
    if(_textView == nil) {
        _textView = [[PlaceholderTextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:14.0f];
        _textView.textColor = FontColor;
        _textView.delegate = self;
        _textView.layer.borderWidth = 1;
        _textView.layer.borderColor = ColorFromRGB255(218, 218, 218).CGColor;
        _textView.layer.cornerRadius = 3;
        _textView.layer.masksToBounds = YES;
        _textView.returnKeyType = UIReturnKeyDone;
    }
    return _textView;
}

#pragma mark -UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    //防止输入时在中文后输入英文过长直接中文和英文换行
    UITextRange *selectedRange = [textView markedTextRange];
    NSString *newText = [textView textInRange:selectedRange];//获取高亮部分
    if(newText.length > 0) {
        return;
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    NSDictionary *attributes = @{
                                 NSFontAttributeName:[UIFont systemFontOfSize:14],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    textView.attributedText = [[NSAttributedString alloc] initWithString:textView.text attributes:attributes];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if([self.delegate respondsToSelector:@selector(publishAssetDescribeCellWithContent:)]) {
        [self.delegate publishAssetDescribeCellWithContent:self.textView.text];
    }
}

- (void)textViewDidEdite:(NSNotification *)noti {
    UITextView *tv = (UITextView *)noti.object;
    while ([self hasEmoji:tv.text] || [self stringContainsEmoji:tv.text] || [tv.text stringContainsEmoji]){
        NSString *temp = [tv.text substringToIndex:tv.text.length - 2];
        while (1) {
            NSData *textData = [temp dataUsingEncoding:NSUTF8StringEncoding];
            if (textData) {
                break;
            } else {
                temp = [temp substringToIndex:temp.length - 1];
            }
        }
        tv.text = temp;
    }
    if ([tv isEqual:self.textView]) {
        UITextRange *selectedRange = [tv markedTextRange];
        UITextPosition *position = [tv positionFromPosition:selectedRange.start offset:0];
        
        if (!position) {
            while (1) {
                NSData *data = [tv.text dataUsingEncoding:NSUTF8StringEncoding];
                if (data.length <= _textLength) {
                    break;
                } else {
                    NSString *text = [tv.text substringToIndex:tv.text.length - 1];
                    while (1) {
                        NSData *textData = [text dataUsingEncoding:NSUTF8StringEncoding];
                        if (textData) {
                            break;
                        } else {
                            text = [tv.text substringToIndex:text.length - 1];
                        }
                    }
                    tv.text = text;
                }
            }
        }
    }
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

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    
    if ([textView isFirstResponder]) {
        
        if ([[[textView textInputMode] primaryLanguage] isEqualToString:@"emoji"] || ![[textView textInputMode] primaryLanguage]) {
            return NO;
        }
        
        //判断键盘是不是九宫格键盘
        if ([self isNineKeyBoard:text] ){
            return YES;
        }else{
            if ([self hasEmoji:text] || [self stringContainsEmoji:text] || [text stringContainsEmoji]){
                return NO;
            }
        }
    }
//    NSString *temp = [NSString stringWithFormat:@"%@%@", self.textView.text, text];
//    if (textView == self.textView) {
//        //这里的if时候为了获取删除操作,如果没有次if会造成当达到字数限制后删除键也不能使用的后果.
//        if (range.length == 1 && text.length == 0) {
//            return YES;
//        }
//        //so easy
//        else if ([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] > self.textLength) {
//            while(1){
//                if ([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] <= self.textLength) {
//                    break;
//                }else {
//                    temp = [temp substringToIndex:temp.length-1];
//                }
//            }
//            self.textView.text = temp;
//            return NO;
//        }
//    }
    return YES;
}

#pragma mark - 创建UI
- (void) initUI {
//    [self addSubview:self.title];
    [self addSubview:self.textView];
    
//    [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.mas_top).offset(17);
//        make.left.equalTo(self.mas_left).offset(6);
//        make.width.equalTo(@(90));
//        make.height.equalTo(@(18));
//    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.right.equalTo(self.mas_right).offset(-12);
        make.left.equalTo(self.mas_left).offset(12);
        make.bottom.equalTo(self.mas_bottom);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
