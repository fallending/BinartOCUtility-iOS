
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

#ifndef __BA_MACROS_H__
#define __BA_MACROS_H__

// ----------------------------------
// Common use macros
// ----------------------------------

#if TARGET_IPHONE_SIMULATOR
#   define __SIMULATOR__     1
#   define __IPHONE__        0
#elif TARGET_OS_IPHONE
#   define __SIMULATOR__     0
#   define __IPHONE__        1
#endif

/**
 *  also can use #pragma unused ( __x )
 */
#undef  UNUSED
#define UNUSED( __x )        { id __unused_var__ __attribute__((unused)) = (id)(__x); }

#undef  ALIAS
#define ALIAS( __a, __b )    __typeof__(__a) __b = __a;

#undef  DEPRECATED
#define DEPRECATED            __attribute__((deprecated))

#undef  deprecatedify
#define deprecatedify( _info_ ) __attribute((deprecated(_info_)))

#undef  EXTERN
#define EXTERN    extern __attribute__((visibility ("default")))

#undef  STATIC_METHOD
#define STATIC_METHOD    __unused static

#undef  TODO
#define TODO( X )            _Pragma(macro_cstr(message("TODO: " X)))

// #define compiler_assert(x) switch(0){case 0: case x:;}
#undef  MUST
#define MUST( X )     switch(0){case 0: case 0:_Pragma(macro_cstr(message("MUST: " X)));}

#if defined(__cplusplus)
#   undef    EXTERN_C
#   define  EXTERN_C            extern "C"
#else
#   undef    EXTERN_C
#   define  EXTERN_C            extern
#endif

#undef  INLINE
#define INLINE                __inline__ __attribute__((always_inline))

// More useful of __has_include()
//#if __has_include(<YYWebImage/YYWebImage.h>)
//#import <YYWebImage/YYImageCache.h>
//#import <YYWebImage/YYWebImageManager.h>
//#else
//#import "YYImageCache.h"
//#import "YYWebImageManager.h"
//#endif

#ifndef CLAMP // return the clamped value
#define CLAMP(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (_high_) : (((_x_) < (_low_)) ? (_low_) : (_x_)))
#endif

#ifndef BETWEEN // return the clamped bool value
#define BETWEEN(_x_, _low_, _high_)  (((_x_) > (_high_)) ? (NO) : (((_x_) < (_low_)) ? (NO) : (YES)))
#endif

// ----------------------------------
// Meta macro
// ----------------------------------

#define macro_first(...)                                macro_first_( __VA_ARGS__, 0 )
#define macro_first_( A, ... )                            A

#define macro_concat( A, B )                            macro_concat_( A, B )
#define macro_concat_( A, B )                            A##B

#define macro_count(...)                                macro_at( 8, __VA_ARGS__, 8, 7, 6, 5, 4, 3, 2, 1 )
#define macro_more(...)                                    macro_at( 8, __VA_ARGS__, 1, 1, 1, 1, 1, 1, 1, 1 )

#define macro_at0(...)                                    macro_first(__VA_ARGS__)
#define macro_at1(_0, ...)                                macro_first(__VA_ARGS__)
#define macro_at2(_0, _1, ...)                            macro_first(__VA_ARGS__)
#define macro_at3(_0, _1, _2, ...)                        macro_first(__VA_ARGS__)
#define macro_at4(_0, _1, _2, _3, ...)                    macro_first(__VA_ARGS__)
#define macro_at5(_0, _1, _2, _3, _4 ...)                macro_first(__VA_ARGS__)
#define macro_at6(_0, _1, _2, _3, _4, _5 ...)            macro_first(__VA_ARGS__)
#define macro_at7(_0, _1, _2, _3, _4, _5, _6 ...)        macro_first(__VA_ARGS__)
#define macro_at8(_0, _1, _2, _3, _4, _5, _6, _7, ...)    macro_first(__VA_ARGS__)
#define macro_at(N, ...)                                macro_concat(macro_at, N)( __VA_ARGS__ )

