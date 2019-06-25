//
//  BRPopoverPresentationView.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/5.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BRPopoverPresentationViewType) {
    BRPopoverPresentationViewTypePublishAsset = 0,
    BRPopoverPresentationViewTypePutCandy = 1,
};

@protocol BRPopoverPresentationViewDelegate <NSObject>

@optional

- (void) popoverPresentationViewForIndexPath:(NSInteger) index;

@end

@class BRCommonDataModel,BRPutCandyModel;

@interface BRPopoverPresentationView : UIView

@property (nonatomic, strong) BRCommonDataModel *selectModel;

@property (nonatomic, strong) BRPutCandyModel *selectCandy;

@property (nonatomic,strong) NSArray *dataSoure;

@property (nonatomic,weak) id<BRPopoverPresentationViewDelegate>delegate;

- (instancetype)initWithShowRegion:(CGSize)size type:(BRPopoverPresentationViewType) type;

- (void) show;

@end
