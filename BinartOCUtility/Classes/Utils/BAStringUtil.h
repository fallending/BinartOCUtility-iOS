#import "BAMacros.h"

@interface NSString ( BAUtil )

- (BOOL)ba_startsWith:(NSString *)prefix;
- (BOOL)ba_endsWith:(NSString *)suffix;

- (BOOL)ba_contains:(NSString *)str;
- (BOOL)ba_contains:(NSString *)str options:(NSStringCompareOptions)option;

- (NSArray *)ba_split:(NSString *)separator;
- (NSString *)ba_append:(NSString *)str;

- (BOOL)ba_empty;
- (BOOL)ba_notEmpty;

- (BOOL)ba_is:(NSString *)other;
- (BOOL)ba_isNot:(NSString *)other;

- (NSString *)ba_trim;
- (NSString *)ba_trimBy:(NSString *)str;
- (NSString *)ba_trimFloatPointNumber; // 去掉浮点数尾部的'0'和'.' 如：1.00 ==> 1, 0.00 ==> 0, 0.50 ==> 0.5
- (NSString *)ba_trimmingWhitespace; // 去除空格
- (NSString *)ba_trimmingWhitespaceAndNewlines; // 去除字符串与空行
+ (NSString *)ba_trimmingWhitespaceAndChangLineWithChangN:(NSString*)str;
- (NSString *)ba_trimmingLeadingWhitespace; // 去掉NSString前面的空格
- (NSString *)ba_trimmingLeadingAndTrailingWhitespace; // 去掉NSString前面和后面的空格

+ (NSString *)ba_random; // count = 8
+ (NSString *)ba_random:(int)count;

- (NSString *)ba_base64EncodedString:(NSStringEncoding)encoding;
- (NSString *)ba_base64DecodedString:(NSStringEncoding)encoding;

- (NSData *)ba_toData;
- (NSString *)ba_MD5String;

- (NSString *)ba_unwrap;
- (NSString *)ba_normalize;

- (NSString *)ba_repeat:(NSUInteger)count;

- (BOOL)ba_match:(NSString *)expression;
- (BOOL)ba_matchAnyOf:(NSArray *)array;
- (NSString *)ba_matchGroupAtIndex:(NSUInteger)idx forRegex:(NSString *)regex;
- (NSArray *)ba_allMatchesForRegex:(NSString *)regex;
- (NSString *)ba_stringByReplacingMatchesForRegex:(NSString *)regex withString:(NSString *)replacement;
- (NSString *)ba_stringByRegex:(NSString*)pattern substitution:(NSString*)substitute;

/**  Return the char value at the specified index. */
- (unichar)ba_charAt:(int)index;
- (int)ba_indexOfChar:(unichar)ch;
- (int)ba_indexOfChar:(unichar)ch fromIndex:(int)index;
- (int)ba_indexOfString:(NSString *)str;
- (int)ba_indexOfString:(NSString *)str fromIndex:(int)index;
- (int)ba_lastIndexOfChar:(unichar)ch;
- (int)ba_lastIndexOfChar:(unichar)ch fromIndex:(int)index;
- (int)ba_lastIndexOfString:(NSString *)str;
- (int)ba_lastIndexOfString:(NSString *)str fromIndex:(int)index;

- (NSString *)ba_toLowerCase;
- (NSString *)ba_toUpperCase;

- (NSString *)ba_replaceAll:(NSString *)origin with:(NSString *)replacement;
+ (NSString *)ba_reverseString:(NSString *)strSrc; // 反转字符串

- (BOOL)ba_equalsIgnoreCase:(NSString *)anotherString;

- (NSComparisonResult)ba_compareTo:(NSString *)anotherString;
- (NSComparisonResult)ba_compareToIgnoreCase:(NSString *)str;

- (BOOL)ba_isValueOf:(NSArray *)array;
- (BOOL)ba_isValueOf:(NSArray *)array caseInsens:(BOOL)caseInsens;

- (NSString *)ba_substringFromIndex:(NSUInteger)from untilString:(NSString *)string;
- (NSString *)ba_substringFromIndex:(NSUInteger)from untilString:(NSString *)string endOffset:(NSUInteger *)endOffset;

- (NSString *)ba_substringFromIndex:(NSUInteger)from untilCharset:(NSCharacterSet *)charset;
- (NSString *)ba_substringFromIndex:(NSUInteger)from untilCharset:(NSCharacterSet *)charset endOffset:(NSUInteger *)endOffset;

- (NSString *)ba_substringFromIndex:(int)beginIndex toIndex:(int)endIndex;

- (NSUInteger)ba_countFromIndex:(NSUInteger)from inCharset:(NSCharacterSet *)charset;

- (NSArray<NSString *> *)ba_rangeStringsOfSubString:(NSString *)subString;

+ (NSString *)ba_randomLength:(NSUInteger)len;

@end

// GBK
// CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)

// Unicode
// NSUnicodeStringEncoding

// UTF8
// NSUTF8StringEncoding

//encoding
#define GBSTR_FROM_DATA(data) [[NSString alloc] initWithData: (data) encoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseSimplif)]
#define UTF82GBK(str) [[NSString alloc] initWithData:[str dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(NSUTF8StringEncoding)] encoding: kCFStringEncodingGB_18030_2000]
#define GBK2UTF8(str) [[NSString alloc] initWithData:[str dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)] encoding: NSUTF8StringEncoding]

@interface NSString (StringEncoding)

- (NSString *)UTF82GBK;

- (NSString *)GBK2UTF8;

@end

// 注意：should be removed

@interface _String : NSObject



@end
