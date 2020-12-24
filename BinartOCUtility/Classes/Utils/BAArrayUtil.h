#import "BAMacros.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSMutableArray * _Nonnull   (^NSArrayElementBlock)(id obj );
typedef NSComparisonResult    (^NSArrayCompareBlock)(id left, id right );

@interface NSArray ( BAUtil )

- (id)ba_first;
- (id)ba_last;

- (NSArray *)ba_head:(NSUInteger)count;
- (NSArray *)ba_tail:(NSUInteger)count;

- (id)ba_atIndex:(NSUInteger)index;

- (id)ba_subWithRange:(NSRange)range;
- (id)ba_subFromIndex:(NSUInteger)index;
- (id)ba_subWithCount:(NSUInteger)count;

- (NSString *)ba_join:(NSString *)delimiter;

- (BOOL)ba_containsString:(NSString *)aString;

/// 遍历
- (void)ba_each:(void (^)(id obj))block;
- (void)ba_apply:(void (^)(id obj))block;

/// 匹配
- (id)ba_match: (BOOL (^)(id obj))block;

/// 筛选
- (NSArray *)ba_select: (BOOL (^)(id obj))block;

- (NSArray *)ba_reject:(BOOL (^)(id obj))block;

/// 映射
- (NSArray *)ba_map: (id (^)(id obj))block;
- (NSArray *)ba_compact:(id (^)(id obj))block;

/// 化简
- (id)ba_reduce:(nullable id)initial withBlock:(__nullable id (^)(__nullable id sum, id obj))block;
- (NSInteger)ba_reduceInteger:(NSInteger)initial withBlock:(NSInteger(^)(NSInteger result, id obj))block;
- (CGFloat)ba_reduceFloat:(CGFloat)inital withBlock:(CGFloat(^)(CGFloat result, id obj))block;

- (BOOL)ba_any:(BOOL (^)(id obj))block;

/** Loops through an array to find whether no objects match the block.
 */
- (BOOL)ba_none:(BOOL (^)(id obj))block;

/** Loops through an array to find whether all objects match the block.
 
 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns YES for all objects in the array, NO otherwise.
 */
- (BOOL)ba_all:(BOOL (^)(id obj))block;

/** Tests whether every element of this array relates to the corresponding element of another array according to match by block.
 */
- (BOOL)ba_corresponds:(NSArray *)list withBlock:(BOOL (^)(id obj1, id obj2))block;

@end

@interface NSMutableArray ( BAUtil )

- (void)ba_add:(id)object;
- (void)ba_add:(id)object atIndex:(NSInteger)index;

- (void)ba_addUniqueObject:(id)object compare:(NSArrayCompareBlock)compare;
- (void)ba_addUniqueObjects:(const id _Nonnull [_Nullable])objects count:(NSUInteger)count compare:(NSArrayCompareBlock)compare;
- (void)ba_addUniqueObjectsFromArray:(NSArray *)array compare:(NSArrayCompareBlock)compare;

- (void)ba_swap:(NSUInteger)i and:(NSUInteger)j;

- (void)ba_unique;
- (void)ba_unique:(NSArrayCompareBlock)compare;

- (void)ba_sort;
- (void)ba_sort:(NSArrayCompareBlock)compare;

- (void)ba_shrink:(NSUInteger)count;
- (void)ba_append:(id)object;

- (NSMutableArray *)ba_pushHead:(NSObject *)obj;
- (NSMutableArray *)ba_pushHeadN:(NSArray *)all;
- (NSMutableArray *)ba_popTail;
- (NSMutableArray *)ba_popTailN:(NSUInteger)n;

- (NSMutableArray *)ba_pushTail:(NSObject *)obj;
- (NSMutableArray *)ba_pushTailN:(NSArray *)all;
- (NSMutableArray *)ba_popHead;
- (NSMutableArray *)ba_popHeadN:(NSUInteger)n;

- (NSMutableArray *)ba_keepHead:(NSUInteger)n;
- (NSMutableArray *)ba_keepTail:(NSUInteger)n;

@end

NS_ASSUME_NONNULL_END