#define macro_join0( ... )
#define macro_join1( A )                                A
#define macro_join2( A, B )                                A##____##B
#define macro_join3( A, B, C )                            A##____##B##____##C
#define macro_join4( A, B, C, D )                        A##____##B##____##C##____##D
#define macro_join5( A, B, C, D, E )                    A##____##B##____##C##____##D##____##E
#define macro_join6( A, B, C, D, E, F )                    A##____##B##____##C##____##D##____##E##____##F
#define macro_join7( A, B, C, D, E, F, G )                A##____##B##____##C##____##D##____##E##____##F##____##G
#define macro_join8( A, B, C, D, E, F, G, H )            A##____##B##____##C##____##D##____##E##____##F##____##G##____##H
#define macro_join( ... )                                macro_concat(macro_join, macro_count(__VA_ARGS__))(__VA_ARGS__)

#define macro_cstr( A )                                    macro_cstr_( A )
#define macro_cstr_( A )                                #A

#define macro_string( A )                                macro_string_( A )
#define macro_string_( A )                                @(#A)

// ----------------------------------
// Objc macros
// ----------------------------------

// weak, 自动变量为 '_'
#define weakly( value ) __unused __weak typeof(value) _ = value;

// 调试代码块
#ifdef DEBUG

#   define LOG( s, ... ) fprintf(stderr,"%s, %d, %s\n", [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:(s), ##__VA_ARGS__] UTF8String]);
#   define debug_code( code_fragment ) { code_fragment }

#else

#   define LOG( s, ... )
#   define debug_code( code_fragment )

#endif

// 大小
#ifndef MAX3
#   define MAX3(a, b, c) ((a) > (b) ? ((a) > (c) ? (a) : (c)) : ((b) > (c) ? (b) : (c)))
#endif

#ifndef MIN3
#   define MIN3(a, b, c) ((a) < (b) ? ((a) < (c) ? (a) : (c)) : ((b) < (c) ? (b) : (c)))
#endif

// 判断某个方法是否覆写
#define is_method_overrided( _subclass_ , _class_ , _selector_ ) [_subclass_ instanceMethodForSelector:_selector_] != [_class_ instanceMethodForSelector:_selector_]

// 判断某个方法是否实现
#define is_method_implemented( _object_, _method_ ) ([_object_ respondsToSelector:@selector(_method_)])

// 判断某个协议是否被实现
#define is_protocol_implemented( _instance_, _protocol_ ) [_instance_ conformsToProtocol:@protocol(_protocol_)]

// compiler help
#define invalidate_timer( _timer_ ) { [_timer_ invalidate]; _timer_ = nil; }
#define verified_class( _className_ ) ((_className_ *) NSClassFromString(@"" # _className_))

#define nonullify( _obj_, _obj_class_ ) (is_null(_obj_)? instanceof(_obj_class_) :_obj_)

// 判断对象是否null
static inline BOOL is_null(id _Nullable thing) {
    return thing == nil ||
    ([thing isEqual:[NSNull null]]) ||
    ([thing isKindOfClass:[NSNull class]]);
}

// 判断任何容器是否为空
// http://www.wilshipley.com/blog/2005/10/pimp-my-code-interlude-free-code.html
static inline BOOL is_empty(id _Nullable thing) {
    return thing == nil ||
    ([thing isEqual:[NSNull null]]) ||
    ([thing isKindOfClass:[NSNull class]]) ||
    ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0) ||
    ([thing respondsToSelector:@selector(count)]  && [(NSArray *)thing count] == 0);
}

#define return_if( _exp_ )              if (_exp_) { return; }

// 从 String 到 NSURL
#undef  url_with_string
#define url_with_string( _str_ )        [NSURL URLWithString:_str_]

// 从 String.filePath 到 NSURL
#undef  url_with_filepath
#define url_with_filepath( _path_ )     [NSURL fileURLWithPath:_path_]

#undef  app_set_indicator
#define app_set_indicator( _value_ )    [UIApplication sharedApplication].networkActivityIndicatorVisible = _value_;

