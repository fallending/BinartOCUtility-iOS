#import "BAMacros.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSMutableArray * _Nonnull   (^NSArrayElementBlock)(id obj );
typedef NSComparisonResult    (^NSArrayCompareBlock)(id left, id right );

@interface NSArray ( BAUtil )

- (id)mt_first;
- (id)mt_last;

- (NSArray *)mt_head:(NSUInteger)count;
- (NSArray *)mt_tail:(NSUInteger)count;

- (id)mt_atIndex:(NSUInteger)index;

- (id)mt_subWithRange:(NSRange)range;
- (id)mt_subFromIndex:(NSUInteger)index;
- (id)mt_subWithCount:(NSUInteger)count;

- (NSString *)mt_join:(NSString *)delimiter;

- (BOOL)mt_containsString:(NSString *)aString;

/// 遍历
- (void)mt_each:(void (^)(id obj))block;
- (void)mt_apply:(void (^)(id obj))block;

/// 匹配
- (id)mt_match: (BOOL (^)(id obj))block;

/// 筛选
- (NSArray *)mt_select: (BOOL (^)(id obj))block;
- (NSArray *)mt_reject:(BOOL (^)(id obj))block;

/// 映射
- (NSArray *)mt_map: (id (^)(id obj))block;
- (NSArray *)mt_compact:(id (^)(id obj))block;

/// 化简
- (id)mt_reduce:(nullable id)initial withBlock:(__nullable id (^)(__nullable id sum, id obj))block;
- (NSInteger)mt_reduceInteger:(NSInteger)initial withBlock:(NSInteger(^)(NSInteger result, id obj))block;
- (CGFloat)mt_reduceFloat:(CGFloat)inital withBlock:(CGFloat(^)(CGFloat result, id obj))block;

- (BOOL)mt_any:(BOOL (^)(id obj))block;

/** Loops through an array to find whether no objects match the block.
 */
- (BOOL)mt_none:(BOOL (^)(id obj))block;

/** Loops through an array to find whether all objects match the block.
 
 @param block A single-argument, BOOL-returning code block.
 @return YES if the block returns YES for all objects in the array, NO otherwise.
 */
- (BOOL)mt_all:(BOOL (^)(id obj))block;

/** Tests whether every element of this array relates to the corresponding element of another array according to match by block.
 */
- (BOOL)mt_corresponds:(NSArray *)list withBlock:(BOOL (^)(id obj1, id obj2))block;

@end

@interface NSMutableArray ( BAUtil )

- (void)mt_add:(id)object;
- (void)mt_add:(id)object atIndex:(NSInteger)index;

- (void)mt_addUniqueObject:(id)object compare:(NSArrayCompareBlock)compare;
- (void)mt_addUniqueObjects:(const id _Nonnull [_Nullable])objects count:(NSUInteger)count compare:(NSArrayCompareBlock)compare;
- (void)mt_addUniqueObjectsFromArray:(NSArray *)array compare:(NSArrayCompareBlock)compare;

- (void)mt_swap:(NSUInteger)i and:(NSUInteger)j;

- (void)mt_unique;
- (void)mt_unique:(NSArrayCompareBlock)compare;

- (void)mt_sort;
- (void)mt_sort:(NSArrayCompareBlock)compare;

- (void)mt_shrink:(NSUInteger)count;
- (void)mt_append:(id)object;

- (NSMutableArray *)mt_pushHead:(NSObject *)obj;
- (NSMutableArray *)mt_pushHeadN:(NSArray *)all;
- (NSMutableArray *)mt_popTail;
- (NSMutableArray *)mt_popTailN:(NSUInteger)n;

- (NSMutableArray *)mt_pushTail:(NSObject *)obj;
- (NSMutableArray *)mt_pushTailN:(NSArray *)all;
- (NSMutableArray *)mt_popHead;
- (NSMutableArray *)mt_popHeadN:(NSUInteger)n;

- (NSMutableArray *)mt_keepHead:(NSUInteger)n;
- (NSMutableArray *)mt_keepTail:(NSUInteger)n;

@end

NS_ASSUME_NONNULL_END
