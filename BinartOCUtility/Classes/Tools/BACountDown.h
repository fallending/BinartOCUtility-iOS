
#import "BAMacros.h"
#import "BAProperty.h"

typedef void(^ BACountDownProgressBlock)(NSTimeInterval timeLeft);
typedef void(^ BACountDownCompletionBlock)(void);

/// 倒计时工具
@interface BACountDown : NSObject

@PROP_READONLY( NSTimeInterval, collapsedTime ) // As Second
@PROP_READONLY( NSTimeInterval, leftTime )  // As Second

@PROP_ASSIGN( NSTimeInterval, interval )    // [1] As Second

/// 初始化倒计时器
- (instancetype)initWithDuration:(NSTimeInterval)duration; // Per Second

/// 设置剩余时间，需要手动重启
- (void)setDuration:(NSTimeInterval)duration;

/// 开始倒计时
- (void)start:(BACountDownProgressBlock)currentBlock;
- (void)start:(BACountDownProgressBlock)currentBlock completion:(BACountDownCompletionBlock)completion;

/// 暂停倒计时器
- (void)pause;

/// 恢复倒计时器
- (void)resume;

/// 停止倒计时器
- (void)stop;

@end
