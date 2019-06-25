//
//  UIView+Extension.m
//  dashwallet
//
//  Created by joker on 2018/6/26.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)

- (void)roundCornerWithRadius:(CGFloat)radius roundingCorners:(UIRectCorner)roundingCorners borderWidth:(CGFloat)width borderColor:(UIColor *)color {
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                               byRoundingCorners:roundingCorners
                                                     cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = path.CGPath;
    
    CAShapeLayer *borderLayer = [CAShapeLayer layer];
    borderLayer.frame = self.bounds;
    borderLayer.lineWidth = width;
    borderLayer.strokeColor = color.CGColor;
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.path = path.CGPath;
    
    [self.layer insertSublayer:borderLayer atIndex:0];
    self.layer.mask = maskLayer;
}

- (UIEdgeInsets)safeInsets {
    if(@available(ios 11.0,*)){
        return self.safeAreaInsets;
    }
    return UIEdgeInsetsZero;
}


@end
