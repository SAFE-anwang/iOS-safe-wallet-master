//
//  BRPublishAssetEditTimeCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/9.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRTextField.h"

#define publishAssetEditTimeCellNotification @"publishAssetEditTimeCellNotification"

@protocol BRPublishAssetEditTimeCellDelegate <NSObject>

@optional

- (void) publishAssetEditTimeWithTime:(NSString *)time;

- (void) publishAssetEditTimeCellSliderValue:(double) sliderValue;

@end

@interface BRPublishAssetEditTimeCell : UITableViewCell

@property (nonatomic,weak) id<BRPublishAssetEditTimeCellDelegate> delegate;

@property (nonatomic,strong) UILabel *title;

@property (nonatomic,strong) BRTextField *textField;

@end
