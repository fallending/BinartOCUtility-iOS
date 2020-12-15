#import "BAError.h"

#import <objc/runtime.h>

//@interface NSObject ( BAError )
//
//- (void)objectPropertyTraversal;
//+ (void)objectPropertyTraversal;
//
//@end

//@implementation NSError ( BA )
//
//- (id)valueForUndefinedKey:(NSString *)key {
//    return nil;
//}
//
//+ (NSError *)errorForCode:(NSInteger)code {
//    NSError *error = make_error(NSStringFromClass([self class]), code);
//
//    if (![error isPooled]) { // pool中没有该key的error
//        [self objectPropertyTraversal];
//    }
//
//    return make_error_3(NSStringFromClass([self class]), code, nil);
//}
//
//- (NSError *)errorForCode:(NSInteger)code {
//    NSError *error = make_error(NSStringFromClass([self class]), code);
//
//    if (![error isPooled]) {
//        [self objectPropertyTraversal];
//    }
//
//    return make_error_3(NSStringFromClass([self class]), code, nil);
//}
//
//@end

#pragma mark -

@implementation NSError (Handler)

@def_nsstring( messagedKey,                 @"NSError.message.key" )

@def_nsstring( CocoaErrorDomain           , NSCocoaErrorDomain )
@def_nsstring( LocalizedDescriptionKey    , NSLocalizedDescriptionKey )
@def_nsstring( StringEncodingErrorKey     , NSStringEncodingErrorKey )
@def_nsstring( URLErrorKey                , NSURLErrorKey )
@def_nsstring( FilePathErrorKey           , NSFilePathErrorKey )
@def_nsstring( errorDomain                , @"NSError.domain" )

#pragma mark - Error maker

+ (instancetype)errorWithDomain:(NSString *)domain
                           code:(NSInteger)code
                           desc:(NSString *)desc { // desc 可以为空
    NSAssert(domain, @"Domain nil");
    
    desc = !desc ? @"" : desc;
    
    NSDictionary *userInfo      = @{[self messagedKey]:desc};
    NSError *error              = [self errorWithDomain:domain code:code userInfo:userInfo];;

    return error;
}

#pragma mark - Equal

- (BOOL)isInteger:(NSInteger)code {
    return [self code] == code;
}

- (BOOL)is:(NSError *)error {
    
    if ([[self domain] isEqual:[error domain]] &&
        [self code] == [error code]) {
        return YES;
    } else if ([self code] == [error code]) {
        LOG(@"error 相比，code相等，domain不同, %@, %@", self, error);
        
        return YES;
    }
    
    return NO;
}

#pragma mark - UserInfo

- (NSString *)message {
    
    if (self.userInfo &&
        [self.userInfo.allKeys containsObject:[self messagedKey]]) {
        
        return self.userInfo[[self messagedKey]];
    }
    
    // 没有消息
    return @"";
}

#pragma mark - Key

- (NSString *)storedKey {
    return [NSString stringWithFormat:@"%@.%zd", self.domain, self.code]; // todo: use MACRO
}

- (NSString *)domainKey {
    return [self domain];
}

- (NSNumber *)codeKey {
    return @(self.code);
}

@end


//@implementation NSObject (Property_Traversal)
//
//+ (void)objectPropertyTraversal {
//    unsigned int propsCount;
//    objc_property_t *props = class_copyPropertyList([self class], &propsCount);
//    
//    //    TODO( "Should be 递归" )
//    for(int i = 0; i < propsCount; i++) {
//        objc_property_t prop    = props[i];
//        NSString *propName      = [NSString stringWithUTF8String:property_getName(prop)];
//        __unused id value       = [self valueForKey:propName];
//    }
//}
//
//- (void)objectPropertyTraversal {
//    unsigned int propsCount;
//    objc_property_t *props = class_copyPropertyList([self class], &propsCount);
//    
//    //    TODO( "Should be 递归" )
//    
//    for(int i = 0; i < propsCount; i++) {
//        objc_property_t prop    = props[i];
//        NSString *propName      = [NSString stringWithUTF8String:property_getName(prop)];
//        __unused id value       = [self valueForKey:propName];
//    }
//}
//
//@end
