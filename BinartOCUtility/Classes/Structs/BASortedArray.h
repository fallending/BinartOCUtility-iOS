
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BASortedMutableArray : NSArray

- (id)initWithDescriptors:(NSArray *)descriptors;
- (id)initWithComparator:(NSComparator)comparator;
- (id)initWithFunction:(NSInteger (*)(id, id, void *))compare context:(void *)context;
- (id)initWithSelector:(SEL)selector;

- (NSUInteger)addObject:(id)obj;
- (NSIndexSet*)addObjectsFromArray:(NSArray*)otherArray;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (void)removeObjectsInRange:(NSRange)range;
- (void)removeAllObjects;
- (void)removeLastObject;

@end

NS_ASSUME_NONNULL_END
