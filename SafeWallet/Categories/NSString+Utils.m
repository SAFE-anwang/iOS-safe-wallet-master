//
//  NSString+Utils.m
//  dashwallet
//
//  Created by 黄锐锋 on 2018/6/28.
//  Copyright © 2018年 Aaron Voisine. All rights reserved.
//

#import "NSString+Utils.h"

@implementation NSString (Utils)

- (BOOL) isEmpty {
    return !self.length;
}

- (NSString *) removeFirstAndEndSpace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (uint64_t) stringToUint64:(NSInteger) decimal {
    NSArray *strArray = [self componentsSeparatedByString:@"."];
    if(strArray.count == 1) return (uint64_t)([self longLongValue] * (uint64_t)(pow(10, decimal)));
    if([strArray.lastObject length] > decimal) {
        return (uint64_t)[[strArray.firstObject stringByAppendingFormat:@"%@", [strArray.lastObject substringWithRange:NSMakeRange(0, decimal)]] longLongValue];
    } else {
        return (uint64_t)([[strArray.firstObject stringByAppendingFormat:@"%@", [strArray.lastObject substringWithRange:NSMakeRange(0, [strArray.lastObject length])]] longLongValue] * (uint64_t)(pow(10, decimal - [strArray.lastObject length])));
    }
}

- (NSInteger) stringToInteger {
    NSArray *strArray = [self componentsSeparatedByString:@"."];
    return (uint32_t)[strArray.firstObject length];
}

- (NSInteger) getDecimal {
    NSArray *strArray = [self componentsSeparatedByString:@"."];
    if(strArray.count <= 1) return 0;
    NSString *str = strArray.lastObject;
    for(int i=str.length-1; i>=0; i--) {
        NSString *charStr = [str substringWithRange:NSMakeRange(i, 1)];
        if(![charStr isEqualToString:@"0"]) {
            return i + 1;
        }
    }
    return 0;
}

- (NSString *) showCandyString:(NSInteger) decimal {
    if(self.length <= decimal) {
        int index = -1;
        for(int i=self.length-1; i>=0; i--) {
            NSString *charStr = [self substringWithRange:NSMakeRange(i, 1)];
            if(![charStr isEqualToString:@"0"]) {
                index = i;
                break;
            }
        }
        if(index == -1) return @"0";
        return [NSString stringWithFormat:@"0.%@", [self substringWithRange:NSMakeRange(0, index + 1)]];
    } else {
        NSString *newStr = [self substringWithRange:NSMakeRange(self.length - decimal, decimal)];
        int index = -1;
        for(int i=newStr.length-1; i>=0; i--) {
            NSString *charStr = [newStr substringWithRange:NSMakeRange(i, 1)];
            if(![charStr isEqualToString:@"0"]) {
                index = i;
                break;
            }
        }
        if(index == -1) return [NSString stringWithFormat:@"%@", [self substringWithRange:NSMakeRange(0, self.length - decimal)]];
        return [NSString stringWithFormat:@"%@.%@", [self substringWithRange:NSMakeRange(0, self.length - decimal)], [newStr substringWithRange:NSMakeRange(0, index+1)]];
    }
}