#undef  invoke_nullable_block_noarg
#define invoke_nullable_block_noarg( _block_ )  { if (_block_) _block_(); }

#undef  invoke_nullable_block
#define invoke_nullable_block( _block_, ... )   { if (_block_) _block_(__VA_ARGS__); }

#undef  selectorify
#define selectorify( _code_ )                   NSSelectorFromString( @#_code_ )

#define keypathify( __keypath__ ) NSStringFromSelector(@selector(__keypath__))

#define take_nonull( ... ) macro_concat(take_nonull_, macro_count(__VA_ARGS__))( __VA_ARGS__ )
#define take_nonull_0( ... )
#define take_nonull_1( ... )
#define take_nonull_2( a, b )   ( a ? a : b )
#define take_nonull_3( a, b, c ) take_nonull_2( take_nonull_2(a, b), c)

// 类型转换：从 id 到 NSObject

#undef  objectype
#define objectype( _val_ )                      ((NSObject *)_val_)

#undef  stringtype
#define stringtype( _val_ )                     ((NSString *)_val_)

#undef  arraytype
#define arraytype( _val_ )                      ((NSArray *)_val_)

#undef  dictionarytype
#define dictionarytype( _val_ )                 ((NSDictionary *)_val_)

#undef  is_main_thread
#define is_main_thread                          [NSThread isMainThread]

#define view_SafeAreaInsets(view) ({UIEdgeInsets insets; if(@available(iOS 11.0, *)) {insets = view.safeAreaInsets;} else {insets = UIEdgeInsetsZero;} insets;})

#define TIMEOUT(timeout, block) \
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeout * NSEC_PER_SEC)), dispatch_get_main_queue(), block);

// ----------------------------------
// System macros
// ----------------------------------

// System Versioning Preprocessor
#define system_version                              [UIDevice currentDevice].systemVersion
#define system_version_equal_to( _version_ )        ([[[UIDevice currentDevice] systemVersion] compare:_version_ options:NSNumericSearch] == NSOrderedSame)

#define system_version_greater_than( _version_ )    ([[[UIDevice currentDevice] systemVersion] compare:_version_ options:NSNumericSearch] == NSOrderedDescending)

#define system_version_greater_than_or_equal_to( _version_ )  ([[[UIDevice currentDevice] systemVersion] compare:_version_ options:NSNumericSearch] != NSOrderedAscending)

#define system_version_less_than( _version_ )                 ([[[UIDevice currentDevice] systemVersion] compare:_version_ options:NSNumericSearch] == NSOrderedAscending)

#define system_version_less_than_or_equal_to( _version_ )     ([[[UIDevice currentDevice] systemVersion] compare:_version_ options:NSNumericSearch] != NSOrderedDescending)

// 系统版本 常量宏 定义
#define system_version_iOS8_or_later system_version_greater_than_or_equal_to(@"8.0")
#define system_version_iOS9_or_later system_version_greater_than_or_equal_to(@"9.0")
#define system_version_iOS10_or_later system_version_greater_than_or_equal_to(@"10.0")

/*
   Usage sample:

if (SYSTEM_VERSION_LESS_THAN(@"4.0")) {
    ...
}

if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"3.1.1")) {
    ...
}

*/

#define runloop_run_for_a_while \
        { \
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]]; \
        }

/** 是否模拟器 */
#define is_simulator  (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)
#define is_device !is_simulator

/** 是否iPad */
#define is_iPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

/** 是否iPhone iPod touch */
#define is_iPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)

/** 是否高清屏 */
#define is_retina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

