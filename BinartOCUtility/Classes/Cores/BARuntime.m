#import "BARuntime.h"
#import "BAEncoding.h"

#include <execinfo.h>
#import <objc/runtime.h>

#import "_pragma_push.h"

void dumpClass(Class cls) {
    const char *className = class_getName(cls);
    
    NSLog(@"=== Class dump for %s ===", className);
    
    Class isa = object_getClass(cls);
    Class superClass = class_getSuperclass(cls);
    
    NSLog(@"  isa = %@", isa);
    NSLog(@"  superclass = %@", superClass);
    
    NSLog(@"Protocols:");
    unsigned int protocolCount = 0;
    Protocol *__unsafe_unretained* protocolList = class_copyProtocolList(cls, &protocolCount);
    for (unsigned int i = 0; i < protocolCount; i++) {
        Protocol *protocol = protocolList[i];
        const char *name = protocol_getName(protocol);
        NSLog(@"<%s>", name);
    }
    free(protocolList);
    
    NSLog(@"Instance variables:");
    unsigned int ivarCount = 0;
    Ivar *ivarList = class_copyIvarList(cls, &ivarCount);
    for (unsigned int i = 0; i < ivarCount; i++) {
        Ivar ivar = ivarList[i];
        const char *name = ivar_getName(ivar);
        ptrdiff_t offset = ivar_getOffset(ivar);
        const char *encoding = ivar_getTypeEncoding(ivar);
        NSLog(@"  %s [%ti] %s", name, offset, encoding);
    }
    free(ivarList);
    
    NSLog(@"Instance methods:");
    unsigned int instanceMethodCount = 0;
    Method *instanceMethodList = class_copyMethodList(cls, &instanceMethodCount);
    for (unsigned int i = 0; i < instanceMethodCount; i++) {
        Method method = instanceMethodList[i];
        SEL name = method_getName(method);
        const char *encoding = method_getTypeEncoding(method);
        NSLog(@"  -[%s %@] %s", className, NSStringFromSelector(name), encoding);
    }
    free(instanceMethodList);
    
    NSLog(@"Class methods:");
    unsigned int classMethodCount = 0;
    Method *classMethodList = class_copyMethodList(isa, &classMethodCount);
    for (unsigned int i = 0; i < classMethodCount; i++) {
        Method method = classMethodList[i];
        SEL name = method_getName(method);
        const char *encoding = method_getTypeEncoding(method);
        NSLog(@"  +[%s %@] %s", className, NSStringFromSelector(name), encoding);
    }
    free(classMethodList);
}

@implementation NSObject ( Runtime )

+ (Class)ba_baseClass {
    return [NSObject class];
}

- (void)ba_deepEqualsTo:(id)obj {
    Class baseClass = [[self class] ba_baseClass];
    if ( nil == baseClass ) {
        baseClass = [NSObject class];
    }
    
    for ( Class clazzType = [self class]; clazzType != baseClass; ) {
        unsigned int        propertyCount = 0;
        objc_property_t *    properties = class_copyPropertyList( clazzType, &propertyCount );
        
        for ( NSUInteger i = 0; i < propertyCount; i++ ) {
            const char *    name = property_getName(properties[i]);
            const char *    attr = property_getAttributes(properties[i]);
            
            if ( [BAEncoding isReadOnly:attr] ) {
                continue;
            }
            
            NSString * propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            NSObject * propertyValue = [(NSObject *)obj valueForKey:propertyName];
            
            [self setValue:propertyValue forKey:propertyName];
        }
        
        free( properties );
        
        clazzType = class_getSuperclass( clazzType );
        if ( nil == clazzType )
            break;
    }
}

