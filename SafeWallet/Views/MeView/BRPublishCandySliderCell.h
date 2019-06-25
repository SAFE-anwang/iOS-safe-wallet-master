//
//  BRPublishCandySliderCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/7/16.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRPublishCandySliderCellDelegate <NSObject>

@optional
- (void) publishCandySliderValue:(double) sliderValue;

@end

@interface BRPublishCandySliderCell : UITableViewCell

@property (nonatomic, weak) id<BRPublishCandySliderCellDelegate>delegate;

@property (nonatomic,strong) UILabel *valueLable;

@property (nonatomic, assign) double sliderValue;

@end
