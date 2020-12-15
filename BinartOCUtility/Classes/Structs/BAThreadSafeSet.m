
#import "BAThreadSafeSet.h"
#import <pthread.h>

static const NSUInteger kDefaultCapacity = 5;

#define LOCK       pthread_mutex_lock(&_lock);
#define UNLOCK     pthread_mutex_unlock(&_lock);

@implementation BAThreadSafeSet {
    pthread_mutex_t _lock;
    CFMutableSetRef _set;
}

+ (instancetype)set {
    return [[self alloc] init];
}

+ (instancetype)setWithCapacity:(NSUInteger)num {
    return [[self alloc] initWithCapacity:num];
}

+ (instancetype)setWithArray:(NSArray *)array {
    BAThreadSafeSet *set = [self set];
    [set addObjectsFromArray:array];
    return set;
}

+ (instancetype)setWithObject:(id)object {
    BAThreadSafeSet *set = [self set];
    [set addObject:object];
    return set;
}

- (instancetype)init {
    return [self initWithCapacity:kDefaultCapacity];
}

- (instancetype)initWithCapacity:(NSUInteger)num {
    if (self = [super init]) {
        pthread_mutex_init(&_lock, NULL);
        _set = CFSetCreateMutable(kCFAllocatorDefault, num,  &kCFTypeSetCallBacks);
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    NSArray *set = nil;
    
    LOCK
    CFSetRef setRef = CFSetCreateCopy(kCFAllocatorDefault, _set);
    if (setRef) {
        set = CFBridgingRelease(setRef);
    }
    UNLOCK
    
    return set;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    NSMutableSet *mutableSet = nil;
    
    LOCK
    CFMutableSetRef mutableSetRef = CFSetCreateMutableCopy(kCFAllocatorDefault, CFSetGetCount(_set),_set);
    if (mutableSetRef) {
        mutableSet = CFBridgingRelease(mutableSetRef);
    }
    UNLOCK
    
    return mutableSet;
}

- (void)addObject:(id)object {
    if (!object) {
        return;
    }
    
    LOCK
    CFSetAddValue(_set, (__bridge const void *)object);
    UNLOCK
}

- (void)addObjectsFromArray:(NSArray *)array {
    if (!([array isKindOfClass:[NSArray class]] && (array.count > 0))) {
        return;
    }
    
    LOCK
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CFSetAddValue(self->_set, (__bridge const void *)obj);
    }];
    UNLOCK;
}

- (void)removeObject:(id)object {
    if (!object) {
        return;
    }
    
    LOCK
    CFSetRemoveValue(_set, (__bridge const void *)(object));
    UNLOCK
}

- (void)removeAllObjects {
    LOCK
    CFSetRemoveAllValues(_set);
    UNLOCK
}

- (NSUInteger)count {
    LOCK
    NSUInteger result = CFSetGetCount(_set);
    UNLOCK
    
    return result;
}

- (nullable NSArray *)allObjects {
    NSMutableArray *array = nil;
    
    LOCK
    NSUInteger count = CFSetGetCount(_set);
    if (count > 0) {
        array = [NSMutableArray arrayWithCapacity:count];
        
        CFTypeRef *objects = malloc(count * sizeof(CFTypeRef));
        CFSetGetValues(_set, (const void **) objects);
        
        for (CFIndex index = 0; index < count; index++) {
            [array addObject:(__bridge id)(objects[index])];
        }
        
        free(objects);
    }
    UNLOCK
    return [array copy];
}

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block {
    if (!block) {
        return;
    }
    
    LOCK
    NSUInteger count = CFSetGetCount(_set);
    if (count > 0) {
        CFTypeRef *objects = malloc(count * sizeof(CFTypeRef));
        CFSetGetValues(_set, (const void **) objects);
        
        BOOL stop = NO;
        for (CFIndex index = 0; index < count; index++) {
            if (stop) {
                break;
            }
            block((__bridge id)(objects[index]), &stop);
        }
        
        free(objects);
    }
    UNLOCK
}

@end

