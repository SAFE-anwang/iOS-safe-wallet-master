//
//  BRAssetHeaderView.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/3/21.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRAssetHeaderViewDelegate <NSObject>

- (void)sendAddress:(NSInteger)btnTag;

@end

@interface BRAssetHeaderView : UIView

@property (nonatomic,strong) UILabel *addressLable;
@property (nonatomic,strong) UIImageView *qrImageView;

@property (nonatomic,weak) id <BRAssetHeaderViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame;

@end
