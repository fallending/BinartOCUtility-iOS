#import "BAMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSMapTable ( BAUtil )

- (void)ba_each:(void (^)(id key, id obj))block;
- (nullable id)ba_match:(BOOL (^)(id key, id obj))block;
- (NSMapTable *)ba_select:(BOOL (^)(id key, id obj))block;
- (NSMapTable *)ba_reject:(BOOL (^)(id key, id obj))block;
- (NSMapTable *)ba_map:(id (^)(id key, id obj))block;
- (BOOL)ba_any:(BOOL (^)(id key, id obj))block;
- (BOOL)ba_none:(BOOL (^)(id key, id obj))block;
- (BOOL)ba_all:(BOOL (^)(id key, id obj))block;

@end

NS_ASSUME_NONNULL_END
