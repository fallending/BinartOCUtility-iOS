
#import "BAThreadSafeArray.h"
#import "BAThreadSafeLocks.h"

#import "_pragma_push.h"

@interface BAThreadSafeArray() {
    NSMutableArray *_container;
    dispatch_semaphore_t _lock;
}

@end

@implementation BAThreadSafeArray

- (instancetype)init {
    INIT(_container = [[NSMutableArray alloc] init]);
}

- (instancetype)initWithCapacity:(NSUInteger)numItems {
    INIT(_container = [[NSMutableArray alloc] initWithCapacity:numItems]);
}

- (instancetype)initWithArray:(NSArray *)array {
    INIT(_container = [[NSMutableArray alloc] initWithArray:array]);
}

- (instancetype)initWithObjects:(const id[])objects count:(NSUInteger)cnt {
    INIT(_container = [[NSMutableArray alloc] initWithObjects:objects count:cnt]);
}

- (instancetype)initWithContentsOfFile:(NSString *)path {
    INIT(_container = [[NSMutableArray alloc] initWithContentsOfFile:path]);
}

- (instancetype)initWithContentsOfURL:(NSURL *)url {
    INIT(_container = [[NSMutableArray alloc] initWithContentsOfURL:url]);
}

// MARK: - method

- (NSUInteger)count {
    LOCK(NSUInteger count = _container.count); return count;
}

- (id)objectAtIndex:(NSUInteger)index {
    LOCK(id obj = [_container objectAtIndex:index]); return obj;
}

- (NSArray *)arrayByAddingObject:(id)anObject {
    LOCK(NSArray * arr = [_container arrayByAddingObject:anObject]); return arr;
}

- (NSArray *)arrayByAddingObjectsFromArray:(NSArray *)otherArray {
    LOCK(NSArray * arr = [_container arrayByAddingObjectsFromArray:otherArray]); return arr;
}

- (NSString *)componentsJoinedByString:(NSString *)separator {
    LOCK(NSString * str = [_container componentsJoinedByString:separator]); return str;
}

- (BOOL)containsObject:(id)anObject {
    LOCK(BOOL c = [_container containsObject:anObject]); return c;
}

- (NSString *)description {
    LOCK(NSString * d = _container.description); return d;
}

- (NSString *)descriptionWithLocale:(id)locale {
    LOCK(NSString * d = [_container descriptionWithLocale:locale]); return d;
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level {
    LOCK(NSString * d = [_container descriptionWithLocale:locale indent:level]); return d;
}

- (id)firstObjectCommonWithArray:(NSArray *)otherArray {
    LOCK(id o = [_container firstObjectCommonWithArray:otherArray]); return o;
}

- (void)getObjects:(id __unsafe_unretained[])objects range:(NSRange)range {
    LOCK([_container getObjects:objects range:range]);
}

- (NSUInteger)indexOfObject:(id)anObject {
    LOCK(NSUInteger i = [_container indexOfObject:anObject]); return i;
}

- (NSUInteger)indexOfObject:(id)anObject inRange:(NSRange)range {
    LOCK(NSUInteger i = [_container indexOfObject:anObject inRange:range]); return i;
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject {
    LOCK(NSUInteger i = [_container indexOfObjectIdenticalTo:anObject]); return i;
}

- (NSUInteger)indexOfObjectIdenticalTo:(id)anObject inRange:(NSRange)range {
    LOCK(NSUInteger i = [_container indexOfObjectIdenticalTo:anObject inRange:range]); return i;
}

- (id)firstObject {
    LOCK(id o = _container.firstObject); return o;
}

- (id)lastObject {
    LOCK(id o = _container.lastObject); return o;
}

- (NSEnumerator *)objectEnumerator {
    LOCK(NSEnumerator * e = [_container objectEnumerator]); return e;
}

- (NSEnumerator *)reverseObjectEnumerator {
    LOCK(NSEnumerator * e = [_container reverseObjectEnumerator]); return e;
}

- (NSData *)sortedArrayHint {
    LOCK(NSData * d = [_container sortedArrayHint]); return d;
}

- (NSArray *)sortedArrayUsingFunction:(NSInteger (NS_NOESCAPE *)(id, id, void *))comparator context:(void *)context {
    LOCK(NSArray * arr = [_container sortedArrayUsingFunction:comparator context:context]) return arr;
}

- (NSArray *)sortedArrayUsingFunction:(NSInteger (NS_NOESCAPE *)(id, id, void *))comparator context:(void *)context hint:(NSData *)hint {
    LOCK(NSArray * arr = [_container sortedArrayUsingFunction:comparator context:context hint:hint]); return arr;
}

- (NSArray *)sortedArrayUsingSelector:(SEL)comparator {
    LOCK(NSArray * arr = [_container sortedArrayUsingSelector:comparator]); return arr;
}

- (NSArray *)subarrayWithRange:(NSRange)range {
    LOCK(NSArray * arr = [_container subarrayWithRange:range]) return arr;
}

- (void)makeObjectsPerformSelector:(SEL)aSelector {
    LOCK([_container makeObjectsPerformSelector:aSelector]);
}

- (void)makeObjectsPerformSelector:(SEL)aSelector withObject:(id)argument {
    LOCK([_container makeObjectsPerformSelector:aSelector withObject:argument]);
}

- (NSArray *)objectsAtIndexes:(NSIndexSet *)indexes {
    LOCK(NSArray * arr = [_container objectsAtIndexes:indexes]); return arr;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
    LOCK(id o = [_container objectAtIndexedSubscript:idx]); return o;
}

- (void)enumerateObjectsUsingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))block {
    LOCK([_container enumerateObjectsUsingBlock:block]);
}

