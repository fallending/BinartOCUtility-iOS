
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 分发队列池，拥有多个串行队列，使用它来控制队列的线程数，取代并发队列
 */
@interface BADispatchQueuePool : NSObject
- (instancetype)init UNAVAILABLE_ATTRIBUTE;
+ (instancetype)new UNAVAILABLE_ATTRIBUTE;

/**
 Creates and returns a dispatch queue pool.
 @param name       The name of the pool.
 @param queueCount Maxmium queue count, should in range (1, 32).
 @param qos        Queue quality of service (QOS).
 @return A new pool, or nil if an error occurs.
 */
- (instancetype)initWithName:(nullable NSString *)name queueCount:(NSUInteger)queueCount qos:(NSQualityOfService)qos;

/// Pool's name.
@property (nullable, nonatomic, readonly) NSString *name;

/// Get a serial queue from pool.
- (dispatch_queue_t)queue;

+ (instancetype)defaultPoolForQOS:(NSQualityOfService)qos;

@end

/**
 异步触发器
 */

@interface BAAsync : NSObject

+ (void)inMain:(dispatch_block_t)block;
+ (void)inGlobal:(dispatch_block_t)block;

+ (void)inMain:(dispatch_block_t)block after:(NSTimeInterval)seconds;
+ (void)inGlobal:(dispatch_block_t)block after:(NSTimeInterval)seconds;

@end

NS_ASSUME_NONNULL_END
