#import "BAMacros.h"

@interface NSString ( BA )

- (BOOL)ba_startsWith:(NSString *)prefix;
- (BOOL)ba_endsWith:(NSString *)suffix;

- (BOOL)ba_contains:(NSString *)str;

- (NSArray *)ba_split:(NSString *)separator;
- (NSString *)ba_append:(NSString *)str;

- (BOOL)ba_empty;
- (BOOL)ba_notEmpty;

- (BOOL)ba_is:(NSString *)other;
- (BOOL)ba_isNot:(NSString *)other;

+ (NSString *)ba_random; // count = 8
+ (NSString *)ba_random:(int)count;

- (NSString *)ba_base64EncodedString:(NSStringEncoding)encoding;
- (NSString *)ba_base64DecodedString:(NSStringEncoding)encoding;

- (NSData *)ba_toData;

- (NSString *)ba_MD5String;

@end
