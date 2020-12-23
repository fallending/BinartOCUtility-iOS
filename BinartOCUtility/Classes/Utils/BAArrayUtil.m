#import "BAArrayUtil.h"

// ----------------------------------
// Source code
// ----------------------------------

#pragma mark -

@implementation NSArray ( BAUtil )

- (id)ba_first { return self.firstObject; }
- (id)ba_last{ return self.lastObject; }

- (NSArray *)ba_head:(NSUInteger)count {
    if ( 0 == self.count || 0 == count ) {
        return nil;
    }
    
    if ( self.count < count ) {
        return self;
    }

    NSRange range;
    range.location = 0;
    range.length = count;

    return [self subarrayWithRange:range];
}

- (NSArray *)ba_tail:(NSUInteger)count {
    if ( 0 == self.count || 0 == count ) {
        return nil;
    }
    
    if ( self.count < count ) {
        return self;
    }

    NSRange range;
    range.location = self.count - count;
    range.length = count;

    return [self subarrayWithRange:range];
}

- (id)ba_atIndex:(NSUInteger)index {
    if ( index >= self.count )
        return nil;
    
    return [self objectAtIndex:index];
}

- (id)ba_subWithRange:(NSRange)range {
    if ( 0 == self.count )
        return [NSArray array];
    
    if ( range.location >= self.count )
        return [NSArray array];
    
    range.length = MIN( range.length, self.count - range.location );
    if ( 0 == range.length )
        return [NSArray array];
    
    return [self ba_subWithRange:NSMakeRange(range.location, range.length)];
}

- (id)ba_subFromIndex:(NSUInteger)index {
    if ( 0 == self.count )
        return [NSArray array];
    
    if ( index >= self.count )
        return [NSArray array];
    
    return [self ba_subWithRange:NSMakeRange(index, self.count - index)];
}

- (id)ba_subWithCount:(NSUInteger)count {
    if ( 0 == self.count )
        return [NSArray array];
    
    return [self ba_subWithRange:NSMakeRange(0, count)];
}

- (NSString *)ba_join:(NSString *)delimiter {
    if ( 0 == self.count ) {
        return @"";
    } else if ( 1 == self.count ) {
        return [[self objectAtIndex:0] description];
    } else {
        NSMutableString * result = [NSMutableString string];
        
        for ( NSUInteger i = 0; i < self.count; ++i ) {
            [result appendString:[[self objectAtIndex:i] description]];
            
            if ( delimiter ) {
                if ( i + 1 < self.count ) {
                    [result appendString:delimiter];
                }
            }
        }
        
        return result;
    }
}

#pragma mark -

- (BOOL)ba_containsString:(NSString *)aString {
    __block BOOL contained = NO;
    
    [self enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[NSString class]]) {
            // 如果有非String对象，返回
            *stop = YES;
        }
        
        if ([obj isEqualToString:aString]) {
            contained = YES;
            *stop = YES;
        }
    }];
    
    return contained;
}

//- (NSArray *)filteredArrayWhereProperty:(NSString *)property equals:(id)value {
//    NSParameterAssert(property); NSParameterAssert(value);
//    NSPredicate *filter = [NSPredicate predicateWithFormat:@"%K = %@", property, value];
//    return [self filteredArrayUsingPredicate:filter];
//}

- (void)ba_each:(void (^)(id _Nonnull))block {
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}

- (void)ba_apply:(void (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    [self enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}
    
- (id)ba_match:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    NSUInteger index = [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }];
    
    if (index == NSNotFound)
    return nil;
    
    return self[index];
}

- (NSArray *)ba_select:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    return [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }]];
}

- (NSArray *)ba_reject:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    return [self ba_select:^BOOL(id obj) {
        return !block(obj);
    }];
}
    
- (NSArray *)ba_map:(id (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = block(obj) ?: [NSNull null];
        [result addObject:value];
    }];
    
    return result;
}

- (NSArray *)ba_compact:(id (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = block(obj);
        if(value) {
            [result addObject:value];
        }
    }];
    
    return result;
}
    
- (id)ba_reduce:(id)initial withBlock:(id (^)(id sum, id obj))block {
    NSParameterAssert(block != nil);
    
    __block id result = initial;
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = block(result, obj);
    }];
    
    return result;
}
    
