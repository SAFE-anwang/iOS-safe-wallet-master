//
//  BRPayLockCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/17.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRPayLockCell.h"
#import "BRPeerManager.h"
#import "BRSafeUtils.h"
@interface BRPayLockCell() <UITextFieldDelegate>

@property (nonatomic,strong) UIButton *lockBtn;

@property (nonatomic,strong) UILabel *lockLabel;

@property (nonatomic,strong) UIView *lockView;

@property (nonatomic,strong) UITextField *textField;

@property (nonatomic,strong) UIButton *addBtn;

@property (nonatomic,strong) UIButton *minusBtn;

@property (nonatomic,strong) UILabel *monthLabel;

@property (nonatomic,assign) BOOL isLock;

@property (nonatomic,assign) BOOL isPay;

@end

@implementation BRPayLockCell

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

- (void)RestrictTextFieldLength:(id)sender {
    UITextField *textField = (UITextField *)sender;
    NSString *temp = textField.text;
    if (textField.markedTextRange == nil) {
        if([temp integerValue] <= 1) {
            textField.text = @"1";
        } else if ([temp integerValue] >= 120) {
            textField.text = @"120";
        } else {
            textField.text = [NSString stringWithFormat:@"%ld", (long)[temp integerValue]];
        }
    }
}

- (UIButton *)payBtn {
    if(_payBtn == nil) {
        _payBtn = [[UIButton alloc] init];
        [_payBtn addTarget:self action:@selector(loadSelectPay) forControlEvents:UIControlEventTouchUpInside];
    }
    return _payBtn;
}

- (void)settingIsPay:(BOOL)isPay {
    self.isPay = isPay;
    if(!isPay) {
        self.payView.backgroundColor = [UIColor whiteColor];
    } else {
        self.payView.backgroundColor = MAIN_COLOR;
    }
}

- (void)settingIsLock:(BOOL)isLock {
    self.isLock = isLock;
    if(!isLock) {
        self.lockView.backgroundColor = [UIColor whiteColor];
        self.addBtn.hidden = YES;
        self.minusBtn.hidden = YES;
        self.textField.hidden = YES;
        self.monthLabel.hidden = YES;
        self.textField.text = @"1";
    } else {
        self.lockView.backgroundColor = MAIN_COLOR;
        self.addBtn.hidden = NO;
        self.minusBtn.hidden = NO;
        self.textField.hidden = NO;
        self.monthLabel.hidden = NO;
    }
}

- (void) loadSelectPay {
//    if ([BRPeerManager sharedInstance].lastBlockHeight < TEST_START_SPOS_UNLOCK_HEIGHT && [BRPeerManager sharedInstance].lastBlockHeight >= TEST_START_SPOS_HEIGHT) {
//        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"This feature is enabled when the block height is % d", nil), TEST_START_SPOS_UNLOCK_HEIGHT] showView:nil];
//        return;
//    }
    if(self.isPay) {
        self.payView.backgroundColor = [UIColor whiteColor];
    } else {
        self.payView.backgroundColor = MAIN_COLOR;
    }
    self.lockView.backgroundColor = [UIColor whiteColor];
    [self.textField resignFirstResponder];
    self.addBtn.hidden = YES;
    self.minusBtn.hidden = YES;
    self.textField.text = @"1";
    self.textField.hidden = YES;
    self.monthLabel.hidden = YES;
    self.isPay = !self.isPay;
    self.isLock = NO;
    if([self.delegate respondsToSelector:@selector(payLockCellForSelectInstantPayment:)]) {
        [self.delegate payLockCellForSelectInstantPayment:self.isPay];
    }
}

- (UILabel *)payLabel {
    if(_payLabel == nil) {
        _payLabel = [[UILabel alloc] init];
        _payLabel.text = NSLocalizedString(@"Use instant payment", nil);
        _payLabel.font = kFont(13);
        _payLabel.userInteractionEnabled = NO;
        _payLabel.textColor = [UIColor blackColor];
    }
    return _payLabel;
}

