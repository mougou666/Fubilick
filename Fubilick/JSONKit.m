//
//  JSONKit.m
//  BilibiliClient
//
//  Created by BilibiliClient on 2026/08/18.
//  Copyright ? 2026 BilibiliClient. All rights reserved.
//

#import "JSONKit.h"
#import <ctype.h>

NSString *const JSONKitErrorDomain = @"JSONKitErrorDomain";

#pragma mark - 内部解析器
@interface JSONParser : NSObject {
    NSString *jsonString;
    NSUInteger position;
    NSUInteger length;
}
- (id)parse;
- (id)parseValue;
- (id)parseObject;
- (id)parseArray;
- (id)parseString;
- (id)parseNumber;
- (void)skipWhitespace;
- (unichar)nextChar;
- (unichar)peekChar;
- (BOOL)isAtEnd;
- (BOOL)isDigit:(unichar)c;
@end

@implementation JSONParser

- (id)initWithString:(NSString *)string {
    self = [super init];
    if (self) {
        jsonString = [string retain];
        length = [string length];
        position = 0;
    }
    return self;
}

- (void)dealloc {
    [jsonString release];
    [super dealloc];
}

- (void)skipWhitespace {
    while (![self isAtEnd] && isspace([self peekChar])) {
        position++;
    }
}

- (unichar)nextChar {
    if ([self isAtEnd]) return 0;
    return [jsonString characterAtIndex:position++];
}

- (unichar)peekChar {
    if ([self isAtEnd]) return 0;
    return [jsonString characterAtIndex:position];
}

- (BOOL)isAtEnd {
    return position >= length;
}

- (BOOL)isDigit:(unichar)c {
    return c >= '0' && c <= '9';
}

- (id)parse {
    [self skipWhitespace];
    id result = [self parseValue];
    [self skipWhitespace];
    if (![self isAtEnd]) return nil;
    return result;
}

- (id)parseValue {
    [self skipWhitespace];
    if ([self isAtEnd]) return nil;
    unichar ch = [self peekChar];
    if (ch == '{') return [self parseObject];
    if (ch == '[') return [self parseArray];
    if (ch == '"') return [self parseString];
    if (ch == 't' || ch == 'f' || ch == 'n') {
        position++;
        if (ch == 't') {
            if (position + 3 <= length &&
                [jsonString characterAtIndex:position] == 'r' &&
                [jsonString characterAtIndex:position+1] == 'u' &&
                [jsonString characterAtIndex:position+2] == 'e') {
                position += 3;
                return [NSNumber numberWithBool:YES];
            }
        } else if (ch == 'f') {
            if (position + 4 <= length &&
                [jsonString characterAtIndex:position] == 'a' &&
                [jsonString characterAtIndex:position+1] == 'l' &&
                [jsonString characterAtIndex:position+2] == 's' &&
                [jsonString characterAtIndex:position+3] == 'e') {
                position += 4;
                return [NSNumber numberWithBool:NO];
            }
        } else if (ch == 'n') {
            if (position + 3 <= length &&
                [jsonString characterAtIndex:position] == 'u' &&
                [jsonString characterAtIndex:position+1] == 'l' &&
                [jsonString characterAtIndex:position+2] == 'l') {
                position += 3;
                return [NSNull null];
            }
        }
        return nil;
    }
    if (ch == '-' || [self isDigit:ch]) {
        return [self parseNumber];
    }
    return nil;
}

- (id)parseObject {
    position++; // '{'
    [self skipWhitespace];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if ([self peekChar] == '}') {
        position++;
        return dict;
    }
    while (![self isAtEnd]) {
        [self skipWhitespace];
        if ([self peekChar] != '"') return nil;
        NSString *key = [self parseString];
        if (!key) return nil;
        [self skipWhitespace];
        if ([self nextChar] != ':') return nil;
        [self skipWhitespace];
        id value = [self parseValue];
        if (!value) return nil;
        [dict setObject:value forKey:key];
        [self skipWhitespace];
        unichar ch = [self nextChar];
        if (ch == '}') return dict;
        if (ch != ',') return nil;
    }
    return nil;
}

- (id)parseArray {
    position++; // '['
    [self skipWhitespace];
    NSMutableArray *array = [NSMutableArray array];
    if ([self peekChar] == ']') {
        position++;
        return array;
    }
    while (![self isAtEnd]) {
        [self skipWhitespace];
        id value = [self parseValue];
        if (!value) return nil;
        [array addObject:value];
        [self skipWhitespace];
        unichar ch = [self nextChar];
        if (ch == ']') return array;
        if (ch != ',') return nil;
    }
    return nil;
}

