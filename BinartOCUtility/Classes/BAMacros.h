// 元宏定义用小写
// 普通宏定义用大写

#ifndef __BA_MACROS_H__
#define __BA_MACROS_H__

// ----------------------------------
// Common headers
// ----------------------------------

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

// ----------------------------------
// Common macros
// ----------------------------------

#if TARGET_IPHONE_SIMULATOR
#   define __SIMULATOR__            1
#   define __IPHONE__               0
#elif TARGET_OS_IPHONE
#   define __SIMULATOR__            0
#   define __IPHONE__               1
#endif

/**
 *  also can use #pragma unused ( __x )
 */
#undef  UNUSED
#define UNUSED( __x )               { id __unused_var__ __attribute__((unused)) = (id)(__x); }

#undef  ALIAS
#define ALIAS( __a, __b )           __typeof__(__a) __b = __a;

#undef  DEPRECATED
#define DEPRECATED                  __attribute__((deprecated))

#undef  deprecatedify
#define deprecatedify( _info_ )     __attribute((deprecated(_info_)))

#undef  EXTERN
#define EXTERN                      extern __attribute__((visibility ("default")))

#undef  STATIC_METHOD
#define STATIC_METHOD               __unused static

#undef  TODO
#define TODO( X )                   _Pragma(macro_cstr(message("TODO: " X)))

#undef  MUST
#define MUST( X )                   switch(0){case 0: case 0:_Pragma(macro_cstr(message("MUST: " X)));}

#if defined(__cplusplus)
#undef  EXTERN_C
#define EXTERN_C                    extern "C"
#else
#undef  EXTERN_C
#define EXTERN_C                    extern
#endif

#undef  INLINE
#define INLINE                      __inline__ __attribute__((always_inline))

//#if __has_include(<YYWebImage/YYWebImage.h>)
#undef  HAS_HEADER
#define HAS_HEADER( ... )           __has_include( __VA_ARGS__ )

// return the clamped value
#undef  CLAMP
#define CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))

// return the clamped bool value
#undef  BETWEEN
#define BETWEEN(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (NO) : (((_x_) < (_low_)) ? (NO) : (YES)))

// ----------------------------------
// Meta macro
// ----------------------------------

#define macro_first(...)                                macro_first_( __VA_ARGS__, 0 )
#define macro_first_( A, ... )                            A

#define macro_concat( A, B )                            macro_concat_( A, B )
#define macro_concat_( A, B )                            A##B

#define macro_count(...)                                macro_at( 8, __VA_ARGS__, 8, 7, 6, 5, 4, 3, 2, 1 )
#define macro_more(...)                                 macro_at( 8, __VA_ARGS__, 1, 1, 1, 1, 1, 1, 1, 1 )

#define macro_at0(...)                                  macro_first(__VA_ARGS__)
#define macro_at1(_0, ...)                              macro_first(__VA_ARGS__)
#define macro_at2(_0, _1, ...)                          macro_first(__VA_ARGS__)
#define macro_at3(_0, _1, _2, ...)                      macro_first(__VA_ARGS__)
#define macro_at4(_0, _1, _2, _3, ...)                  macro_first(__VA_ARGS__)
#define macro_at5(_0, _1, _2, _3, _4 ...)               macro_first(__VA_ARGS__)
#define macro_at6(_0, _1, _2, _3, _4, _5 ...)           macro_first(__VA_ARGS__)
#define macro_at7(_0, _1, _2, _3, _4, _5, _6 ...)       macro_first(__VA_ARGS__)
#define macro_at8(_0, _1, _2, _3, _4, _5, _6, _7, ...)  macro_first(__VA_ARGS__)
#define macro_at(N, ...)                                macro_concat(macro_at, N)( __VA_ARGS__ )

#define macro_join0( ... )
#define macro_join1( A )                                A
#define macro_join2( A, B )                             A##____##B
#define macro_join3( A, B, C )                          A##____##B##____##C
#define macro_join4( A, B, C, D )                       A##____##B##____##C##____##D
#define macro_join5( A, B, C, D, E )                    A##____##B##____##C##____##D##____##E
#define macro_join6( A, B, C, D, E, F )                 A##____##B##____##C##____##D##____##E##____##F
#define macro_join7( A, B, C, D, E, F, G )                A##____##B##____##C##____##D##____##E##____##F##____##G
#define macro_join8( A, B, C, D, E, F, G, H )            A##____##B##____##C##____##D##____##E##____##F##____##G##____##H
#define macro_join( ... )                                macro_concat(macro_join, macro_count(__VA_ARGS__))(__VA_ARGS__)

