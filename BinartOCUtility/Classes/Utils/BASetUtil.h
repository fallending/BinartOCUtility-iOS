#import "BAMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSOrderedSet ( BAUtil )

- (void)mt_each:(void (^)(id obj))block;
- (void)mt_apply:(void (^)(id obj))block;
- (nullable id)mt_match:(BOOL (^)(id obj))block;
- (NSOrderedSet *)mt_select:(BOOL (^)(id obj))block;
- (NSOrderedSet *)mt_reject:(BOOL (^)(id obj))block;
- (NSOrderedSet *)mt_map:(id (^)(id obj))block;
- (nullable id)mt_reduce:(nullable id)initial withBlock:(__nullable id (^)(__nullable id sum, id obj))block;
- (BOOL)mt_any:(BOOL (^)(id obj))block;
- (BOOL)mt_none:(BOOL (^)(id obj))block;
- (BOOL)mt_all:(BOOL (^)(id obj))block;

/** Tests whether every element of this ordered set relates to the corresponding
 element of another array according to match by block.
 */
- (BOOL)mt_corresponds:(NSOrderedSet *)list withBlock:(BOOL (^)(id obj1, id obj2))block;

@end

@interface NSSet ( BAUtil )

- (void)mt_each:(void (^)(id obj))block;
- (void)mt_eachWithIndex:(void (^)(id obj, int idx))block;
- (void)mt_apply:(void (^)(id obj))block;
- (nullable id)mt_match: (BOOL (^)(id obj))block;
- (NSSet *)mt_select: (BOOL (^)(id obj))block;
- (NSSet *)mt_reject:(BOOL (^)(id obj))block;
- (NSSet *)mt_map: (id (^)(id obj))block;
- (id)mt_reduce:(id)initial withBlock:(id (^)(id sum, id obj))block;
- (BOOL)mt_any:(BOOL (^)(id obj))block;
- (BOOL)mt_none:(BOOL (^)(id obj))block;
- (BOOL)mt_all:(BOOL (^)(id obj))block;
- (NSSet *)mt_sort;

@end

NS_ASSUME_NONNULL_END

