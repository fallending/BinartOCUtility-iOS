#import "BAMacros.h"
#import "BAProperty.h"

/**
 -- 声明
 @ error( XXXXFailed )
 
 -- 实现
 @ def_error(   )
 
 */

#undef  MAKE_ERROR
#define MAKE_ERROR( __domain, __code ) \
        ([NSError errorWithDomain:__domain code:__code userInfo:nil])

#undef  MAKE_ERROR_3
#define MAKE_ERROR_3( __domain, __code, __desc ) \
        ([NSError errorWithDomain:__domain \
        code:__code \
        desc:__desc])

#undef  NSERROR
#define NSERROR( __name ) \
        property (nonatomic, readonly) NSError * __name; \
        - (NSError *)__name; \
        + (NSError *)__name;

// Error definition has error poll below

// 默认，把当前类，作为域 (domain)
#undef  DEF_ERROR
#define DEF_ERROR( __name, __value, __desc ) \
        dynamic __name; \
        - (NSError *)__name { return MAKE_ERROR_3(NSStringFromClass([self class]), __value, __desc); } \
        + (NSError *)__name { return MAKE_ERROR_3(NSStringFromClass([self class]), __value, __desc); }

#undef  DEF_ERROR_1 // 自定义 domain
#define DEF_ERROR_1( __name, __domain, __value, __desc ) \
dynamic __name; \
- (NSError *)__name { return MAKE_ERROR_3(__domain, __value, __desc); } \
+ (NSError *)__name { return MAKE_ERROR_3(__domain, __value, __desc); }

#undef  DEF_ERROR_2 // 默认，使用系统域
#define DEF_ERROR_2( __name, __value, __desc ) \
        DEF_ERROR_1( __name, [NSError errorDomain], __value, __desc)



// ErrorCode for error
#undef  error_for
#define error_for( __code ) ([self errorForCode:__code])

// MARK: - NSError ( Handler )

NS_ASSUME_NONNULL_BEGIN

@interface NSError (Handler) // NSError的属性：domain、code、userinfo.....

@prop_readonly( NSString *, domainKey )
@prop_readonly( NSNumber *, codeKey )

@NSSTRING( messagedKey )
@NSSTRING( errorDomain )

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
