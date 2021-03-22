#import "BAMacros.h"

@interface NSString ( BAUtil )

- (BOOL)mt_startsWith:(NSString *)prefix;
- (BOOL)mt_endsWith:(NSString *)suffix;

- (BOOL)mt_contains:(NSString *)str;
- (BOOL)mt_contains:(NSString *)str options:(NSStringCompareOptions)option;

- (NSArray *)mt_split:(NSString *)separator;
- (NSString *)mt_append:(NSString *)str;

- (BOOL)mt_empty;
- (BOOL)mt_notEmpty;

- (BOOL)mt_is:(NSString *)other;
- (BOOL)mt_isNot:(NSString *)other;

- (NSString *)mt_trim;
- (NSString *)mt_trimBy:(NSString *)str;
- (NSString *)mt_trimFloatPointNumber; // 去掉浮点数尾部的'0'和'.' 如：1.00 ==> 1, 0.00 ==> 0, 0.50 ==> 0.5
- (NSString *)mt_trimmingWhitespace; // 去除空格
- (NSString *)mt_trimmingWhitespaceAndNewlines; // 去除字符串与空行
+ (NSString *)mt_trimmingWhitespaceAndChangLineWithChangN:(NSString*)str;
- (NSString *)mt_trimmingLeadingWhitespace; // 去掉NSString前面的空格
- (NSString *)mt_trimmingLeadingAndTrailingWhitespace; // 去掉NSString前面和后面的空格

+ (NSString *)mt_random; // count = 8
+ (NSString *)mt_random:(int)count;

- (NSString *)mt_base64EncodedString:(NSStringEncoding)encoding;
- (NSString *)mt_base64DecodedString:(NSStringEncoding)encoding;

- (NSData *)mt_toData;
- (NSString *)mt_MD5String;

- (NSString *)mt_unwrap;
- (NSString *)mt_normalize;

- (NSString *)mt_repeat:(NSUInteger)count;

- (BOOL)mt_match:(NSString *)expression;
- (BOOL)mt_matchAnyOf:(NSArray *)array;
- (NSString *)mt_matchGroupAtIndex:(NSUInteger)idx forRegex:(NSString *)regex;
- (NSArray *)mt_allMatchesForRegex:(NSString *)regex;
- (NSString *)mt_stringByReplacingMatchesForRegex:(NSString *)regex withString:(NSString *)replacement;
- (NSString *)mt_stringByRegex:(NSString*)pattern substitution:(NSString*)substitute;

/**  Return the char value at the specified index. */
- (unichar)mt_charAt:(int)index;
- (int)mt_indexOfChar:(unichar)ch;
- (int)mt_indexOfChar:(unichar)ch fromIndex:(int)index;
- (int)mt_indexOfString:(NSString *)str;
- (int)mt_indexOfString:(NSString *)str fromIndex:(int)index;
- (int)mt_lastIndexOfChar:(unichar)ch;
- (int)mt_lastIndexOfChar:(unichar)ch fromIndex:(int)index;
- (int)mt_lastIndexOfString:(NSString *)str;
- (int)mt_lastIndexOfString:(NSString *)str fromIndex:(int)index;

- (NSString *)mt_toLowerCase;
- (NSString *)mt_toUpperCase;

- (NSString *)mt_replaceAll:(NSString *)origin with:(NSString *)replacement;
+ (NSString *)mt_reverseString:(NSString *)strSrc; // 反转字符串

- (BOOL)mt_equalsIgnoreCase:(NSString *)anotherString;

- (NSComparisonResult)mt_compareTo:(NSString *)anotherString;
- (NSComparisonResult)mt_compareToIgnoreCase:(NSString *)str;

- (BOOL)mt_isValueOf:(NSArray *)array;
- (BOOL)mt_isValueOf:(NSArray *)array caseInsens:(BOOL)caseInsens;

- (NSString *)mt_substringFromIndex:(NSUInteger)from untilString:(NSString *)string;
- (NSString *)mt_substringFromIndex:(NSUInteger)from untilString:(NSString *)string endOffset:(NSUInteger *)endOffset;

- (NSString *)mt_substringFromIndex:(NSUInteger)from untilCharset:(NSCharacterSet *)charset;
- (NSString *)mt_substringFromIndex:(NSUInteger)from untilCharset:(NSCharacterSet *)charset endOffset:(NSUInteger *)endOffset;

- (NSString *)mt_substringFromIndex:(int)beginIndex toIndex:(int)endIndex;

- (NSUInteger)mt_countFromIndex:(NSUInteger)from inCharset:(NSCharacterSet *)charset;

- (NSArray<NSString *> *)mt_rangeStringsOfSubString:(NSString *)subString;

+ (NSString *)mt_randomLength:(NSUInteger)len;

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
