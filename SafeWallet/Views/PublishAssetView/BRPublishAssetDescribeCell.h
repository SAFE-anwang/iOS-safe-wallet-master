//
//  BRPublishAssetDescribeCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/8.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceholderTextView.h"

@protocol BRPublishAssetDescribeCellDelegate <NSObject>

@optional

- (void) publishAssetDescribeCellWithContent:(NSString *) contentString;

@end

@interface BRPublishAssetDescribeCell : UITableViewCell

@property (nonatomic, weak) id<BRPublishAssetDescribeCellDelegate> delegate;

@property (nonatomic,strong) PlaceholderTextView *textView;

@property (nonatomic,strong) UILabel *title;

@property (nonatomic,assign) int textLength;

@end
