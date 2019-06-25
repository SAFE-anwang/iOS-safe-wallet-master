//
//  UIImage+Color.h
//  xfg
//
//  Created by zhangmiao on 16/9/6.
//  Copyright © 2016年 zss. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color;

+ (UIImage*)imageWithColorAndHeight:(UIColor*)color andHeight:(CGFloat)height;

- (UIImage *)renderingColor:(UIColor *)color;

+ (UIImage*)ImageWithColor:(UIColor *)color size:(CGFloat)size round:(BOOL)round;

@end
