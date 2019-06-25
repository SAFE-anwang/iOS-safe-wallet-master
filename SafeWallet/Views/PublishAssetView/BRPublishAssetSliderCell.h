//
//  BRPublishAssetSliderCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/30.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRPublishAssetSliderCellDelegate <NSObject>

@optional
- (void) publishAssetSliderCellSliderValue:(double) sliderValue;

@end

@interface BRPublishAssetSliderCell : UITableViewCell

@property (nonatomic, weak) id<BRPublishAssetSliderCellDelegate>delegate;

@property (nonatomic,strong) UILabel *valueLable;

@property (nonatomic, assign) double sliderValue;

@end
