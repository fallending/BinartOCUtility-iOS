
#import <Foundation/Foundation.h>

typedef void (^ BAChronographTimeBlock)(NSString *timeString);

@interface BAChronograph : NSObject

/**
 * @brief 启动秒表，包括暂停和继续
 */
- (void)start:(BAChronographTimeBlock) timeBlock;

/**
 * @brief 重置秒表，归0
 */
- (void)reset;

@end