#define macro_cstr( A )                                 macro_cstr_( A )
#define macro_cstr_( A )                                #A

#define macro_string( A )                               macro_string_( A )
#define macro_string_( A )                              @(#A)

// ----------------------------------
// Objc macros
// ----------------------------------

// weak, 自动变量为 '_'
#undef  WEAKLY
#define WEAKLY( value )                 __unused __weak typeof(value) _ = value;

#undef  IS_MAIN
#define IS_MAIN                          [NSThread isMainThread]

#undef  WEAKIFY
#define WEAKIFY( x ) \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wshadow\"") \
    autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x; \
    _Pragma("clang diagnostic pop")

#undef  STRONGIFY
#define STRONGIFY( x ) \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wshadow\"") \
    try{} @finally{} __typeof__(x) x = __weak_##x##__; \
    _Pragma("clang diagnostic pop")

#undef  DELAY // timeout ms
#define DELAY(timeout, block) \
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), block);

/// 信号量实现简单的异步转同步
#undef  SYNC_INIT
#define SYNC_INIT dispatch_semaphore_t sema = dispatch_semaphore_create(0);

#undef  SYNC_WAIT
#define SYNC_WAIT dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);

#undef  SYNC_SEND
#define SYNC_SEND dispatch_semaphore_signal(sema);

/// 当前方法名称
#undef  SEL_NAME
#define SEL_NAME NSStringFromSelector(_cmd)
#define METHOD_NAME SEL_NAME

/// 属性已过期
#undef  DEPRECATED_PROP
#define DEPRECATED_PROP __attribute__((deprecated("属性已过期")))

// 标记这个属性已过期
//@property (nonatomic, copy) NSString *name __attribute__((deprecated("属性已过期")));
//
//// 标记方法已过期
//- (void)testOld __attribute__((deprecated("方法已过期, 请使用 test2"))) {
//
//}

/// 方法已过期
#undef  DEPRECATED_SEL
#define DEPRECATED_SEL() __attribute__((deprecated("方法已过期")))

// https://cloud.tencent.com/developer/article/1400469
// 可以自定义描述信息
//__attribute__((deprecated("已过期!"))) // 编译警告
// 系统的宏定义
//DEPRECATED_ATTRIBUTE

// 可以自定义描述信息
//__attribute__((unavailable("已经废弃,请使用 xxxx"))) // 编译报错
// 系统宏定义
//NS_UNAVAILABLE;
//UNAVAILABLE_ATTRIBUTE;

// 调试代码块
#ifdef DEBUG
#define BA_LOG( s, ... )                   fprintf(stderr,"%s, %d, %s\n", [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:(s), ##__VA_ARGS__] UTF8String]);
#else
#define BA_LOG( s, ... )
#endif

// 大小
#undef  MAX3
#define MAX3(a, b, c)                   ((a) > (b) ? ((a) > (c) ? (a) : (c)) : ((b) > (c) ? (b) : (c)))

#undef  MIN3
#define MIN3(a, b, c)                   ((a) < (b) ? ((a) < (c) ? (a) : (c)) : ((b) < (c) ? (b) : (c)))

// 判断某个方法是否覆写
#undef  IS_METHOD_OVERRIDED
#define IS_METHOD_OVERRIDED( sc , c , m ) [sc instanceMethodForSelector:@selector(m)] != [c instanceMethodForSelector:@selector(m)]

// 判断某个方法是否实现
#undef  IS_METHOD_IMPLEMENTED
#define IS_METHOD_IMPLEMENTED( o, m )   ([o respondsToSelector:@selector(m)])

// 判断某个协议是否被实现
#undef  IS_PROTOCOL_IMPLEMENTED
#define IS_PROTOCOL_IMPLEMENTED( o, p ) [o conformsToProtocol:@protocol(p)]

#undef  RETURN_IF
#define RETURN_IF( _exp_ )                      if (_exp_) { return; }

// block can be null, more safely
#undef  INVOKE_BLOCK_VOID
#define INVOKE_BLOCK_VOID( _block_ )            { if (_block_) _block_(); }

#undef  INVOKE_BLOCK
#define INVOKE_BLOCK( _block_, ... )            { if (_block_) _block_(__VA_ARGS__); }

#undef  SELECTOR_IFY
#define SELECTOR_IFY( c )                       NSSelectorFromString( @#c )

#undef  KEYPATH_IFY
#define KEYPATH_IFY( keypath )                  NSStringFromSelector(@selector(keypath))

