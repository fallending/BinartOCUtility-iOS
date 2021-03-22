
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject ( BARuntime )

+ (Class)mt_baseClass;

- (void)mt_deepEqualsTo:(id)obj;
- (void)mt_deepCopyFrom:(id)obj;

- (BOOL)mt_shallowCopy:(NSObject *)obj;
- (BOOL)mt_deepCopy:(NSObject *)obj;
- (id)mt_deepCopy;

- (id)mt_clone;                    // override point

+ (BOOL)mt_isNullValue:(id)value;

// Get all classes those are loaded
+ (__unsafe_unretained Class _Nonnull *_Nonnull)mt_loadedClasses;
+ (void)mt_enumerateloadedClassesUsingBlock:(void (^)(__unsafe_unretained Class cls))block;

+ (NSArray *)mt_subClasses;

+ (NSArray *)mt_methods;
+ (NSArray *)mt_methodsInfo;
+ (NSArray *)mt_methodsUntilClass:(Class)baseClass;
+ (NSArray *)mt_methodsWithPrefix:(NSString *)prefix;
+ (NSArray *)mt_methodsWithPrefix:(NSString *)prefix untilClass:(Class)baseClass;

+ (NSArray *)mt_properties;
+ (NSArray *)mt_propertiesUntilClass:(Class)baseClass;
+ (NSArray *)mt_propertiesWithPrefix:(NSString *)prefix;
+ (NSArray *)mt_propertiesWithPrefix:(NSString *)prefix untilClass:(Class)baseClass;

- (NSDictionary *)mt_propertyDictionary; //实例属性字典
- (NSArray *)mt_propertyKeys; //属性名称列表
+ (NSArray *)mt_propertyKeys;
- (NSArray *)mt_propertiesInfo; //属性详细信息列表
+ (NSArray *)mt_propertiesInfo;
+ (NSArray *)mt_propertiesWithCodeFormat; //格式化后的属性列表
+ (NSArray *)mt_instanceVariable; // 实例变量
- (BOOL)mt_hasPropertyForKey:(NSString *)key;

/**
 * Check whether the receiver implements or inherits a specified method up to and exluding a particular class in hierarchy.
 */
- (BOOL)mt_respondsToSelector:(SEL)selector untilClass:(Class)stopClass;

/**
 * Check whether a superclass implements or inherits a specified method.
 */
- (BOOL)mt_superRespondsToSelector:(SEL)selector;

/**
 * Check whether a superclass implements or inherits a specified method.
 */
- (BOOL)mt_superRespondsToSelector:(SEL)selector untilClass:(Class)stopClass;

/**
 * Check whether the receiver's instances implement or inherit a specified method up to and exluding a particular class in hierarchy.
 */
+ (BOOL)mt_instancesRespondToSelector:(SEL)selector untilClass:(Class)stopClass;

/**
 * perform a selector take care of selector not existing.
 */
+ (id)mt_touchSelector:(SEL)selector;
- (id)mt_touchSelector:(SEL)selector;

/**
 * 该对象所遵循的协议
 */
- (NSArray *)mt_conformedProtocols;
- (NSDictionary *)mt_protocols;
+ (NSDictionary *)mt_protocols;
+ (NSArray *)mt_classesWithProtocolName:(NSString *)protocolName;

/**
 * 返回对象的所有 ivar
 */
- (NSArray *)mt_allIvars;
- (BOOL)mt_hasIvarForKey:(NSString *)key;

/**
 * 以 NSString 描述的类名
 */
- (NSString *)mt_className;
+ (NSString *)mt_className;

- (NSString *)mt_superClassName;
+ (NSString *)mt_superClassName;

/**
 * 所有父类
 */
- (NSArray *)mt_parents;

+ (BOOL)mt_isNSObjectClass:(Class)clazz;

@end

@interface NSInvocation ( Extension )

+ (id)mt_doInstanceMethodTarget:(id)target
                selectorName:(NSString *)selectorName
                        args:(NSArray *)args;

+ (id)mt_doClassMethod:(NSString *)className
       selectorName:(NSString *)selectorName
               args:(NSArray *)args;

- (void)mt_setArgumentWithObject:(id)object atIndex:(NSUInteger)index;

+ (instancetype)mt_invocationWithTarget:(id)target block:(void (^)(id target))block;
+ (instancetype)mt_invocationWithBlock:(id) block;
+ (instancetype)mt_invocationWithBlockAndArguments:(id) block ,...;

@end

@interface BARuntime : NSObject

- (NSArray *)backtrace:(NSException *)exception;

@end


NS_ASSUME_NONNULL_END

