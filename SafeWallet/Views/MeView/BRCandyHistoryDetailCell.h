//
//  BRCandyHistoryDetailCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/24.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRCandyHistoryDetailCellDelegate <NSObject>

- (void)qrcodeLongpress:(UIImage *)longpressImage;

@end

@interface BRCandyHistoryDetailCell : UITableViewCell

@property (nonatomic, weak) id<BRCandyHistoryDetailCellDelegate>delegate;

@property (nonatomic,strong) UILabel *nameLable;

@property (nonatomic,strong) UILabel *numberLable;

@property (nonatomic,strong) UILabel *addressLable;

@property (nonatomic,strong) UILabel *blockHeightLable;

@property (nonatomic,strong) UILabel *txTimeLable;

@property (nonatomic,strong) UILabel *txIDLable;

@property (nonatomic,strong) NSString *txId;

@property (nonatomic,strong) UIImageView *codeimageView;

@property (nonatomic, strong) UILabel *amountLabel;
@end
