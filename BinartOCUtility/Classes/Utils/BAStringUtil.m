#import "BAStringUtil.h"
#import "BADataUtil.h"
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonRandom.h>

@implementation NSString ( BA )

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
    return [data ba_base64EncodedString];
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
    return [NSData ba_base64EncodedString:self];
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

@end