- (UIButton *)lockBtn {
    if(_lockBtn == nil) {
        _lockBtn = [[UIButton alloc] init];
        [_lockBtn addTarget:self action:@selector(loadSelectlock) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lockBtn;
}

- (UIView *)lockView {
    if(_lockView == nil) {
        _lockView = [[UIView alloc] init];
        _lockView.layer.masksToBounds = YES;
        _lockView.layer.cornerRadius = 10;
        _lockView.layer.borderWidth = 1;
        _lockView.layer.borderColor = ColorFromRGB255(218, 218, 218).CGColor;
        _lockView.userInteractionEnabled = NO;
    }
    return _lockView;
}

- (void) loadSelectlock {
//    if ([BRPeerManager sharedInstance].lastBlockHeight < TEST_START_SPOS_UNLOCK_HEIGHT && [BRPeerManager sharedInstance].lastBlockHeight >= TEST_START_SPOS_HEIGHT) {
//        [AppTool showMessage:[NSString stringWithFormat:NSLocalizedString(@"This feature is enabled when the block height is % d", nil), TEST_START_SPOS_UNLOCK_HEIGHT] showView:nil];
//        return;
//    }
    if(self.isLock) {
        self.lockView.backgroundColor = [UIColor whiteColor];
        self.payView.backgroundColor = [UIColor whiteColor];
        self.addBtn.hidden = YES;
        self.minusBtn.hidden = YES;
        self.textField.hidden = YES;
        self.monthLabel.hidden = YES;
        self.textField.text = @"1";
    } else {
        self.lockView.backgroundColor = MAIN_COLOR;
        self.payView.backgroundColor = [UIColor whiteColor];
        self.addBtn.hidden = NO;
        self.minusBtn.hidden = NO;
        self.textField.hidden = NO;
        self.monthLabel.hidden = NO;
    }
    self.isLock = !self.isLock;
    self.isPay = NO;
    if([self.delegate respondsToSelector:@selector(payLockCellForSelectLock:)]) {
        [self.delegate payLockCellForSelectLock:self.isLock];
    }
}

- (UILabel *)lockLabel {
    if(_lockLabel == nil) {
        _lockLabel = [[UILabel alloc] init];
        _lockLabel.text = NSLocalizedString(@"Lock", nil);
        _lockLabel.font = kFont(13);
        _lockLabel.textColor = [UIColor blackColor];
        _lockLabel.userInteractionEnabled = NO;
    }
    return _lockLabel;
}

- (UIView *)payView {
    if(_payView == nil) {
        _payView = [[UIView alloc] init];
        _payView.layer.masksToBounds = YES;
        _payView.layer.cornerRadius = 10;
        _payView.layer.borderWidth = 1;
        _payView.layer.borderColor = ColorFromRGB255(218, 218, 218).CGColor;
        _payView.userInteractionEnabled = NO;
    }
    return _payView;
}

- (UIButton *)addBtn {
    if(_addBtn == nil) {
        _addBtn = [[UIButton alloc] init];
        [_addBtn addTarget:self action:@selector(addMonth) forControlEvents:UIControlEventTouchUpInside];
        [_addBtn setTitle:@"+" forState:UIControlStateNormal];
        [_addBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _addBtn.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        _addBtn.hidden = YES;
        _addBtn.layer.borderWidth = 1;
        _addBtn.layer.borderColor = ColorFromRGB255(218, 218, 218).CGColor;
    }
    return _addBtn;
}

- (void)addMonth {
    if([self.textField.text integerValue] >= 120) {
        self.textField.text = @"120";
    } else {
        self.textField.text = [NSString stringWithFormat:@"%ld", [self.textField.text integerValue] + 1];
    }
    if([self.delegate respondsToSelector:@selector(payLockCellForSelectLockMonth:)]) {
        [self.delegate payLockCellForSelectLockMonth:self.textField.text];
    }
}

- (UIButton *)minusBtn {
    if(_minusBtn == nil) {
        _minusBtn = [[UIButton alloc] init];
        [_minusBtn addTarget:self action:@selector(minusMonth) forControlEvents:UIControlEventTouchUpInside];
        [_minusBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_minusBtn setTitle:@"-" forState:UIControlStateNormal];
        _minusBtn.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        _minusBtn.hidden = YES;
        _minusBtn.layer.borderWidth = 1;
        _minusBtn.layer.borderColor = ColorFromRGB255(218, 218, 218).CGColor;
    }
    return _minusBtn;
}

- (void) minusMonth {
    if([self.textField.text integerValue] <= 1) {
        self.textField.text = @"1";
    } else {
        self.textField.text = [NSString stringWithFormat:@"%ld", [self.textField.text integerValue] - 1];
    }
    if([self.delegate respondsToSelector:@selector(payLockCellForSelectLockMonth:)]) {
        [self.delegate payLockCellForSelectLockMonth:self.textField.text];
    }
}

- (UILabel *)monthLabel {
    if(_monthLabel == nil) {
        _monthLabel = [[UILabel alloc] init];
        _monthLabel.text = NSLocalizedString(@"month", nil);
        _monthLabel.font = [UIFont systemFontOfSize:14];
        _monthLabel.textColor = [UIColor blackColor];
        _monthLabel.hidden = YES;
    }
    return _monthLabel;
}

- (UITextField *)textField {
    if(_textField == nil) {
        _textField = [[UITextField alloc] init];
        _textField.delegate = self;
        _textField.keyboardType = UIKeyboardTypePhonePad;
        _textField.hidden = YES;
        _textField.text = @"1";
        _textField.layer.borderWidth = 1;
        _textField.layer.borderColor = ColorFromRGB255(218, 218, 218).CGColor;
        _textField.textAlignment = NSTextAlignmentCenter;
    }
    return _textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if([self.delegate respondsToSelector:@selector(payLockCellForSelectLockMonth:)]) {
        [self.delegate payLockCellForSelectLockMonth:self.textField.text];
    }
}

- (BOOL)validateNumberByRegExp:(NSString *)string {
    BOOL isValid = YES;
    NSUInteger len = string.length;
    if (len > 0) {
        NSString *numberRegex = @"^[0-9]*$";
        NSPredicate *numberPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegex];
        isValid = [numberPredicate evaluateWithObject:string];
    }
    return isValid;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *temp = [textField.text stringByAppendingString:string];
    if(temp.length > 3) {
        return NO;
    }
    BOOL isValid = [self validateNumberByRegExp:string];
    if(!isValid) return isValid;
    if(range.location == 0 && [string isEqualToString:@"0"]) {
        return NO;
    }
    if(temp.length <= 1 && [string integerValue] <= 0) {
        self.textField.text = @"1";
        return NO;
    }
    if([temp integerValue] > 120) {
        self.textField.text = @"120";
        return NO;
    }

    return YES;
}


- (void)setup {
    self.isLock = NO;
    self.isPay = NO;
    [self addSubview:self.lockLabel];
    [self addSubview:self.lockView];
    [self addSubview:self.payLabel];
    [self addSubview:self.payView];
    [self addSubview:self.addBtn];
    [self addSubview:self.minusBtn];
    [self addSubview:self.textField];
    [self addSubview:self.monthLabel];
    [self addSubview:self.lockBtn];
    [self addSubview:self.payBtn];
    
    [self.lockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(30);
        make.left.equalTo(self.mas_left).offset(12);
        make.width.equalTo(@(20));
        make.height.equalTo(@(20));
    }];
    
    [self.lockLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.lockView.mas_right).offset(10);
        make.centerY.equalTo(self.lockView.mas_centerY);
    }];
    
    [self.lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(20);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.lockLabel.mas_right);
        make.height.equalTo(@(40));
    }];
    
    [self.addBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(20);
        make.left.equalTo(self.textField.mas_right).offset(-1);
        make.width.equalTo(@(40));
        make.height.equalTo(@(40));
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(20);
        make.left.equalTo(self.minusBtn.mas_right).offset(-1);
        make.width.equalTo(@(60));
        make.height.equalTo(@(40));
    }];
    
    [self.minusBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(20);
        make.left.equalTo(self.lockLabel.mas_right).offset(20);
        make.height.equalTo(@(40));
        make.width.equalTo(@(40));
    }];
    
    [self.monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.addBtn.mas_right).offset(8);
        make.centerY.equalTo(self.addBtn.mas_centerY);
    }];
    
    [self.payView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lockBtn.mas_bottom).offset(26);
        make.left.equalTo(self.mas_left).offset(12);
        make.width.equalTo(@(20));
        make.height.equalTo(@(20));
    }];
    
    [self.payLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.payView.mas_right).offset(10);
        make.centerY.equalTo(self.payView.mas_centerY);
        make.height.equalTo(@(20));
    }];
    
    [self.payBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lockBtn.mas_bottom).offset(16);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.payLabel.mas_right);
        make.height.equalTo(@(40));
    }];
}

@end
