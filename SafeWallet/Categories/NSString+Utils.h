//
//  NSString+Utils.h
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/28.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Utils)

/**
 判断字符串是否为空
 */
- (BOOL) isEmpty;


/**
 移除首尾空格是否为空
 */
- (NSString *) removeFirstAndEndSpace;


/**
 字符串转uint64_t
 */
- (uint64_t) stringToUint64:(NSInteger) decimal;

/**
 字符串获取整数部分位数
 */
- (NSInteger) stringToInteger;


/**
 获取字符串中小数有多少位
 */
- (NSInteger) getDecimal;


/**
 显示糖果字符串
 */
- (NSString *) showCandyString:(NSInteger) decimal;

// 判断是否含有emoji表情
- (BOOL)stringContainsEmoji;

- (NSString *) stringShowUint64;

// 判断是否以数字开头
- (BOOL)isNumberFirst;
@end
