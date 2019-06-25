//
//  BRHistoryHeaderView.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/21.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRHistoryHeaderView.h"
#import "BRWalletManager.h"
#import "BRSafeUtils.h"

@implementation BRHistoryHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    CGFloat margin = 5;
    /// 背景图片
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
    imageView.frame = self.frame;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [self addSubview:imageView];
    self.headerImageView = imageView;
    
    
    /// 资产总额
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin * 2, SCREEN_WIDTH - 2 * margin, 60)];
    label.text = [NSString stringWithFormat:@"%@\n%@",NSLocalizedString(@"Total Assets", nil), @"8888888888"];
    label.numberOfLines = 0;
    self.totalAssetLable = label;
    [self addSubview:label];
    
    /// 可用金额
    UILabel *useMoneyLable = [[UILabel alloc] initWithFrame:CGRectMake(margin, margin + CGRectGetMaxY(label.frame), SCREEN_WIDTH - 2 * margin, 50)];
    useMoneyLable.text = @"可使用的资产\n888888888";
    useMoneyLable.numberOfLines = 0;
    [self addSubview:useMoneyLable];
    self.useAssetLable = useMoneyLable;
    
    CGFloat y = CGRectGetMaxY(useMoneyLable.frame) + margin;
    CGFloat w = (SCREEN_WIDTH - margin * 3) * 0.5;
    /// 等待余额
    UILabel *waitMoneyLable = [[UILabel alloc] initWithFrame:CGRectMake(margin, y, w, 50)];
    waitMoneyLable.text = @"等待中的资产\n888888888";
    waitMoneyLable.numberOfLines = 0;
    [self addSubview:waitMoneyLable];
    self.waitAssetLable = waitMoneyLable;
    
    /// 锁定余额
    UILabel *lockMoneyLable = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(waitMoneyLable.frame) + margin, y, w, 50)];
    lockMoneyLable.text = @"锁定中的资产\n88888888";
    lockMoneyLable.numberOfLines = 0;
    [self addSubview:lockMoneyLable];
    self.lockAssetLable = lockMoneyLable;

}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self reloadBalanceShow];
}

- (void) reloadBalanceShow {
    for(int i=0; i<[BRWalletManager sharedInstance].wallet.balanceArray.count; i++) {
        BRBalanceModel *model = [BRWalletManager sharedInstance].wallet.balanceArray[i];
        if([self.balanceModel.assetId isEqual:model.assetId]) {
            self.balanceModel = model;
            break;
        }
    }
    uint64_t useBalance = [[BRWalletManager sharedInstance].wallet useBalance:self.balanceModel.assetId];
    uint64_t lockBalance = [[BRWalletManager sharedInstance].wallet lockBalance:self.balanceModel.assetId];
    if(self.balanceModel.assetId.length == 0) {
        self.totalAssetLable.attributedText = [self createAttributeString:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"Total", nil), [BRSafeUtils showSAFEAmount:self.balanceModel.balance]] fontSize:14];
        self.useAssetLable.attributedText = [self createAttributeString:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"Amount available", nil), [BRSafeUtils showSAFEAmount:useBalance]] fontSize:12];
        self.waitAssetLable.attributedText = [self createAttributeString:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"Amount waiting", nil), [BRSafeUtils showSAFEAmount:self.balanceModel.balance - useBalance - lockBalance]] fontSize:12];
        self.lockAssetLable.attributedText = [self createAttributeString:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"Amount in lock", nil), [BRSafeUtils showSAFEAmount:lockBalance]] fontSize:12];
    } else {
        self.totalAssetLable.attributedText = [self createAttributeString:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"Total", nil), [BRSafeUtils amountForAssetAmount:self.balanceModel.balance decimals:self.balanceModel.multiple]] fontSize:14];
        self.useAssetLable.attributedText = [self createAttributeString:[NSString stringWithFormat:@"%@\n%@",  NSLocalizedString(@"Amount available", nil),  [BRSafeUtils amountForAssetAmount:useBalance decimals:self.balanceModel.multiple]] fontSize:12];
        self.waitAssetLable.attributedText = [self createAttributeString:[NSString stringWithFormat:@"%@\n%@",NSLocalizedString(@"Amount waiting", nil), [BRSafeUtils amountForAssetAmount:self.balanceModel.balance - useBalance - lockBalance decimals:self.balanceModel.multiple]] fontSize:12];
        self.lockAssetLable.attributedText = [self createAttributeString:[NSString stringWithFormat:@"%@\n%@", NSLocalizedString(@"Amount in lock", nil), [BRSafeUtils amountForAssetAmount:lockBalance decimals:self.balanceModel.multiple]] fontSize:12];
    }
}

- (NSMutableAttributedString *)createAttributeString:(NSString *)string fontSize:(CGFloat)size {
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = 5;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary *attrDict = @{
                               NSForegroundColorAttributeName : [UIColor whiteColor],
                               NSFontAttributeName            : kFont(size),
                               NSParagraphStyleAttributeName  : paragraphStyle
                               };
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:string attributes:attrDict];
    return attrStr;
}

@end
