#import "BAMacros.h"
#import "BAProperty.h"

#undef  NSERROR
#define NSERROR( name ) \
        property (class, nonatomic, readonly) NSError *name;

// 默认，把当前类，作为域 (domain)
#undef  DEF_NSERROR
#define DEF_NSERROR( name, v, d ) \
        + (NSError *)name { return MAKE_ERROR_3(NSStringFromClass([self class]), v, d); }

NS_ASSUME_NONNULL_BEGIN

@interface NSError ( Handler )

@NSSTRING( messagedKey )
@NSSTRING( errorDomain )

@PROP_READONLY( NSString *, message )

+ (instancetype)errorWithDomain:(NSString *)domain
                           code:(NSInteger)code
                           desc:(NSString *)desc;

- (BOOL)is:(NSInteger)code;

@end

NS_ASSUME_NONNULL_END
