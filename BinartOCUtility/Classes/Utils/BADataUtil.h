#import "BAMacros.h"
#import "BAProperty.h"

@interface NSData ( BAUtil )

@PROP_READONLY( BOOL, ba_isJPEG )
@PROP_READONLY( BOOL, ba_isPNG )
@PROP_READONLY( BOOL, ba_isImage )
@PROP_READONLY( BOOL, ba_isMPEG4 )
@PROP_READONLY( BOOL, ba_isMedia )
@PROP_READONLY( BOOL, ba_isCompressed )

@PROP_READONLY( NSString *, ba_appropriateFileExtension )

@PROP_READONLY( NSString *, ba_UTF8String )
@PROP_READONLY( NSString *, ba_ASCIIString )
@PROP_READONLY( NSString *, ba_MD5String )
@PROP_READONLY( NSString *, ba_HEXString )

@PROP_READONLY( NSString *, ba_BASE64String )

@end

///
@interface BADataUtil: NSObject

+ (NSData *)ba_base64EncodedString:(NSString *)string;

@end