- (void)ba_deepCopyFrom:(id)obj {
    if ( nil == obj ) {
        return;
    }
    
    Class baseClass = [[obj class] ba_baseClass];
    if ( nil == baseClass ) {
        baseClass = [NSObject class];
    }
    
    for ( Class clazzType = [obj class]; clazzType != baseClass; ) {
        unsigned int        propertyCount = 0;
        objc_property_t *    properties = class_copyPropertyList( clazzType, &propertyCount );
        
        for ( NSUInteger i = 0; i < propertyCount; i++ ) {
            const char *    name = property_getName(properties[i]);
            const char *    attr = property_getAttributes(properties[i]);
            
            if ( [BAEncoding isReadOnly:attr] ) {
                continue;
            }
            
            NSString * propertyName = [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
            NSObject * propertyValue = [(NSObject *)obj valueForKey:propertyName];
            
            [self setValue:propertyValue forKey:propertyName];
        }
        
        free( properties );
        
        clazzType = class_getSuperclass( clazzType );
        if ( nil == clazzType )
            break;
    }
}

- (id)ba_clone {
    id newObject = [[[self class] alloc] init];
    
    if ( newObject ) {
        [newObject ba_deepCopyFrom:self];
    }
    
    return newObject;
}

- (BOOL)ba_shallowCopy:(NSObject *)obj {
    Class currentClass = [self class];
    Class instanceClass = [obj class];
    
    if (self == obj) { //相同实例
        return NO;
    }
    
    if (![obj isMemberOfClass:currentClass] ) { //不是当前类的实例
        return NO;
    }
    
    while (instanceClass != [NSObject class]) {
        unsigned int propertyListCount = 0;
        objc_property_t *propertyList = class_copyPropertyList(currentClass, &propertyListCount);
        for (int i = 0; i < propertyListCount; i++) {
            objc_property_t property = propertyList[i];
            const char *property_name = property_getName(property);
            NSString *propertyName = [NSString stringWithCString:property_name encoding:NSUTF8StringEncoding];
            
            //check if property is dynamic and readwrite
            char *dynamic = property_copyAttributeValue(property, "D");
            char *readonly = property_copyAttributeValue(property, "R");
            if (propertyName && !readonly) {
                id propertyValue = [obj valueForKey:propertyName];
                [self setValue:propertyValue forKey:propertyName];
            }
            free(dynamic);
            free(readonly);
        }
        free(propertyList);
        instanceClass = class_getSuperclass(instanceClass);
    }
    
    return YES;
}

- (BOOL)ba_deepCopy:(NSObject *)obj {
    Class currentClass = [self class];
    Class instanceClass = [obj class];
    
    if (self == obj) { // 相同实例
        return NO;
    }
    
    if (![obj isMemberOfClass:currentClass] ) { // 不是当前类的实例
        return NO;
    }
    
    while (instanceClass != [NSObject class]) {
        unsigned int propertyListCount = 0;
        objc_property_t *propertyList = class_copyPropertyList(currentClass, &propertyListCount);
        for (int i = 0; i < propertyListCount; i++) {
            objc_property_t property = propertyList[i];
            const char *property_name = property_getName(property);
            NSString *propertyName = [NSString stringWithCString:property_name encoding:NSUTF8StringEncoding];
            
            //check if property is dynamic and readwrite
            char *dynamic = property_copyAttributeValue(property, "D");
            char *readonly = property_copyAttributeValue(property, "R");
            if (propertyName && !readonly) {
                id propertyValue = [obj valueForKey:propertyName];
                Class propertyValueClass = [propertyValue class];
                BOOL flag = [NSObject ba_isNSObjectClass:propertyValueClass];
                if (flag) {
                    if ([propertyValue conformsToProtocol:@protocol(NSCopying)]) {
                        NSObject *copyValue = [propertyValue copy];
                        [self setValue:copyValue forKey:propertyName];
                    }else{
                        NSObject *copyValue = [[[propertyValue class]alloc]init];
                        [obj ba_deepCopy:propertyValue];
                        [self setValue:copyValue forKey:propertyName];
                    }
                }else{
                    [self setValue:propertyValue forKey:propertyName];
                }
            }
            free(dynamic);
            free(readonly);
        }
        free(propertyList);
        instanceClass = class_getSuperclass(instanceClass);
    }
    
    return YES;
}

- (id)ba_deepCopy {
    id obj = nil;
    @try {
        obj = [NSKeyedUnarchiver unarchiveObjectWithData:[NSKeyedArchiver archivedDataWithRootObject:self]];
    }
    
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    return obj;
}

+ (BOOL)ba_isNullValue:(id)value {
    return ((NSNull *)value == [NSNull null] ||
            [@"<null>" isEqualToString:(NSString *)value] ||
            [@"(null)" isEqualToString:(NSString *)value] ||
            [@"null" isEqualToString:(NSString *)value] ||
            value == nil);
}

- (id)ba_getObjectInternal:(id)obj {
    if([obj isKindOfClass:[NSString class]]
       || [obj isKindOfClass:[NSNumber class]]
       || [obj isKindOfClass:[NSNull class]]) {
        return obj;
    }
    
    if([obj isKindOfClass:[NSArray class]]) {
        NSArray *objarr = obj;
        NSMutableArray *arr = [NSMutableArray arrayWithCapacity:objarr.count];
        
        for(int i = 0; i < objarr.count; i++) {
            [arr setObject:[self ba_getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        
        return arr;
    }
    
    if([obj isKindOfClass:[NSDictionary class]]) {
        NSDictionary *objdic = obj;
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        
        for(NSString *key in objdic.allKeys) {
            [dic setObject:[self ba_getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }
        
        return dic;
    }
    
    return [self ba_getObjectData:obj];
}

- (NSDictionary*)ba_getObjectData:(NSObject *)obj {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    unsigned int propsCount;
    objc_property_t *props = class_copyPropertyList([obj class], &propsCount);
    
    for(int i = 0; i < propsCount; i++) {
        objc_property_t prop = props[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(prop)];
        id value = [obj valueForKey:propName];
        if(value == nil) {
            value = [NSNull null];
        } else {
            value = [self ba_getObjectInternal:value];
            
        }
        
        [dic setObject:value forKey:propName];
    }
    
    return dic;
}

+ (NSArray *)ba_loadedClassNames {
    static dispatch_once_t		once;
    static NSMutableArray *		classNames;
    
    dispatch_once( &once, ^ {
                      classNames = [[NSMutableArray alloc] init];
                      
                      unsigned int 	classesCount = 0;
                      Class *		classes = objc_copyClassList( &classesCount );
                      
                      for ( unsigned int i = 0; i < classesCount; ++i ) {
                          Class classType = classes[i];
                          
                          if ( class_isMetaClass( classType ) )
                              continue;
                          
                          Class superClass = class_getSuperclass( classType );
                          
                          if ( nil == superClass )
                              continue;
                          
                          [classNames addObject:[NSString stringWithUTF8String:class_getName(classType)]];
                      }
                      
                      [classNames sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                          return [obj1 compare:obj2];
                      }];
                      
                      free( classes );
                  });
    
    return classNames;
}

+ (__unsafe_unretained Class *)ba_loadedClasses {
    int numClasses;
    Class *classes = NULL;
    
    numClasses = objc_getClassList(NULL,0);
    
    if (numClasses > 0) {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        
        numClasses = objc_getClassList(classes, numClasses);
    }
    
    return classes;
}

+ (void)ba_enumerateloadedClassesUsingBlock:(void (^)(__unsafe_unretained Class))block {
    for ( NSString * className in [self ba_loadedClassNames] ) {
        Class classType = NSClassFromString( className );
        
        if (block) block(classType);
    }
}

+ (NSArray *)ba_subClasses {
    NSMutableArray * results = [[NSMutableArray alloc] init];
    
    for ( NSString * className in [self ba_loadedClassNames] ) {
        Class classType = NSClassFromString( className );
        if ( classType == self ) {
            continue;
        }
        
        // bugfix: but not know why
//        if ( NO == [classType isSubclassOfClass:self] )
//            conti
    
        if (class_getSuperclass(classType) != self) {
            continue;
        }
        
        [results addObject:[classType description]];
    }
    
    return results;
}

+ (NSArray *)ba_methods {
    return [self ba_methodsUntilClass:[self superclass]];
}

+ (NSArray *)ba_methodsUntilClass:(Class)baseClass {
    NSMutableArray * methodNames = [[NSMutableArray alloc] init];
    
    Class thisClass = self;
    
    baseClass = baseClass ?: [NSObject class];
    
    while ( NULL != thisClass ) {
        unsigned int	methodCount = 0;
        Method *		methodList = class_copyMethodList( thisClass, &methodCount );
        
        for ( unsigned int i = 0; i < methodCount; ++i ) {
            SEL selector = method_getName( methodList[i] );
            if ( selector ) {
                const char * cstrName = sel_getName(selector);
                if ( NULL == cstrName )
                    continue;
                
                NSString * selectorName = [NSString stringWithUTF8String:cstrName];
                if ( NULL == selectorName )
                    continue;
                
                [methodNames addObject:selectorName];
            }
        }
        
        free( methodList );
        
        thisClass = class_getSuperclass( thisClass );
        
        if ( nil == thisClass || baseClass == thisClass ) {
            break;
        }
    }
    
    return methodNames;
}

+ (NSArray *)ba_methodsWithPrefix:(NSString *)prefix {
    return [self ba_methodsWithPrefix:prefix untilClass:[self superclass]];
}

+ (NSArray *)ba_methodsWithPrefix:(NSString *)prefix untilClass:(Class)baseClass {
    NSArray * methods = [self ba_methodsUntilClass:baseClass];
    
    if ( nil == methods || 0 == methods.count ) {
        return nil;
    }
    
    if ( nil == prefix ) {
        return methods;
    }
    
    NSMutableArray * result = [[NSMutableArray alloc] init];
    
    for ( NSString * selectorName in methods ) {
        if ( NO == [selectorName hasPrefix:prefix] ) {
            continue;
        }
        
        [result addObject:selectorName];
    }
    
    [result sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    return result;
}

+ (NSArray *)ba_properties {
    return [self ba_propertiesUntilClass:[self superclass]];
}

+ (NSArray *)ba_propertiesUntilClass:(Class)baseClass {
    NSMutableArray * propertyNames = [[NSMutableArray alloc] init];
    
    Class thisClass = self;
    
    baseClass = baseClass ?: [NSObject class];
    
    while ( NULL != thisClass ) {
        unsigned int		propertyCount = 0;
        objc_property_t *	propertyList = class_copyPropertyList( thisClass, &propertyCount );
        
        for ( unsigned int i = 0; i < propertyCount; ++i ) {
            const char * cstrName = property_getName( propertyList[i] );
            if ( NULL == cstrName )
                continue;
            
            NSString * propName = [NSString stringWithUTF8String:cstrName];
            if ( NULL == propName )
                continue;
            
            [propertyNames addObject:propName];
        }
        
        free( propertyList );
        
        thisClass = class_getSuperclass( thisClass );
        
        if ( nil == thisClass || baseClass == thisClass ) {
            break;
        }
    }
    
    return propertyNames;
}

+ (NSArray *)ba_propertiesWithPrefix:(NSString *)prefix {
    return [self ba_propertiesWithPrefix:prefix untilClass:[self superclass]];
}

+ (NSArray *)ba_propertiesWithPrefix:(NSString *)prefix untilClass:(Class)baseClass {
    NSArray * properties = [self ba_propertiesUntilClass:baseClass];
    
    if ( nil == properties || 0 == properties.count ) {
        return nil;
    }
    
    if ( nil == prefix ) {
        return properties;
    }
    
    NSMutableArray * result = [[NSMutableArray alloc] init];
    
    for ( NSString * propName in properties ) {
        if ( NO == [propName hasPrefix:prefix] ) {
            continue;
        }
        
        [result addObject:propName];
    }
    
    [result sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2];
    }];
    
    return result;
}

- (NSDictionary *)ba_propertyDictionary {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    unsigned int outCount;
    objc_property_t *props = class_copyPropertyList([self class], &outCount);
    for(int i=0;i<outCount;i++){
        objc_property_t prop = props[i];
        NSString *propName = [[NSString alloc]initWithCString:property_getName(prop) encoding:NSUTF8StringEncoding];
        id propValue = [self valueForKey:propName];
        [dict setObject:propValue?:[NSNull null] forKey:propName];
    }
    free(props);
    
    return dict;
}

+ (NSArray *)ba_classesWithProtocolName:(NSString *)protocolName {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    Protocol * protocol = NSProtocolFromString(protocolName);
    for ( NSString *className in [self ba_loadedClassNames] ) {
        Class classType = NSClassFromString( className );
        if ( classType == self )
            continue;
        
        if ( NO == [classType conformsToProtocol:protocol] )
            continue;
        
        [results addObject:[classType description]];
    }
    
    return results;
}

// MARK: -

- (BOOL)ba_respondsToSelector:(SEL)selector untilClass:(Class)stopClass {
    return [self.class ba_instancesRespondToSelector:selector untilClass:stopClass];
}

- (BOOL)ba_superRespondsToSelector:(SEL)selector {
    return [self.superclass instancesRespondToSelector:selector];
}

- (BOOL)ba_superRespondsToSelector:(SEL)selector untilClass:(Class)stopClass {
    return [self.superclass ba_instancesRespondToSelector:selector untilClass:stopClass];
}

+ (BOOL)ba_instancesRespondToSelector:(SEL)selector untilClass:(Class)stopClass {
    BOOL __block (^ __weak block_self)(Class klass, SEL selector, Class stopClass);
    BOOL (^block)(Class klass, SEL selector, Class stopClass) = [^
                                                                 (Class klass, SEL selector, Class stopClass)
                                                                 {
                                                                     if (!klass || klass == stopClass)
                                                                         return NO;
                                                                     
                                                                     unsigned methodCount = 0;
                                                                     Method *methodList = class_copyMethodList(klass, &methodCount);
                                                                     
                                                                     if (methodList)
                                                                         for (unsigned i = 0; i < methodCount; ++i)
                                                                             if (method_getName(methodList[i]) == selector)
                                                                                 return YES;
                                                                     
                                                                     return block_self(klass.superclass, selector, stopClass);
                                                                 } copy];
    
    block_self = block;
    
    return block(self.class, selector, stopClass);
}

+ (id)ba_touchSelector:(SEL)selector {
    id obj = nil;
    if([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        obj = [self performSelector:selector];
#pragma clang diagnostic pop
    }
    return obj;
}

- (id)ba_touchSelector:(SEL)selector {
    id obj = nil;
    if([self respondsToSelector:selector]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        obj = [self performSelector:selector];
#pragma clang diagnostic pop
    }
    return obj;
}

- (NSArray *)ba_propertyKeys {
    return [[self class] ba_propertyKeys];
}

+ (NSArray *)ba_propertyKeys {
    unsigned int propertyCount = 0;
    objc_property_t * properties = class_copyPropertyList(self, &propertyCount);
    NSMutableArray * propertyNames = [NSMutableArray array];
    for (unsigned int i = 0; i < propertyCount; ++i) {
        objc_property_t property = properties[i];
        const char * name = property_getName(property);
        [propertyNames addObject:[NSString stringWithUTF8String:name]];
    }
    free(properties);
    return propertyNames;
}

- (NSArray *)ba_propertiesInfo {
    return [[self class] ba_propertiesInfo];
}

+ (NSArray *)ba_propertiesInfo {
    NSMutableArray *propertieArray = [NSMutableArray array];
    
    unsigned int propertyCount;
    objc_property_t *properties = class_copyPropertyList([self class], &propertyCount);
    
    for (int i = 0; i < propertyCount; i++) {
        [propertieArray addObject:({
            
            NSDictionary *dictionary = [self ba_dictionaryWithProperty:properties[i]];
            
            dictionary;
        })];
    }
    
    free(properties);
    
    return propertieArray;
}

+ (NSArray *)ba_propertiesWithCodeFormat {
    NSMutableArray *array = [NSMutableArray array];
    
    NSArray *properties = [[self class] ba_propertiesInfo];
    
    for (NSDictionary *item in properties) {
        NSMutableString *format = ({
            
            NSMutableString *formatString = [NSMutableString stringWithFormat:@"@property "];
            //attribute
            NSArray *attribute = [item objectForKey:@"attribute"];
            attribute = [attribute sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                return [obj1 compare:obj2 options:NSNumericSearch];
            }];
            
            if (attribute && attribute.count > 0) {
                NSString *attributeStr = [NSString stringWithFormat:@"(%@)",[attribute componentsJoinedByString:@", "]];
                
                [formatString appendString:attributeStr];
            }
            
            //type
            NSString *type = [item objectForKey:@"type"];
            if (type) {
                [formatString appendString:@" "];
                [formatString appendString:type];
            }
            
            //name
            NSString *name = [item objectForKey:@"name"];
            if (name) {
                [formatString appendString:@" "];
                [formatString appendString:name];
                [formatString appendString:@";"];
            }
            
            formatString;
        });
        
        [array addObject:format];
    }
    
    return array;
}

/**
 * 相关数据结构：Method, IMP, SEL, NSMethodSignature
 */
+ (NSArray *)ba_methodsInfo {
    u_int               count;
    NSMutableArray *methodList = [NSMutableArray array];
    Method *methods = class_copyMethodList([self class], &count);
    for (int i = 0; i < count ; i++) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        
        Method method = methods[i];
        
        IMP imp = method_getImplementation(method); // 方法实现
        SEL name = method_getName(method); // 方法名
        const char *nameAddr = (void *)name;
        int argumentsCount = method_getNumberOfArguments(method); // 方法参数个数
        const char *encoding = method_getTypeEncoding(method); // 方法入参描述
        const char *returnType = method_copyReturnType(method); // 方法出参描述

        NSMutableArray *arguments = [NSMutableArray array];
        for (int index=0; index<argumentsCount; index++) {
            char *arg = method_copyArgumentType(method,index);
            NSString *argString = [NSString stringWithCString:arg encoding:NSUTF8StringEncoding];
            [arguments addObject:[[self class] ba_decodeType:arg]];
        }
        
        NSString *returnTypeString =[[self class] ba_decodeType:returnType];
        NSString *encodeString = [[self class] ba_decodeType:encoding];
        NSString *nameString = [NSString  stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        
        [info setObject:arguments forKey:@"arguments"];
        [info setObject:[NSString stringWithFormat:@"%d",argumentsCount] forKey:@"argumentsCount"];
        [info setObject:returnTypeString forKey:@"returnType"];
        [info setObject:encodeString forKey:@"encode"];
        [info setObject:nameString forKey:@"name"];
        [info setObject:@((int64_t)nameAddr) forKey:@"nameAddr"];
//        [info setObject:imp forKey:@"imp"];
        [methodList addObject:info];
    }
    free(methods);
    
    return methodList;
}

- (NSDictionary *)ba_protocols {
    return [[self class] ba_protocols];
}

+ (NSDictionary *)ba_protocols {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
    unsigned int count;
    Protocol * __unsafe_unretained * protocols = class_copyProtocolList([self class], &count);
    for (int i = 0; i < count; i++) {
        Protocol *protocol = protocols[i];
        
        NSString *protocolName = [NSString stringWithCString:protocol_getName(protocol) encoding:NSUTF8StringEncoding];
        
        NSMutableArray *superProtocolArray = ({
            
            NSMutableArray *array = [NSMutableArray array];
            
            unsigned int superProtocolCount;
            Protocol * __unsafe_unretained * superProtocols = protocol_copyProtocolList(protocol, &superProtocolCount);
            for (int ii = 0; ii < superProtocolCount; ii++) {
                Protocol *superProtocol = superProtocols[ii];
                
                NSString *superProtocolName = [NSString stringWithCString:protocol_getName(superProtocol) encoding:NSUTF8StringEncoding];
                
                [array addObject:superProtocolName];
            }
            free(superProtocols);
            
            array;
        });
        
        [dictionary setObject:superProtocolArray forKey:protocolName];
    }
    free(protocols);
    
    return dictionary;
}

+ (NSArray *)ba_instanceVariable {
    unsigned int outCount;
    Ivar *ivars = class_copyIvarList([self class], &outCount);
    NSMutableArray *result = [NSMutableArray array];
    for (int i = 0; i < outCount; i++) {
        NSString *type = [[self class] ba_decodeType:ivar_getTypeEncoding(ivars[i])];
        NSString *name = [NSString stringWithCString:ivar_getName(ivars[i]) encoding:NSUTF8StringEncoding];
        NSString *ivarDescription = [NSString stringWithFormat:@"%@ %@", type, name];
        [result addObject:ivarDescription];
    }
    free(ivars);
    return result.count ? [result copy] : nil;
}

- (BOOL)ba_hasPropertyForKey:(NSString *)key {
    objc_property_t property = class_getProperty([self class], [key UTF8String]);
    return (BOOL)property;
}

- (BOOL)ba_hasIvarForKey:(NSString *)key {
    Ivar ivar = class_getInstanceVariable([self class], [key UTF8String]);
    return (BOOL)ivar;
}

#pragma mark -- help

+ (NSDictionary *)ba_dictionaryWithProperty:(objc_property_t)property {
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    //name
    NSString *propertyName = __propertyName(property);
    [result setObject:propertyName forKey:@"name"];
    
    //attribute
    NSMutableDictionary *attributeDictionary = ({
        
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        
        unsigned int attributeCount;
        objc_property_attribute_t *attrs = property_copyAttributeList(property, &attributeCount);
        
        for (int i = 0; i < attributeCount; i++) {
            NSString *name = [NSString stringWithCString:attrs[i].name encoding:NSUTF8StringEncoding];
            NSString *value = [NSString stringWithCString:attrs[i].value encoding:NSUTF8StringEncoding];
            [dictionary setObject:value forKey:name];
        }
        
        free(attrs);
        
        dictionary;
    });
    
    NSMutableArray *attributeArray = [NSMutableArray array];
    
    /***
     https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
     
     R           | The property is read-only (readonly).
     C           | The property is a copy of the value last assigned (copy).
     &           | The property is a reference to the value last assigned (retain).
     N           | The property is non-atomic (nonatomic).
     G<name>     | The property defines a custom getter selector name. The name follows the G (for example, GcustomGetter,).
     S<name>     | The property defines a custom setter selector name. The name follows the S (for example, ScustomSetter:,).
     D           | The property is dynamic (@dynamic).
     W           | The property is a weak reference (__weak).
     P           | The property is eligible for garbage collection.
     t<encoding> | Specifies the type using old-style encoding.
     */
    
    //R
    if ([attributeDictionary objectForKey:@"R"]) {
        [attributeArray addObject:@"readonly"];
    }
    
    //C
    if ([attributeDictionary objectForKey:@"C"]) {
        [attributeArray addObject:@"copy"];
    }
    
    //&
    if ([attributeDictionary objectForKey:@"&"]) {
        [attributeArray addObject:@"strong"];
    }
    
    //N
    if ([attributeDictionary objectForKey:@"N"]) {
        [attributeArray addObject:@"nonatomic"];
    } else {
        [attributeArray addObject:@"atomic"];
    }
    
    //G<name>
    if ([attributeDictionary objectForKey:@"G"]) {
        [attributeArray addObject:[NSString stringWithFormat:@"getter=%@", [attributeDictionary objectForKey:@"G"]]];
    }
    
    //S<name>
    if ([attributeDictionary objectForKey:@"S"]) {
        [attributeArray addObject:[NSString stringWithFormat:@"setter=%@", [attributeDictionary objectForKey:@"G"]]];
    }
    
    //D
    if ([attributeDictionary objectForKey:@"D"]) {
        [result setObject:[NSNumber numberWithBool:YES] forKey:@"isDynamic"];
    } else {
        [result setObject:[NSNumber numberWithBool:NO] forKey:@"isDynamic"];
    }
    
    //W
    if ([attributeDictionary objectForKey:@"W"]) {
        [attributeArray addObject:@"weak"];
    }
    
    //P
    if ([attributeDictionary objectForKey:@"P"]) {
        //TODO:P | The property is eligible for garbage collection.
    }
    
    //T
    if ([attributeDictionary objectForKey:@"T"]) {
        /*
         https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html
         c               A char
         i               An int
         s               A short
         l               A long l is treated as a 32-bit quantity on 64-bit programs.
         q               A long long
         C               An unsigned char
         I               An unsigned int
         S               An unsigned short
         L               An unsigned long
         Q               An unsigned long long
         f               A float
         d               A double
         B               A C++ bool or a C99 _Bool
         v               A void
         *               A character string (char *)
         @               An object (whether statically typed or typed id)
         #               A class object (Class)
         :               A method selector (SEL)
         [array type]    An array
         {name=type...}  A structure
         (name=type...)  A union
         bnum            A bit field of num bits
         ^type           A pointer to type
         ?               An unknown type (among other things, this code is used for function pointers)
         
         */
        
        NSDictionary *typeDic = @{@"c":@"char",
                                  @"i":@"int",
                                  @"s":@"short",
                                  @"l":@"long",
                                  @"q":@"long long",
                                  @"C":@"unsigned char",
                                  @"I":@"unsigned int",
                                  @"S":@"unsigned short",
                                  @"L":@"unsigned long",
                                  @"Q":@"unsigned long long",
                                  @"f":@"float",
                                  @"d":@"double",
                                  @"B":@"BOOL",
                                  @"v":@"void",
                                  @"*":@"char *",
                                  @"@":@"id",
                                  @"#":@"Class",
                                  @":":@"SEL",
                                  };
        //TODO:An array
        NSString *key = [attributeDictionary objectForKey:@"T"];
        
        id type_str = [typeDic objectForKey:key];
        
        if (type_str == nil) {
            if ([[key substringToIndex:1] isEqualToString:@"@"] && [key rangeOfString:@"?"].location == NSNotFound) {
                type_str = [[key substringWithRange:NSMakeRange(2, key.length - 3)] stringByAppendingString:@"*"];
            } else if ([[key substringToIndex:1] isEqualToString:@"^"]) {
                id str = [typeDic objectForKey:[key substringFromIndex:1]];
                
                if (str) {
                    type_str = [NSString stringWithFormat:@"%@ *",str];
                }
            } else {
                type_str = @"unknow";
            }
        }
        
        [result setObject:type_str forKey:@"type"];
    }
    
    [result setObject:attributeArray forKey:@"attribute"];
    
    return result;
}

+ (NSString *)ba_decodeType:(const char *)cString {
    if (!strcmp(cString, @encode(char)))
        return @"char";
    if (!strcmp(cString, @encode(int)))
        return @"int";
    if (!strcmp(cString, @encode(short)))
        return @"short";
    if (!strcmp(cString, @encode(long)))
        return @"long";
    if (!strcmp(cString, @encode(long long)))
        return @"long long";
    if (!strcmp(cString, @encode(unsigned char)))
        return @"unsigned char";
    if (!strcmp(cString, @encode(unsigned int)))
        return @"unsigned int";
    if (!strcmp(cString, @encode(unsigned short)))
        return @"unsigned short";
    if (!strcmp(cString, @encode(unsigned long)))
        return @"unsigned long";
    if (!strcmp(cString, @encode(unsigned long long)))
        return @"unsigned long long";
    if (!strcmp(cString, @encode(float)))
        return @"float";
    if (!strcmp(cString, @encode(double)))
        return @"double";
    if (!strcmp(cString, @encode(bool)))
        return @"bool";
    if (!strcmp(cString, @encode(_Bool)))
        return @"_Bool";
    if (!strcmp(cString, @encode(void)))
        return @"void";
    if (!strcmp(cString, @encode(char *)))
        return @"char *";
    if (!strcmp(cString, @encode(id)))
        return @"id";
    if (!strcmp(cString, @encode(Class)))
        return @"class";
    if (!strcmp(cString, @encode(SEL)))
        return @"SEL";
    if (!strcmp(cString, @encode(BOOL)))
        return @"BOOL";
    
    //    NSDictionary *typeDic = @{@"c":@"char",
    //                              @"i":@"int",
    //                              @"s":@"short",
    //                              @"l":@"long",
    //                              @"q":@"long long",
    //                              @"C":@"unsigned char",
    //                              @"I":@"unsigned int",
    //                              @"S":@"unsigned short",
    //                              @"L":@"unsigned long",
    //                              @"Q":@"unsigned long long",
    //                              @"f":@"float",
    //                              @"d":@"double",
    //                              @"B":@"BOOL",
    //                              @"v":@"void",
    //                              @"*":@"char *",
    //                              @"@":@"id",
    //                              @"#":@"Class",
    //                              @":":@"SEL",
    //                              };
    
    //@TODO: do handle bitmasks
    NSString *result = [NSString stringWithCString:cString encoding:NSUTF8StringEncoding];
    //    if ([typeDic objectForKey:result]) {
    //        return [typeDic objectForKey:result];
    //    }
    if ([[result substringToIndex:1] isEqualToString:@"@"] && [result rangeOfString:@"?"].location == NSNotFound) {
        result = [[result substringWithRange:NSMakeRange(2, result.length - 3)] stringByAppendingString:@"*"];
    } else {
        if ([[result substringToIndex:1] isEqualToString:@"^"]) {
            result = [NSString stringWithFormat:@"%@ *",
                      [NSString ba_decodeType:[[result substringFromIndex:1] cStringUsingEncoding:NSUTF8StringEncoding]]];
        }
    }
    return result;
}

- (NSArray *)ba_conformedProtocols {
    unsigned int outCount = 0;
    Class obj_class = [self class];
    __unsafe_unretained Protocol **protocols = class_copyProtocolList(obj_class, &outCount);
    
    NSMutableArray *protocol_array = nil;
    if (outCount > 0) {
        protocol_array = [[NSMutableArray alloc] initWithCapacity:outCount];
        
        for (NSInteger i = 0; i < outCount; i++) {
            NSString *protocol_name_string;
            const char *protocol_name = protocol_getName(protocols[i]);
            protocol_name_string = [[NSString alloc] initWithCString:protocol_name
                                                            encoding:NSUTF8StringEncoding];
            [protocol_array addObject:protocol_name_string];
        }
    }
    
    return protocol_array;
}

- (NSArray *)ba_allIvars {
    unsigned int count = 0;
    Ivar *ivar_ptr = NULL;
    ivar_ptr = class_copyIvarList([self class], &count);
    
    if ( !ivar_ptr ) {
        return [NSArray array];
    }
    
    NSMutableArray *all = [[NSMutableArray alloc] initWithCapacity:count];
    for (NSInteger i = 0; i < count; i++) {
        @autoreleasepool {
            NSString *ivar = __ivarName(ivar_ptr[i]);
            [all addObject:ivar];
        }
    }
    free(ivar_ptr);
    return all;
}

- (NSArray *)ba_parents {
    Class selfClass = object_getClass(self);
    NSMutableArray *all = [[NSMutableArray alloc] initWithCapacity:0];
    
    Class aClass = class_getSuperclass(selfClass);
    while (aClass != nil) {
        @autoreleasepool {
            [all addObject: NSStringFromClass(aClass) ];
            aClass = class_getSuperclass(aClass);
        }
    }
    return all;
}

- (NSString *)ba_className {
    return NSStringFromClass(object_getClass(self));
}

+ (NSString *)ba_className {
    return NSStringFromClass([self class]);
}

- (NSString *)ba_superClassName {
    return NSStringFromClass([self superclass]);
}

+ (NSString *)ba_superClassName {
    return NSStringFromClass([self superclass]);
}

+ (BOOL)ba_isNSObjectClass:(Class)clazz {
    BOOL flag = class_conformsToProtocol(clazz, @protocol(NSObject));
    if (flag) {
        return flag;
    } else {
        Class superClass = class_getSuperclass(clazz);
        if (!superClass) {
            return NO;
        } else {
            return  [NSObject ba_isNSObjectClass:superClass];
        }
    }
}

// MARK: - Inline method

/*! 以 NSString 类型返回 property名称 */
static inline NSString *__propertyName(objc_property_t property) {
    const char *name = property_getName(property);
    return [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
}

/*! 以 NSString 类型返回 ivar 名称 */
static inline NSString *__ivarName(Ivar ivar) {
    const char *name = ivar_getName(ivar);
    return [NSString stringWithCString:name encoding:NSUTF8StringEncoding];
}

/*! 以 NSString 类型返回 method 名称 */
static inline NSString *__methodName(Method m) {
    return NSStringFromSelector(method_getName(m));
}

@end

#import <objc/runtime.h>
#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <QuartzCore/QuartzCore.h>

struct Block_literal_1 {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 {
        unsigned long int reserved;     // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        // void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        // void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        // const char *signature;                         // IFF (1<<30)
        void* rest[1];
    } *descriptor;
    // imported variables
};

enum {
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25),
    BLOCK_HAS_CTOR =          (1 << 26), // helpers have C++ code
    BLOCK_IS_GLOBAL =         (1 << 28),
    BLOCK_HAS_STRET =         (1 << 29), // IFF BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE =     (1 << 30),
};

static const char *__BlockSignature__(id blockObj) {
    struct Block_literal_1 *block = (__bridge void *)blockObj;
    struct Block_descriptor_1 *descriptor = block->descriptor;
    assert(block->flags & BLOCK_HAS_SIGNATURE);
    int offset = 0;
    if(block->flags & BLOCK_HAS_COPY_DISPOSE)
    offset += 2;
    return (char*)(descriptor->rest[offset]);
}

@interface _InvocationGrabber : NSProxy
    
+ (_InvocationGrabber *)grabberWithTarget:(id)target;
    
    @property (nonatomic, strong) id target;
    @property (nonatomic, strong) NSInvocation *invocation;
    
    @end

@implementation _InvocationGrabber
    
+ (_InvocationGrabber *)grabberWithTarget:(id)target {
    _InvocationGrabber *instance = [_InvocationGrabber alloc];
    instance.target = target;
    return instance;
}
    
- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector {
    return [self.target methodSignatureForSelector:selector];
}
    
- (void)forwardInvocation:(NSInvocation*)invocation {
    [invocation setTarget:self.target];
    NSParameterAssert(self.invocation == nil);
    self.invocation = invocation;
}
    
@end


@implementation NSInvocation ( Extension )

+ (NSString*)encodeType:(char *)encodedType {
    return [NSString stringWithUTF8String:encodedType];
}

+ (NSArray *)getClassNamesMatchingPattern:(NSString *)matchingPattern {
    NSArray *allClasses = [NSInvocation getClassList];
    if ( nil == allClasses || allClasses.count == 0 ) {
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like %@",matchingPattern];
    NSArray *filtered = [allClasses filteredArrayUsingPredicate:predicate];
    
    return filtered;
}

+ (NSArray *)getClassList {
    unsigned int count;
    objc_copyClassList(&count);
    Class *buffer = (Class *)malloc(sizeof(Class)*count);
    objc_getClassList(buffer, count);
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int i = 0; i < count; i++) {
        Class aClass = buffer[i];
        NSString *className = NSStringFromClass(aClass);
        [temp addObject:className];
    }
    if ( count > 0 ) {
        free(buffer);
    }
    return [NSArray arrayWithArray:temp];
}

+ (NSArray *)getMethodListForClass:(NSString *)className {
    Class class = NSClassFromString(className);
    unsigned int count = 0;
    class_copyMethodList(class, &count);
    if ( count == 0 ) {
        return nil;
    }
    
    Method *methods = (Method *)malloc(sizeof(Method)*count);
    unsigned int copiedCount = 0;
    methods = class_copyMethodList(class, &copiedCount);
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:copiedCount];
    for (unsigned int i = 0; i<copiedCount; i++) {
        Method aMethod = methods[i];
        SEL aSelector = method_getName(aMethod);
        NSString *selectorName = NSStringFromSelector(aSelector);
        [temp addObject:selectorName];
    }
    
    if ( temp.count == 0 ) {
        return nil;
    }
    
    return [temp sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

+ (NSArray *)getMethodListForClass:(NSString *)className matchingPattern:(NSString *)matchingPattern {
    NSArray *methodList = [NSInvocation getMethodListForClass:className];
    
    if ( nil == methodList || methodList.count == 0 ) {
        return nil;
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF like[cd] %@",matchingPattern];
    NSArray *filtered = [methodList filteredArrayUsingPredicate:predicate];
    
    return filtered;
}

+ (Class)lookupClass:(NSString *)className {
    NSArray *classList = [NSInvocation getClassList];
    
    if ( [classList containsObject:className] == NO ) {
        NSString *match = [NSString stringWithFormat:@"%@*",className];
        NSArray *classes = [NSInvocation getClassNamesMatchingPattern:match];
        if ( nil == classes || classes.count == 0 ) {
            return nil;
        }
        
        className = classes.firstObject;
    }
    
    return NSClassFromString(className);
}

+ (SEL)lookupSelector:(NSString *)selectorName forClass:(Class)class {
    NSString *match = [NSString stringWithFormat:@"%@",selectorName];
    NSArray *methodList = [NSInvocation getMethodListForClass:NSStringFromClass(class) matchingPattern:match];
    NSUInteger count = methodList.count;
    
    if ( nil != methodList && count > 0 ) {
        return NSSelectorFromString(methodList.firstObject);
    }else{
        Class superclass = class_getSuperclass(class);
        if ( superclass != 0 ) {
            return [NSInvocation lookupSelector:selectorName forClass:superclass];
        }else{
            return NSSelectorFromString(selectorName);
        }
    }
}

+ (id)doInstanceMethodTarget:(id)target selectorName:(NSString *)selectorName args:(NSArray *)args {
    if ( nil == target || nil == selectorName ) {
        return nil;
    }
    
    Class c = [target class];
    SEL theSelector = [NSInvocation lookupSelector:selectorName forClass:c];
    
    if ( NULL == theSelector || NULL == c ) {
        return nil;
    }
    
    if ( [c instancesRespondToSelector:theSelector] == NO ) {
        return nil;
    }
    
    NSMethodSignature *methodSig = [c instanceMethodSignatureForSelector:theSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    invocation.target = target;
    invocation.selector = theSelector;
    [invocation setArgumentsWithArray:args];
    
    [invocation invoke];
    id result = [invocation getEncodedReturnValue];
    return result;
}

+ (id)doClassMethod:(NSString *)className
       selectorName:(NSString *)selectorName
               args:(NSArray *)args {
    if ( nil == className || nil == selectorName ) {
        return nil;
    }
    
    Class c = [NSInvocation lookupClass:className];
    SEL theSelector = [NSInvocation lookupSelector:selectorName forClass:c];
    
    if ( NULL == theSelector || NULL == c ) {
        return nil;
    }
    
    NSMethodSignature *methodSig = [c methodSignatureForSelector:theSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSig];
    invocation.target = c;
    invocation.selector = theSelector;
    
    [invocation setArgumentsWithArray:args];
    
    [invocation invoke];
    id result = [invocation getEncodedReturnValue];
    return result;
}

- (void)setArgumentsWithArray:(NSArray *)array {
    if (nil != array && array.count > 0) {
        NSUInteger numargs = [self.methodSignature numberOfArguments] - 2;
        if (array.count != numargs) {
            id arg = [self getArgAtIndex:0 fromArray:array];
            [self setArgumentWithObject:arg atIndex:0];
        }else{
            for (NSUInteger i = 0; i < numargs; i++) {
                [self setArgumentWithObject:array[i] atIndex:i];
            }
        }
    }
}

- (void)setArgumentWithObject:(id)object atIndex:(NSUInteger)index {
    NSInteger argIdx = 2+index;
    NSString *type = [NSString stringWithUTF8String:[self.methodSignature getArgumentTypeAtIndex:argIdx]];
    id arg = object;
    if ([type isEqualToString:[NSInvocation encodeType:@encode(id)]]){
        id myArg = arg;
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(CGRect)]]){
        CGRect myArg = [arg CGRectValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(CGSize)]]){
        CGSize myArg = [arg CGSizeValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(CGPoint)]]){
        CGPoint myArg = [arg CGPointValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(CGAffineTransform)]]){
        CGAffineTransform myArg = [arg CGAffineTransformValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(NSInteger)]]){
        NSInteger myArg = [arg integerValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(NSUInteger)]]){
        NSUInteger myArg = [arg unsignedIntegerValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(long)]]){
        long myArg = [arg longValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(unsigned)]]){
        unsigned myArg = [arg unsignedIntValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(long long)]]){
        long long myArg = [arg longLongValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(int)]]){
        int myArg = [arg intValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(CGFloat)]]){
        CGFloat myArg = [arg doubleValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(float)]]){
        float myArg = [arg floatValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(double)]]){
        double myArg = [arg doubleValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(BOOL)]]){
        BOOL myArg = [arg boolValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(CLLocationCoordinate2D)]]){
        CLLocationCoordinate2D myArg = [arg MKCoordinateValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(MKCoordinateSpan)]]){
        MKCoordinateSpan myArg = [arg MKCoordinateSpanValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(CATransform3D)]]){
        CATransform3D myArg = [arg CATransform3DValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(NSRange)]]){
        NSRange myArg = [arg rangeValue];
        [self setArgument:&myArg atIndex:argIdx];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(UIEdgeInsets)]]){
        UIEdgeInsets myArg = [arg UIEdgeInsetsValue];
        [self setArgument:&myArg atIndex:argIdx];
    }

}