/**
 *  判断系统版本宏定义，一般用于判断某段功能代码，是否参与编译
 
     #define __IPHONE_2_0      20000
     #define __IPHONE_2_1      20100
     #define __IPHONE_2_2      20200
     #define __IPHONE_3_0      30000
     #define __IPHONE_3_1      30100
     #define __IPHONE_3_2      30200
     #define __IPHONE_4_0      40000
     #define __IPHONE_4_1      40100
     #define __IPHONE_4_2      40200
     #define __IPHONE_4_3      40300
     #define __IPHONE_5_0      50000
     #define __IPHONE_5_1      50100
     #define __IPHONE_6_0      60000
     #define __IPHONE_6_1      60100
     #define __IPHONE_7_0      70000
     #define __IPHONE_7_1      70100
     #define __IPHONE_8_0      80000
     #define __IPHONE_8_1      80100
     #define __IPHONE_8_2      80200
     #define __IPHONE_8_3      80300
     #define __IPHONE_8_4      80400
     #define __IPHONE_9_0      90000
     #define __IPHONE_9_1      90100
     #define __IPHONE_9_2      90200
     #define __IPHONE_9_3      90300
     #define __IPHONE_10_0    100000
     #define __IPHONE_10_1    100100
     #define __IPHONE_10_2    100200
     #define __IPHONE_10_3    100300
 
 *  __IPHONE_OS_VERSION_MIN_REQUIRED 支持最低的系统版本
 *  __IPHONE_OS_VERSION_MAX_ALLOWED 允许最高的系统版本, 可以代表当前SDK的版本
 */

//screen
#define IS_3_7_INCH_SCREEN CGSizeEqualToSize(CGSizeMake(320, 480), [[UIScreen mainScreen] bounds].size)
#define IS_4_0_INCH_SCREEN CGSizeEqualToSize(CGSizeMake(320, 568), [[UIScreen mainScreen] bounds].size)
#define IS_4_7_INCH_SCREEN CGSizeEqualToSize(CGSizeMake(375, 667), [[UIScreen mainScreen] bounds].size)
#define IS_5_5_INCH_SCREEN CGSizeEqualToSize(CGSizeMake(414, 736), [[UIScreen mainScreen] bounds].size)


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

#define color_with_rgba_value( value, a ) \
        [UIColor \
        colorWithRed:((float)((value & 0xFF0000) >> 16))/255.0 \
        green:((float)((value & 0xFF00) >> 8))/255.0 \
        blue:((float)(value & 0xFF))/255.0 \
        alpha:a]
#define color_with_hex( value )             color_with_rgba_value( value, 1.0 )
#define color_with_hexa( value, a )         color_with_rgba_value( value, a )
#define color_with_rgba(r, g, b, a)         [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define color_with_rgb(r, g,  b)            color_with_rgba(r, g, b, 1.0f)

#define color_white                         [UIColor whiteColor]            // 1.0 white
#define color_black                         [UIColor blackColor]            // 0.0 white
#define color_darkGray                      [UIColor darkGrayColor]         // 0.333 white
#define color_lightGray                     [UIColor lightGrayColor]        // 0.667 white
#define color_gray                          [UIColor grayColor]             // 0.5 white
#define color_red                           [UIColor redColor]              // 1.0, 0.0, 0.0 RGB
#define color_green                         [UIColor greenColor]            // 0.0, 1.0, 0.0 RGB
#define color_blue                          [UIColor blueColor]             // 0.0, 0.0, 1.0 RGB
#define color_cyan                          [UIColor cyanColor]             // 0.0, 1.0, 1.0 RGB
#define color_yellow                        [UIColor yellowColor]           // 1.0, 1.0, 0.0 RGB
#define color_magenta                       [UIColor magentaColor]          // 1.0, 0.0, 1.0 RGB
#define color_orange    [UIColor orangeColor]           // 1.0, 0.5, 0.0 RGB
#define color_purple    [UIColor purpleColor]           // 0.5, 0.0, 0.5 RGB
#define color_brown     [UIColor brownColor]            // 0.6, 0.4, 0.2 RGB
#define color_clear     [UIColor clearColor]            // 0.0 white, 0.0 alpha

#define font_gray_1     [UIColor colorWithRGBHex:0xc8c8c8]
#define font_gray_2     [UIColor colorWithRGBHex:0x5e5e5e]
#define font_gray_3     [UIColor colorWithRGBHex:0x1e1e1e]
#define font_gray_4     [UIColor colorWithRGBHex:0x000000]

