//
//  BRKeySequence.h
//  BreadWallet
//
//  Created by Aaron Voisine on 5/27/13.
//  Copyright (c) 2013 Aaron Voisine <voisine@gmail.com>
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

#import <Foundation/Foundation.h>

#define SEQUENCE_GAP_LIMIT_EXTERNAL 10
#define SEQUENCE_GAP_LIMIT_INTERNAL 5
#define BIP44_PURPOSE      44
#define BIP32_PURPOSE      0
#define BIP44_PURPOSE_ACCOUNT_DEPTH      3
#define BIP32_PURPOSE_ACCOUNT_DEPTH      1
#define ADDRESS_DEFAULT      BIP44_PURPOSE

@protocol BRKeySequence<NSObject>

@optional
- (NSData *)deprecatedIncorrectExtendedPublicKeyForAccount:(uint32_t)account fromSeed:(NSData *)seed purpose:(uint32_t)purpose;

@required

- (NSData *)extendedPublicKeyForAccount:(uint32_t)account fromSeed:(NSData *)seed purpose:(uint32_t)purpose;
- (NSData *)publicKey:(uint32_t)n internal:(BOOL)internal masterPublicKey:(NSData *)masterPublicKey;
- (NSString *)privateKey:(uint32_t)n purpose:(uint32_t)purpose internal:(BOOL)internal fromSeed:(NSData *)seed;
- (NSArray *)privateKeys:(NSArray *)n purpose:(uint32_t)purpose internal:(BOOL)internal fromSeed:(NSData *)seed;

- (NSArray *)ecprivateKeys:(NSArray *)n purpose:(uint32_t)purpose internal:(BOOL)internal fromSeed:(NSData *)seed;

@end
