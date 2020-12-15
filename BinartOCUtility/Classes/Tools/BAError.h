#import "BAMacros.h"
#import "BAProperty.h"

/**
 -- 声明
 @ error( XXXXFailed )
 
 -- 实现
 @ def_error(   )
 
 */

#undef  make_error
#define make_error( __domain, __code ) \
([NSError errorWithDomain:__domain code:__code userInfo:nil])

#undef  make_error_3
#define make_error_3( __domain, __code, __desc ) \
([NSError errorWithDomain:__domain \
code:__code \
desc:__desc])

#undef  error_message_of
#define error_message_of( __error ) \
(__error . userInfo [kErrorDescString])

#pragma mark -

#undef    error
#define error( __name ) \
property (nonatomic, readonly) NSError * __name; \
- (NSError *)__name; \
+ (NSError *)__name;

// Error definition has error poll below

#undef    def_error // 默认，把当前类，作为域 (domain)
// @example: XXXVM的error属性，则domain为'XXXVM'
#define def_error( __name, __value, __desc ) \
dynamic __name; \
- (NSError *)__name { return make_error_3(make_string_obj(NSStringFromClass([self class])), __value, __desc); } \
+ (NSError *)__name { return make_error_3(make_string_obj(NSStringFromClass([self class])), __value, __desc); }

#undef    def_error_1 // 自定义 domain
#define def_error_1( __name, __domain, __value, __desc ) \
dynamic __name; \
- (NSError *)__name { return make_error_3(__domain, __value, __desc); } \
+ (NSError *)__name { return make_error_3(__domain, __value, __desc); }

#undef    def_error_2 // 默认，使用系统域
#define def_error_2( __name, __value, __desc ) \
def_error_1( __name, [NSError errorDomain], __value, __desc)



// ErrorCode for error
#undef  error_for
#define error_for( __code ) ([self errorForCode:__code])

// MARK: - NSError ( Handler )

NS_ASSUME_NONNULL_BEGIN

@interface NSError (Handler) // NSError的属性：domain、code、userinfo.....

@prop_readonly( NSString *, domainKey )
@prop_readonly( NSNumber *, codeKey )

@nsstring( messagedKey )

// == 系统的
@nsstring( CocoaErrorDomain )
@nsstring( LocalizedDescriptionKey )
@nsstring( StringEncodingErrorKey )
@nsstring( URLErrorKey )
@nsstring( FilePathErrorKey )

// == 框架的
@nsstring( errorDomain )

@prop_readonly( NSString *, message )


// Error maker

+ (instancetype)errorWithDomain:(NSString *)domain
                           code:(NSInteger)code
                           desc:(NSString *)desc;

// Equal

- (BOOL)isInteger:(NSInteger)code;

- (BOOL)is:(NSError *)error;

@end

@interface NSError ( BA )

- (NSError *)errorForCode:(NSInteger)code;

+ (NSError *)errorForCode:(NSInteger)code;

@end

NS_ASSUME_NONNULL_END