- (NSInteger)ba_reduceInteger:(NSInteger)initial withBlock:(NSInteger (^)(NSInteger, id))block {
    NSParameterAssert(block != nil);
    
    __block NSInteger result = initial;
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = block(result, obj);
    }];
    
    return result;
}
    
- (CGFloat)ba_reduceFloat:(CGFloat)inital withBlock:(CGFloat (^)(CGFloat, id))block {
    NSParameterAssert(block != nil);
    
    __block CGFloat result = inital;
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = block(result, obj);
    }];
    
    return result;
}
    
- (BOOL)ba_any:(BOOL (^)(id obj))block {
    return [self ba_match:block] != nil;
}
    
- (BOOL)ba_none:(BOOL (^)(id obj))block {
    return [self ba_match:block] == nil;
}
    
- (BOOL)ba_all:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    __block BOOL result = YES;
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (!block(obj)) {
            result = NO;
            *stop = YES;
        }
    }];
    
    return result;
}
    
- (BOOL)ba_corresponds:(NSArray *)list withBlock:(BOOL (^)(id obj1, id obj2))block {
    NSParameterAssert(block != nil);
    
    __block BOOL result = NO;
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx < list.count) {
            id obj2 = list[idx];
            result = block(obj, obj2);
        } else {
            result = NO;
        }
        *stop = !result;
    }];
    
    return result;
}
@end

#pragma mark -

static const void *    __RetainFunc( CFAllocatorRef allocator, const void * value ) { return value; }
static void            __ReleaseFunc( CFAllocatorRef allocator, const void * value ) {}

@implementation NSMutableArray(Extension)

+ (NSMutableArray *)ba_nonRetainingArray {// copy from Three20
    CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
    callbacks.retain = __RetainFunc;
    callbacks.release = __ReleaseFunc;
    return (__bridge_transfer NSMutableArray *)CFArrayCreateMutable( nil, 0, &callbacks );
}

- (void)ba_add:(id)object {
    if (object) {
        [self addObject:object];
    }
}

- (void)ba_add:(id)object atIndex:(NSInteger)index {
    if (object && index < self.count) {
        [self insertObject:object atIndex:index];
    }
}

- (void)ba_addUniqueObject:(id)object compare:(NSArrayCompareBlock)compare {
    BOOL found = NO;
    
    for ( id obj in self ) {
        if ( compare ) {
            NSComparisonResult result = compare( obj, object );
            if ( NSOrderedSame == result ) {
                found = YES;
                break;
            }
        }
        else if ( [obj class] == [object class] && [obj respondsToSelector:@selector(compare:)] ) {
            NSComparisonResult result = [obj compare:object];
            if ( NSOrderedSame == result ) {
                found = YES;
                break;
            }
        }
    }
    
    if ( NO == found ) {
        [self addObject:object];
    }
}

- (void)ba_addUniqueObjects:(const __unsafe_unretained id [])objects count:(NSUInteger)count compare:(NSArrayCompareBlock)compare {
    for ( NSUInteger i = 0; i < count; ++i ) {
        BOOL    found = NO;
        id        object = objects[i];

        for ( id obj in self ) {
            if ( compare ) {
                NSComparisonResult result = compare( obj, object );
                if ( NSOrderedSame == result ) {
                    found = YES;
                    break;
                }
            }
            else if ( [obj class] == [object class] && [obj respondsToSelector:@selector(compare:)] ) {
                NSComparisonResult result = [obj compare:object];
                if ( NSOrderedSame == result ) {
                    found = YES;
                    break;
                }
            }
        }

        if ( NO == found ) {
            [self addObject:object];
        }
    }
}

- (void)ba_addUniqueObjectsFromArray:(NSArray *)array compare:(NSArrayCompareBlock)compare {
    for ( id object in array ) {
        BOOL found = NO;

        for ( id obj in self ) {
            if ( compare ) {
                NSComparisonResult result = compare( obj, object );
                if ( NSOrderedSame == result ) {
                    found = YES;
                    break;
                }
            }
            else if ( [obj class] == [object class] && [obj respondsToSelector:@selector(compare:)] ) {
                NSComparisonResult result = [obj compare:object];
                if ( NSOrderedSame == result ) {
                    found = YES;
                    break;
                }
            }
        }
        
        if ( NO == found ) {
            [self addObject:object];
        }
    }
}

