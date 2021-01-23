#import "BAMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface BAAtomicNSInteger : NSObject

- (instancetype)initWithValue:(NSInteger)val;
- (NSInteger)getValue;
- (void)setValue:(NSInteger)value;
- (BOOL)compareTo:(NSInteger)expected andSetValue:(NSInteger)value;
- (NSInteger)getAndSetValue:(NSInteger)value;

// Return old value and update
- (NSInteger)getAndIncrementValue;
- (NSInteger)getAndDecrementValue;
- (NSInteger)getAndAddValue:(NSInteger)delta;

// Update and return new value
- (NSInteger)incrementAndGetValue;
- (NSInteger)decrementAndGetValue;
- (NSInteger)addAndGetValue:(NSInteger)delta;

@end

NS_ASSUME_NONNULL_END