- (id)getEncodedReturnValue {
    id result = nil;
    NSString *type = [NSString stringWithUTF8String:[self.methodSignature methodReturnType]];
    
    if ([type isEqualToString:[NSInvocation encodeType:@encode(id)]]) {
        void *returnVal = nil;
        [self getReturnValue:&returnVal];
        result = (__bridge NSObject *)returnVal;
    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(CGRect)]]){
        CGRect returnVal;
        [self getReturnValue:&returnVal];
        result = [NSValue valueWithCGRect:returnVal];
    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(CGSize)]]){
        CGSize returnVal;
        [self getReturnValue:&returnVal];
        result = [NSValue valueWithCGSize:returnVal];
    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(CGPoint)]]){
        CGPoint returnVal;
        [self getReturnValue:&returnVal];
        result = [NSValue valueWithCGPoint:returnVal];
    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(CGAffineTransform)]]){
        CGAffineTransform returnVal;
        [self getReturnValue:&returnVal];
        result = [NSValue valueWithCGAffineTransform:returnVal];
    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(NSInteger)]]){
        NSInteger returnVal;
        [self getReturnValue:&returnVal];
        result = [NSNumber numberWithInteger:returnVal];
    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(NSUInteger)]]){
        NSUInteger returnVal;
        [self getReturnValue:&returnVal];
        result = [NSNumber numberWithUnsignedInteger:returnVal];
    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(long)]]){
        long returnVal;
        [self getReturnValue:&returnVal];
        result = [NSNumber numberWithLong:returnVal];
    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(unsigned)]]){
        unsigned returnVal;
        [self getReturnValue:&returnVal];
        result = [NSNumber numberWithUnsignedLong:returnVal];

    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(long long)]]){
        long long returnVal;
        [self getReturnValue:&returnVal];
        result = [NSNumber numberWithLongLong:returnVal];

    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(int)]]){
        int returnVal;
        [self getReturnValue:&returnVal];
        result = [NSNumber numberWithInt:returnVal];

    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(CGFloat)]]){
        CGFloat returnVal;
        [self getReturnValue:&returnVal];
        result = [NSNumber numberWithDouble:returnVal];

    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(float)]]){
        float returnVal;
        [self getReturnValue:&returnVal];
        result = [NSNumber numberWithFloat:returnVal];

    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(double)]]){
        double returnVal;
        [self getReturnValue:&returnVal];
        result = [NSNumber numberWithDouble:returnVal];
    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(BOOL)]]){
        BOOL returnVal;
        [self getReturnValue:&returnVal];
        result = [NSNumber numberWithBool:returnVal];

    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(CLLocationCoordinate2D)]]){
        CLLocationCoordinate2D returnVal;
        [self getReturnValue:&returnVal];
        result = [NSValue valueWithMKCoordinate:returnVal];
    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(MKCoordinateSpan)]]){
        MKCoordinateSpan returnVal;
        [self getReturnValue:&returnVal];
        result = [NSValue valueWithMKCoordinateSpan:returnVal];
    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(CATransform3D)]]){
        CATransform3D returnVal;
        [self getReturnValue:&returnVal];
        result = [NSValue valueWithCATransform3D:returnVal];
    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(NSRange)]]){
        NSRange returnVal;
        [self getReturnValue:&returnVal];
        result = [NSValue valueWithRange:returnVal];
    } else if ([type isEqualToString:[NSInvocation encodeType:@encode(UIEdgeInsets)]]){
        UIEdgeInsets returnVal;
        [self getReturnValue:&returnVal];
        result = [NSValue valueWithUIEdgeInsets:returnVal];
    }
    
    return result;
}

