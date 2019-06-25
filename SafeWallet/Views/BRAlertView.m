//
//  BRAlertView.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/8/29.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRAlertView.h"

@interface BRAlertView()

/** 弹窗主内容view */
@property (nonatomic,strong) UIView  *contentView;
/** 弹窗message */
@property (nonatomic,copy)   NSString *message;
/** message label */
@property (nonatomic,strong) UILabel  *messageLabel;

@property (nonatomic,strong) UIButton *leftButton;

@property (nonatomic,strong) UIButton *rightButton;

@property (nonatomic,strong) UIButton *backButton;

@property (nonatomic,assign) NSTextAlignment type;

@end

@implementation BRAlertView

#pragma mark - 构造方法
/**
 构造方法
 
 @param message 弹窗message
 @param delegate 确定代理方
 @return 一个弹窗
 */
- (instancetype)initWithMessage:(NSString *)message messageType:(NSTextAlignment) type delegate:(id)delegate {
    if (self = [super init]) {
        self.message = message;
        self.delegate = delegate;
        self.type = type;
        // UI搭建
        [self setUpUI];
    }
    return self;
}

- (CGFloat)contentCellHeightWithText:(NSString*)text
{
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] init];
    
    NSMutableParagraphStyle *contentParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    contentParagraphStyle.lineSpacing = 0.2f;
    
    //计算标题size
    
    CGSize size = CGSizeMake(SCREEN_WIDTH - 40 * 2 - 20 * 2, CGFLOAT_MAX);
    
    //计算内容size
    NSDictionary *contentAttribute = @{NSFontAttributeName:[UIFont systemFontOfSize:16.f],
                                       NSParagraphStyleAttributeName:contentParagraphStyle,
                                       NSKernAttributeName:@(0.2)};
    CGSize contentSize = [text boundingRectWithSize:size
                                                    options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                                 attributes:contentAttribute
                                                    context:nil].size;
    
    return contentSize.height;
}

#pragma mark - UI搭建
/** UI搭建 */
- (void)setUpUI{
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    
    self.backButton = [[UIButton alloc] initWithFrame:self.frame];
    self.backButton.backgroundColor = [UIColor blackColor];
    self.backButton.alpha = 0.3;
//    [self.backButton addTarget:self action:@selector(backButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.backButton];
    
    //------- 弹窗主内容 -------//
    CGFloat height = 98 + [self contentCellHeightWithText:self.message];
    if(height < 160) height = 160;
    CGFloat margin = 40;
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.frame = CGRectMake(margin, (SCREEN_HEIGHT - height) / 2, SCREEN_WIDTH - margin * 2, height);
    self.contentView.center = self.center;
    [self addSubview:self.contentView];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.contentView.layer.cornerRadius = 6;
    
#warning Language International
    CGFloat lableWidth = 20;
    self.messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(lableWidth, 14, SCREEN_WIDTH - margin * 2 - lableWidth * 2, height - 8 - 90)];
    ;
    self.messageLabel.numberOfLines = 0;
    self.messageLabel.textColor = [UIColor blackColor];
    self.messageLabel.font = [UIFont systemFontOfSize:16.f];
    self.messageLabel.textAlignment = self.type;
    self.messageLabel.text = self.message;
    self.messageLabel.lineBreakMode = NSLineBreakByCharWrapping;
    [self.contentView addSubview:self.messageLabel];
    
    self.rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightButton.frame = CGRectMake((SCREEN_WIDTH - margin * 2) / 2 + 12, height - 60, 100, 40);
    self.rightButton.backgroundColor = MAIN_COLOR;
    [self.rightButton setTitle:NSLocalizedString(@"ok", nil) forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.rightButton.layer.cornerRadius = 3;
    self.rightButton.layer.masksToBounds = YES;
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [self.contentView addSubview:self.rightButton];
    [self.rightButton addTarget:self action:@selector(rightButtonClicked) forControlEvents:UIControlEventTouchUpInside];

    self.leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.leftButton.frame = CGRectMake((SCREEN_WIDTH - margin * 2) / 2 - 12 - 100, height - 60, 100, 40);
    self.leftButton.backgroundColor = [UIColor whiteColor];
    [self.leftButton setTitle:NSLocalizedString(@"cancel", nil) forState:UIControlStateNormal];
    self.leftButton.layer.borderWidth = 1;
    self.leftButton.layer.cornerRadius = 3;
    self.leftButton.layer.masksToBounds = YES;
    self.leftButton.layer.borderColor = ColorFromRGB255(232, 232, 232).CGColor;
    [self.leftButton setTitleColor:ColorFromRGB255(183, 183, 183) forState:UIControlStateNormal];
    self.leftButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [self.contentView addSubview:self.leftButton];
    [self.leftButton addTarget:self action:@selector(leftButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - 弹出此弹窗
/** 弹出此弹窗 */
- (void)show{
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
}

#pragma mark - 移除此弹窗
/** 移除此弹窗 */
- (void)dismiss{
    [self removeFromSuperview];
}

- (void)leftButtonClicked{
    self.leftButton.enabled = NO;
    self.rightButton.enabled = NO;
    self.backButton.enabled = NO;
    [self dismiss];
}

- (void)rightButtonClicked{
    self.leftButton.enabled = NO;
    self.rightButton.enabled = NO;
    self.backButton.enabled = NO;
    if([self.delegate respondsToSelector:@selector(loadSendTxRequest)]) {
        [self.delegate loadSendTxRequest];
    }
    [self dismiss];
}

- (void)backButtonClicked{
    self.leftButton.enabled = NO;
    self.rightButton.enabled = NO;
    self.backButton.enabled = NO;
    [self dismiss];
}

@end
