#import "BAComparable.h"

@implementation NSNumber (LLCComparable)

- (BACompareResult)compareTo:(id <BAComparable>)other {
    if (!other || ![other isKindOfClass:self.class]) {
        return BACompareResultBigger;
    }

    BACompareResult result;
    switch ([self compare:(NSNumber *)other]) {
        case NSOrderedAscending:
            result = BACompareResultSmaller;
            break;
        case NSOrderedSame:
            result = BACompareResultEqual;
            break;
        case NSOrderedDescending:
        default:
            result = BACompareResultBigger;
            break;
    }
    return result;
}

@end
