#import "BAMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSMapTable ( BAUtil )

/** Loops through the maptable and executes the given block using each item.
 */
- (void)ba_each:(void (^)(id key, id obj))block;

/** Loops through a maptable to find the first key/value pair matching the block.
 */
- (nullable id)ba_match:(BOOL (^)(id key, id obj))block;

/** Loops through a maptable to find the key/value pairs matching the block.
 */
- (NSMapTable *)ba_select:(BOOL (^)(id key, id obj))block;

/** Loops through a maptable to find the key/value pairs not matching the block.
 */
- (NSMapTable *)ba_reject:(BOOL (^)(id key, id obj))block;

/** Call the block once for each object and create a maptable with the same keys
 and a new set of values.
 */
- (NSMapTable *)ba_map:(id (^)(id key, id obj))block;

/** Loops through a maptable to find whether any key/value pair matches the block.
 */
- (BOOL)ba_any:(BOOL (^)(id key, id obj))block;

/** Loops through a maptable to find whether no key/value pairs match the block.
 */
- (BOOL)ba_none:(BOOL (^)(id key, id obj))block;

/** Loops through a maptable to find whether all key/value pairs match the block.
 */
- (BOOL)ba_all:(BOOL (^)(id key, id obj))block;

@end

NS_ASSUME_NONNULL_END
