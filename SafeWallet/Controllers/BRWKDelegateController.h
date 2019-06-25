//
//  BRWKDelegateController.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/8.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@protocol WKDelegate <NSObject>

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;

@end

@interface BRWKDelegateController : UIViewController <WKScriptMessageHandler>

@property (weak , nonatomic) id <WKDelegate> delegate;

@end
