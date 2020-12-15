
#import "BAThreadSafeDictionary.h"
#import "BAThreadSafeLocks.h"

#import "_pragma_push.h"

@interface BAThreadSafeDictionary () {
    NSMutableDictionary *_container;
    dispatch_semaphore_t _lock;
}

@end

@implementation BAThreadSafeDictionary

#pragma mark - init

- (instancetype)init {
    INIT(_container = [[NSMutableDictionary alloc] init]);
}

- (instancetype)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys {
    INIT(_container =  [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys]);
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {
    INIT(_container = [[NSMutableDictionary alloc] initWithCapacity:capacity]);
}

- (instancetype)initWithObjects:(const id[])objects forKeys:(const id <NSCopying>[])keys count:(NSUInteger)cnt {
    INIT(_container = [[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys count:cnt]);
}

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary {
    INIT(_container = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary]);
}

- (instancetype)initWithDictionary:(NSDictionary *)otherDictionary copyItems:(BOOL)flag {
    INIT(_container = [[NSMutableDictionary alloc] initWithDictionary:otherDictionary copyItems:flag]);
}


#pragma mark - method

- (NSUInteger)count {
    LOCK(NSUInteger c = _container.count); return c;
}

- (id)objectForKey:(id)aKey {
    LOCK(id o = [_container objectForKey:aKey]); return o;
}

- (NSEnumerator *)keyEnumerator {
    LOCK(NSEnumerator * e = [_container keyEnumerator]); return e;
}

- (NSArray *)allKeys {
    LOCK(NSArray * a = [_container allKeys]); return a;
}

- (NSArray *)allKeysForObject:(id)anObject {
    LOCK(NSArray * a = [_container allKeysForObject:anObject]); return a;
}

- (NSArray *)allValues {
    LOCK(NSArray * a = [_container allValues]); return a;
}

- (NSString *)description {
    LOCK(NSString * d = [_container description]); return d;
}

- (NSString *)descriptionInStringsFileFormat {
    LOCK(NSString * d = [_container descriptionInStringsFileFormat]); return d;
}

- (NSString *)descriptionWithLocale:(id)locale {
    LOCK(NSString * d = [_container descriptionWithLocale:locale]); return d;
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    LOCK(NSString * d = [_container descriptionWithLocale:locale indent:level]); return d;
}

- (BOOL)isEqualToDictionary:(NSDictionary *)otherDictionary {
    if (otherDictionary == self) return YES;
    
    if ([otherDictionary isKindOfClass:BAThreadSafeDictionary.class]) {
        BAThreadSafeDictionary *other = (id)otherDictionary;
        BOOL isEqual;
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(other->_lock, DISPATCH_TIME_FOREVER);
        isEqual = [_container isEqual:other->_container];
        dispatch_semaphore_signal(other->_lock);
        dispatch_semaphore_signal(_lock);
        return isEqual;
    }
    return NO;
}

- (NSEnumerator *)objectEnumerator {
    LOCK(NSEnumerator * e = [_container objectEnumerator]); return e;
}

- (NSArray *)objectsForKeys:(NSArray *)keys notFoundMarker:(id)marker {
    LOCK(NSArray * a = [_container objectsForKeys:keys notFoundMarker:marker]); return a;
}

- (NSArray *)keysSortedByValueUsingSelector:(SEL)comparator {
    LOCK(NSArray * a = [_container keysSortedByValueUsingSelector:comparator]); return a;
}

- (void)getObjects:(id __unsafe_unretained[])objects andKeys:(id __unsafe_unretained[])keys {
    LOCK([_container getObjects:objects andKeys:keys]);
}

- (id)objectForKeyedSubscript:(id)key {
    LOCK(id o = [_container objectForKeyedSubscript:key]); return o;
}

- (void)enumerateKeysAndObjectsUsingBlock:(void (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))block {
    LOCK([_container enumerateKeysAndObjectsUsingBlock:block]);
}

- (void)enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id key, id obj, BOOL *stop))block {
    LOCK([_container enumerateKeysAndObjectsWithOptions:opts usingBlock:block]);
}

- (NSArray *)keysSortedByValueUsingComparator:(NSComparator)cmptr {
    LOCK(NSArray * a = [_container keysSortedByValueUsingComparator:cmptr]); return a;
}

- (NSArray *)keysSortedByValueWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr {
    LOCK(NSArray * a = [_container keysSortedByValueWithOptions:opts usingComparator:cmptr]); return a;
}

- (NSSet *)keysOfEntriesPassingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate {
    LOCK(NSSet * a = [_container keysOfEntriesPassingTest:predicate]); return a;
}

- (NSSet *)keysOfEntriesWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (^)(id key, id obj, BOOL *stop))predicate {
    LOCK(NSSet * a = [_container keysOfEntriesWithOptions:opts passingTest:predicate]); return a;
}

#pragma mark - mutable

- (void)removeObjectForKey:(id)aKey {
    LOCK([_container removeObjectForKey:aKey]);
}

- (void)setObject:(id)anObject forKey:(id <NSCopying> )aKey {
    LOCK([_container setObject:anObject forKey:aKey]);
}

- (void)addEntriesFromDictionary:(NSDictionary *)otherDictionary {
    LOCK([_container addEntriesFromDictionary:otherDictionary]);
}

- (void)removeAllObjects {
    LOCK([_container removeAllObjects]);
}

- (void)removeObjectsForKeys:(NSArray *)keyArray {
    LOCK([_container removeObjectsForKeys:keyArray]);
}

- (void)setDictionary:(NSDictionary *)otherDictionary {
    LOCK([_container setDictionary:otherDictionary]);
}

- (void)setObject:(id)obj forKeyedSubscript:(id <NSCopying> )key {
    LOCK([_container setObject:obj forKeyedSubscript:key]);
}

#pragma mark - protocol

- (id)copyWithZone:(NSZone *)zone {
    return [self mutableCopyWithZone:zone];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    LOCK(id copiedDictionary = [[self.class allocWithZone:zone] initWithDictionary:_container]);
    return copiedDictionary;
}

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained[])stackbuf
                                    count:(NSUInteger)len {
    LOCK(NSUInteger count = [_container countByEnumeratingWithState:state objects:stackbuf count:len]);
    return count;
}

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    
    if ([object isKindOfClass:BAThreadSafeDictionary.class]) {
        BAThreadSafeDictionary *other = object;
        BOOL isEqual;
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(other->_lock, DISPATCH_TIME_FOREVER);
        isEqual = [_container isEqual:other->_container];
        dispatch_semaphore_signal(other->_lock);
        dispatch_semaphore_signal(_lock);
        return isEqual;
    }
    return NO;
}

- (NSUInteger)hash {
    LOCK(NSUInteger hash = [_container hash]);
    return hash;
}

@end

#import "_pragma_pop.h"
