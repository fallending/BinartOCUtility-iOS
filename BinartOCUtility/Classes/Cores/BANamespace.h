
#import <Foundation/Foundation.h>

#define NAMESPACE( ... )		macro_concat( NAMESPACE_, macro_count(__VA_ARGS__) )( __VA_ARGS__ )
#define NAMESPACE_0( ... )

/** 当参数为 1 个，建立一个以_parent为名字的命名空间，不需要支持sharedInstance */
#define NAMESPACE_1( _parent, ... ) \
        class _Namespace_##_parent; \
        extern _Namespace_##_parent *_parent; \
        @interface _Namespace_##_parent : _Namespace \
        @end \
        @interface _Namespace (_Namespace_##_parent) \
        @prop_readonly( _Namespace_##_parent *, _parent ); \
        @end

/** 当参数为 2 个，在根命名空间namespace_root上，追加服务对象，但不建立新的命名空间 */
#define NAMESPACE_2( _clild, _class, ... ) \
        interface _Namespace (_class) \
        @prop_readonly( _class *, _clild ); \
        @end

/** 当参数为 3 个，在命名空间_parent上，追加服务对象，前提是命名空间_parent要存在 */
#define NAMESPACE_3( _parent, _child, _class, ... ) \
        interface _Namespace_##_parent (_Namespace_##_child) \
        @prop_readonly( _class *, _child ); \
        @end

// ----------------------------------
// MARK: Macro - def_namespace( ... )
// ----------------------------------

#define DEF_NAMESPACE( ... )	macro_concat( DEF_NAMESPACE_, macro_count(__VA_ARGS__) )( __VA_ARGS__ )
#define DEF_NAMESPACE_0( ... )
#define DEF_NAMESPACE_1( _parent, ... ) \
        implementation _Namespace_##_parent \
        @end \
        __strong _Namespace_##_parent * _parent = nil; \
        @implementation _Namespace (_Namespace_##_parent) \
        @def_prop_dynamic( _Namespace_##_parent *, _parent ); \
        + (void)load \
        { \
            [[_Namespace new] _parent]; \
        }\
        - (_Namespace_##_parent *)_parent { \
            if ( nil == _parent ) \
            { \
                _parent = [[_Namespace_##_parent alloc] init]; \
            } \
            return _parent; \
        } \
        @end

#define DEF_NAMESPACE_2( _object, _class, ... ) \
        implementation _Namespace (_class) \
        @def_prop_dynamic( _class *, _object ); \
        - (_class *)_object { \
            static __strong id __instance = nil; \
            if ( nil == __instance ) \
            { \
                if ( [_class respondsToSelector:@selector(sharedInstance)] ) \
                { \
                    __instance = [_class sharedInstance]; \
                } \
                else \
                { \
                    __instance = [[_class alloc] init]; \
                } \
            } \
            return __instance; \
        } \
        @end

#define DEF_NAMESPACE_3( _parent, _child, _class, ... ) \
        implementation _Namespace_##_parent (_Namespace_##_child) \
        @def_prop_dynamic( _class *, _child ); \
        - (_class *)_child { \
            static __strong id __instance = nil; \
            if ( nil == __instance ) \
            { \
                if ( [_class respondsToSelector:@selector(sharedInstance)] ) \
                { \
                    __instance = [_class sharedInstance]; \
                } \
                else \
                { \
                    __instance = [[_class alloc] init]; \
                } \
            } \
            return __instance; \
        } \
        @end

@interface BANamespace : NSObject

@end

// ----------------------------------
// MARK: Extern - Default namespace
//
// 设计目标：
// 1. 从根域可以点操作符，树状访问所有相关单例或对象
// 2. 从任意命名空间出发，能够树状访问所有内部单例或对象
// ----------------------------------

extern BANamespace * namespace_root;
