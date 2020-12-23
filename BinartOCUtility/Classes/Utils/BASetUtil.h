#import "BAMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSOrderedSet ( BAUtil )
/**
 * 遍历
 */
- (void)each:(void (^)(id obj))block;

/**
 * 并发遍历
 */
- (void)apply:(void (^)(id obj))block;

/**
 * 匹配查找单个
 */
- (nullable id)match:(BOOL (^)(id obj))block;

/**
 * 查询一组
 */
- (NSOrderedSet *)select:(BOOL (^)(id obj))block;

/**
 * 查询不符合的一组
 */
- (NSOrderedSet *)reject:(BOOL (^)(id obj))block;

/**
 * 映射
 */
- (NSOrderedSet *)map:(id (^)(id obj))block;

/**
 * 化简
 */
- (nullable id)reduce:(nullable id)initial withBlock:(__nullable id (^)(__nullable id sum, id obj))block;

/** Loops through an ordered set to find whether any object matches the block.
 */
- (BOOL)any:(BOOL (^)(id obj))block;

/** Loops through an ordered set to find whether no objects match the block.
 */
- (BOOL)none:(BOOL (^)(id obj))block;

/** Loops through an ordered set to find whether all objects match the block.
 */
- (BOOL)all:(BOOL (^)(id obj))block;

/** Tests whether every element of this ordered set relates to the corresponding
 element of another array according to match by block.
 */
- (BOOL)corresponds:(NSOrderedSet *)list withBlock:(BOOL (^)(id obj1, id obj2))block;

@end

@interface NSSet ( BAUtil )

/**
 *  遍历
 */
- (void)each:(void (^)(id obj))block;
- (void)eachWithIndex:(void (^)(id obj, int idx))block;

/**
 * 并发
 */
- (void)apply:(void (^)(id obj))block;

/**
 *  匹配
 */
- (nullable id)match: (BOOL (^)(id obj))block;

/**
 *  筛选
 */
- (NSSet *)select: (BOOL (^)(id obj))block;

/**
 *  排除
 */
- (NSSet *)reject:(BOOL (^)(id obj))block;

/**
 *  映射
 */
- (NSSet *)map: (id (^)(id obj))block;

/**
 *  化简
 */
- (id)reduce:(id)initial withBlock:(id (^)(id sum, id obj))block;

/**
 * 条件判断：任意一个满足
 */
- (BOOL)any:(BOOL (^)(id obj))block;

/**
 * 条件判断：无一满足
 */
- (BOOL)none:(BOOL (^)(id obj))block;

/**
 * 条件判断：所有都满足
 */
- (BOOL)all:(BOOL (^)(id obj))block;

/**
 *  排序
 */
- (NSSet *)sort;

@end

NS_ASSUME_NONNULL_END