#define gray_1     [UIColor colorWithRGBHex:0xf7f7f7]
#define gray_2     [UIColor colorWithRGBHex:0xf0f0f0]
#define gray_3     [UIColor colorWithRGBHex:0xebebeb]
#define gray_4     [UIColor colorWithRGBHex:0xcccccc]
#define gray_5     [UIColor colorWithRGBHex:0x999999]
#define gray_6     [UIColor colorWithRGBHex:0x666666]
#define gray_7     [UIColor colorWithRGBHex:0x333333]
#define gray_8     [UIColor colorWithHexString:@"979797"]

// ----------------------------------
// 系统屏幕
// ----------------------------------

#define screen_bounds                   [[UIScreen mainScreen] bounds]
#define screen_size                     screen_bounds.size
#define screen_width                    [[UIScreen mainScreen] bounds].size.width
#define screen_height                   [[UIScreen mainScreen] bounds].size.height
#define screen_scale                    [[UIScreen mainScreen] scale]
#define border_width                    (1.0 / screen_scale)

#define app_frame                       [[UIScreen mainScreen] applicationFrame]
#define app_frame_height                ([[UIScreen mainScreen] applicationFrame].size.height)
#define app_frame_width                 ([[UIScreen mainScreen] applicationFrame].size.width)

// ----------------------------------
// 系统控件基础定义，如：导航栏、状态栏、标签栏
// ----------------------------------

#define is_iPhoneX (screen_width == 375.f && screen_height == 812.f ? YES : NO)

#define status_bar_height      (is_iPhoneX ? 44.f : 20.f)
#define navigation_bar_height           44.f
#define navigation_status_bar_height    (status_bar_height+navigation_bar_height)
#define large_navigation_bar_height     96.f
#define large_navigation_status_bar_height (status_bar_height+large_navigation_bar_height)

#define keyboard_height                 216.f

#define tabbar_height         (is_iPhoneX ? (49.f+34.f) : 49.f)
#define tabbar_safe_bottom_margin         (is_iPhoneX ? 34.f : 0.f)
#define status_bar_navigation_bar_height  (is_iPhoneX ? 88.f : 64.f)

#define separator_height                8

#define status_bar_orientation          [[UIApplication sharedApplication] statusBarOrientation]

#define iPhone4_4s     (screen_width == 320.f && screen_height == 480.f ? YES : NO)
#define iPhone5_5s     (screen_width == 320.f && screen_height == 568.f ? YES : NO)
#define iPhone6_6s     (screen_width == 375.f && screen_height == 667.f ? YES : NO)
#define iPhone6_6sPlus (screen_width == 414.f && screen_height == 736.f ? YES : NO)

// ----------------------------------
// 间隔与边距基础定义
// ----------------------------------

#define PIXEL_sss                       0.5f
#define PIXEL_1                         1.f
#define PIXEL_3                         3.f
#define PIXEL_2                         2.f
#define PIXEL_4                         4.f
#define PIXEL_5                         5.f
#define PIXEL_6                         6.f
#define PIXEL_8                         8.f
#define PIXEL_10                        10.f
#define PIXEL_12                        12.f
#define PIXEL_16                        16.f
#define PIXEL_24                        24.f
#define PIXEL_36                        36.f
#define PIXEL_40                        40.f
#define PIXEL_48                        48.f
#define PIXEL_56                        56.f

#define margin_l    PIXEL_16
#define margin_m    PIXEL_8
#define margin_s    PIXEL_4


#define app_build                   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
#define app_version                 [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define app_display_name            [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
#define app_bundle_name             [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey]
#define app_bundle_id               [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey]

#define app_device_name             [[UIDevice currentDevice] name]
#define app_device_model            [[UIDevice currentDevice] model]
#define app_device_system_version   [[UIDevice currentDevice] systemVersion]

#define app_window                  [[UIApplication sharedApplication].delegate window]
#define app_window_is_landscape     UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)
#define app_window_is_portrait      !app_window_is_landscape
#define app_window_current_width    (app_window_is_landscape ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)
#define app_window_current_height   (app_window_is_landscape ? [UIScreen mainScreen].bounds.size.width : [UIScreen mainScreen].bounds.size.height)
#define app_window_current_size     CGSizeMake(app_window_current_width, app_window_current_height)

