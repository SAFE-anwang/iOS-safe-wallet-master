//
//  BRPublishAssetEditDescribeCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/9.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPublishAssetEditDescribeCell.h"
#import "NSString+Utils.h"

#define FontColor [UIColor blackColor]

@interface BRPublishAssetEditDescribeCell() <UITextViewDelegate>

@end

@implementation BRPublishAssetEditDescribeCell

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
        _textView.font = [UIFont systemFontOfSize:13.0f];
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
//- (void)textViewDidChange:(UITextView *)textView {
//    NSInteger length = [textView.text dataUsingEncoding:NSUTF8StringEncoding].length;
//    if (length > (_textLength - 50)){
//        //获得已输出字数与正输入字母数
//        UITextRange *textRange = textView.markedTextRange;
//        //获取高亮部分
//        UITextPosition *position = [textView positionFromPosition:textRange.start offset:0];
//        if (position != nil){
//            return;
//        }
//        NSString *textContent = textView.text;
//        int textNum = [textView.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
//        //截取200个字
//        if (textNum > _textLength)
//        {
//            NSRange rangeIndex = [textContent rangeOfComposedCharacterSequenceAtIndex:_textLength];
//            if (rangeIndex.length == 1)//表情占用两个字符这里能更好的判断
//            {
//                textView.text = [textContent substringToIndex:_textLength];
//            }
//            else
//            {
//                NSRange rangeRange = [textContent rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, _textLength)];
//                textView.text = [textContent substringWithRange:rangeRange];
//            }
//        }
//    }
////    self.textNum = (int)textView.text.length;
////    self.numLabel.text = [NSString stringWithFormat:@"%d/%d",self.textNum, TOTAL_NUM];
//}

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
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@([tv.text length]) forKey:StringLength];
    [dict setValue:@"BRPublishAssetEditDescribeCell" forKey:CellName];
    [dict setValue:self.indexPath forKey:publishAssetEditDescribeCellNSIndexPath];
    NSNotification *notification = [NSNotification notificationWithName:publishAssetEditDescribeCellNotification object:nil userInfo:dict];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
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
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
//    NSDictionary *attributes = @{NSParagraphStyleAttributeName:paragraphStyle};
//    self.textView.attributedText = [[NSAttributedString alloc] initWithString:tv.text attributes:attributes];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if([self.delegate respondsToSelector:@selector(publishAssetEditDescribeCellWithContent:andIndexPath:)]) {
        [self.delegate publishAssetEditDescribeCellWithContent:self.textView.text andIndexPath:self.indexPath];
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
        make.right.equalTo(self.mas_right).offset(-12);
        make.left.equalTo(self.mas_left).offset(12);
        make.bottom.equalTo(self.mas_bottom);
        make.top.equalTo(self.mas_top);
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

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
