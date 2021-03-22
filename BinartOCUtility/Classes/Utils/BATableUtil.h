#import "BAMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSMapTable ( BAUtil )

- (void)mt_each:(void (^)(id key, id obj))block;
- (nullable id)mt_match:(BOOL (^)(id key, id obj))block;
- (NSMapTable *)mt_select:(BOOL (^)(id key, id obj))block;
- (NSMapTable *)mt_reject:(BOOL (^)(id key, id obj))block;
- (NSMapTable *)mt_map:(id (^)(id key, id obj))block;
- (BOOL)mt_any:(BOOL (^)(id key, id obj))block;
- (BOOL)mt_none:(BOOL (^)(id key, id obj))block;
- (BOOL)mt_all:(BOOL (^)(id key, id obj))block;

@end

NS_ASSUME_NONNULL_END
