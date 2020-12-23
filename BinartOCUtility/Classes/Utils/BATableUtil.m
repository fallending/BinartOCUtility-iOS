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

- (void)ba_each:(void (^)(id key, id obj))block {
    NSParameterAssert(block != nil);

    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}

- (id)ba_match:(BOOL (^)(id key, id obj))block {
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

- (NSMapTable *)ba_select:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);

    NSMapTable *result = [[NSMapTable alloc] initWithKeyPointerFunctions:self.keyPointerFunctions valuePointerFunctions:self.valuePointerFunctions capacity:self.count];

    [self ba_each:^(id key, id obj) {
        if(block(key, obj)) {
            [result setObject:obj forKey:key];
        }
    }];

    return result;
}

- (NSMapTable *)ba_reject:(BOOL (^)(id key, id obj))block {
    return [self ba_select:^BOOL(id key, id obj) {
        return !block(key, obj);
    }];
}

- (NSMapTable *)ba_map:(id (^)(id key, id obj))block {
    NSParameterAssert(block != nil);

    NSMapTable *result = [[NSMapTable alloc] initWithKeyPointerFunctions:self.keyPointerFunctions valuePointerFunctions:self.valuePointerFunctions capacity:self.count];

    [self ba_each:^(id key, id obj) {
        id value = block(key, obj);
        if (!value)
            value = [NSNull null];

        [result setObject:value forKey:key];
    }];

    return result;
}

- (BOOL)ba_any:(BOOL (^)(id key, id obj))block {
    return [self ba_match:block] != nil;
}

- (BOOL)ba_none:(BOOL (^)(id key, id obj))block {
    return [self ba_match:block] == nil;
}

- (BOOL)ba_all:(BOOL (^)(id key, id obj))block {
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
