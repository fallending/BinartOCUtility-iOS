#import "BATrigger.h"

#import <objc/runtime.h>

typedef void ( *ImpFuncType )( id a, SEL b, void * c );

static const void *    __RetainFunc( CFAllocatorRef allocator, const void * value ) { return value; }
static void            __ReleaseFunc( CFAllocatorRef allocator, const void * value ) {}

#pragma mark -

@interface NSMutableArray (BAUTrigger)
+ (NSMutableArray *)nonRetainingArray;
@end

@implementation NSMutableArray (BAUTrigger)

+ (NSMutableArray *)nonRetainingArray {// copy from Three20
    CFArrayCallBacks callbacks = kCFTypeArrayCallBacks;
    callbacks.retain = __RetainFunc;
    callbacks.release = __ReleaseFunc;
    return (__bridge_transfer NSMutableArray *)CFArrayCreateMutable( nil, 0, &callbacks );
}

@end

@implementation BAUTrigger

// MARK: -

+ (void)performSelectorWithPrefix:(NSString *)prefixName {
    unsigned int    methodCount = 0;
    Method *        methodList = class_copyMethodList( self, &methodCount );
    
    if ( methodList && methodCount ) {
        for ( NSUInteger i = 0; i < methodCount; ++i ) {
            SEL sel = method_getName( methodList[i] );
            
            const char * name = sel_getName( sel );
            const char * prefix = [prefixName UTF8String];
            
            if ( 0 == strcmp(prefix, name) ) {
                continue;
            }
            
            if ( 0 == strncmp( name, prefix, strlen(prefix) ) ) {
                ImpFuncType imp = (ImpFuncType)method_getImplementation( methodList[i] );
                if ( imp ) {
                    imp( self, sel, nil );
                }
            }
        }
    }
    
    free( methodList );
}

+ (id)performCallChainWithSelector:(SEL)sel {
    return [self performCallChainWithSelector:sel reversed:NO];
}

+ (id)performCallChainWithSelector:(SEL)sel reversed:(BOOL)flag {
    NSMutableArray * classStack = [NSMutableArray nonRetainingArray];
    
    for ( Class thisClass = [self class]; nil != thisClass; thisClass = class_getSuperclass( thisClass ) ) {
        if ( flag ) {
            [classStack addObject:thisClass];
        } else {
            [classStack insertObject:thisClass atIndex:0];
        }
    }
    
    ImpFuncType prevImp = NULL;
    
    for ( Class thisClass in classStack ) {
        Method method = class_getInstanceMethod( thisClass, sel );
        if ( method ) {
            ImpFuncType imp = (ImpFuncType)method_getImplementation( method );
            if ( imp ) {
                if ( imp == prevImp ) {
                    continue;
                }
                
                imp( self, sel, nil );
                
                prevImp = imp;
            }
        }
    }
    
    return self;
}

+ (id)performCallChainWithPrefix:(NSString *)prefix {
    return [self performCallChainWithPrefix:prefix reversed:YES];
}

+ (id)performCallChainWithPrefix:(NSString *)prefixName reversed:(BOOL)flag {
    NSMutableArray * classStack = [NSMutableArray nonRetainingArray];
    
    for ( Class thisClass = [self class]; nil != thisClass; thisClass = class_getSuperclass( thisClass ) ) {
        if ( flag ) {
            [classStack addObject:thisClass];
        } else {
            [classStack insertObject:thisClass atIndex:0];
        }
    }
    
    for ( Class thisClass in classStack ) {
        unsigned int    methodCount = 0;
        Method *        methodList = class_copyMethodList( thisClass, &methodCount );
        
        if ( methodList && methodCount ) {
            for ( NSUInteger i = 0; i < methodCount; ++i ) {
                SEL sel = method_getName( methodList[i] );
                
                const char * name = sel_getName( sel );
                const char * prefix = [prefixName UTF8String];
                
                if ( 0 == strcmp( prefix, name ) ) {
                    continue;
                }
                
                if ( 0 == strncmp( name, prefix, strlen(prefix) ) ) {
                    ImpFuncType imp = (ImpFuncType)method_getImplementation( methodList[i] );
                    if ( imp ) {
                        imp( self, sel, nil );
                    }
                }
            }
        }
        
        free( methodList );
    }
    
    return self;
}

+ (id)performCallChainWithName:(NSString *)name {
    return [self performCallChainWithName:name reversed:NO];
}

+ (id)performCallChainWithName:(NSString *)name reversed:(BOOL)flag {
    SEL selector = NSSelectorFromString( name );
    if ( selector ) {
        NSString * prefix1 = [NSString stringWithFormat:@"before_%@", name];
        NSString * prefix2 = [NSString stringWithFormat:@"after_%@", name];
        
        [self performCallChainWithPrefix:prefix1 reversed:flag];
        [self performCallChainWithSelector:selector reversed:flag];
        [self performCallChainWithPrefix:prefix2 reversed:flag];
    }
    return self;
}

+ (id)performSelector:(SEL)selector withObjects:(NSArray *)objects {
    // 方法签名(方法的描述)
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        
        //可以抛出异常也可以不操作。
    }
    
    // NSInvocation : 利用一个NSInvocation对象包装一次方法调用（方法调用者、方法名、方法参数、方法返回值）
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    invocation.selector = selector;
    
    // 设置参数
    NSInteger paramsCount = signature.numberOfArguments - 2; // 除self、_cmd以外的参数个数
    paramsCount = MIN(paramsCount, objects.count);
    for (NSInteger i = 0; i < paramsCount; i++) {
        id object = objects[i];
        if ([object isKindOfClass:[NSNull class]]) continue;
        [invocation setArgument:&object atIndex:i + 2];
    }
    
    // 调用方法
    [invocation invoke];
    
    // 获取返回值
    id returnValue = nil;
    if (signature.methodReturnLength) { // 有返回值类型，才去获得返回值
        [invocation getReturnValue:&returnValue];
    }
    
    return returnValue;
}

+ (void)performSelectorOnMainThread:(SEL)selector withObject:(id)arg1 withObject:(id)arg2 waitUntilDone:(BOOL)wait {
    NSMethodSignature *sig = [self methodSignatureForSelector:selector];
    if (!sig)
        return;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    
    [invocation setTarget:self];
    [invocation setSelector:selector];
    [invocation setArgument:&arg1 atIndex:2];
    [invocation setArgument:&arg2 atIndex:3];
    [invocation retainArguments];
    
    [invocation performSelectorOnMainThread:@selector(invoke) withObject:nil waitUntilDone:wait];
}

+ (void)performSelector:(SEL)aSelector withObjects:(NSArray *)arguments afterDelay:(NSTimeInterval)delay {
    NSMethodSignature *sig = [self methodSignatureForSelector:aSelector];
    if (!sig)
        return;
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    
    [invocation setTarget:self];
    [invocation setSelector:aSelector];
    
    for (int i = 0; i < arguments.count; i++) {
        id argument = [arguments objectAtIndex:i];
        [invocation setArgument:&argument atIndex:2+i];
    }
    
    [invocation retainArguments];
    
    [invocation performSelector:@selector(invoke) withObject:nil afterDelay:delay];
}

// MARK: -

+ (void)onMain:(void (^)(void))block {
    dispatch_async(dispatch_get_main_queue(), block);
}

+ (void)onMain:(void (^)(void))block after:(BOOL)seconds {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}

+ (void)onGlobal:(void (^)(void))block {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

+ (void)onGlobal:(void (^)(void))block after:(BOOL)seconds {
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, seconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
}

@end