// 横竖屏
#define is_landscape                app_window_is_landscape
#define is_portrait                 app_window_is_portrait

// 常用的沙盒目录
#define path_of_app_home    NSHomeDirectory()
#define path_of_temp        NSTemporaryDirectory()
#define path_of_document    [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define path_of_library    [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define path_of_cache       [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

// 预设文件存储位置
#define path_to_database    [path_of_cache stringByAppendingPathComponent:@"dbs"]
#define path_to_filecache   [path_of_cache stringByAppendingPathComponent:@"files"]
#define path_to_imagecache  [path_of_cache stringByAppendingPathComponent:@"images"]

#define path_for_png_res( _name_ )    [[NSBundle mainBundle] pathForResource:(_name_) ofType:@"png"]
#define path_for_xml_res( _name_ )    [[NSBundle mainBundle] pathForResource:(_name_) ofType:@"xml"]
#define path_for_res( _res_, _type_)  [[NSBundle mainBundle] pathForResource:(_res_) ofType:(_type_)]

// 特殊数值
#undef  invalid_int32
#define invalid_int32 INT32_MAX

#undef  invalid_int64
#define invalid_int64 INT64_MAX

#undef  invalid_float
#define invalid_float MAXFLOAT

#undef  invalid_bool
#define invalid_bool NO

#undef  MIN_FLOAT
#define MIN_FLOAT 0.000001f

// 特定的字符串

#define empty_string        @""

#undef undefined_string
#define undefined_string @"未定义"

#undef unselected_string
#define unselected_string @"请选择"

// 中文
#define yyyy                @"yyyy"
#define yyyyMM              @"yyyy年MM月"
#define yyyyMMdd            @"yyyy年MM月dd日"
#define MMdd                @"MM月dd日"

// 短横分割线
#define yyyy_MM_dd          @"yyyy-MM-dd"

// inspired by https://github.com/6david9/CBExtension/tree/master/CBExtension/CBExtension/UtilityMacro
/** 一天的秒数 */
#define seconds_of_1day                 (24.f * 60.f * 60.f)
/** 几天的秒数 */
#define seconds_of( value )             (24.f * 60.f * 60.f * (value))
/** 一天的毫秒数 */
#define milliseconds_of_1day            (24.f * 60.f * 60.f * 1000.f)
/** 几天的毫秒数 */
#define milliseconds_of( value )        (24.f * 60.f * 60.f * 1000.f * (value))


// ----------------------------------
// Image macros
// ----------------------------------

#define image_named( _pointer_ )        [UIImage imageNamed:_pointer_]
#define image_pathof( _path_ )          [UIImage imageWithContentsOfFile:(path)]
#define png_image( _name_ )             [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(_name_) ofType:@"png"]]
#define jpg_image( _name_ )             [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:(_name_) ofType:@"jpg"]]

// ----------------------------------
// Font macros
// ----------------------------------

#define POUND_9                         9.f// 24, PS 大小
#define POUND_13                        13.f// 36???
#define POUND_14                        14.f// 36
#define POUND_15                        15.f// 40 ＊＊＊
#define POUND_18                        18.f// 48 ＊＊＊
#define POUND_23                        23.f// 60

#define POUND_7                         7.f // 18
#define POUND_11                        11.f// 30 ＊＊＊
#define POUND_12                        12.f// 32

// system font
#define FONT_9                          [UIFont systemFontOfSize:POUND_9]
#define FONT_13                         [UIFont systemFontOfSize:POUND_13]
#define FONT_14                         [UIFont systemFontOfSize:POUND_14]
#define FONT_15                         [UIFont systemFontOfSize:POUND_15]
#define FONT_18                         [UIFont systemFontOfSize:POUND_18]
#define FONT_23                         [UIFont systemFontOfSize:POUND_23]

