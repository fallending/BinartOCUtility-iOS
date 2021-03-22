#import "BANumberUtil.h"

@implementation NSNumber ( BAUtil )

- (NSString *)mt_toDisplayNumberWithDigit:(NSInteger)digit {
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

- (NSString *)mt_toDisplayPercentageWithDigit:(NSInteger)digit {
    NSString *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setNumberStyle:NSNumberFormatterPercentStyle];
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:digit];
    
    result = [formatter  stringFromNumber:self];
    
    return result;
}

- (NSNumber *)mt_doRoundWithDigit:(NSUInteger)digit {
    NSNumber *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setRoundingMode:NSNumberFormatterRoundHalfUp];
    [formatter setMaximumFractionDigits:digit];
    [formatter setMinimumFractionDigits:digit];
    
    result = [NSNumber numberWithDouble:[[formatter  stringFromNumber:self] doubleValue]];
    
    return result;
}

- (NSNumber *)mt_doCeilWithDigit:(NSUInteger)digit {
    NSNumber *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setRoundingMode:NSNumberFormatterRoundCeiling];
    [formatter setMaximumFractionDigits:digit];
    
    result = [NSNumber numberWithDouble:[[formatter  stringFromNumber:self] doubleValue]];
    
    return result;
}

- (NSNumber *)mt_doFloorWithDigit:(NSUInteger)digit {
    NSNumber *result = nil;
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    
    [formatter setRoundingMode:NSNumberFormatterRoundFloor];
    [formatter setMaximumFractionDigits:digit];
    
    result = [NSNumber numberWithDouble:[[formatter  stringFromNumber:self] doubleValue]];
    
    return result;
}

- (void)mt_times:(void (^)(void))block {
    NSParameterAssert(block != nil);
    
    for (NSInteger idx = 0 ; idx < self.integerValue ; ++idx ) {
        block();
    }
}

@end