- (id)parseString {
    position++; // '"'
    NSMutableString *str = [NSMutableString string];
    while (![self isAtEnd]) {
        unichar ch = [self nextChar];
        if (ch == '"') return str;
        if (ch == '\\') {
            if ([self isAtEnd]) return nil;
            unichar esc = [self nextChar];
            switch (esc) {
                case '"': [str appendString:@"\""]; break;
                case '\\': [str appendString:@"\\"]; break;
                case '/': [str appendString:@"/"]; break;
                case 'b': [str appendString:@"\b"]; break;
                case 'f': [str appendString:@"\f"]; break;
                case 'n': [str appendString:@"\n"]; break;
                case 'r': [str appendString:@"\r"]; break;
                case 't': [str appendString:@"\t"]; break;
                case 'u': {
                    if (position + 4 > length) return nil;
                    NSString *hex = [jsonString substringWithRange:NSMakeRange(position, 4)];
                    position += 4;
                    unsigned int val = 0;
                    [[NSScanner scannerWithString:hex] scanHexInt:&val];
                    [str appendFormat:@"%C", (unichar)val];
                    break;
                }
                default: return nil;
            }
        } else {
            [str appendFormat:@"%C", ch];
        }
    }
    return nil;
}

- (id)parseNumber {
    NSUInteger start = position;
    if ([self peekChar] == '-') position++;
    if ([self isAtEnd] || ![self isDigit:[self peekChar]]) return nil;
    while (![self isAtEnd] && [self isDigit:[self peekChar]]) position++;
    if (![self isAtEnd] && [self peekChar] == '.') {
        position++;
        if ([self isAtEnd] || ![self isDigit:[self peekChar]]) return nil;
        while (![self isAtEnd] && [self isDigit:[self peekChar]]) position++;
    }
    if (![self isAtEnd] && ([self peekChar] == 'e' || [self peekChar] == 'E')) {
        position++;
        if (![self isAtEnd] && ([self peekChar] == '+' || [self peekChar] == '-')) position++;
        if ([self isAtEnd] || ![self isDigit:[self peekChar]]) return nil;
        while (![self isAtEnd] && [self isDigit:[self peekChar]]) position++;
    }
    NSString *numStr = [jsonString substringWithRange:NSMakeRange(start, position - start)];
    if ([numStr rangeOfString:@"."].location != NSNotFound ||
        [numStr rangeOfString:@"e"].location != NSNotFound ||
        [numStr rangeOfString:@"E"].location != NSNotFound) {
        return [NSNumber numberWithDouble:[numStr doubleValue]];
    } else {
        return [NSNumber numberWithLongLong:[numStr longLongValue]];
    }
}

@end

#pragma mark - JSONDecoder
@implementation JSONDecoder

+ (JSONDecoder *)decoder {
    return [[[JSONDecoder alloc] init] autorelease];
}

- (id)objectWithData:(NSData *)data error:(NSError **)error {
    if (!data) {
        if (error) {
            *error = [NSError errorWithDomain:JSONKitErrorDomain
                                         code:-1
                                     userInfo:[NSDictionary dictionaryWithObject:@"Data is nil" forKey:NSLocalizedDescriptionKey]];
        }
        return nil;
    }
    NSString *str = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
    if (!str) {
        if (error) {
            *error = [NSError errorWithDomain:JSONKitErrorDomain
                                         code:-2
                                     userInfo:[NSDictionary dictionaryWithObject:@"Invalid UTF-8 data" forKey:NSLocalizedDescriptionKey]];
        }
        return nil;
    }
    return [self objectWithString:str error:error];
}

- (id)objectWithString:(NSString *)string error:(NSError **)error {
    if (!string) {
        if (error) {
            *error = [NSError errorWithDomain:JSONKitErrorDomain
                                         code:-3
                                     userInfo:[NSDictionary dictionaryWithObject:@"String is nil" forKey:NSLocalizedDescriptionKey]];
        }
        return nil;
    }
    JSONParser *parser = [[JSONParser alloc] initWithString:string];
    id result = [parser parse];
    [parser release];
    if (!result) {
        if (error) {
            *error = [NSError errorWithDomain:JSONKitErrorDomain
                                         code:-4
                                     userInfo:[NSDictionary dictionaryWithObject:@"Invalid JSON" forKey:NSLocalizedDescriptionKey]];
        }
        return nil;
    }
    return result;
}

@end

#pragma mark - NSString 分类
@implementation NSString (JSONKit)
- (id)JSONObject {
    JSONDecoder *decoder = [JSONDecoder decoder];
    return [decoder objectWithString:self error:nil];
}
@end

#pragma mark - NSData 分类
@implementation NSData (JSONKit)
- (id)JSONObject {
    JSONDecoder *decoder = [JSONDecoder decoder];
    return [decoder objectWithData:self error:nil];
}
@end