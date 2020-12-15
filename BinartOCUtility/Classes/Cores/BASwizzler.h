
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject ( BASwizzler )

/**
 * @description exchange methods' implementations.
 
 * @param originalSelector method to exchange.
 * @param newSelector method to exchange.
 */
+ (BOOL)swizzleMethod:(SEL)originalSelector withMethod:(SEL)newSelector error:(NSError **)error;
+ (BOOL)swizzleClassMethod:(SEL)originalSelector withClassMethod:(SEL)newSelector error:(NSError **)error;

/**
 * @description copy methods' implementations.
 
 * @param newSelector method to exchange.
 * @param dstSelector method to exchange.
 */
+ (BOOL)copyMethod:(SEL)newSelector toMethod:(SEL)dstSelector error:(NSError **)error;
+ (BOOL)copyClassMethod:(SEL)newSelector toClassMethod:(SEL)dstSelector error:(NSError **)error;

/**
 Exchange methods' implementations.
 
 @param originalSelector Method to exchange.
 @param newSelector Method to exchange.
 */
+ (void)swizzleMethod:(SEL)originalSelector withMethod:(SEL)newSelector;

/**
 Append a new method to an object.
 
 @param newSelector Method to exchange.
 @param klass Host class.
 */
+ (void)appendMethod:(SEL)newSelector fromClass:(Class)klass;

/**
 Replace a method in an object.
 
 @param selector Method to exchange.
 @param klass Host class.
 */
+ (void)replaceMethod:(SEL)selector fromClass:(Class)klass;

@end

NS_ASSUME_NONNULL_END
