#import "BAMacros.h"

@interface NSData ( BA )

+ (NSData *)ba_base64EncodedString:(NSString *)string;
- (NSString *)ba_base64EncodedString;

- (NSString *)ba_UTF8String;
- (NSString *)ba_ASCIIString;
- (NSString *)ba_MD5String;

@end
