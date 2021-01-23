
#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject ( BA )

/**
 *  通过Block方式注册一个KVO，通过该方式注册的KVO无需手动移除，其会在被监听对象销毁的时候自动移除,所以下面的两个移除方法一般无需使用
 *
 *  @param keyPath 监听路径
 *  @param block   KVO回调block，obj为监听对象，oldVal为旧值，newVal为新值
 */
- (void)ba_observe:(NSString *)keyPath block:(void (^)(id obj, id oldVal, id newVal))block;

@end