#define font_sm                         font_normal_9
#define font_ss                         font_normal_11
#define font_s                          font_normal_14
#define font_m                          font_normal_15
#define font_l                          font_normal_18
#define font_xl                         font_normal_23

//粗体
#define bold_font_ss                    font_bold_11
#define bold_font_s                     font_bold_14
#define bold_font_m                     font_bold_15
#define bold_font_l                     font_bold_18
#define bold_font_xl                    font_bold_23

#define font_normal_7    [UIFont systemFontOfSize:7]
#define font_normal_8    [UIFont systemFontOfSize:8]
#define font_normal_9    [UIFont systemFontOfSize:9]
#define font_normal_10   [UIFont systemFontOfSize:10]
#define font_normal_11   [UIFont systemFontOfSize:11]
#define font_normal_12   [UIFont systemFontOfSize:12]
#define font_normal_13   [UIFont systemFontOfSize:13]
#define font_normal_14   [UIFont systemFontOfSize:14]
#define font_normal_15   [UIFont systemFontOfSize:15]
#define font_normal_16   [UIFont systemFontOfSize:16]
#define font_normal_17   [UIFont systemFontOfSize:17]
#define font_normal_18   [UIFont systemFontOfSize:18]
#define font_normal_19   [UIFont systemFontOfSize:19]
#define font_normal_20   [UIFont systemFontOfSize:20]
#define font_normal_21   [UIFont systemFontOfSize:21]
#define font_normal_22   [UIFont systemFontOfSize:22]
#define font_normal_23   [UIFont systemFontOfSize:23]
#define font_normal_24   [UIFont systemFontOfSize:24]
#define font_normal_32   [UIFont systemFontOfSize:32]
#define font_normal_33   [UIFont fontWithName:@"Helvetica" size:33.0]

#define font_bold_7    [UIFont boldSystemFontOfSize:7]
#define font_bold_8    [UIFont boldSystemFontOfSize:8]
#define font_bold_9    [UIFont boldSystemFontOfSize:9]
#define font_bold_10   [UIFont boldSystemFontOfSize:10]
#define font_bold_11   [UIFont boldSystemFontOfSize:11]
#define font_bold_12   [UIFont boldSystemFontOfSize:12]
#define font_bold_13   [UIFont boldSystemFontOfSize:13]
#define font_bold_14   [UIFont boldSystemFontOfSize:14]
#define font_bold_15   [UIFont boldSystemFontOfSize:15]
#define font_bold_16   [UIFont boldSystemFontOfSize:16]
#define font_bold_17   [UIFont boldSystemFontOfSize:17]
#define font_bold_18   [UIFont boldSystemFontOfSize:18]
#define font_bold_19   [UIFont boldSystemFontOfSize:19]
#define font_bold_20   [UIFont boldSystemFontOfSize:20]
#define font_bold_21   [UIFont boldSystemFontOfSize:21]
#define font_bold_22   [UIFont boldSystemFontOfSize:22]
#define font_bold_23   [UIFont boldSystemFontOfSize:23]
#define font_bold_24   [UIFont boldSystemFontOfSize:24]
#define font_bold_32   [UIFont boldSystemFontOfSize:32]
#define font_bold_33   [UIFont fontWithName:@"Helvetica-Bold" size:33.0]

// ----------------------------------
// String macros
// ----------------------------------

#define stringify(string)                @#string // 双 # 号 是拼接成c字符串

#define string_concat( _str_, _cat_ )    (_str_ _cat_)
#define string_concat_3( _str1_, _str2_, _str3_ ) (_str1_ _str2_ _str3_)

#define is_string_empty( _str_ )                is_empty( _str_ )
#define is_string_present( _str_ )              !is_string_empty(_str_)