- (void)enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))block {
    LOCK([_container enumerateObjectsWithOptions:opts usingBlock:block]);
}

- (void)enumerateObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts usingBlock:(void (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))block {
    LOCK([_container enumerateObjectsAtIndexes:s options:opts usingBlock:block]);
}

- (NSUInteger)indexOfObjectPassingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    LOCK(NSUInteger i = [_container indexOfObjectPassingTest:predicate]); return i;
}

- (NSUInteger)indexOfObjectWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    LOCK(NSUInteger i = [_container indexOfObjectWithOptions:opts passingTest:predicate]); return i;
}

- (NSUInteger)indexOfObjectAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    LOCK(NSUInteger i = [_container indexOfObjectAtIndexes:s options:opts passingTest:predicate]); return i;
}

- (NSIndexSet *)indexesOfObjectsPassingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    LOCK(NSIndexSet * i = [_container indexesOfObjectsPassingTest:predicate]); return i;
}

- (NSIndexSet *)indexesOfObjectsWithOptions:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    LOCK(NSIndexSet * i = [_container indexesOfObjectsWithOptions:opts passingTest:predicate]); return i;
}

- (NSIndexSet *)indexesOfObjectsAtIndexes:(NSIndexSet *)s options:(NSEnumerationOptions)opts passingTest:(BOOL (NS_NOESCAPE ^)(id obj, NSUInteger idx, BOOL *stop))predicate {
    LOCK(NSIndexSet * i = [_container indexesOfObjectsAtIndexes:s options:opts passingTest:predicate]); return i;
}

- (NSArray *)sortedArrayUsingComparator:(NSComparator)cmptr {
    LOCK(NSArray * a = [_container sortedArrayUsingComparator:cmptr]); return a;
}

- (NSArray *)sortedArrayWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr {
    LOCK(NSArray * a = [_container sortedArrayWithOptions:opts usingComparator:cmptr]); return a;
}

- (NSUInteger)indexOfObject:(id)obj inSortedRange:(NSRange)r options:(NSBinarySearchingOptions)opts usingComparator:(NSComparator)cmp {
    LOCK(NSUInteger i = [_container indexOfObject:obj inSortedRange:r options:opts usingComparator:cmp]); return i;
}

// MARK: - mutable

- (void)addObject:(id)anObject {
    LOCK([_container addObject:anObject]);
}

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    LOCK([_container insertObject:anObject atIndex:index]);
}

