#import "BAMacros.h"
#import "BAProperty.h"

@interface NSData ( BAUtil )

@property (nonatomic, readonly) NSString *    string;
@property (nonatomic, readonly) NSString *    utf8String;

- (BOOL)isJPEG;
- (BOOL)isPNG;
- (BOOL)isImage;
- (BOOL)isMPEG4;
- (BOOL)isMedia;
- (BOOL)isCompressed;
- (NSString *)appropriateFileExtension;

+ (NSData *)ba_base64EncodedString:(NSString *)string;
- (NSString *)ba_base64EncodedString;

- (NSString *)ba_UTF8String;
- (NSString *)ba_ASCIIString;
- (NSString *)ba_MD5String;

@PROP_READONLY( NSString *, ba_HEXString)

@end

///
@interface BADataUtil: NSObject

@end
