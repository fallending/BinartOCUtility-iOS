#import "BAAnnotation.h"
#include <mach-o/getsect.h>
#include <mach-o/loader.h>
#include <mach-o/dyld.h>
#include <dlfcn.h>
#import <objc/runtime.h>
#import <objc/message.h>


// ----------------------------------
// MARK: C code
// ----------------------------------

static NSArray<NSString *>* __variablesAt(char *section) {
    NSMutableArray *configs = [NSMutableArray array];
    
    Dl_info info;
    dladdr(__variablesAt, &info);
    
#ifndef __LP64__
    //        const struct mach_header *mhp = _dyld_get_image_header(0); // both works as below line
    const struct mach_header *mhp = (struct mach_header*)info.dli_fbase;
    unsigned long size = 0;
    uint32_t *memory = (uint32_t*)getsectiondata(mhp, "__DATA", section, & size);
#else /* defined(__LP64__) */
    const struct mach_header_64 *mhp = (struct mach_header_64*)info.dli_fbase;
    unsigned long size = 0;
    uint64_t *memory = (uint64_t*)getsectiondata(mhp, "__DATA", section, & size);
#endif /* defined(__LP64__) */
    
    for(int idx = 0; idx < size/sizeof(void *); ++idx) {
        char *string = (char *)memory[idx];
        
        NSString *str = [NSString stringWithUTF8String:string];
        
        if(!str) {
            continue;
        }
        
        [configs addObject:str];
    }
    
    return configs;
    
}

// ----------------------------------
// MARK: Source code
// ----------------------------------

@implementation BAAnnotation

+ (NSArray<NSString *> *)ba_annotationObjects {
    static NSArray<NSString *> *objects = nil;
    
    ba_exec_once( ^{
        objects = __variablesAt(ANNOTATION_SECTIONNAME);
    })
    
    return objects;
}

+ (NSArray<NSString *> *)ba_annotationBindings {
    static NSArray<NSString *> *bindings = nil;
    
    ba_exec_once( ^{
        bindings = __variablesAt(ANNOTATION_SECTIONNAME);
    })
    
    return bindings;
}

+ (NSArray<NSString *> *)ba_annotationObjectsForSectioname:(NSString *)sectioname {
    return __variablesAt((char *)sectioname.UTF8String);
}

+ (NSArray<NSString *> *)ba_annotationBindingsForSectioname:(NSString *)sectioname {
    return __variablesAt((char *)sectioname.UTF8String);
}

@end
