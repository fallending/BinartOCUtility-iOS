
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject ( BARuntime )

+ (Class)ba_baseClass;

- (void)ba_deepEqualsTo:(id)obj;
- (void)ba_deepCopyFrom:(id)obj;

- (BOOL)ba_shallowCopy:(NSObject *)obj;
- (BOOL)ba_deepCopy:(NSObject *)obj;
- (id)ba_deepCopy;

- (id)ba_clone;                    // override point

+ (BOOL)ba_isNullValue:(id)value;

// Get all classes those are loaded
+ (__unsafe_unretained Class _Nonnull *_Nonnull)ba_loadedClasses;
+ (void)ba_enumerateloadedClassesUsingBlock:(void (^)(__unsafe_unretained Class cls))block;

+ (NSArray *)ba_subClasses;

+ (NSArray *)ba_methods;
+ (NSArray *)ba_methodsInfo;
+ (NSArray *)ba_methodsUntilClass:(Class)baseClass;
+ (NSArray *)ba_methodsWithPrefix:(NSString *)prefix;
+ (NSArray *)ba_methodsWithPrefix:(NSString *)prefix untilClass:(Class)baseClass;

+ (NSArray *)ba_properties;
+ (NSArray *)ba_propertiesUntilClass:(Class)baseClass;
+ (NSArray *)ba_propertiesWithPrefix:(NSString *)prefix;
+ (NSArray *)ba_propertiesWithPrefix:(NSString *)prefix untilClass:(Class)baseClass;

- (NSDictionary *)ba_propertyDictionary; //实例属性字典
- (NSArray *)ba_propertyKeys; //属性名称列表
+ (NSArray *)ba_propertyKeys;
- (NSArray *)ba_propertiesInfo; //属性详细信息列表
+ (NSArray *)ba_propertiesInfo;
+ (NSArray *)ba_propertiesWithCodeFormat; //格式化后的属性列表
+ (NSArray *)ba_instanceVariable; // 实例变量
- (BOOL)ba_hasPropertyForKey:(NSString *)key;

/**
 * Check whether the receiver implements or inherits a specified method up to and exluding a particular class in hierarchy.
 */
- (BOOL)ba_respondsToSelector:(SEL)selector untilClass:(Class)stopClass;

/**
 * Check whether a superclass implements or inherits a specified method.
 */
- (BOOL)ba_superRespondsToSelector:(SEL)selector;

/**
 * Check whether a superclass implements or inherits a specified method.
 */
- (BOOL)ba_superRespondsToSelector:(SEL)selector untilClass:(Class)stopClass;

/**
 * Check whether the receiver's instances implement or inherit a specified method up to and exluding a particular class in hierarchy.
 */
+ (BOOL)ba_instancesRespondToSelector:(SEL)selector untilClass:(Class)stopClass;

/**
 * perform a selector take care of selector not existing.
 */
+ (id)ba_touchSelector:(SEL)selector;
- (id)ba_touchSelector:(SEL)selector;

/**
 * 该对象所遵循的协议
 */
- (NSArray *)ba_conformedProtocols;
- (NSDictionary *)ba_protocols;
+ (NSDictionary *)ba_protocols;
+ (NSArray *)ba_classesWithProtocolName:(NSString *)protocolName;

/**
 * 返回对象的所有 ivar
 */
- (NSArray *)ba_allIvars;
- (BOOL)ba_hasIvarForKey:(NSString *)key;

/**
 * 以 NSString 描述的类名
 */
- (NSString *)ba_className;
+ (NSString *)ba_className;

- (NSString *)ba_superClassName;
+ (NSString *)ba_superClassName;

/**
 * 所有父类
 */
- (NSArray *)ba_parents;

+ (BOOL)ba_isNSObjectClass:(Class)clazz;

@end

@interface NSInvocation ( Extension )

+ (id)ba_doInstanceMethodTarget:(id)target
                selectorName:(NSString *)selectorName
                        args:(NSArray *)args;

+ (id)ba_doClassMethod:(NSString *)className
       selectorName:(NSString *)selectorName
               args:(NSArray *)args;

- (void)ba_setArgumentWithObject:(id)object atIndex:(NSUInteger)index;

+ (instancetype)ba_invocationWithTarget:(id)target block:(void (^)(id target))block;
+ (instancetype)ba_invocationWithBlock:(id) block;
+ (instancetype)ba_invocationWithBlockAndArguments:(id) block ,...;

@end

@interface BARuntime : NSObject

- (NSArray *)backtrace:(NSException *)exception;

@end


NS_ASSUME_NONNULL_END