#define TAKE_NONULL( ... )                      macro_concat(TAKE_NONULL_, macro_count(__VA_ARGS__))( __VA_ARGS__ )
#define TAKE_NONULL_0( ... )
#define TAKE_NONULL_1( ... )
#define TAKE_NONULL_2( a, b )                   ( a ? a : b )
#define TAKE_NONULL_3( a, b, c )                TAKE_NONULL_2( take_nonull_2(a, b), c)

#undef  TIMEOUT
#define TIMEOUT(timeout, block) \
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), block);

#undef  EXEC_ONCE
#define EXEC_ONCE( _block_ ) \
        { \
            static dispatch_once_t predicate; \
            dispatch_once(&predicate, _block_); \
        }

#undef  SINGLETON
#define SINGLETON( cls ) \
        property (nonatomic, readonly) cls * shared; \
        @property (class, nonatomic, readonly) cls *shared;

#undef  DEF_SINGLETON
#define DEF_SINGLETON( cls ) \
        dynamic shared; \
        - (cls *)shared \
        { \
            return [cls shared]; \
        } \
        + (cls *)shared \
        { \
            static dispatch_once_t once; \
            static __strong id __singleton__ = nil; \
            dispatch_once( &once, ^{ __singleton__ = [[cls alloc] init]; } ); \
            return __singleton__; \
        }

#undef  DEF_SINGLETON_AUTOLOAD
#define DEF_SINGLETON_AUTOLOAD( cls ) \
        DEF_SINGLETON( cls ) \
        + (void)load \
        { \
            [self shared]; \
        }

// ----------------------------------
// Inline functions
// ----------------------------------

static inline BOOL BA_IS_NULL(id _Nullable thing) {
    return thing == nil ||
    ([thing isEqual:[NSNull null]]) ||
    ([thing isKindOfClass:[NSNull class]]);
}


static inline BOOL BA_IS_EMPTY(id _Nonnull thing) {
    return thing == nil ||
    ([thing isEqual:[NSNull null]]) ||
    ([thing isKindOfClass:[NSNull class]]) ||
    ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0) ||
    ([thing respondsToSelector:@selector(count)]  && [(NSArray *)thing count] == 0);
}

static inline BOOL BA_NOT_EMPTY(id _Nonnull thing) {
    return !BA_IS_EMPTY(thing);
}

static inline size_t BA_LEN(id _Nonnull thing) {
    if (BA_IS_EMPTY(thing)) return 0;
    
    if ([thing respondsToSelector:@selector(length)]) {
        return (size_t)[thing performSelector:@selector(length)];
    }
    
    if ([thing respondsToSelector:@selector(count)]) {
        return (size_t)[thing performSelector:@selector(count)];
    }
    
    if ([thing respondsToSelector:@selector(allKeys)]) {
        return BA_LEN([thing performSelector:@selector(allKeys)]);
    }
    
    return 0;
}

// ----------------------------------
// System macros
// ----------------------------------

// System Versioning

#define SYS_VER                                 [UIDevice currentDevice].systemVersion
#define SYS_VER_EQ( v )                         ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)

#define SYS_VER_GT( v )                         ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)

#define SYS_VER_GE( v )                         ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define SYS_VER_LT( v )                         ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)

#define SYS_VER_LE( v )                         ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#undef  RUNLOOP_SKIP_A_WHILE
#define RUNLOOP_SKIP_A_WHILE \
        { \
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]]; \
        }

#include <unistd.h>

#if defined(__APPLE__) && defined(__aarch64__)

#define __debugbreak() __asm__ __volatile__(                \
        "   mov    x0, %x0;    \n" /* pid                */ \
        "   mov    x1, #0x11;  \n" /* SIGSTOP            */ \
        "   mov    x16, #0x25; \n" /* syscall 37 = kill  */ \
        "   svc    #0x80       \n" /* software interrupt */ \
        "   mov    x0, x0      \n" /* nop                */ \
        ::  "r"(getpid())                                   \
        :   "x0", "x1", "x16", "memory")
#elif defined(__APPLE__) && defined(__arm__)

#define __debugbreak() __asm__ __volatile__(                \
        "   mov    r0, %0;     \n" /* pid                */ \
        "   mov    r1, #0x11;  \n" /* SIGSTOP            */ \
        "   mov    r12, #0x25; \n" /* syscall 37 = kill  */ \
        "   svc    #0x80       \n" /* software interrupt */ \
        "   mov    r0, r0      \n" /* nop                */ \
        ::  "r"(getpid())                                   \
        :   "r0", "r1", "r12", "memory")

#elif defined(__APPLE__) && (defined(__i386__) || defined(__x86_64__))

#define __debugbreak() __asm__ __volatile__("int $3; mov %eax, %eax")

#endif


// ----------------------------------
// Color macros
// ----------------------------------

