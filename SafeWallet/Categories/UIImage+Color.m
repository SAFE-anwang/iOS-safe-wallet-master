//
//  UIImage+Color.m
//  xfg
//
//  Created by zhangmiao on 16/9/6.
//  Copyright © 2016年 zss. All rights reserved.
//

#import "UIImage+Color.h"

@implementation UIImage (Color)

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*) imageWithColorAndHeight:(UIColor*)color andHeight:(CGFloat)height
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage*)ImageWithColor:(UIColor *)color size:(CGFloat)size round:(BOOL)round {
    
    
    CGSize s = CGSizeMake(size, size);
    CGRect r = CGRectMake(0, 0, size, size);
    UIGraphicsBeginImageContextWithOptions(s, NO, 1);
    CGContextRef context = UIGraphicsGetCurrentContext();
    UIBezierPath *path;
        
    path = [UIBezierPath bezierPathWithRect:r];
    
    path.lineWidth = 0.001;
    [color setFill];
    [path fill];
    CGContextAddPath(context, path.CGPath);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    if (round) {
        image = [image roundCorner:size * 0.5];
    }
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)roundCorner:(CGFloat)radius {
    CGFloat maxR = MIN(self.size.width, self.size.height) * 0.5;
    CGFloat r;
    if (radius > 0 && radius <= maxR) {
        r = radius;
    } else {
        r = maxR;
    }
    UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:r] addClip];
    [self drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}



- (UIImage *)renderingColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, self.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    CGContextClipToMask(context, rect, self.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


@end