- (id)getArgAtIndex:(NSUInteger)index fromArray:(NSArray *)array {
    id result = nil;
    NSUInteger argIndex = index+2;
    NSString *type = [NSString stringWithUTF8String:[self.methodSignature getArgumentTypeAtIndex:argIndex]];
    NSEnumerator *enumerator = [array objectEnumerator];
    
    if ([type isEqualToString:[NSInvocation encodeType:@encode(CGRect)]]){
        CGRect returnVal;
        returnVal.origin.x = [[enumerator nextObject]doubleValue];
        returnVal.origin.y = [[enumerator nextObject]doubleValue];
        returnVal.size.width = [[enumerator nextObject]doubleValue];
        returnVal.size.height = [[enumerator nextObject]doubleValue];
        result = [NSValue valueWithCGRect:returnVal];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(CGSize)]]){
        CGSize returnVal;
        returnVal.width = [[enumerator nextObject]doubleValue];
        returnVal.height = [[enumerator nextObject]doubleValue];
        result = [NSValue valueWithCGSize:returnVal];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(CGPoint)]]){
        CGPoint returnVal;
        returnVal.x = [[enumerator nextObject]doubleValue];
        returnVal.y = [[enumerator nextObject]doubleValue];
        result = [NSValue valueWithCGPoint:returnVal];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(CGAffineTransform)]]){
        CGAffineTransform returnVal = CGAffineTransformIdentity; // added by 7
        result = [NSValue valueWithCGAffineTransform:returnVal];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(CLLocationCoordinate2D)]]){
        CLLocationCoordinate2D returnVal;
        returnVal.latitude = [[enumerator nextObject]doubleValue];
        returnVal.longitude = [[enumerator nextObject]doubleValue];
        result = [NSValue valueWithMKCoordinate:returnVal];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(MKCoordinateSpan)]]){
        MKCoordinateSpan returnVal;
        returnVal.latitudeDelta = [[enumerator nextObject]doubleValue];
        returnVal.longitudeDelta = [[enumerator nextObject]doubleValue];
        result = [NSValue valueWithMKCoordinateSpan:returnVal];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(CATransform3D)]]){
        CATransform3D returnVal = CATransform3DIdentity; // added by 7
        result = [NSValue valueWithCATransform3D:returnVal];
    }else if ([type isEqualToString:[NSInvocation encodeType:@encode(NSRange)]]){
        NSRange returnVal;
        returnVal.location = [[enumerator nextObject]unsignedIntegerValue];
        returnVal.length = [[enumerator nextObject]unsignedIntegerValue];
        result = [NSValue valueWithRange:returnVal];
    }else if ( [type isEqualToString:[NSInvocation encodeType:@encode(UIEdgeInsets)]]){
        UIEdgeInsets returnVal;
        returnVal.top = [[enumerator nextObject]doubleValue];
        returnVal.left = [[enumerator nextObject]doubleValue];
        returnVal.bottom = [[enumerator nextObject]doubleValue];
        returnVal.right = [[enumerator nextObject]doubleValue];
        result = [NSValue valueWithUIEdgeInsets:returnVal];
    }else{
        return array;
    }
    
    return result;
}

