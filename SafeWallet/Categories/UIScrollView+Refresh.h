//
//  UIScrollView+Refresh.h
//  dashwallet
//
//  Created by joker on 2018/6/29.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MJRefresh.h"

@interface UIScrollView (Refresh)


/**
 添加上拉加载

 @param refreshBlock 回调
 */
- (void)addFooterRefresh:(MJRefreshComponentRefreshingBlock)refreshBlock;


/** 开始加载 */
- (void)beginFooterRefresh;


/** 结束刷新 */
- (void)endFooterRefresh;

@end
