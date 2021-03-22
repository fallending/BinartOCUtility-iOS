#import "BADictionaryUtil.h"

@implementation NSMutableDictionary ( BAUtil )

- (BOOL)mt_set:(NSObject *)obj atPath:(NSString *)path {
    return [self mt_set:obj atPath:path separator:nil];
}

- (BOOL)mt_set:(NSObject *)obj atPath:(NSString *)path separator:(NSString *)separator {
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

+ (NSMutableDictionary *)mt_keyValues:(id)first, ... {
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
        
        [dict mt_set:value atPath:(NSString *)key];
    }
    va_end( args );
    return dict;
}

- (BOOL)mt_setKeyValues:(id)first, ... {
    va_list args;
    va_start( args, first );
    
    for ( ;; first = nil ) {
        NSObject * key = first ? first : va_arg( args, NSObject * );
        if ( nil == key || NO == [key isKindOfClass:[NSString class]] )
            break;

        NSObject * value = va_arg( args, NSObject * );
        if ( nil == value )
            break;

        BOOL ret = [self mt_set:value atPath:(NSString *)key];
        if ( NO == ret ) {
            va_end( args );
            return NO;
        }
    }
    va_end( args );
    return YES;
}

// MARK: -

- (void)mt_setPoint:(CGPoint)o forKey:(NSString *)key{
    self[key] = NSStringFromCGPoint(o);
}

- (void)mt_setSize:(CGSize)o forKey:(NSString *)key {
    self[key] = NSStringFromCGSize(o);
}

- (void)mt_setRect:(CGRect)o forKey:(NSString *)key {
    self[key] = NSStringFromCGRect(o);
}

@end

@implementation NSDictionary ( BAUtil )

// MARK: -

- (BOOL)mt_hasKey:(id)key {
    return [self objectForKey:key] ? YES : NO;
}

- (id)mt_atPath:(NSString *)path {
    return [self mt_atPath:path separator:nil];
}

- (id)mt_atPath:(NSString *)path separator:(NSString *)separator {
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

- (id)mt_atPath:(NSString *)path otherwise:(NSObject *)other {
    NSObject * obj = [self mt_atPath:path];
    
    return obj ? obj : other;
}

- (id)mt_atPath:(NSString *)path otherwise:(NSObject *)other separator:(NSString *)separator {
    NSObject * obj = [self mt_atPath:path separator:separator];
    
    return obj ? obj : other;
}

- (CGPoint)mt_pointAtPath:(NSString *)path {
    CGPoint o = CGPointFromString([self mt_atPath:path]);
    return o;
}

- (CGSize)mt_sizeAtPath:(NSString *)path {
    CGSize o = CGSizeFromString([self mt_atPath:path]);
    return o;
}

- (CGRect)mt_rectAtPath:(NSString *)path {
    CGRect o = CGRectFromString([self mt_atPath:path]);
    return o;
}

// MARK: -

- (void)mt_each:(void (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}
    
- (void)mt_apply:(void (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    [self enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id obj, BOOL *stop) {
        block(key, obj);
    }];
}
    
- (id)mt_match:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    return self[[[self keysOfEntriesPassingTest:^(id key, id obj, BOOL *stop) {
        if (block(key, obj)) {
            *stop = YES;
            return YES;
        }
        
        return NO;
    }] anyObject]];
}
    
- (NSDictionary *)mt_select:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    NSArray *keys = [[self keysOfEntriesPassingTest:^(id key, id obj, BOOL *stop) {
        return block(key, obj);
    }] allObjects];
    
    NSArray *objects = [self objectsForKeys:keys notFoundMarker:[NSNull null]];
    return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
}
    
- (NSDictionary *)mt_reject:(BOOL (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    return [self mt_select:^BOOL(id key, id obj) {
        return !block(key, obj);
    }];
}
    
- (NSDictionary *)mt_map:(id (^)(id key, id obj))block {
    NSParameterAssert(block != nil);
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:self.count];
    
    [self mt_each:^(id key, id obj) {
        id value = block(key, obj) ?: [NSNull null];
        result[key] = value;
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