+ (instancetype)invocationWithTarget:(id)target block:(void (^)(id target))block {
    NSParameterAssert(block != nil);
    _InvocationGrabber *grabber = [_InvocationGrabber grabberWithTarget:target];
    block(grabber);
    return grabber.invocation;
}

+ (instancetype)invocationWithBlock:(id) block {
    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:[NSMethodSignature signatureWithObjCTypes:__BlockSignature__(block)]];
    invocation.target = block;
    return invocation;
}
#define ARG_GET_SET(type) do { type val = 0; val = va_arg(args,type); [invocation setArgument:&val atIndex:1 + i];} while (0)
+ (instancetype)invocationWithBlockAndArguments:(id) block ,... {
    NSInvocation* invocation = [NSInvocation invocationWithBlock:block];
    NSUInteger argsCount = invocation.methodSignature.numberOfArguments - 1;
    va_list args;
    va_start(args, block);
    for(NSUInteger i = 0; i < argsCount ; ++i){
        const char* argType = [invocation.methodSignature getArgumentTypeAtIndex:i + 1];
        if (argType[0] == _C_CONST) argType++;
        
        if (argType[0] == '@') {                                //id and block
            ARG_GET_SET(id);
        } else if (strcmp(argType, @encode(Class)) == 0 ){       //Class
            ARG_GET_SET(Class);
        } else if (strcmp(argType, @encode(IMP)) == 0 ){         //IMP
            ARG_GET_SET(IMP);
        } else if (strcmp(argType, @encode(SEL)) == 0) {         //SEL
            ARG_GET_SET(SEL);
        } else if (strcmp(argType, @encode(double)) == 0){       //
            ARG_GET_SET(double);
        } else if (strcmp(argType, @encode(float)) == 0){
            float val = 0;
            val = (float)va_arg(args,double);
            [invocation setArgument:&val atIndex:1 + i];
        } else if (argType[0] == '^'){                           //pointer ( andconst pointer)
            ARG_GET_SET(void*);
        } else if (strcmp(argType, @encode(char *)) == 0) {      //char* (and const char*)
            ARG_GET_SET(char *);
        } else if (strcmp(argType, @encode(unsigned long)) == 0) {
            ARG_GET_SET(unsigned long);
        } else if (strcmp(argType, @encode(unsigned long long)) == 0) {
            ARG_GET_SET(unsigned long long);
        } else if (strcmp(argType, @encode(long)) == 0) {
            ARG_GET_SET(long);
        } else if (strcmp(argType, @encode(long long)) == 0) {
            ARG_GET_SET(long long);
        } else if (strcmp(argType, @encode(int)) == 0) {
            ARG_GET_SET(int);
        } else if (strcmp(argType, @encode(unsigned int)) == 0) {
            ARG_GET_SET(unsigned int);
        } else if (strcmp(argType, @encode(BOOL)) == 0 || strcmp(argType, @encode(bool)) == 0
                  || strcmp(argType, @encode(char)) == 0 || strcmp(argType, @encode(unsigned char)) == 0
                  || strcmp(argType, @encode(short)) == 0 || strcmp(argType, @encode(unsigned short)) == 0) {
            ARG_GET_SET(int);
        } else {                  //struct union and array
            assert(false && "struct union array unsupported!");
        }
    }
    va_end(args);
    return invocation;
}
@end

@implementation BARuntime

- (NSArray *)backtrace:(NSException *)exception {
    NSArray *addresses = exception.callStackReturnAddresses;
    unsigned count = (int)addresses.count;
    void **stack = malloc(count * sizeof(void *));
    
    for (unsigned i = 0; i < count; ++i)
        stack[i] = (void *)[addresses[i] longValue];
    
    char **strings = backtrace_symbols(stack, count);
    NSMutableArray<NSString *> *ret = [NSMutableArray arrayWithCapacity:count];
    
    for (int i = 0; i < count; ++i)
        [ret addObject:@(strings[i])];
    
    free(stack);
    free(strings);
    
    return ret;
}

@end

#import "_pragma_pop.h"
