//
//  BRCandyHistoryDetailCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/24.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRCandyHistoryDetailCell.h"

@interface BRCandyHistoryDetailCell()

@property (nonatomic, strong) UIImageView *imgView;

@end

@implementation BRCandyHistoryDetailCell


- (UIImageView *)imgView {
    if (!_imgView) {
        _imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg"]];
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        _imgView.clipsToBounds = YES;
    }
    return _imgView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 130)];
    [self.contentView addSubview:topView];
    
    [topView addSubview:self.imgView];
    
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.bottom.mas_equalTo(topView);
        make.top.mas_equalTo(topView.mas_top);
    }];
    
    UILabel *amountLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH * 0.8, 100)];
    self.amountLabel = amountLabel;
    amountLabel.center = CGPointMake(SCREEN_WIDTH * 0.5, CGRectGetHeight(topView.frame) * 0.5);
    amountLabel.font = kBlodFont(14);
    amountLabel.textAlignment = NSTextAlignmentCenter;
    amountLabel.textColor = [UIColor whiteColor];
    amountLabel.numberOfLines = 3;
    [topView addSubview:amountLabel];
    
//    self.nameLable = [[UILabel alloc] initWithFrame:CGRectMake(12, 0, SCREEN_WIDTH - 24, 40)];
//    self.nameLable.text = @"SAFE";
//    self.nameLable.font = kBlodFont(22);//[UIFont systemFontOfSize:25.f weight:UIFontWeightBold];
//    self.nameLable.textAlignment = NSTextAlignmentCenter;
//    self.nameLable.textColor = [UIColor whiteColor];
//    [topView addSubview:self.nameLable];
    
//    self.numberLable = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.nameLable.frame) + 20, SCREEN_WIDTH - 40, 20)];
//    self.numberLable.text = @"资产数量：10";
//    self.numberLable.textColor = [UIColor whiteColor];
//    self.numberLable.font = kFont(12);//[UIFont systemFontOfSize:14.f];
//    self.numberLable.textAlignment = NSTextAlignmentLeft;
//    [topView addSubview:self.numberLable];
    
//    self.addressLable = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(self.numberLable.frame) + 10, SCREEN_WIDTH - 40, 60)];
//    self.addressLable.text = @"领取地址：\nXgxrGRC8AC3Fsw8RoMi89xtn11AMqQ3gNB";
//    self.addressLable.textColor = [UIColor whiteColor];
//    self.addressLable.font = kFont(12);//[UIFont systemFontOfSize:14.f];
//    self.addressLable.textAlignment = NSTextAlignmentLeft;
//    self.addressLable.numberOfLines = 0;
//    [topView addSubview:self.addressLable];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame) + 1, SCREEN_WIDTH, 1)];
    line.backgroundColor = ColorFromRGB(0xf0f0f0);
    [self.contentView addSubview:line];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame) + 30, SCREEN_WIDTH, 205)];
    [self.contentView addSubview:bottomView];
    
    UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 120, 20)];
    addressLabel.text = NSLocalizedString(@"Receive address", nil);
    addressLabel.textAlignment = NSTextAlignmentLeft;
    addressLabel.font =kRegularFont(12);
    [bottomView addSubview:addressLabel];
    
    UILabel *addresDetailLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(addressLabel.frame) + 5, SCREEN_WIDTH - 30, 20)];
    self.addressLable = addresDetailLabel;
    addresDetailLabel.text = @"XgxrGRC8AC3Fsw8RoMi89xtn11AMqQ3gNB";
    addresDetailLabel.textColor = ColorFromRGB(0x666666);
    addresDetailLabel.font = kFont(12);
    [bottomView addSubview:addresDetailLabel];
    
    self.codeimageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 15 - 105, CGRectGetMaxY(addresDetailLabel.frame) + 15, 105, 105)];
