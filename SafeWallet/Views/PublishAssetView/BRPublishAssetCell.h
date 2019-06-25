//
//  BRPublishAssetCell.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/8.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BRTextField.h"

#define publishAssetCellNotification @"BRPublishAssetCellNotification"
#define publishAssetCellType @"BRPublishAssetCellType"
#define publishAssetCellIndexPath @"BRPublishAssetCellIndexPath"

typedef NS_ENUM(NSInteger, BRPublishAssetCellType)
{
    BRPublishAssetCellTypePublishAsset = 0,
    BRPublishAssetCellTypeAddPublishAsset
};

@protocol BRPublishAssetCellDelegate <NSObject>

@optional

- (void) publishAssetCellWithContent:(NSString *) contentString andIndexPath:(NSIndexPath  *) path;

@end

@interface BRPublishAssetCell : UITableViewCell

@property (nonatomic, weak) id<BRPublishAssetCellDelegate> delegate;

@property (nonatomic,strong) NSIndexPath *indexPath;

@property (nonatomic,strong) UILabel *title;

@property (nonatomic,strong) BRTextField *textField;

@property (nonatomic, copy) NSString *holderText;

@property (nonatomic, assign) int stringLength;

@property (nonatomic, assign) BRPublishAssetCellType type;

@end
