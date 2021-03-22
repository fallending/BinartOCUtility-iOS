
#import <objc/runtime.h>
#import "BAProperty.h"

@implementation NSObject ( Property )

+ (const char *)mt_attributesForProperty:(NSString *)property {
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

- (const char *)mt_attributesForProperty:(NSString *)property {
    return [[self class] mt_attributesForProperty:property];
}

+ (NSDictionary *)mt_extentionForProperty:(NSString *)property {
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

- (NSDictionary *)mt_extentionForProperty:(NSString *)property {
    return [[self class] mt_extentionForProperty:property];
}

+ (NSString *)mt_extentionForProperty:(NSString *)property stringValueWithKey:(NSString *)key {
    NSDictionary * extension = [self mt_extentionForProperty:property];
    if ( nil == extension )
        return nil;
    
    return [extension objectForKey:key];
}

- (NSString *)mt_extentionForProperty:(NSString *)property stringValueWithKey:(NSString *)key {
    return [[self class] mt_extentionForProperty:property stringValueWithKey:key];
}

+ (NSArray *)mt_extentionForProperty:(NSString *)property arrayValueWithKey:(NSString *)key {
    NSDictionary * extension = [self mt_extentionForProperty:property];
    if ( nil == extension )
        return nil;
    
    NSString * value = [extension objectForKey:key];
    if ( nil == value )
        return nil;
    
    return [value componentsSeparatedByString:@"|"];
}

- (NSArray *)mt_extentionForProperty:(NSString *)property arrayValueWithKey:(NSString *)key {
    return [[self class] mt_extentionForProperty:property arrayValueWithKey:key];
}

- (BOOL)mt_hasAssociatedObjectForKey:(const char *)key {
    const char * propName = key;
    id currValue = objc_getAssociatedObject( self, propName );
    return currValue != nil;
}

- (id)mt_getAssociatedObjectForKey:(const char *)key {
    const char * propName = key;
    
    id currValue = objc_getAssociatedObject( self, propName );
    return currValue;
}

- (id)mt_copyAssociatedObject:(id)obj forKey:(const char *)key {
    const char * propName = key;
    
    id oldValue = objc_getAssociatedObject( self, propName );
    objc_setAssociatedObject( self, propName, obj, OBJC_ASSOCIATION_COPY );
    return oldValue;
}

- (id)mt_retainAssociatedObject:(id)obj forKey:(const char *)key; {
    const char * propName = key;
    id oldValue = objc_getAssociatedObject( self, propName );
    objc_setAssociatedObject( self, propName, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
    return oldValue;
}

- (id)mt_assignAssociatedObject:(id)obj forKey:(const char *)key {
    const char * propName = key;
    
    id oldValue = objc_getAssociatedObject( self, propName );
    objc_setAssociatedObject( self, propName, obj, OBJC_ASSOCIATION_ASSIGN );
    return oldValue;
}

- (void)mt_weaklyAssociateObject:(id)obj forKey:(const char *)key {
    objc_setAssociatedObject(self, key, obj, OBJC_ASSOCIATION_ASSIGN);
}

- (void)mt_removeAssociatedObjectForKey:(const char *)key {
    const char * propName = key;
    
    objc_setAssociatedObject( self, propName, nil, OBJC_ASSOCIATION_ASSIGN );
}

- (void)mt_removeAllAssociatedObjects {
    objc_removeAssociatedObjects( self );
}

@end

