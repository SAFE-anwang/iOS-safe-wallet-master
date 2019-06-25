//
//  BRTextField.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/5/30.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "BRTextField.h"

@implementation BRTextField

//控制placeHolder的位置
-(CGRect)placeholderRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x+4, bounds.origin.y, bounds.size.width -4, bounds.size.height);
    return inset;
}

//控制显示文本的位置
-(CGRect)textRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x+4, bounds.origin.y, bounds.size.width -4, bounds.size.height);
    return inset;
}

//控制编辑文本的位置
-(CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect inset = CGRectMake(bounds.origin.x +4, bounds.origin.y, bounds.size.width -4, bounds.size.height);
    return inset;
}

@end
