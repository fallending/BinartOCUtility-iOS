#import "BAMacros.h"

@interface NSNumber ( BAUtil )

/// 展示
- (NSString *)mt_toDisplayNumberWithDigit:(NSInteger)digit;
- (NSString *)mt_toDisplayPercentageWithDigit:(NSInteger)digit;

/// 四舍五入
- (NSNumber *)mt_doRoundWithDigit:(NSUInteger)digit;

/// 取上整
- (NSNumber *)mt_doCeilWithDigit:(NSUInteger)digit;

/// 取下整
- (NSNumber *)mt_doFloorWithDigit:(NSUInteger)digit;
    
/// 循环执行
- (void)mt_times:(void (^)(void))block;

@end