#define COLOR_HEXA( value, a ) \
        [UIColor colorWithRed:((float)((value & 0xFF0000) >> 16))/255.0 \
        green:((float)((value & 0xFF00) >> 8))/255.0 \
        blue:((float)(value & 0xFF))/255.0 \
        alpha:a]
#define COLOR_HEX( hex )                    COLOR_HEXA( hex, 1.0 )
#define COLOR_RGBA( r, g, b, a )            [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define COLOR_RGB( r, g,  b )               COLOR_RGBA(r, g, b, 1.0f)

// ----------------------------------
// App info
// ----------------------------------

#define APP_BUILD                   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define APP_VERSION                 [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define APP_DISPLAY_NAME            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
#define APP_BUNDLE_NAME             [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey]
#define APP_BUNDLE_ID               [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey]

#define APP_DEVICE_NAME             [[UIDevice currentDevice] name]
#define APP_DEVICE_MODEL            [[UIDevice currentDevice] model]
#define APP_DEVIXE_SYSTEM_VERSION   [[UIDevice currentDevice] systemVersion]

#define APP_WINDOW                  [[UIApplication sharedApplication].delegate window]
#define APP_WINDOW_IS_LANDSCAPE     UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
#define APP_WINDOW_IS_PORTRAIT      !APP_WINDOW_IS_LANDSCAPE
#define APP_WINDOW_CURRENT_WIDTH    (APP_WINDOW_IS_LANDSCAPE ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)
#define APP_WINDOW_CURRENT_HEIGHT   (APP_WINDOW_IS_LANDSCAPE ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
#define APP_WINDOW_CURRENT_SIZE     CGSizeMake(APP_WINDOW_CURRENT_WIDTH, APP_WINDOW_CURRENT_HEIGHT)

// 常用的沙盒目录
#define PATH_OF_APP_HOME            NSHomeDirectory()
#define PATH_OF_TEMP                NSTemporaryDirectory()
#define PATH_OF_DOCUMENT            [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define PATH_OF_LIBRARY             [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define PATH_OF_CACHE               [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

// 预设文件存储位置
#define PATH_TO_DATABASE            [PATH_OF_CACHE stringByAppendingPathComponent:@"dbs"]
#define PATH_TO_FILECACHE           [PATH_OF_CACHE stringByAppendingPathComponent:@"files"]
#define PATH_TO_IMAGECACHE          [PATH_OF_CACHE stringByAppendingPathComponent:@"images"]

// ----------------------------------
// String macros
// ----------------------------------

#undef  STRINGIFY
#define STRINGIFY( s )                  @#s // 双 # 号 是拼接成c字符串

#undef  FILENAME
#define FILENAME    [[string_from_charPtr(__FILE__) lastPathComponent] split:@"."][0]

// ----------------------------------
// Block predefine
// ----------------------------------

typedef void(^ BABlock)( void );
typedef void(^ BABlockBlock)( _Nullable BABlock block );
typedef void(^ BABOOLBlock)( BOOL b );
typedef void(^ BAObjectBlock)( _Nullable id obj );
typedef void(^ BAArrayBlock)( NSArray * _Nullable array );
typedef void(^ BAMutableArrayBlock)( NSMutableArray * _Nullable array );
typedef void(^ BADictionaryBlock)( NSDictionary *_Nullable dic );
typedef void(^ BAErrorBlock)( NSError * _Nullable error );
typedef void(^ BAIndexBlock)( NSInteger index );
typedef void(^ BAListItemBlock)( NSInteger index, id _Nullable item );
typedef void(^ BAFloatBlock)( CGFloat afloat );
typedef void(^ BAStringBlock)( NSString * _Nullable str );
typedef void(^ BAImageBlock)( UIImage * _Nullable image );
typedef void(^ ProgressBlock)( NSProgress * _Nullable progress );
typedef void(^ BACompleteBlock)( NSObject * _Nullable res, NSInteger err, NSString * _Nullable msg );
typedef void(^ BAResponseBlock)( NSObject * _Nullable res, NSError * _Nullable err );
typedef void(^ BAPercentBlock)( double percent); // 0~100

/**
 操作类型：OperationType
 操作类型可用key：如下
 */
#define OperationTypeKey @"key.OperationType"
typedef enum : NSUInteger {
    BAOperationAdd = 0,
    BAOperationDelete,
    BAOperationEdit,
    BAOperationQuery,
} BAOperationType;

typedef enum {
    BAHttpMethodGet = 0,
    BAHttpMethodPost = 1,
    BAHttpMethodDelete = 2
} _HttpMethodType;

#endif // __BA_MACROS_H__
