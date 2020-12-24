#import "BAMacros.h"

#undef  ANNOTATION_SECTIONNAME
#define ANNOTATION_SECTIONNAME "annotation.section"

#undef  META_ANNOTATION_ATTR
#define META_ANNOTATION_ATTR( _section_name_ ) __attribute((used, section("__DATA,"#_section_name_" ")))

#undef  META_ANNOTATION
#define META_ANNOTATION( _section_name_, _obj_name_) \
        char * _obj_name_##_obj META_ANNOTATION_ATTR( _section_name_ ) = ""#_obj_name_;

#undef  META_ANNOTATION_BIND
#define META_ANNOTATION_BIND( _section_name_, _intf_name_, _impl_name_ ) \
        char * _impl_name_##_ META_ANNOTATION_ATTR( _section_name_ ) = "{ \""#_intf_name_"\" : \""#_impl_name_"\"}";

#undef  ANNOTATION
#define ANNOTATION( _name_ ) META_ANNOTATION( ANNOTATION_SECTIONNAME, _name_ )

#undef  ANNOTATION_BIND
#define ANNOTATION_BIND( _intf_name_, _impl_name_ ) \
        META_ANNOTATION_BIND( ANNOTATION_SECTIONNAME, _intf_name_, _impl_name_ )

// ----------------------------------
// MARK: Interface
//
// 1. 该__DATA 区段，是否有大小限制
// 2. 其他平台的注解例子：(对AOP依赖过高)
//    DAO: as_dao,as_update, as_delete, def_query
//    Service: as_service(...,...,...)
// ----------------------------------

NS_ASSUME_NONNULL_BEGIN

@interface BAAnnotation : NSObject

+ (NSArray <NSString *> *)ba_annotationObjects; // Objects at section ##ANNOTATION_SECTIONNAME
+ (NSArray <NSString *> *)ba_annotationBindings; // Bindings at section ##ANNOTATION_SECTIONNAME

+ (NSArray <NSString *> *)ba_annotationObjectsForSectioname:(NSString *)sectioname;
+ (NSArray <NSString *> *)ba_annotationBindingsForSectioname:(NSString *)sectioname;

@end

NS_ASSUME_NONNULL_END
