//
//  BRPayAddressCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/17.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPayAddressCell.h"

@interface BRPayAddressCell() <UITextFieldDelegate>

@property (nonatomic,strong) UILabel *titleLabel;

@end

@implementation BRPayAddressCell

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

- (UILabel *)titleLabel {
    if(_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightBold];
        _titleLabel.text = NSLocalizedString(@"Pay to", nil);
        _titleLabel.textColor = [UIColor blackColor];
    }
    return _titleLabel;
}

- (BRTextField *)textField  {
    if(_textField == nil) {
        _textField = [[BRTextField alloc] init];
        _textField.delegate = self;
        _textField.font = [UIFont systemFontOfSize:14];
        _textField.textColor = [UIColor blackColor];
        _textField.layer.borderWidth = 1;
        _textField.layer.borderColor = ColorFromRGB255(218, 218, 218).CGColor;
        _textField.layer.cornerRadius = 3;
        _textField.layer.masksToBounds = YES;
        _textField.returnKeyType = UIReturnKeyDone;
    }
    return _textField;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if([self.delegate respondsToSelector:@selector(payAddressCellForText:)]) {
        [self.delegate payAddressCellForText:self.textField.text];
    }
}

- (void)setup {
    [self addSubview:self.titleLabel];
    [self addSubview:self.textField];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(20);
        make.left.equalTo(self.mas_left).offset(12);
        make.right.equalTo(self.mas_right).offset(-12);
        make.height.equalTo(@(20));
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(6);
        make.left.equalTo(self.mas_left).offset(12);
        make.right.equalTo(self.mas_right).offset(-12);
        make.bottom.equalTo(self.mas_bottom);
    }];
}

- (void)RestrictTextFieldLength:(id)sender {
    UITextField *textField = (UITextField *)sender;
    NSString *temp = textField.text;
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:@([temp length]) forKey:StringLength];
    [dict setValue:@"BRPayAddressCell" forKey:CellName];
    NSNotification *notification = [NSNotification notificationWithName:payAddressCellNotification object:nil userInfo:dict];
    //通过通知中心发送通知
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    if (textField.markedTextRange == nil) {
        if([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding] <= 40) {
            return;
        }
        while (1) {
            NSData *data = [temp dataUsingEncoding:NSUTF8StringEncoding];
            if (data.length <= 40) {
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
        textField.text = temp;
    }
}


@end
