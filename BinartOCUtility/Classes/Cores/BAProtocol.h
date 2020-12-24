
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

// Interface
#define DEF_PROTOCOL( $protocol ) DEF_PROTOCOL_IMP( $protocol, _pk_get_container_class( $protocol ) )

// Implementation
#undef  DEF_PROTOCOL_IMP
#define DEF_PROTOCOL_IMP($protocol, $container_class) \
        protocol $protocol; \
        @interface $container_class : NSObject <$protocol> @end \
        @implementation $container_class \
        + (void)load { \
            _pk_extension_load(@protocol($protocol), $container_class.class); \
        } \

// Get container class name by counter
#define _pk_get_container_class($protocol) _pk_get_container_class_imp($protocol, __COUNTER__)
#define _pk_get_container_class_imp($protocol, $counter) _pk_get_container_class_imp_concat(__PKContainer_, $protocol, $counter)
#define _pk_get_container_class_imp_concat($a, $b, $c) $a ## $b ## _ ## $c

void _pk_extension_load(Protocol *protocol, Class containerClass);

/**
 * Protocol Extension Usage
 *
 * @code

// Protocol

@protocol Forkable <NSObject>

@optional
- (void)fork;

@required
- (NSString *)github;

@end

// Protocol Extension

@defs(Forkable)

- (void)fork {
    NSLog(@"Forkable protocol extension: I'm forking (%@).", self.github);
}

- (NSString *)github {
    return @"This is a required method, concrete class must override me.";
}

@end

// Concrete Class

@interface Forkingdog : NSObject <Forkable>
@end

@implementation Forkingdog

- (NSString *)github {
    return @"https://github.com/forkingdog";
}

@end
 
 * @endcode
 *
 * @note You can either implement within a single @defs or multiple ones.
 *
 */