- (void)ba_swap:(NSUInteger)i and:(NSUInteger)j {
    NSObject *n1 = [self ba_atIndex:i];
    NSObject *n2 = [self ba_atIndex:j];
    
    self[i] = n2;
    self[j] = n1;
}

- (void)ba_unique {
    [self ba_unique:^NSComparisonResult(id left, id right) {
        return [left compare:right];
    }];
}

- (void)ba_unique:(NSArrayCompareBlock)compare {
    if ( self.count <= 1 ) {
        return;
    }

    // Optimize later ...

    NSMutableArray * dupArray = [NSMutableArray ba_nonRetainingArray];
    NSMutableArray * delArray = [NSMutableArray ba_nonRetainingArray];

    [dupArray addObjectsFromArray:self];
    [dupArray sortUsingComparator:compare];
    
    for ( NSUInteger i = 0; i < dupArray.count; ++i ) {
        id elem1 = [dupArray ba_atIndex:i];
        id elem2 = [dupArray ba_atIndex:(i + 1)];
        
        if ( elem1 && elem2 ) {
            if ( NSOrderedSame == compare(elem1, elem2) ) {
                [delArray addObject:elem1];
            }
        }
    }
    
    for ( id delElem in delArray ) {
        [self removeObject:delElem];
    }
}

- (void)ba_sort {
    [self ba_sort:^NSComparisonResult(id left, id right) {
        return [left compare:right];
    }];
}

- (void)ba_sort:(NSArrayCompareBlock)compare {
    [self sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return compare( obj1, obj2 );
    }];
}

- (void)ba_shrink:(NSUInteger)count {
    if ( 0 == count ) {
        [self removeAllObjects];
    } else if ( count <= self.count ) {
        [self removeObjectsInRange:NSMakeRange(count, self.count - count)];
    }
}

- (void)ba_append:(id)object {
    [self addObject:object];
}

- (NSMutableArray *)ba_pushHead:(NSObject *)obj {
    if ( obj ) {
        [self insertObject:obj atIndex:0];
    }
    
    return self;
}

- (NSMutableArray *)ba_pushHeadN:(NSArray *)all {
    if ( [all count] ) {
        for ( NSUInteger i = [all count]; i > 0; --i ) {
            [self insertObject:[all objectAtIndex:i - 1] atIndex:0];
        }
    }
    
    return self;
}

- (NSMutableArray *)ba_popTail {
    if ( [self count] > 0 ) {
        [self removeObjectAtIndex:[self count] - 1];
    }
    
    return self;
}

- (NSMutableArray *)ba_popTailN:(NSUInteger)n {
    if ( [self count] > 0 ) {
        if ( n >= [self count] ) {
            [self removeAllObjects];
        } else {
            NSRange range;
            range.location = n;
            range.length = [self count] - n;
            
            [self removeObjectsInRange:range];
        }
    }
    
    return self;
}

- (NSMutableArray *)ba_pushTail:(NSObject *)obj {
    if ( obj ) {
        [self addObject:obj];
    }
    
    return self;
}

- (NSMutableArray *)ba_pushTailN:(NSArray *)all {
    if ( [all count] ) {
        [self addObjectsFromArray:all];
    }
    
    return self;
}

- (NSMutableArray *)ba_popHead {
    if ( [self count] ) {
        [self removeLastObject];
    }
    
    return self;
}

- (NSMutableArray *)ba_popHeadN:(NSUInteger)n {
    if ( [self count] > 0 ) {
        if ( n >= [self count] ) {
            [self removeAllObjects];
        } else {
            NSRange range;
            range.location = 0;
            range.length = n;
            
            [self removeObjectsInRange:range];
        }
    }
    
    return self;
}

- (NSMutableArray *)ba_keepHead:(NSUInteger)n {
    if ( [self count] > n ) {
        NSRange range;
        range.location = n;
        range.length = [self count] - n;
        
        [self removeObjectsInRange:range];
    }
    
    return self;
}

- (NSMutableArray *)ba_keepTail:(NSUInteger)n {
    if ( [self count] > n ) {
        NSRange range;
        range.location = 0;
        range.length = [self count] - n;
        
        [self removeObjectsInRange:range];
    }
    
    return self;
}

@end