#define string_format( _format_, ... )          [NSString stringWithFormat:_format_, __VA_ARGS__]
#define string_from_url( _url_ )                [NSString stringWithFormat:@"url = {scheme: %@, host: %@, port: %@, path: %@, relative path: %@, path components as array: %@, parameter string: %@, query: %@, fragment: %@, user: %@, password: %@}", url.scheme, url.host, url.port, url.path, url.relativePath, url.pathComponents, url.parameterString, url.query, url.fragment, url.user, url.password]
#define string_from_charPtr( _charPtr_ )        [NSString stringWithUTF8String:_charPtr_]
#define string_from_type( _type_ )              string_from_charPtr( @encode(_type_) )
#define string_from_int32( _value_ )            [NSString stringWithFormat:@"%d",(int32_t)_value_]
#define string_from_int64( _value_ )            [NSString stringWithFormat:@"%qi", (int64_t)_value_]
#define string_from_obj( _value_ )              [NSString stringWithFormat:@"%@", (NSObject *)_value_]
#define string_from_bool( _bool_ )              [NSString stringWithFormat:@"%d", _bool_]
#define string_from_float( _float_ )            [NSString stringWithFormat:@"%f", _float_]
#define string_from_double( _double_ )          [NSString stringWithFormat:@"%f", _double_]
#define string_from_selector( _selector_ )      NSStringFromSelector(_selector_)
#define string_from_char( _char_ )              [NSString stringWithFormat:@"%c", _char_]
#define string_from_short( _short_ )            [NSString stringWithFormat:@"%hi", _short_]
#define string_from_class( _class_ )            NSStringFromClass(_class_)
#define string_from_point( _point_ )            NSStringFromCGPoint(_point_)
#define string_from_rect( _rect_ )              NSStringFromCGRect(_rect_)
#define string_from_range( _range_ )            NSStringFromRange(_range_)

#define __FILENAME__    [[string_from_charPtr(__FILE__) lastPathComponent] split:@"."][0]
#define __CMD_SEL__     _cmd
#define __CMD_NAME__    string_from_selector(_cmd)

/**
 @knowledge
 
 *  避免滥用block
 
 *  好处：定义简单，并可以捕获上下文变量，还有大部分时候，便于代码顺序阅读
 
 *  滥用：
 1. 忽视循环引用（相反，delegate会比较安全）
 2. 对block生命周期不熟悉，多见于多线程情况下。
 3. 复杂逻辑用多层block嵌套实现，导致调试困难
 */

typedef void(^ Block)( void );
typedef void(^ BlockBlock)( _Nullable Block block );
typedef void(^ BOOLBlock)( BOOL b );
typedef void(^ ObjectBlock)( _Nullable id obj );
typedef void(^ ArrayBlock)( NSArray * _Nullable array );
typedef void(^ MutableArrayBlock)( NSMutableArray * _Nullable array );
typedef void(^ DictionaryBlock)( NSDictionary *_Nullable dic );
typedef void(^ ErrorBlock)( NSError * _Nullable error );
typedef void(^ IndexBlock)( NSInteger index );
typedef void(^ ListItemBlock)( NSInteger index, id _Nullable param );
typedef void(^ FloatBlock)( CGFloat afloat );
typedef void(^ StringBlock)( NSString * _Nullable str );
typedef void(^ ImageBlock)( UIImage * _Nullable image );
typedef void(^ ProgressBlock)( NSProgress * _Nullable progress );
typedef void(^ PercentBlock)( double percent); // 0~100

typedef void(^ Event)( id _Nullable event, NSInteger type, id _Nullable object );

typedef void(^ CancelBlock)( id _Nullable viewController );
typedef void(^ FinishedBlock)( id _Nullable viewController, id _Nullable object );

typedef void(^ SendRequestAndResendRequestBlock)( id _Nullable sendBlock, id _Nullable resendBlock);

/*
 * 结构定义
 */

/**
 操作类型：OperationType
 操作类型可用key：如下
 */
#define OperationTypeKey @"key.OperationType"
typedef enum : NSUInteger {
    OperationAdd = 0,
    OperationDelete,
    OperationEdit,
    OperationQuery,
} _OperationType;

typedef enum {
    HttpMethodGet = 0,
    HttpMethodPost = 1,
    HttpMethodDelete = 2
} _HttpMethodType;

#endif // __BA_MACROS_H__
