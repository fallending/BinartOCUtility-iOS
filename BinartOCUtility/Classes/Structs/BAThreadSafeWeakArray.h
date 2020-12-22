
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Usage

// 1. 遍历
// for (id item in weakArray.objectEnumerator) {
//      [item isProxy];
// }

@interface BAThreadSafeWeakArray : NSObject // : NSMutableArray

- (NSUInteger)count;

- (BOOL)containsObject:(id)anObject;

- (NSEnumerator *)objectEnumerator;

- (void)addObject:(id)anObject;

- (void)removeAllObjects;

- (void)removeObject:(id)anObject;

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id _Nonnull __unsafe_unretained[_Nonnull])stackbuf
                                    count:(NSUInteger)len;

@end

NS_ASSUME_NONNULL_END
