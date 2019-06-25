//
//  UIScrollView+Refresh.m
//  dashwallet
//
//  Created by joker on 2018/6/29.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "UIScrollView+Refresh.h"

@implementation UIScrollView (Refresh)

- (void)addFooterRefresh:(MJRefreshComponentRefreshingBlock)refreshBlock
{
    MJRefreshBackNormalFooter *footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:refreshBlock];
    footer.stateLabel.hidden = YES;
    footer.arrowView.hidden = YES;
    self.mj_footer = footer;
}

- (void)beginFooterRefresh
{
    [self.mj_footer beginRefreshing];
}

- (void)endFooterRefresh
{
    [self.mj_footer endRefreshingWithCompletionBlock:nil];
}



@end
