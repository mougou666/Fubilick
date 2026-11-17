//
//  JSONKit.h
//  JSONKit
//
//  Created by John Engelhart on 2010/01/01.
//  Copyright 2010 John Engelhart. All rights reserved.
//
//  本文件为 JSONKit 库，用于 iOS 4 兼容的 JSON 解析。
//  原始代码来自: https://github.com/johnezang/JSONKit
//  为了兼容 iOS 4，使用非 ARC 模式编译。
//

#import <Foundation/Foundation.h>

#pragma mark - JSONKit 主要类

@interface JSONDecoder : NSObject {
    void *__parser;
    BOOL *__parserError;
    NSMutableArray *__arrayStack;
    NSMutableDictionary *__dictStack;
    NSString *__currentString;
    NSUInteger __currentIndex;
    NSUInteger __currentLength;
    BOOL __isParsing;
    BOOL __error;
}

+ (JSONDecoder *)decoder;
- (id)objectWithData:(NSData *)data error:(NSError **)error;
- (id)objectWithString:(NSString *)string error:(NSError **)error;

@end

#pragma mark - NSObject 分类

@interface NSObject (JSONKit)
- (id)JSONObject;
@end

#pragma mark - NSString 分类

@interface NSString (JSONKit)
- (id)JSONObject;
@end

#pragma mark - NSData 分类

@interface NSData (JSONKit)
- (id)JSONObject;
@end

#pragma mark - 错误域

extern NSString *const JSONKitErrorDomain;
extern const NSInteger JSONKitErrorCode_InvalidData;
extern const NSInteger JSONKitErrorCode_InvalidString;
extern const NSInteger JSONKitErrorCode_UnsupportedEncoding;
extern const NSInteger JSONKitErrorCode_InvalidNumber;
extern const NSInteger JSONKitErrorCode_InvalidDictionaryKey;
extern const NSInteger JSONKitErrorCode_InvalidJSON;