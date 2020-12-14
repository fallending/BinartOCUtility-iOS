#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 A proxy used to hold a weak object.
 It can be used to avoid retain cycles, such as the target in NSTimer or CADisplayLink.

 Example:

    @implementation MyView {
       NSTimer *_timer;
    }
    
    - (void)initTimer {
       YYWeakProxy *proxy = [YYWeakProxy proxyWithTarget:self];
       _timer = [NSTimer timerWithTimeInterval:0.1 target:proxy selector:@selector(tick:) userInfo:nil repeats:YES];
    }
    
    - (void)tick:(NSTimer *)timer {...}
    @end
*/
@interface BAWeakProxy : NSProxy

@property (nullable, nonatomic, weak, readonly) id target;

- (instancetype)initWithTarget:(id)target;

+ (instancetype)proxyWithTarget:(id)target;

@end

NS_ASSUME_NONNULL_END
