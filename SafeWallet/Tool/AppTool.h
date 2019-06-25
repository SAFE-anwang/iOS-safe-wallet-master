//
//  AppTool.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/30.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppTool : NSObject

// 显示提示信息
+ (void) showMessage:(NSString *) message showView:(UIView *) showView;

+ (void) showHUDView:(UIView *) showView animated:(BOOL) animated;

+ (void) hideHUDView:(UIView *) showView animated:(BOOL) animated;

+ (double) getAssetMultiple:(NSInteger) integer;

@end
