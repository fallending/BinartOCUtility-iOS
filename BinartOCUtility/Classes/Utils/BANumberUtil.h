#import "BAMacros.h"

@interface NSNumber ( BAUtil )

/// 展示
- (NSString *)ba_toDisplayNumberWithDigit:(NSInteger)digit;
- (NSString *)ba_toDisplayPercentageWithDigit:(NSInteger)digit;

/// 四舍五入
- (NSNumber *)ba_doRoundWithDigit:(NSUInteger)digit;

/// 取上整
- (NSNumber *)ba_doCeilWithDigit:(NSUInteger)digit;

/// 取下整
- (NSNumber *)ba_doFloorWithDigit:(NSUInteger)digit;
    
/// 循环执行
- (void)ba_times:(void (^)(void))block;

@end
