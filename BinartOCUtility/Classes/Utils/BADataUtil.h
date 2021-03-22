#import "BAMacros.h"
#import "BAProperty.h"

@interface NSData ( BAUtil )

@PROP_READONLY( BOOL, mt_isJPEG )
@PROP_READONLY( BOOL, mt_isPNG )
@PROP_READONLY( BOOL, mt_isImage )
@PROP_READONLY( BOOL, mt_isMPEG4 )
@PROP_READONLY( BOOL, mt_isMedia )
@PROP_READONLY( BOOL, mt_isCompressed )

@PROP_READONLY( NSString *, mt_appropriateFileExtension )

@PROP_READONLY( NSString *, mt_UTF8String )
@PROP_READONLY( NSString *, mt_ASCIIString )
@PROP_READONLY( NSString *, mt_MD5String )
@PROP_READONLY( NSString *, mt_HEXString )

@PROP_READONLY( NSString *, mt_BASE64String )

@end

///
@interface BADataUtil: NSObject

+ (NSData *)mt_base64EncodedString:(NSString *)string;

@end
