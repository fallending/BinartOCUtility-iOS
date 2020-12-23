
#import "BANamespace.h"

// ----------------------------------
// MARK: Extern
// ----------------------------------

__strong BANamespace * namespace_root = nil;

// ----------------------------------
// MARK: Source - _Namespace
// ----------------------------------

@implementation BANamespace

+ (void)load {
    namespace_root = [[BANamespace alloc] init];
}

@end
