
#import "BANamespace.h"

__strong BANamespace * namespace_root = nil;

@implementation BANamespace

+ (void)load {
    namespace_root = [[BANamespace alloc] init];
}

@end
