#import "BAStringUtil.h"
#import "BADataUtil.h"
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonRandom.h>
#import "regex.h"
#import <CommonCrypto/CommonHMAC.h>

/*
 * Replaces all occurences and stores it in buf
 */
int rreplace (char *buf, int size, regex_t *re, char *rp) {
    char *pos;
    long long sub, so, n;
    regmatch_t pmatch [10]; /* regoff_t is int so size is int */
    
    if (regexec (re, buf, 10, pmatch, 0)) return 0;
    for (pos = rp; *pos; pos++) {
        if (*pos == '\\' && *(pos + 1) > '0' && *(pos + 1) <= '9') {
            so = pmatch [*(pos + 1) - 48].rm_so;
            n = pmatch [*(pos + 1) - 48].rm_eo - so;
            if (so < 0 || strlen (rp) + n - 1 > size) return 1;
            memmove (pos + n, pos + 2, strlen (pos) - 1);
            memmove (pos, buf + so, n);
            pos = pos + n - 2;
        }
    }
    
    sub = pmatch [1].rm_so; /* no repeated replace when sub >= 0 */
    for (pos = buf; !regexec (re, pos, 1, pmatch, 0); ) {
        n = pmatch [0].rm_eo - pmatch [0].rm_so;
        pos += pmatch [0].rm_so;
        if (strlen (buf) - n + strlen (rp) + 1 > size) return 1;
        memmove (pos + strlen (rp), pos + n, strlen (pos) - n + 1);
        memmove (pos, rp, strlen (rp));
        pos += strlen (rp);
        if (sub >= 0) break;
    }
    
    return 0;
}

@implementation NSString ( BAUtil )

- (BOOL)ba_startsWith:(NSString*)prefix {
    return [self hasPrefix:prefix];
}

- (BOOL)ba_endsWith:(NSString*)suffix {
    return [self hasSuffix:suffix];
}

- (BOOL)ba_contains:(NSString*) str {
    NSRange range = [self rangeOfString:str];
    return (range.location != NSNotFound);
}

- (BOOL)ba_contains:(NSString*) str options:(NSStringCompareOptions)option {
    NSRange range = [self rangeOfString:str options:option];
    return (range.location != NSNotFound);
}

- (NSArray *)ba_split:(NSString *)separator {
    return [self componentsSeparatedByString:separator];
}

- (NSString *)ba_append:(NSString *)str {
    return [self stringByAppendingString:str];
}

- (BOOL)ba_empty {
    return ![self length];
}

- (BOOL)ba_notEmpty {
    return !![self length];
}

- (BOOL)ba_is:(NSString *)other {
    return [self isEqualToString:other];
}

- (BOOL)ba_isNot:(NSString *)other {
    return ![self isEqualToString:other];
}

- (NSString *)ba_trim {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *)ba_trimmingWhitespace {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (NSString *)ba_trimmingWhitespaceAndNewlines {
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)ba_trimmingWhitespaceAndChangLineWithChangN:(NSString*)str{
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]; //去除掉首尾的空白字符和换行字符
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return str;
}

- (NSString *)ba_trimmingLeadingAndTrailingWhitespace {
    
    NSString *newString = [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return [newString ba_trimmingLeadingWhitespace];
}

- (NSString *)ba_trimmingLeadingWhitespace {
    NSInteger i = 0;
    
    while ((i < [self length])
           && [[NSCharacterSet whitespaceCharacterSet] characterIsMember:[self characterAtIndex:i]]) {
        i++;
    }
    return [self substringFromIndex:i];
}

- (NSString *)ba_trimBy:(NSString *)str {
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:str];
    return [self stringByTrimmingCharactersInSet:set];
}
- (NSString *)delZero:(NSString *)src { // 去掉当前字符串的0，不同于[self trimBy:@"0"]
    if ([src ba_endsWith:@"0"]) {
        return [self delZero:[src ba_substringFromIndex:0 toIndex:(int)[src length]-1]];
    } else {
        return src;
    }
}
- (NSString *)ba_trimFloatPointNumber {
    return [[self delZero:self] ba_trimBy:@"."];
}

