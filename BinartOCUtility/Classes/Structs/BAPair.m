#import "BAPair.h"

@interface BAPair ()

@end

@implementation BAPair

+ (instancetype)with:(id)first second:(id)second  {
    return [[self new] with:first second:second];
}

- (instancetype)init {
    if (self = [super init]) {
        self.first = nil;
        self.second = nil;
    }
    return self;
}

- (instancetype)with:(id)first second:(id)second {
    self.first = nil;
    self.second = nil;
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    BAPair *newPair = [[BAPair allocWithZone:zone] init];
    newPair.first = _first;
    newPair.second = _second;
    return newPair;
}

- (id)mutableCopyWithZone:(nullable NSZone *)zone {
    BAPair *newPair = [[BAPair alloc] copyWithZone:zone];
    newPair.first = [_first copyWithZone:zone];
    newPair.second = [_second copyWithZone:zone];
    return newPair;
}

- (id)copy {
    return [BAPair with:_first second:_second];
}

- (id)mutableCopy {
    return [BAPair with:[_first copy] second:[_second copy]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p, fist: %@, second: %@>",
            NSStringFromClass(self.class),
            self,
            self.first,
            self.second];
}

@end
