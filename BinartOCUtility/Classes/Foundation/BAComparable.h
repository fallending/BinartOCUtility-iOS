#import "BAMacros.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, BACompareResult) {
    BACompareResultSmaller = -1,
    BACompareResultEqual = 0,
    BACompareResultBigger = 1,
    BACompareResultUnknown = NSIntegerMax,
};

@protocol BAComparable <NSObject>

- (BACompareResult)compareTo:(id <BAComparable>)other;

@end


@interface NSNumber (BAComparable) <BAComparable>

@end


NS_ASSUME_NONNULL_END
