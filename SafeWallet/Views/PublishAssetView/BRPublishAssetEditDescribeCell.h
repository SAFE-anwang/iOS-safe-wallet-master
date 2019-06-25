//
//  BRPublishAssetEditDescribeCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/9.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceholderTextView.h"

#define publishAssetEditDescribeCellNotification @"publishAssetEditDescribeCellNotification"
#define publishAssetEditDescribeCellNSIndexPath @"publishAssetEditDescribeCellNSIndexPath"

@protocol BRPublishAssetEditDescribeCellDelegate <NSObject>

@optional

- (void) publishAssetEditDescribeCellWithContent:(NSString *) contentString andIndexPath:(NSIndexPath *) indexPath;

@end

@interface BRPublishAssetEditDescribeCell : UITableViewCell

@property (nonatomic,weak) id<BRPublishAssetEditDescribeCellDelegate> delegate;

@property (nonatomic,strong) PlaceholderTextView *textView;

@property (nonatomic,strong) UILabel *title;

@property (nonatomic,strong) NSIndexPath *indexPath;

@property (nonatomic,assign) int textLength;

@end