+ (NSString *)ba_random {
    return [self ba_random:8];
}

+ (NSString *)ba_random:(int)count {
    if (count < 1) {
        return nil;
    }
    
    count = count*0.5;
    unsigned char digest[count];
    CCRNGStatus status = CCRandomGenerateBytes(digest, count);
    if (status == kCCSuccess) {
        return [self ba_stringFrom:digest length:count];
    }
    return nil;
}


+ (NSString *)ba_stringFrom:(unsigned char *)digest length:(size_t)length {
    NSMutableString *string = [NSMutableString string];
    for (int i = 0; i < length; i++) {
        [string appendFormat:@"%02x",digest[i]];
    }
    return string;
}


- (NSString *)ba_base64EncodedString:(NSStringEncoding)encoding {
    NSData *data = [self dataUsingEncoding:encoding allowLossyConversion:YES];
    return data.ba_BASE64String;
}

- (NSString *)ba_base64DecodedString:(NSStringEncoding)encoding {
    return [NSString ba_stringWithBase64EncodedString:self encoding:encoding];
}

+ (NSString *)ba_stringWithBase64EncodedString:(NSString *)string encoding:(NSStringEncoding)encoding {
    NSData *data = [string ba_base64DecodedData];
    if (data) {
        return [[self alloc] initWithData:data encoding:encoding];
    }
    return nil;
}

- (NSData *)ba_base64DecodedData {
    return [BADataUtil ba_base64EncodedString:self];
}

