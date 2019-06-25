//
//  BRCandyHistoryDetailCell.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/24.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRCandyHistoryDetailCell.h"

@implementation BRCandyHistoryDetailCell

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
    UIView *topView = [[UIView alloc] initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, 185)];
    [self.contentView addSubview:topView];
    
    UILabel *nameLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    nameLable.text = @"SAFE";
    nameLable.textColor = [UIColor blackColor];
    nameLable.font = [UIFont systemFontOfSize:25.f weight:UIFontWeightBold];
    nameLable.textAlignment = NSTextAlignmentCenter;
    [topView addSubview:nameLable];
    
    UILabel *numberLable = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(nameLable.frame) + 20, SCREEN_WIDTH - 40, 20)];
    numberLable.text = @"资产数量：10";
    numberLable.textColor = [UIColor blackColor];
    numberLable.font = [UIFont systemFontOfSize:16.f];
    numberLable.textAlignment = NSTextAlignmentLeft;
    [topView addSubview:numberLable];
    
    UILabel *addressLable = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(numberLable.frame) + 15, SCREEN_WIDTH - 40, 60)];
    addressLable.text = @"领取地址：\nXgxrGRC8AC3Fsw8RoMi89xtn11AMqQ3gNB";
    addressLable.textColor = [UIColor blackColor];
    addressLable.font = [UIFont systemFontOfSize:16.f];
    addressLable.textAlignment = NSTextAlignmentLeft;
    addressLable.numberOfLines = 0;
    [topView addSubview:addressLable];
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame) + 1, SCREEN_WIDTH, 1)];
    line.backgroundColor = ColorFromRGB(0xf0f0f0);
    [self.contentView addSubview:line];
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(line.frame) + 30, SCREEN_WIDTH, 205)];
    [self.contentView addSubview:bottomView];
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 20 - 105, 0, 105, 105)];
    imageView.userInteractionEnabled = YES;
    [bottomView addSubview:imageView];
    //二维码
    NSString *txId = @"bfb5f7e96e72bda3480567a6c44c25cc23154d227d25f5b65bc10f97ec131315";
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    NSString *string = [NSString stringWithFormat:@"http://10.0.0.249:3001/tx/%@",txId];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    CIImage *image = [filter outputImage];
    imageView.image = [self creatNonInterpolatedUIImageFormCIImage:image withSize:105];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewLongPress:)];
    [imageView addGestureRecognizer:longGesture];
    
    UILabel *blockLable = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 100, 20)];
    blockLable.text = NSLocalizedString(@"Block", nil);
    blockLable.textColor = [UIColor blackColor];
    blockLable.textAlignment = NSTextAlignmentLeft;
    blockLable.font = [UIFont systemFontOfSize:15.f];
    [bottomView addSubview:blockLable];
    
    UILabel *blockHeightLable = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(blockLable.frame) + 5, SCREEN_WIDTH - 40 - 105, 20)];
    blockHeightLable.text = @"100000";
    blockHeightLable.textColor = ColorFromRGB(0x666666);
    blockHeightLable.textAlignment = NSTextAlignmentLeft;
    blockHeightLable.font = [UIFont systemFontOfSize:15.f];
    [bottomView addSubview:blockHeightLable];
    
    UILabel *txLable = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(blockHeightLable.frame) + 15, 100, 20)];
    txLable.text = NSLocalizedString(@"Transaction time", nil);
    txLable.textColor = [UIColor blackColor];
    txLable.textAlignment = NSTextAlignmentLeft;
    txLable.font = [UIFont systemFontOfSize:15.f];
    [bottomView addSubview:txLable];
    
    UILabel *txTimeLable = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(txLable.frame) + 5, SCREEN_WIDTH - 40 - 105, 20)];
    txTimeLable.text = @"2018/12/12 12:12";
    txTimeLable.textColor = ColorFromRGB(0x666666);
    txTimeLable.textAlignment = NSTextAlignmentLeft;
    txTimeLable.font = [UIFont systemFontOfSize:15.f];
    [bottomView addSubview:txTimeLable];
    
    UILabel *idLable = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(txTimeLable.frame) + 15, SCREEN_WIDTH - 40, 20)];
    idLable.text = NSLocalizedString(@"Transaction ID", nil);
    idLable.textColor = [UIColor blackColor];
    idLable.textAlignment = NSTextAlignmentLeft;
    idLable.font = [UIFont systemFontOfSize:15.f];
    [bottomView addSubview:idLable];
    
    UILabel *txIDLable = [[UILabel alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY(idLable.frame) + 5, SCREEN_WIDTH - 40, 60)];
    txIDLable.text = txId;
    txIDLable.numberOfLines = 0;
    txIDLable.textColor = ColorFromRGB(0x666666);
    txIDLable.textAlignment = NSTextAlignmentLeft;
    txIDLable.font = [UIFont systemFontOfSize:15.f];
    [bottomView addSubview:txIDLable];
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
    return [UIImage imageWithCGImage:scaledImage];
}

#pragma maek -- MARK:长按二维码事件
- (void)imageViewLongPress:(UILongPressGestureRecognizer *)longPress {
    UIImageView *imageView = (UIImageView *)longPress.view;
    UIImage *image = imageView.image;
    if (self.delegate && [self.delegate respondsToSelector:@selector(qrcodeLongpress:)]) {
        [self.delegate qrcodeLongpress:image];
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
