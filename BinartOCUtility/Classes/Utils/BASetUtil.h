#import "BAMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSOrderedSet ( BAUtil )

- (void)ba_each:(void (^)(id obj))block;
- (void)ba_apply:(void (^)(id obj))block;
- (nullable id)ba_match:(BOOL (^)(id obj))block;
- (NSOrderedSet *)ba_select:(BOOL (^)(id obj))block;
- (NSOrderedSet *)ba_reject:(BOOL (^)(id obj))block;
- (NSOrderedSet *)ba_map:(id (^)(id obj))block;
- (nullable id)ba_reduce:(nullable id)initial withBlock:(__nullable id (^)(__nullable id sum, id obj))block;
- (BOOL)ba_any:(BOOL (^)(id obj))block;
- (BOOL)ba_none:(BOOL (^)(id obj))block;
- (BOOL)ba_all:(BOOL (^)(id obj))block;

/** Tests whether every element of this ordered set relates to the corresponding
 element of another array according to match by block.
 */
- (BOOL)ba_corresponds:(NSOrderedSet *)list withBlock:(BOOL (^)(id obj1, id obj2))block;

@end

@interface NSSet ( BAUtil )

- (void)ba_each:(void (^)(id obj))block;
- (void)ba_eachWithIndex:(void (^)(id obj, int idx))block;
- (void)ba_apply:(void (^)(id obj))block;
- (nullable id)ba_match: (BOOL (^)(id obj))block;
- (NSSet *)ba_select: (BOOL (^)(id obj))block;
- (NSSet *)ba_reject:(BOOL (^)(id obj))block;
- (NSSet *)ba_map: (id (^)(id obj))block;
- (id)ba_reduce:(id)initial withBlock:(id (^)(id sum, id obj))block;
- (BOOL)ba_any:(BOOL (^)(id obj))block;
- (BOOL)ba_none:(BOOL (^)(id obj))block;
- (BOOL)ba_all:(BOOL (^)(id obj))block;
- (NSSet *)ba_sort;

@end

NS_ASSUME_NONNULL_END

