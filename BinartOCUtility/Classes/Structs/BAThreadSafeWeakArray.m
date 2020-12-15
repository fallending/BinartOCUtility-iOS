
#import "BAThreadSafeWeakArray.h"
#import "BAThreadSafeLocks.h"

@interface BAThreadSafeWeakArray() {
    NSHashTable *_container; // NSHashTable 有一个 allObjectes 的属性，返回 NSArray，即使 NSHashTable 是弱引用成员，allObjects 依然会对成员进行强引用
    dispatch_semaphore_t _lock;
}

@end

@implementation BAThreadSafeWeakArray

- (instancetype)init {
    INIT(_container = [NSHashTable weakObjectsHashTable]);
}

#pragma mark - method

- (NSUInteger)count {
    LOCK(NSUInteger count = _container.count); return count;
}

- (BOOL)containsObject:(id)anObject {
    LOCK(BOOL c = [_container containsObject:anObject]); return c;
}

- (NSString *)description {
    LOCK(NSString * d = _container.description); return d;
}

- (NSEnumerator *)objectEnumerator {
    LOCK(NSEnumerator * e = [_container objectEnumerator]); return e;
}

#pragma mark - mutable

- (void)addObject:(id)anObject {
    LOCK([_container addObject:anObject]);
}

- (void)removeAllObjects {
    LOCK([_container removeAllObjects]);
}

- (void)removeObject:(id)anObject {
    LOCK([_container removeObject:anObject]);
}

#pragma mark - protocol

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained[])stackbuf
                                    count:(NSUInteger)len {
    LOCK(NSUInteger count = [_container countByEnumeratingWithState:state objects:stackbuf count:len]);
    return count;
}

- (BOOL)isEqual:(id)object {
    if (object == self) return YES;
    
    if ([object isKindOfClass:BAThreadSafeWeakArray.class]) {
        BAThreadSafeWeakArray *other = object;
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