- (NSData *)ba_toData {
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)ba_MD5String {
    const char * pointer = [self UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(pointer, (CC_LONG)strlen(pointer), md5Buffer);
    
    NSMutableString *string = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [string appendFormat:@"%02x",md5Buffer[i]];
    
    return string;
}

- (NSString *)ba_unwrap {
    if ( self.length >= 2 ) {
        if ( [self hasPrefix:@"\""] && [self hasSuffix:@"\""] ) {
            return [self substringWithRange:NSMakeRange(1, self.length - 2)];
        }
        
        if ( [self hasPrefix:@"'"] && [self hasSuffix:@"'"] ) {
            return [self substringWithRange:NSMakeRange(1, self.length - 2)];
        }
    }
    
    return self;
}

- (NSString *)ba_normalize {
    NSArray * lines = [self componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    if ( lines && lines.count ) {
        NSMutableString * mergedString = [NSMutableString string];
        
        for ( NSString * line in lines ) {
            NSString * trimed = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            if ( trimed && trimed.length ) {
                [mergedString appendString:trimed];
            }
        }
        
        return mergedString;
    }
    
    return nil;
}

- (NSString *)ba_fill:(NSString *)origin
               sub:(NSString*)str
         maxLength:(int)len
                at:(BOOL)tail {
    NSString *ret = origin;
    for (int i = 0; i < (len - origin.length) ; i++ ) {
        
        ret = tail ? [NSString stringWithFormat:@"%@%@", ret, str] : [NSString stringWithFormat:@"%@%@", str, ret];
    }
    return ret;
}

- (NSString *)ba_repeat:(NSUInteger)count {
    if ( 0 == count )
        return @"";

    NSMutableString * text = [NSMutableString string];
    
    for ( NSUInteger i = 0; i < count; ++i ) {
        [text appendString:self];
    }
    
    return text;
}

- (NSString *)ba_strongify {
    return [self stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
}

- (BOOL)ba_match:(NSString *)expression {
    NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:expression
                                                                            options:NSRegularExpressionCaseInsensitive
                                                                              error:nil];
    if ( nil == regex )
        return NO;
    
    NSUInteger numberOfMatches = [regex numberOfMatchesInString:self
                                                        options:0
                                                          range:NSMakeRange(0, self.length)];
    if ( 0 == numberOfMatches )
        return NO;
    
    return YES;
}

- (BOOL)ba_matchAnyOf:(NSArray *)array {
    for ( NSString * str in array ) {
        if ( NSOrderedSame == [self compare:str options:NSCaseInsensitiveSearch] ) {
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)ba_isValueOf:(NSArray *)array {
    return [self ba_isValueOf:array caseInsens:NO];
}

- (BOOL)ba_isValueOf:(NSArray *)array caseInsens:(BOOL)caseInsens {
    NSStringCompareOptions option = caseInsens ? NSCaseInsensitiveSearch : 0;
    
    for ( NSObject * obj in array ) {
        if ( NO == [obj isKindOfClass:[NSString class]] )
            continue;
        
        if ( NSOrderedSame == [(NSString *)obj compare:self options:option] )
            return YES;
    }
    
    return NO;
}

//added end
- (NSString *)ba_substringFromIndex:(NSUInteger)from untilString:(NSString *)string {
    return [self ba_substringFromIndex:from untilString:string endOffset:NULL];
}

- (NSString *)ba_substringFromIndex:(NSUInteger)from untilString:(NSString *)string endOffset:(NSUInteger *)endOffset {
    if ( 0 == self.length )
        return nil;
    
    if ( from >= self.length )
        return nil;
    
    NSRange range = NSMakeRange( from, self.length - from );
    NSRange range2 = [self rangeOfString:string options:NSCaseInsensitiveSearch range:range];
    
    if ( NSNotFound == range2.location ) {
        if ( endOffset ) {
            *endOffset = range.location + range.length;
        }
        
        return [self substringWithRange:range];
    } else {
        if ( endOffset ) {
            *endOffset = range2.location + range2.length;
        }
        
        return [self substringWithRange:NSMakeRange(from, range2.location - from)];
    }
}

- (NSString *)ba_substringFromIndex:(NSUInteger)from untilCharset:(NSCharacterSet *)charset {
    return [self ba_substringFromIndex:from untilCharset:charset endOffset:NULL];
}

- (NSString *)ba_substringFromIndex:(NSUInteger)from untilCharset:(NSCharacterSet *)charset endOffset:(NSUInteger *)endOffset {
    if ( 0 == self.length )
        return nil;
    
    if ( from >= self.length )
        return nil;

    NSRange range = NSMakeRange( from, self.length - from );
    NSRange range2 = [self rangeOfCharacterFromSet:charset options:NSCaseInsensitiveSearch range:range];

    if ( NSNotFound == range2.location ) {
        if ( endOffset ) {
            *endOffset = range.location + range.length;
        }
        
        return [self substringWithRange:range];
    } else {
        if ( endOffset ) {
            *endOffset = range2.location + range2.length;
        }

        return [self substringWithRange:NSMakeRange(from, range2.location - from)];
    }
}

- (NSUInteger)ba_countFromIndex:(NSUInteger)from inCharset:(NSCharacterSet *)charset {
    if ( 0 == self.length )
        return 0;
    
    if ( from >= self.length )
        return 0;
    
    NSCharacterSet * reversedCharset = [charset invertedSet];

    NSRange range = NSMakeRange( from, self.length - from );
    NSRange range2 = [self rangeOfCharacterFromSet:reversedCharset options:NSCaseInsensitiveSearch range:range];

    if ( NSNotFound == range2.location ) {
        return self.length - from;
    } else {
        return range2.location - from;
    }
}

#define NotFoundEx -1

/**  Java-like method. Returns the char value at the specified index. */
- (unichar)ba_charAt:(int)index {
    return [self characterAtIndex:index];
}

/**
 * Java-like method. Compares two strings lexicographically.
 * the value 0 if the argument string is equal to this string;
 * a value less than 0 if this string is lexicographically less than the string argument;
 * and a value greater than 0 if this string is lexicographically greater than the string argument.
 */
- (NSComparisonResult)ba_compareTo:(NSString *)anotherString {
    return [self compare:anotherString];
}

/** Java-like method. Compares two strings lexicographically, ignoring case differences. */
- (NSComparisonResult)ba_compareToIgnoreCase:(NSString *)str {
    return [self compare:str options:NSCaseInsensitiveSearch];
}

- (BOOL)ba_equalsIgnoreCase:(NSString *)anotherString {
    return [[self ba_toLowerCase] ba_is:[anotherString ba_toLowerCase]];
}

- (int)ba_indexOfChar:(unichar)ch {
    return [self ba_indexOfChar:ch fromIndex:0];
}

- (int)ba_indexOfChar:(unichar)ch fromIndex:(int)index {
    int len = (int)self.length;
    for (int i = index; i < len; ++i) {
        if (ch == [self ba_charAt:i]) {
            return i;
        }
    }
    return NotFoundEx;
}

- (int)ba_indexOfString:(NSString*)str {
    NSRange range = [self rangeOfString:str];
    if (range.location == NSNotFound) {
        return NotFoundEx;
    }
    return (int)range.location;
}

- (int)ba_indexOfString:(NSString*)str fromIndex:(int)index {
    NSRange fromRange = NSMakeRange(index, self.length - index);
    NSRange range = [self rangeOfString:str options:NSLiteralSearch range:fromRange];
    if (range.location == NSNotFound) {
        return NotFoundEx;
    }
    return (int)range.location;
}

- (int)ba_lastIndexOfChar:(unichar)ch {
    int len = (int)self.length;
    for (int i = len-1; i >=0; --i) {
        if ([self ba_charAt:i] == ch) {
            return i;
        }
    }
    return NotFoundEx;
}

- (int)ba_lastIndexOfChar:(unichar)ch fromIndex:(int)index {
    int len = (int)self.length;
    if (index >= len) {
        index = len - 1;
    }
    for (int i = index; i >= 0; --i) {
        if ([self ba_charAt:i] == ch) {
            return index;
        }
    }
    return NotFoundEx;
}

- (int)ba_lastIndexOfString:(NSString*)str {
    NSRange range = [self rangeOfString:str options:NSBackwardsSearch];
    if (range.location == NSNotFound) {
        return NotFoundEx;
    }
    return (int)range.location;
}

- (int)ba_lastIndexOfString:(NSString*)str fromIndex:(int)index {
    NSRange fromRange = NSMakeRange(0, index);
    NSRange range = [self rangeOfString:str options:NSBackwardsSearch range:fromRange];
    if (range.location == NSNotFound) {
        return NotFoundEx;
    }
    return (int)range.location;
}

- (NSString *)ba_substringFromIndex:(int)beginIndex toIndex:(int)endIndex {
    if (endIndex <= beginIndex) {
        return @"";
    }
    NSRange range = NSMakeRange(beginIndex, endIndex - beginIndex);
    return [self substringWithRange:range];
}

- (NSString *)ba_toLowerCase {
    return [self lowercaseString];
}

- (NSString *)ba_toUpperCase {
    return [self uppercaseString];
}

- (NSString *)ba_replaceAll:(NSString*)origin with:(NSString*)replacement {
    return [self stringByReplacingOccurrencesOfString:origin withString:replacement];
}

+ (NSString *)ba_reverseString:(NSString *)strSrc {
    NSMutableString* reverseString = [[NSMutableString alloc] init];
    NSInteger charIndex = [strSrc length];
    while (charIndex > 0) {
        charIndex --;
        NSRange subStrRange = NSMakeRange(charIndex, 1);
        [reverseString appendString:[strSrc substringWithRange:subStrRange]];
    }
    return reverseString;
}

- (NSString *)ba_matchGroupAtIndex:(NSUInteger)idx forRegex:(NSString *)regex {
    NSArray *matches = [self ba_matchesForRegex:regex];
    if (matches.count == 0) return nil;
    NSTextCheckingResult *match = matches[0];
    if (idx >= match.numberOfRanges) return nil;
    
    return [self substringWithRange:[match rangeAtIndex:idx]];
}

- (NSArray *)ba_matchesForRegex:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    if (error)
        return nil;
    NSArray *matches = [regex matchesInString:self options:0 range:NSMakeRange(0, self.length)];
    if (matches.count == 0)
        return nil;
    
    return matches;
}

- (NSArray *)ba_allMatchesForRegex:(NSString *)regex {
    NSArray *matches = [self ba_matchesForRegex:regex];
    if (matches.count == 0) return @[];
    
    NSMutableArray *strings = [NSMutableArray new];
    for (NSTextCheckingResult *result in matches)
        [strings addObject:[self substringWithRange:[result rangeAtIndex:1]]];
    
    return strings;
}

- (NSString *)ba_stringByReplacingMatchesForRegex:(NSString *)pattern withString:(NSString *)replacement {
    return [self stringByReplacingOccurrencesOfString:pattern withString:replacement options:NSRegularExpressionSearch range:NSMakeRange(0, self.length)];
}

- (NSString *)ba_stringByRegex:(NSString*)pattern substitution:(NSString*)substitute {
    regex_t preg;
    NSString *result = nil;
    
    // compile pattern
    int err = regcomp(&preg, [pattern UTF8String], 0 | REG_ICASE | REG_EXTENDED);
    if (err) {
        char errmsg[256];
        regerror(err, &preg, errmsg, sizeof(errmsg));
        //        [NSException raise:@"AFRegexStringException"
        //                    format:@"Regex compilation failed for \"%@\": %s", pattern, errmsg];
        return [NSString stringWithString:self];
    } else {
        char buffer[4096];
        char *buf = buffer;
        const char *utf8String = [self UTF8String];
        
        if(strlen(utf8String) >= sizeof(buffer))
            buf = malloc(strlen(utf8String) + 1);
        
        strcpy(buf, utf8String);
        char *replaceStr = (char*)[substitute UTF8String];
        
        if (rreplace (buf, 4096, &preg, replaceStr)) {
            //            [NSException raise:@"AFRegexStringException"
            //                        format:@"Replace failed"];
            result = [NSString stringWithString:self];
        } else {
            result = [NSString stringWithUTF8String:buf];
        }
        
        if(buf != buffer)
            free(buf);
    }
    
    
    regfree(&preg);  // fixme: used to be commented
    return result;
}

- (NSArray<NSString *> *)ba_rangeStringsOfSubString:(NSString *)subString {
    if (![subString isKindOfClass:[NSString class]]) {
        return nil;
    }
    if ([subString length] == 0 || [self length] == 0) {
        return nil;
    }
    NSString *copyStr = self;
    NSMutableString *replaceString = [[NSMutableString alloc] init];
    for (NSUInteger index = 0; index < [subString length]; index ++) {
        [replaceString appendString:@"x"];
    }
    NSMutableArray *tempArray = [[NSMutableArray alloc] init];
    while ([copyStr rangeOfString:subString].location != NSNotFound) {
        NSRange  range  = [copyStr rangeOfString:subString];
        if (range.location != NSNotFound) {
            [tempArray addObject:NSStringFromRange(range)];
        }
        copyStr = [copyStr stringByReplacingCharactersInRange:NSMakeRange(range.location, range.length) withString:replaceString];
    }
    if ([tempArray count] > 0) {
        return [NSArray arrayWithArray:tempArray];
    }
    return nil;
}

+ (NSString *)ba_randomLength:(NSUInteger)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (NSInteger i = 0; i < len; i++) {
        [randomString appendFormat:@"%C", [letters characterAtIndex: arc4random_uniform((uint32_t)[letters length])]];
    }
    return randomString;
    
}

@end

@implementation NSString (StringEncoding)

- (NSString *)UTF82GBK {
    return [[NSString alloc] initWithData:[self dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(NSUTF8StringEncoding)] encoding: kCFStringEncodingGB_18030_2000];
}

- (NSString *)GBK2UTF8 {
    return [[NSString alloc] initWithData:[self dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)] encoding: NSUTF8StringEncoding];
}

@end

@implementation _String

//iOS中对字符串进行UTF-8编码：输出str字符串的UTF-8格式
//
//[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//
//
//
//解码：把str字符串以UTF-8规则进行解码
//
//[str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

// http://www.cocoachina.com/bbs/read.php?tid=167144

@end
