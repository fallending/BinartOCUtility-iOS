#import "BATableUtil.h"

@implementation NSMapTable ( BAUtil )

- (void)enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block {
    BOOL stop = NO;
    for(id key in self) {
        id obj = [self objectForKey:key];
        block(key, obj, &stop);
        if(stop) {
            break;
        }
    }
}

- (void)mt_each:(void (^)(id key, id obj))block {
    NSParameterAssert(block != nil);

    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}

- (id)mt_match:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);

    __block id match = nil;
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if(block(key, obj)) {
            match = obj;
            *stop = YES;
        }
    }];
    return match;
}

- (NSMapTable *)mt_select:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);

    NSMapTable *result = [[NSMapTable alloc] initWithKeyPointerFunctions:self.keyPointerFunctions valuePointerFunctions:self.valuePointerFunctions capacity:self.count];

    [self mt_each:^(id key, id obj) {
        if(block(key, obj)) {
            [result setObject:obj forKey:key];
        }
    }];

    return result;
}

- (NSMapTable *)mt_reject:(BOOL (^)(id key, id obj))block {
    return [self mt_select:^BOOL(id key, id obj) {
        return !block(key, obj);
    }];
}

- (NSMapTable *)mt_map:(id (^)(id key, id obj))block {
    NSParameterAssert(block != nil);

    NSMapTable *result = [[NSMapTable alloc] initWithKeyPointerFunctions:self.keyPointerFunctions valuePointerFunctions:self.valuePointerFunctions capacity:self.count];

    [self mt_each:^(id key, id obj) {
        id value = block(key, obj);
        if (!value)
            value = [NSNull null];

        [result setObject:value forKey:key];
    }];

    return result;
}

- (BOOL)mt_any:(BOOL (^)(id key, id obj))block {
    return [self mt_match:block] != nil;
}

- (BOOL)mt_none:(BOOL (^)(id key, id obj))block {
    return [self mt_match:block] == nil;
}

- (BOOL)mt_all:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);

    __block BOOL result = YES;

    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (!block(key, obj)) {
            result = NO;
            *stop = YES;
        }
    }];
    
    return result;
}

@end
