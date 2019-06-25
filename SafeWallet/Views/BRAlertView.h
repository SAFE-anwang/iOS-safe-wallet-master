//
//  BRAlertView.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/8/29.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BRAlertViewDelegate <NSObject>

-(void)loadSendTxRequest;

@end

@interface BRAlertView : UIView


@property (nonatomic,weak) id<BRAlertViewDelegate> delegate;

/**
 构造方法

 @param message 弹窗message
 @param delegate 确定代理方
 @return 一个弹窗
 */
- (instancetype)initWithMessage:(NSString *)message messageType:(NSTextAlignment) type delegate:(id)delegate;

/** show出这个弹窗 */
- (void)show;

@end