- (void)removeLastObject {
    LOCK([_container removeLastObject]);
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    LOCK([_container removeObjectAtIndex:index]);
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    LOCK([_container replaceObjectAtIndex:index withObject:anObject]);
}

- (void)addObjectsFromArray:(NSArray *)otherArray {
    LOCK([_container addObjectsFromArray:otherArray]);
}

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2 {
    LOCK([_container exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2]);
}

- (void)removeAllObjects {
    LOCK([_container removeAllObjects]);
}

- (void)removeObject:(id)anObject inRange:(NSRange)range {
    LOCK([_container removeObject:anObject inRange:range]);
}

- (void)removeObject:(id)anObject {
    LOCK([_container removeObject:anObject]);
}

- (void)removeObjectIdenticalTo:(id)anObject inRange:(NSRange)range {
    LOCK([_container removeObjectIdenticalTo:anObject inRange:range]);
}

- (void)removeObjectIdenticalTo:(id)anObject {
    LOCK([_container removeObjectIdenticalTo:anObject]);
}

- (void)removeObjectsInArray:(NSArray *)otherArray {
    LOCK([_container removeObjectsInArray:otherArray]);
}

- (void)removeObjectsInRange:(NSRange)range {
    LOCK([_container removeObjectsInRange:range]);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray range:(NSRange)otherRange {
    LOCK([_container replaceObjectsInRange:range withObjectsFromArray:otherArray range:otherRange]);
}

- (void)replaceObjectsInRange:(NSRange)range withObjectsFromArray:(NSArray *)otherArray {
    LOCK([_container replaceObjectsInRange:range withObjectsFromArray:otherArray]);
}

- (void)setArray:(NSArray *)otherArray {
    LOCK([_container setArray:otherArray]);
}

- (void)sortUsingFunction:(NSInteger (NS_NOESCAPE *)(id, id, void *))compare context:(void *)context {
    LOCK([_container sortUsingFunction:compare context:context]);
}

- (void)sortUsingSelector:(SEL)comparator {
    LOCK([_container sortUsingSelector:comparator]);
}

- (void)insertObjects:(NSArray *)objects atIndexes:(NSIndexSet *)indexes {
    LOCK([_container insertObjects:objects atIndexes:indexes]);
}

- (void)removeObjectsAtIndexes:(NSIndexSet *)indexes {
    LOCK([_container removeObjectsAtIndexes:indexes]);
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects {
    LOCK([_container replaceObjectsAtIndexes:indexes withObjects:objects]);
}

- (void)setObject:(id)obj atIndexedSubscript:(NSUInteger)idx {
    LOCK([_container setObject:obj atIndexedSubscript:idx]);
}

- (void)sortUsingComparator:(NSComparator)cmptr {
    LOCK([_container sortUsingComparator:cmptr]);
}

- (void)sortWithOptions:(NSSortOptions)opts usingComparator:(NSComparator)cmptr {
    LOCK([_container sortWithOptions:opts usingComparator:cmptr]);
}

- (BOOL)isEqualToArray:(NSArray *)otherArray {
    if (otherArray == self) return YES;
    if ([otherArray isKindOfClass:BAThreadSafeArray.class]) {
        BAThreadSafeArray *other = (id)otherArray;
        BOOL isEqual;
        dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
        dispatch_semaphore_wait(other->_lock, DISPATCH_TIME_FOREVER);
        isEqual = [_container isEqualToArray:other->_container];
        dispatch_semaphore_signal(other->_lock);
        dispatch_semaphore_signal(_lock);
        return isEqual;
    }
    return NO;
}

// MARK: - protocol

- (id)copyWithZone:(NSZone *)zone {
    return [self mutableCopyWithZone:zone];
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    LOCK(id copiedDictionary = [[self.class allocWithZone:zone] initWithArray:_container]);
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
    
    if ([object isKindOfClass:BAThreadSafeArray.class]) {
        BAThreadSafeArray *other = object;
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
