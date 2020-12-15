
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BAThreadSafeSet : NSObject

+ (instancetype)set;
+ (instancetype)setWithCapacity:(NSUInteger)num;
+ (instancetype)setWithArray:(NSArray *)array;
+ (instancetype)setWithObject:(id)object;

- (void)addObject:(id)object;
- (void)addObjectsFromArray:(NSArray *)array;

- (void)removeObject:(id)object;
- (void)removeAllObjects;

- (NSUInteger)count;
- (nullable NSArray *)allObjects;

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block;

@end

NS_ASSUME_NONNULL_END
