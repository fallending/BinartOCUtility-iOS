
#import <Foundation/Foundation.h>

// ----------------------------------
// MARK: Macros
// ----------------------------------

#undef  STATIC_PROPERTY
#define STATIC_PROPERTY( _name_ ) \
        property (nonatomic, readonly) NSString * _name_; \
        - (NSString *)_name_; \
        + (NSString *)_name_;

#undef  DEF_STATIC_PROPERTY
#define DEF_STATIC_PROPERTY( _name_, ... ) \
        macro_concat(DEF_STATIC_PROPERTY, macro_count(__VA_ARGS__))(_name_, __VA_ARGS__)

#undef  DEF_STATIC_PROPERTY0
#define DEF_STATIC_PROPERTY0( _name_ ) \
        dynamic _name_; \
        - (NSString *)_name_ { return [NSString stringWithFormat:@"%s", #_name_]; } \
        + (NSString *)_name_ { return [NSString stringWithFormat:@"%s", #_name_]; }

#undef  DEF_STATIC_PROPERTY1
#define DEF_STATIC_PROPERTY1( _name_, A ) \
        dynamic _name_; \
        - (NSString *)_name_ { return [NSString stringWithFormat:@"%@.%s", A, #_name_]; } \
        + (NSString *)_name_ { return [NSString stringWithFormat:@"%@.%s", A, #_name_]; }

#undef  DEF_STATIC_PROPERTY2
#define DEF_STATIC_PROPERTY2( _name_, A, B ) \
        dynamic _name_; \
        - (NSString *)_name_ { return [NSString stringWithFormat:@"%@.%@.%s", A, B, #_name_]; } \
        + (NSString *)_name_ { return [NSString stringWithFormat:@"%@.%@.%s", A, B, #_name_]; }

#undef  DEF_STATIC_PROPERTY3
#define DEF_STATIC_PROPERTY3( _name_, A, B, C ) \
        dynamic _name_; \
        - (NSString *)_name_ { return [NSString stringWithFormat:@"%@.%@.%@.%s", A, B, C, #_name_]; } \
        + (NSString *)_name_ { return [NSString stringWithFormat:@"%@.%@.%@.%s", A, B, C, #_name_]; }

#undef  NSNUMBER
#define NSNUMBER( _name_ ) \
        property (nonatomic, readonly) NSNumber * _name_; \
        - (NSNumber *)_name_; \
        + (NSNumber *)_name_;

#undef  DEF_NSNUMBER
#define DEF_NSNUMBER( _name_, _value_ ) \
        dynamic _name_; \
        - (NSNumber *)_name_ { return @(_value_); } \
        + (NSNumber *)_name_ { return @(_value_); }

#undef  NSSTRING
#define NSSTRING( _name_ ) \
        property (nonatomic, readonly) NSString * _name_; \
        - (NSString *)_name_; \
        + (NSString *)_name_;

#undef  DEF_NSSTRING
#define DEF_NSSTRING( _name_ ) \
        dynamic _name_; \
        - (NSString *)_name_ { return [NSString stringWithFormat:@"%s", #_name_]; } \
        + (NSString *)_name_ { return [NSString stringWithFormat:@"%s", #_name_]; }

// MAKR: -

#define PROP_READONLY( type, name )         property (nonatomic, readonly) type name;
#define PROP_DYNAMIC( type, name )          property (nonatomic, strong) type name;
#define PROP_ASSIGN( type, name )           property (nonatomic, assign) type name;
#define PROP_STRONG( type, name )           property (nonatomic, strong) type name;
#define PROP_WEAK( type, name )             property (nonatomic, weak) type name;
#define PROP_COPY( type, name )             property (nonatomic, copy) type name;
#define PROP_STATIC( type, name )           property (nonatomic, class) type name;

// MAKR: -

#define DEF_PROP_READONLY( type, name, ... ) \
        synthesize name = _##name; \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

#define DEF_PROP_DYNAMIC( type, name, ... ) \
        dynamic name; \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

#define DEF_PROP_ASSIGN( type, name, ... ) \
        synthesize name = _##name; \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

#define DEF_PROP_STRONG( type, name, ... ) \
        synthesize name = _##name; \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

#define DEF_PROP_WEAK( type, name, ... ) \
        synthesize name = _##name; \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

#define DEF_PROP_COPY( type, name, ... ) \
        synthesize name = _##name; \
        + (NSString *)property_##name { return macro_string( macro_join(__VA_ARGS__) ); }

#define DEF_PROP_STATIC( type, name, setName ) \
        dynamic name; \
        static type __##name; \
        + (type)name { return __##name; } \
        + (void)setName:(type)name { __##name = name; }

// ----------------------------------
// MARK: Class code
// ----------------------------------

NS_ASSUME_NONNULL_BEGIN

@interface NSObject ( BAProperty )

+ (const char *)mt_attributesForProperty:(NSString *)property;
- (const char *)mt_attributesForProperty:(NSString *)property;

+ (NSDictionary *)mt_extentionForProperty:(NSString *)property;
- (NSDictionary *)mt_extentionForProperty:(NSString *)property;

+ (NSString *)mt_extentionForProperty:(NSString *)property stringValueWithKey:(NSString *)key;
- (NSString *)mt_extentionForProperty:(NSString *)property stringValueWithKey:(NSString *)key;

+ (NSArray *)mt_extentionForProperty:(NSString *)property arrayValueWithKey:(NSString *)key;
- (NSArray *)mt_extentionForProperty:(NSString *)property arrayValueWithKey:(NSString *)key;

- (BOOL)mt_hasAssociatedObjectForKey:(const char *)key;
- (id)mt_getAssociatedObjectForKey:(const char *)key;
- (id)mt_copyAssociatedObject:(id)obj forKey:(const char *)key;
- (id)mt_retainAssociatedObject:(id)obj forKey:(const char *)key;
- (id)mt_assignAssociatedObject:(id)obj forKey:(const char *)key;
- (void)mt_weaklyAssociateObject:(id)obj forKey:(const char *)key;
- (void)mt_removeAssociatedObjectForKey:(const char *)key;
- (void)mt_removeAllAssociatedObjects;

@end

NS_ASSUME_NONNULL_END
