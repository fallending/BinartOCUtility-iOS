
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject ( BARuntime )

// Get all classes those are loaded
+ (__unsafe_unretained Class _Nonnull *_Nonnull)loadedClasses;
+ (void)enumerateloadedClassesUsingBlock:(void (^)(__unsafe_unretained Class cls))block;

+ (NSArray *)subClasses;

+ (NSArray *)methods;
+ (NSArray *)methodsInfo;
+ (NSArray *)methodsUntilClass:(Class)baseClass;
+ (NSArray *)methodsWithPrefix:(NSString *)prefix;
+ (NSArray *)methodsWithPrefix:(NSString *)prefix untilClass:(Class)baseClass;

+ (NSArray *)properties;
+ (NSArray *)propertiesUntilClass:(Class)baseClass;
+ (NSArray *)propertiesWithPrefix:(NSString *)prefix;
+ (NSArray *)propertiesWithPrefix:(NSString *)prefix untilClass:(Class)baseClass;

- (NSDictionary *)propertyDictionary; //实例属性字典
- (NSArray *)propertyKeys; //属性名称列表
+ (NSArray *)propertyKeys;
- (NSArray *)propertiesInfo; //属性详细信息列表
+ (NSArray *)propertiesInfo;
+ (NSArray *)propertiesWithCodeFormat; //格式化后的属性列表
+ (NSArray *)instanceVariable; // 实例变量
- (BOOL)hasPropertyForKey:(NSString *)key;

/**
 * Check whether the receiver implements or inherits a specified method up to and exluding a particular class in hierarchy.
 */
- (BOOL)respondsToSelector:(SEL)selector untilClass:(Class)stopClass;

/**
 * Check whether a superclass implements or inherits a specified method.
 */
- (BOOL)superRespondsToSelector:(SEL)selector;

/**
 * Check whether a superclass implements or inherits a specified method.
 */
- (BOOL)superRespondsToSelector:(SEL)selector untilClass:(Class)stopClass;

/**
 * Check whether the receiver's instances implement or inherit a specified method up to and exluding a particular class in hierarchy.
 */
+ (BOOL)instancesRespondToSelector:(SEL)selector untilClass:(Class)stopClass;

/**
 * perform a selector take care of selector not existing.
 */
+ (id)touchSelector:(SEL)selector;
- (id)touchSelector:(SEL)selector;

/**
 * 该对象所遵循的协议
 */
- (NSArray *)conformedProtocols;
- (NSDictionary *)protocols;
+ (NSDictionary *)protocols;
+ (NSArray *)classesWithProtocolName:(NSString *)protocolName;

/**
 * 返回对象的所有 ivar
 */
- (NSArray *)allIvars;
- (BOOL)hasIvarForKey:(NSString *)key;

/**
 * 以 NSString 描述的类名
 */
- (NSString *)className;
+ (NSString *)className;

- (NSString *)superClassName;
+ (NSString *)superClassName;

/**
 * 所有父类
 */
- (NSArray *)parents;

+ (BOOL)isNSObjectClass:(Class)clazz;

@end

@interface NSObject ( Extension )

+ (Class)baseClass;

- (void)deepEqualsTo:(id)obj;
- (void)deepCopyFrom:(id)obj;

- (BOOL)shallowCopy:(NSObject *)obj;
- (BOOL)deepCopy:(NSObject *)obj;
- (id)deepCopy;

- (id)clone;                    // override point

+ (BOOL)isNullValue:(id)value;

@end

@interface NSInvocation ( Extension )

+ (id)doInstanceMethodTarget:(id)target
                selectorName:(NSString *)selectorName
                        args:(NSArray *)args;

+ (id)doClassMethod:(NSString *)className
       selectorName:(NSString *)selectorName
               args:(NSArray *)args;

- (void)setArgumentWithObject:(id)object atIndex:(NSUInteger)index;

+ (instancetype)invocationWithTarget:(id)target block:(void (^)(id target))block;
+ (instancetype)invocationWithBlock:(id) block;
+ (instancetype)invocationWithBlockAndArguments:(id) block ,...;

@end

@interface BARuntime : NSObject

- (NSArray *)backtrace:(NSException *)exception;

@end


NS_ASSUME_NONNULL_END