//    self.codeimageView.userInteractionEnabled = YES;
    [bottomView addSubview:self.codeimageView];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewLongPress:)];
    [self.codeimageView addGestureRecognizer:longGesture];
    
    UILabel *blockLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMinY(self.codeimageView.frame), 100, 20)];
    blockLable.text = NSLocalizedString(@"Block", nil);
    blockLable.textColor = [UIColor blackColor];
    blockLable.textAlignment = NSTextAlignmentLeft;
    blockLable.font = kRegularFont(12);//[UIFont systemFontOfSize:13.f];
    [bottomView addSubview:blockLable];
    
    self.blockHeightLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(blockLable.frame) + 5, SCREEN_WIDTH - 30 - 105, 20)];
    self.blockHeightLable.text = @"100000";
    self.blockHeightLable.textColor = ColorFromRGB(0x666666);
    self.blockHeightLable.textAlignment = NSTextAlignmentLeft;
    self.blockHeightLable.font = kFont(12);//[UIFont systemFontOfSize:15.f];
    [bottomView addSubview:self.blockHeightLable];
    
    UILabel *txLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.blockHeightLable.frame) + 15, 120, 20)];
    txLable.text = NSLocalizedString(@"Transaction time", nil);
    txLable.textColor = [UIColor blackColor];
    txLable.textAlignment = NSTextAlignmentLeft;
    txLable.font = kRegularFont(12);//[UIFont systemFontOfSize:15.f];
    [bottomView addSubview:txLable];
    
    self.txTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(txLable.frame) + 5, SCREEN_WIDTH - 30 - 105, 20)];
    self.txTimeLable.text = @"2018/12/12 12:12";
    self.txTimeLable.textColor = ColorFromRGB(0x666666);
    self.txTimeLable.textAlignment = NSTextAlignmentLeft;
    self.txTimeLable.font = kFont(12);//[UIFont systemFontOfSize:15.f];
    [bottomView addSubview:self.txTimeLable];
    
    UILabel *idLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(self.txTimeLable.frame) + 15, SCREEN_WIDTH - 30, 30)];
    idLable.text = NSLocalizedString(@"Transaction ID", nil);
    idLable.textColor = [UIColor blackColor];
    idLable.textAlignment = NSTextAlignmentLeft;
    idLable.font = kRegularFont(12);//[UIFont systemFontOfSize:15.f];
    [bottomView addSubview:idLable];
    
    UIButton *browserBtn = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 75, CGRectGetMaxY(self.txTimeLable.frame) + 15, 60, 30)];
    [browserBtn setTitle:NSLocalizedString(@"Browse", nil) forState:UIControlStateNormal];
    browserBtn.backgroundColor = MAIN_COLOR;
    browserBtn.titleLabel.font = kFont(13);
    [browserBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [browserBtn addTarget:self action:@selector(loadSafari) forControlEvents:UIControlEventTouchUpInside];
    browserBtn.layer.masksToBounds = YES;
    browserBtn.layer.cornerRadius = 3;
    [bottomView addSubview:browserBtn];
    
    self.txIDLable = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(idLable.frame) + 5, SCREEN_WIDTH - 30, 40)];

    self.txIDLable.numberOfLines = 0;
    self.txIDLable.textColor = ColorFromRGB(0x666666);
    self.txIDLable.textAlignment = NSTextAlignmentLeft;
    self.txIDLable.font = kFont(12);//[UIFont systemFontOfSize:15.f];
    [bottomView addSubview:self.txIDLable];
}

- (void)setTxId:(NSString *)txId {
    _txId = txId;
    //二维码
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSString *string = [NSString stringWithFormat:@"%@%@", BLOCKWEB_URL, txId];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    CIImage *image = [filter outputImage];
    self.codeimageView.image = [self creatNonInterpolatedUIImageFormCIImage:image withSize:105];
}

- (UIImage *)creatNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1. 创建bitmap
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    UIImage *newImg = [UIImage imageWithCGImage:scaledImage];
    CGImageRelease(scaledImage);
    return newImg;
}

#pragma maek -- MARK:长按二维码事件
- (void)imageViewLongPress:(UILongPressGestureRecognizer *)longPress {
    UIImageView *imageView = (UIImageView *)longPress.view;
    UIImage *image = imageView.image;
    if (self.delegate && [self.delegate respondsToSelector:@selector(qrcodeLongpress:)]) {
        [self.delegate qrcodeLongpress:image];
    }
}

- (void) loadSafari {
    if([self.delegate respondsToSelector:@selector(qrcodeLongpress:)]) {
        [self.delegate qrcodeLongpress:nil];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