// 判断是否含有emoji表情
- (BOOL)stringContainsEmoji
{
    NSUInteger len = [self lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (len < 3) {// 大于2个字符需要验证Emoji(有些Emoji仅三个字符)
        return NO;
    }// 仅考虑字节长度为3的字符,大于此范围的全部做Emoji处理
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bts = (Byte *)[data bytes];
    Byte bt;
    short v;
    for (NSUInteger i = 0; i < len; i++) {
        bt = bts[i];
        
        if ((bt | 0x7F) == 0x7F) {// 0xxxxxxxASIIC编码
            continue;
        }
        if ((bt | 0x1F) == 0xDF) {// 110xxxxx两个字节的字符
            i += 1;
            continue;
        }
        if ((bt | 0x0F) == 0xEF) {// 1110xxxx三个字节的字符(重点过滤项目)
            // 计算Unicode下标
            v = bt & 0x0F;
            v = v << 6;
            v |= bts[i + 1] & 0x3F;
            v = v << 6;
            v |= bts[i + 2] & 0x3F;
            
            // NSLog(@"%02X%02X", (Byte)(v >> 8), (Byte)(v & 0xFF));
            if ([self emojiInSoftBankUnicode:v] || [self emojiInUnicode:v]) {
                return YES;
            }
            
            i += 2;
            continue;
        }
        if ((bt | 0x3F) == 0xBF) {// 10xxxxxx10开头,为数据字节,直接过滤
            continue;
        }
        
        return YES; // 不是以上情况的字符全部超过三个字节,做Emoji处理
    }
    return NO;
}

- (BOOL) emojiInUnicode:(short)code
{
    if (code == 0x0023
        || code == 0x002A
        || (code >= 0x0030 && code <= 0x0039)
        || code == 0x00A9
        || code == 0x00AE
        || code == 0x203C
        || code == 0x2049
        || code == 0x2122
        || code == 0x2139
        || (code >= 0x2194 && code <= 0x2199)
        || code == 0x21A9 || code == 0x21AA
        || code == 0x231A || code == 0x231B
        || code == 0x2328
        || code == 0x23CF
        || (code >= 0x23E9 && code <= 0x23F3)
        || (code >= 0x23F8 && code <= 0x23FA)
        || code == 0x24C2
        || code == 0x25AA || code == 0x25AB
        || code == 0x25B6
        || code == 0x25C0
        || (code >= 0x25FB && code <= 0x25FE)
        || (code >= 0x2600 && code <= 0x2604)
        || code == 0x260E
        || code == 0x2611
        || code == 0x2614 || code == 0x2615
        || code == 0x2618
        || code == 0x261D
        || code == 0x2620
        || code == 0x2622 || code == 0x2623
        || code == 0x2626
        || code == 0x262A
        || code == 0x262E || code == 0x262F
        || (code >= 0x2638 && code <= 0x263A)
        || (code >= 0x2648 && code <= 0x2653)
        || code == 0x2660
        || code == 0x2663
        || code == 0x2665 || code == 0x2666
        || code == 0x2668
        || code == 0x267B
        || code == 0x267F
        || (code >= 0x2692 && code <= 0x2694)
        || code == 0x2696 || code == 0x2697
        || code == 0x2699
        || code == 0x269B || code == 0x269C
        || code == 0x26A0 || code == 0x26A1
        || code == 0x26AA || code == 0x26AB
        || code == 0x26B0 || code == 0x26B1
        || code == 0x26BD || code == 0x26BE
        || code == 0x26C4 || code == 0x26C5
        || code == 0x26C8
        || code == 0x26CE
        || code == 0x26CF
        || code == 0x26D1
        || code == 0x26D3 || code == 0x26D4
        || code == 0x26E9 || code == 0x26EA
        || (code >= 0x26F0 && code <= 0x26F5)
        || (code >= 0x26F7 && code <= 0x26FA)
        || code == 0x26FD
        || code == 0x2702
        || code == 0x2705
        || (code >= 0x2708 && code <= 0x270D)
        || code == 0x270F
        || code == 0x2712
        || code == 0x2714
        || code == 0x2716
        || code == 0x271D
        || code == 0x2721
        || code == 0x2728
        || code == 0x2733 || code == 0x2734
        || code == 0x2744
        || code == 0x2747
        || code == 0x274C
        || code == 0x274E
        || (code >= 0x2753 && code <= 0x2755)
        || code == 0x2757
        || code == 0x2763 || code == 0x2764
        || (code >= 0x2795 && code <= 0x2797)
        || code == 0x27A1
        || code == 0x27B0
        || code == 0x27BF
        || code == 0x2934 || code == 0x2935
        || (code >= 0x2B05 && code <= 0x2B07)
        || code == 0x2B1B || code == 0x2B1C
        || code == 0x2B50
        || code == 0x2B55
        || code == 0x3030
        || code == 0x303D
        || code == 0x3297
        || code == 0x3299
        // 第二段
        || code == 0x23F0) {
        return YES;
    }
    return NO;
}

- (BOOL) emojiInSoftBankUnicode:(short)code
{
    return ((code >> 8) >= 0xE0 && (code >> 8) <= 0xE5 && (Byte)(code & 0xFF) < 0x60);
}

- (NSString *) stringShowUint64 {
    NSArray *strArray = [self componentsSeparatedByString:@"."];
    if(strArray.count == 1) return self;
    int index = 0;
    for(int i=[strArray[1] length]-1; i>=0; i--) {
        NSString *charStr = [strArray[1] substringWithRange:NSMakeRange(i, 1)];
        if(![charStr isEqualToString:@"0"]) {
            index = i;
            break;
        }
    }
    if(index == -1) index = 0;
    if(index == [strArray[1] length] - 1) index = [strArray[1] length];
    NSString *newStr = [strArray[1] substringWithRange:NSMakeRange(0, index)];
    if(newStr.length == 0) {
        return strArray[0];
    } else {
        return [NSString stringWithFormat:@"%@.%@", strArray[0], newStr];
    }
}

// 判断是否以数字开头
- (BOOL)isNumberFirst {
    NSString *regular = @"^[0-9].+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regular];
    
    if ([predicate evaluateWithObject:self] == YES){
        return YES;
    }else{
        return NO;
    }
}


@end
