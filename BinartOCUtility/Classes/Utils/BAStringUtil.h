#import "BAMacros.h"

#pragma mark -

@interface NSString ( Extension )

- (NSString *)unwrap;
- (NSString *)normalize;

- (NSString *)repeat:(NSUInteger)count;

- (BOOL)match:(NSString *)expression;
- (BOOL)matchAnyOf:(NSArray *)array;
- (NSString *)matchGroupAtIndex:(NSUInteger)idx forRegex:(NSString *)regex;
- (NSArray *)allMatchesForRegex:(NSString *)regex;
- (NSString *)stringByReplacingMatchesForRegex:(NSString *)regex withString:(NSString *)replacement;
- (NSString *)stringByRegex:(NSString*)pattern substitution:(NSString*)substitute;

/**  Return the char value at the specified index. */
- (unichar)charAt:(int)index;
- (int)indexOfChar:(unichar)ch;
- (int)indexOfChar:(unichar)ch fromIndex:(int)index;
- (int)indexOfString:(NSString *)str;
- (int)indexOfString:(NSString *)str fromIndex:(int)index;
- (int)lastIndexOfChar:(unichar)ch;
- (int)lastIndexOfChar:(unichar)ch fromIndex:(int)index;
- (int)lastIndexOfString:(NSString *)str;
- (int)lastIndexOfString:(NSString *)str fromIndex:(int)index;

- (NSString *)toLowerCase;
- (NSString *)toUpperCase;

- (NSString *)replaceAll:(NSString *)origin with:(NSString *)replacement;
- (NSArray *)split:(NSString *)separator;
+ (NSString *)reverseString:(NSString *)strSrc; // 反转字符串

- (BOOL)empty;
- (BOOL)notEmpty;

- (BOOL)is:(NSString *)other;
- (BOOL)isNot:(NSString *)other;
- (BOOL)equalsIgnoreCase:(NSString *)anotherString;

/**
 * Compares two strings lexicographically.
 * the value 0 if the argument string is equal to this string;
 * a value less than 0 if this string is lexicographically less than the string argument;
 * and a value greater than 0 if this string is lexicographically greater than the string argument.
 */
- (NSComparisonResult)compareTo:(NSString *)anotherString;
- (NSComparisonResult)compareToIgnoreCase:(NSString *)str;

- (BOOL)isValueOf:(NSArray *)array;
- (BOOL)isValueOf:(NSArray *)array caseInsens:(BOOL)caseInsens;

- (NSString *)substringFromIndex:(NSUInteger)from untilString:(NSString *)string;
- (NSString *)substringFromIndex:(NSUInteger)from untilString:(NSString *)string endOffset:(NSUInteger *)endOffset;

- (NSString *)substringFromIndex:(NSUInteger)from untilCharset:(NSCharacterSet *)charset;
- (NSString *)substringFromIndex:(NSUInteger)from untilCharset:(NSCharacterSet *)charset endOffset:(NSUInteger *)endOffset;

- (NSString *)substringFromIndex:(int)beginIndex toIndex:(int)endIndex;

- (NSUInteger)countFromIndex:(NSUInteger)from inCharset:(NSCharacterSet *)charset;

- (NSArray<NSString *> *)rangeStringsOfSubString:(NSString *)subString;

+ (NSString *)randomLength:(NSUInteger)len;

@end


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

@end
