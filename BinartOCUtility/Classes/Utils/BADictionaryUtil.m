#import "BADictionaryUtil.h"

@implementation NSMutableDictionary ( BAUtil )

- (BOOL)ba_set:(NSObject *)obj atPath:(NSString *)path {
    return [self ba_set:obj atPath:path separator:nil];
}

- (BOOL)ba_set:(NSObject *)obj atPath:(NSString *)path separator:(NSString *)separator {
    if ( 0 == [path length] )
        return NO;
    
    if ( nil == separator ) {
        path = [path stringByReplacingOccurrencesOfString:@"." withString:@"/"];
        separator = @"/";
    }
    
    NSArray * array = [path componentsSeparatedByString:separator];
    if ( 0 == [array count] ) {
        [self setObject:obj forKey:path];
        return YES;
    }

    NSMutableDictionary *    upperDict = self;
    NSDictionary *            dict = nil;
    NSString *                subPath = nil;

    for ( subPath in array ) {
        if ( 0 == [subPath length] )
            continue;

        if ( [array lastObject] == subPath )
            break;

        dict = [upperDict objectForKey:subPath];
        if ( nil == dict ) {
            dict = [NSMutableDictionary dictionary];
            [upperDict setObject:dict forKey:subPath];
        } else {
            if ( NO == [dict isKindOfClass:[NSDictionary class]] )
                return NO;

            if ( NO == [dict isKindOfClass:[NSMutableDictionary class]] )
            {
                dict = [NSMutableDictionary dictionaryWithDictionary:dict];
                [upperDict setObject:dict forKey:subPath];
            }
        }

        upperDict = (NSMutableDictionary *)dict;
    }

    if ( subPath && obj ) {
        [upperDict setObject:obj forKey:subPath];
    }
    return YES;
}

+ (NSMutableDictionary *)ba_keyValues:(id)first, ... {
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
    
    va_list args;
    va_start( args, first );
    
    for ( ;; first = nil ) {
        NSObject * key = first ? first : va_arg( args, NSObject * );
        if ( nil == key || NO == [key isKindOfClass:[NSString class]] )
            break;
        
        NSObject * value = va_arg( args, NSObject * );
        if ( nil == value )
            break;
        
        [dict ba_set:value atPath:(NSString *)key];
    }
    va_end( args );
    return dict;
}

- (BOOL)ba_setKeyValues:(id)first, ... {
    va_list args;
    va_start( args, first );
    
    for ( ;; first = nil ) {
        NSObject * key = first ? first : va_arg( args, NSObject * );
        if ( nil == key || NO == [key isKindOfClass:[NSString class]] )
            break;

        NSObject * value = va_arg( args, NSObject * );
        if ( nil == value )
            break;

        BOOL ret = [self ba_set:value atPath:(NSString *)key];
        if ( NO == ret ) {
            va_end( args );
            return NO;
        }
    }
    va_end( args );
    return YES;
}

// MARK: -

- (void)ba_setPoint:(CGPoint)o forKey:(NSString *)key{
    self[key] = NSStringFromCGPoint(o);
}

- (void)ba_setSize:(CGSize)o forKey:(NSString *)key {
    self[key] = NSStringFromCGSize(o);
}

- (void)ba_setRect:(CGRect)o forKey:(NSString *)key {
    self[key] = NSStringFromCGRect(o);
}

@end

@implementation NSDictionary ( BAUtil )

// MARK: -

- (BOOL)ba_hasKey:(id)key {
    return [self objectForKey:key] ? YES : NO;
}

- (id)ba_atPath:(NSString *)path {
    return [self ba_atPath:path separator:nil];
}

- (id)ba_atPath:(NSString *)path separator:(NSString *)separator {
    if ( nil == separator ) {
        path = [path stringByReplacingOccurrencesOfString:@"." withString:@"/"];
        separator = @"/";
    }
    
    NSArray * array = [path componentsSeparatedByString:separator];
    if ( 0 == [array count] ) {
        return nil;
    }

    NSObject * result = nil;
    NSDictionary * dict = self;
    
    for ( NSString * subPath in array ) {
        if ( 0 == [subPath length] )
            continue;
        
        result = [dict objectForKey:subPath];
        if ( nil == result )
            return nil;

        if ( [array lastObject] == subPath ) {
            return result;
        } else if ( NO == [result isKindOfClass:[NSDictionary class]] ) {
            return nil;
        }

        dict = (NSDictionary *)result;
    }
    
    return (result == [NSNull null]) ? nil : result;
}

- (id)ba_atPath:(NSString *)path otherwise:(NSObject *)other {
    NSObject * obj = [self ba_atPath:path];
    
    return obj ? obj : other;
}

- (id)ba_atPath:(NSString *)path otherwise:(NSObject *)other separator:(NSString *)separator {
    NSObject * obj = [self ba_atPath:path separator:separator];
    
    return obj ? obj : other;
}

- (CGPoint)ba_pointAtPath:(NSString *)path {
    CGPoint o = CGPointFromString([self ba_atPath:path]);
    return o;
}

- (CGSize)ba_sizeAtPath:(NSString *)path {
    CGSize o = CGSizeFromString([self ba_atPath:path]);
    return o;
}

- (CGRect)ba_rectAtPath:(NSString *)path {
    CGRect o = CGRectFromString([self ba_atPath:path]);
    return o;
}

// MARK: -

- (void)ba_each:(void (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}
    
- (void)ba_apply:(void (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    [self enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}
    
- (id)ba_match:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    return self[[[self keysOfEntriesPassingTest:^(id key, id obj, BOOL *stop) {
        if (block(key, obj)) {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }] anyObject]];
}
    
- (NSDictionary *)ba_select:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    NSArray *keys = [[self keysOfEntriesPassingTest:^(id key, id obj, BOOL *stop) {
        return block(key, obj);
    }] allObjects];
    
    NSArray *objects = [self objectsForKeys:keys notFoundMarker:[NSNull null]];
    return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
}
    
- (NSDictionary *)ba_reject:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    return [self ba_select:^BOOL(id key, id obj) {
        return !block(key, obj);
    }];
}
    
- (NSDictionary *)ba_map:(id (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];
    
    [self ba_each:^(id key, id obj) {
        id value = block(key, obj) ?: [NSNull null];
        result[key] = value;
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
