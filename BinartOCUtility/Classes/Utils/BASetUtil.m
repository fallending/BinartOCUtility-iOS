#import "BASetUtil.h"

@implementation NSOrderedSet ( BAUtil )
    
- (void)mt_each:(void (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}
    
- (void)mt_apply:(void (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    [self enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        block(obj);
    }];
}
    
- (id)mt_match:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    NSUInteger index = [self indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }];
    
    if (index == NSNotFound) return nil;
    return self[index];
}
    
- (NSOrderedSet *)mt_select:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    NSArray *objects = [self objectsAtIndexes:[self indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return block(obj);
    }]];
    
    if (!objects.count) return [[self class] orderedSet];
    return [[self class] orderedSetWithArray:objects];
}
    
- (NSOrderedSet *)mt_reject:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    return [self mt_select:^BOOL(id obj) {
        return !block(obj);
    }];
}
    
- (NSOrderedSet *)mt_map:(id (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    NSMutableOrderedSet *result = [NSMutableOrderedSet orderedSetWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id value = block(obj) ?: [NSNull null];
        [result addObject:value];
    }];
    
    return result;
}
    
- (id)mt_reduce:(id)initial withBlock:(id (^)(id sum, id obj))block {
    NSParameterAssert(block != nil);
    
    __block id result = initial;
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        result = block(result, obj);
    }];
    
    return result;
}
    
- (BOOL)mt_any:(BOOL (^)(id obj))block {
    return [self mt_match:block] != nil;
}
    
- (BOOL)mt_none:(BOOL (^)(id obj))block {
    return [self mt_match:block] == nil;
}
    
- (BOOL)mt_all:(BOOL (^)(id obj))block {
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
    
- (BOOL)mt_corresponds:(NSOrderedSet *)list withBlock:(BOOL (^)(id obj1, id obj2))block {
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


@implementation NSSet ( BAUtil )

- (void)mt_each:(void (^)(id))block {
    NSParameterAssert(block != nil);
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        block(obj);
    }];
}
    
- (void)mt_eachWithIndex:(void (^)(id, int))block {
    __block int counter = 0;
    
    NSParameterAssert(block != nil);
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        block(obj, counter);
        counter ++;
    }];
}
    
- (void)mt_apply:(void (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    [self enumerateObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id obj, BOOL *stop) {
        block(obj);
    }];
}
    
- (id)mt_match:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    return [[self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        if (block(obj)) {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }] anyObject];
}

- (NSSet *)mt_select:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    return [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        return block(obj);
    }];
}
    
- (NSSet *)mt_reject:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    return [self objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        return !block(obj);
    }];
}

- (NSSet *)mt_map:(id (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    NSMutableSet *result = [NSMutableSet setWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        id value = block(obj) ?:[NSNull null];
        [result addObject:value];
    }];
    
    return result;
}

- (id)mt_reduce:(id)initial withBlock:(id (^)(id sum, id obj))block {
    NSParameterAssert(block != nil);
    
    __block id result = initial;
    
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        result = block(result, obj);
    }];
    
    return result;
}

- (BOOL)mt_any:(BOOL (^)(id obj))block {
    return [self mt_match:block] != nil;
}
    
- (BOOL)mt_none:(BOOL (^)(id obj))block {
    return [self mt_match:block] == nil;
}
    
- (BOOL)mt_all:(BOOL (^)(id obj))block {
    NSParameterAssert(block != nil);
    
    __block BOOL result = YES;
    
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if (!block(obj)) {
            result = NO;
            *stop = YES;
        }
    }];
    
    return result;
}

- (NSArray *)mt_sort {
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    return [self sortedArrayUsingDescriptors:@[sortDescriptor]];
}

@end
