#import "BANumberUtil.h"

@implementation NSNumber ( BAUtil )

- (NSString *)ba_toDisplayNumberWithDigit:(NSInteger)digit {
    NSString *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:digit];
    
    result = [formatter  stringFromNumber:self];
    
    if (result == nil)
        return @"";
    
    return result;
}

- (NSString *)ba_toDisplayPercentageWithDigit:(NSInteger)digit {
    NSString *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setNumberStyle:NSNumberFormatterPercentStyle];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:digit];
    
    result = [formatter  stringFromNumber:self];
    
    return result;
}

- (NSNumber *)ba_doRoundWithDigit:(NSUInteger)digit {
    NSNumber *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:digit];
    [formatter setMinimumFractionDigits:digit];
    
    result = [NSNumber numberWithDouble:[[formatter  stringFromNumber:self] doubleValue]];
    
    return result;
}

- (NSNumber *)ba_doCeilWithDigit:(NSUInteger)digit {
    NSNumber *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setRoundingMode:NSNumberFormatterRoundCeiling];
    [formatter setMaximumFractionDigits:digit];
    
    result = [NSNumber numberWithDouble:[[formatter  stringFromNumber:self] doubleValue]];
    
    return result;
}

- (NSNumber *)ba_doFloorWithDigit:(NSUInteger)digit {
    NSNumber *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setRoundingMode:NSNumberFormatterRoundFloor];
    [formatter setMaximumFractionDigits:digit];
    
    result = [NSNumber numberWithDouble:[[formatter  stringFromNumber:self] doubleValue]];
    
    return result;
}

- (void)ba_times:(void (^)(void))block {
    NSParameterAssert(block != nil);
    
    for (NSInteger idx = 0 ; idx < self.integerValue ; ++idx ) {
        block();
    }
}

@end
