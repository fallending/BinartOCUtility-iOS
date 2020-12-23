
#import <objc/runtime.h>
#import "BAProperty.h"

@implementation NSObject ( Property )

+ (const char *)ba_attributesForProperty:(NSString *)property {
    Class baseClass = [NSObject class];
    
    for ( Class clazzType = self; clazzType != baseClass; ) {
        objc_property_t prop = class_getProperty( clazzType, [property UTF8String] );
        if ( prop ) {
            return property_getAttributes( prop );
        }
        
        clazzType = class_getSuperclass( clazzType );
        if ( nil == clazzType )
            break;
    }
    
    return NULL;
}

- (const char *)ba_attributesForProperty:(NSString *)property {
    return [[self class] ba_attributesForProperty:property];
}

+ (NSDictionary *)ba_extentionForProperty:(NSString *)property {
    SEL fieldSelector = NSSelectorFromString( [NSString stringWithFormat:@"property_%@", property] );
    if ( [self respondsToSelector:fieldSelector] ) {
        __autoreleasing NSString * field = nil;
        
        NSMethodSignature * signature = [self methodSignatureForSelector:fieldSelector];
        NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:signature];
        
        [invocation setTarget:self];
        [invocation setSelector:fieldSelector];
        [invocation invoke];
        [invocation getReturnValue:&field];
        
        if ( field && [field length] ) {
            NSMutableDictionary * dict = [NSMutableDictionary dictionary];
            
            NSArray * attributes = [field componentsSeparatedByString:@"____"];
            for ( NSString * attrGroup in attributes ) {
                NSArray *groupComponents = [attrGroup componentsSeparatedByString:@"=>"];
                NSString *groupName = [groupComponents objectAtIndex:0];
                NSString *groupValue = [groupComponents objectAtIndex:1];
                
                if ( groupName && groupValue ) {
                    [dict setObject:groupValue forKey:groupName];
                }
            }
            
            return dict;
        }
    }
    
    return nil;
}

- (NSDictionary *)ba_extentionForProperty:(NSString *)property {
    return [[self class] ba_extentionForProperty:property];
}

+ (NSString *)ba_extentionForProperty:(NSString *)property stringValueWithKey:(NSString *)key {
    NSDictionary * extension = [self ba_extentionForProperty:property];
    if ( nil == extension )
        return nil;
    
    return [extension objectForKey:key];
}

- (NSString *)ba_extentionForProperty:(NSString *)property stringValueWithKey:(NSString *)key {
    return [[self class] ba_extentionForProperty:property stringValueWithKey:key];
}

+ (NSArray *)ba_extentionForProperty:(NSString *)property arrayValueWithKey:(NSString *)key {
    NSDictionary * extension = [self ba_extentionForProperty:property];
    if ( nil == extension )
        return nil;
    
    NSString * value = [extension objectForKey:key];
    if ( nil == value )
        return nil;
    
    return [value componentsSeparatedByString:@"|"];
}

- (NSArray *)ba_extentionForProperty:(NSString *)property arrayValueWithKey:(NSString *)key {
    return [[self class] ba_extentionForProperty:property arrayValueWithKey:key];
}

- (BOOL)ba_hasAssociatedObjectForKey:(const char *)key {
    const char * propName = key;
    id currValue = objc_getAssociatedObject( self, propName );
    return currValue != nil;
}

- (id)ba_getAssociatedObjectForKey:(const char *)key {
    const char * propName = key;
    
    id currValue = objc_getAssociatedObject( self, propName );
    return currValue;
}

- (id)ba_copyAssociatedObject:(id)obj forKey:(const char *)key {
    const char * propName = key;
    
    id oldValue = objc_getAssociatedObject( self, propName );
    objc_setAssociatedObject( self, propName, obj, OBJC_ASSOCIATION_COPY );
    return oldValue;
}

- (id)ba_retainAssociatedObject:(id)obj forKey:(const char *)key; {
    const char * propName = key;
    id oldValue = objc_getAssociatedObject( self, propName );
    objc_setAssociatedObject( self, propName, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
    return oldValue;
}

- (id)ba_assignAssociatedObject:(id)obj forKey:(const char *)key {
    const char * propName = key;
    
    id oldValue = objc_getAssociatedObject( self, propName );
    objc_setAssociatedObject( self, propName, obj, OBJC_ASSOCIATION_ASSIGN );
    return oldValue;
}

- (void)ba_weaklyAssociateObject:(id)obj forKey:(const char *)key {
    objc_setAssociatedObject(self, key, obj, OBJC_ASSOCIATION_ASSIGN);
}

- (void)ba_removeAssociatedObjectForKey:(const char *)key {
    const char * propName = key;
    
    objc_setAssociatedObject( self, propName, nil, OBJC_ASSOCIATION_ASSIGN );
}

- (void)ba_removeAllAssociatedObjects {
    objc_removeAssociatedObjects( self );
}

@end

