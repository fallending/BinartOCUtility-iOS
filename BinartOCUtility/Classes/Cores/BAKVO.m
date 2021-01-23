#import "BAProperty.h"
#import "BAKVO.h"

#import <objc/message.h>
#import <objc/runtime.h>


#pragma mark - 私有实现KVO的真实target类，每一个target对应了一个keyPath和监听该keyPath的所有block，当其KVO方法调用时，需要回调所有的block

@interface _BlockTarget : NSObject

- (void)addBlock:(void(^)(__weak id obj, id oldValue, id newValue))block;

@end

@implementation _BlockTarget {
    NSMutableSet *_kvoBlockSet;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _kvoBlockSet = [NSMutableSet new];
    }
    return self;
}

- (void)addBlock:(void(^)(__weak id obj, id oldValue, id newValue))block{
    [_kvoBlockSet addObject:[block copy]];
}

- (void)observe:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if (!_kvoBlockSet.count) return;
    BOOL prior = [[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue];
    
    if (prior) return;
    
    NSKeyValueChange changeKind = [[change objectForKey:NSKeyValueChangeKindKey] integerValue];
    if (changeKind != NSKeyValueChangeSetting) return;
    id oldVal = [change objectForKey:NSKeyValueChangeOldKey];
    if (oldVal == [NSNull null]) oldVal = nil;
    id newVal = [change objectForKey:NSKeyValueChangeNewKey];
    if (newVal == [NSNull null]) newVal = nil;
    
    [_kvoBlockSet enumerateObjectsUsingBlock:^(void (^block)(__weak id obj, id oldVal, id newVal), BOOL * _Nonnull stop) {
        block(object, oldVal, newVal);
    }];
}

@end

@implementation NSObject ( BA )

static void *const __KVOBlockKey = "KVOBlockKey";

- (void)ba_observe:(NSString*)keyPath block:(void (^)(id obj, id oldVal, id newVal))block {
    if (!keyPath || !block) return;
    //取出存有所有KVOTarget的字典
    NSMutableDictionary *allTargets = objc_getAssociatedObject(self, __KVOBlockKey);
    if (!allTargets) {
        //没有则创建
        allTargets = [NSMutableDictionary new];
        //绑定在该对象中
        objc_setAssociatedObject(self, __KVOBlockKey, allTargets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    //获取对应keyPath中的所有target
    _BlockTarget *targetForKeyPath = allTargets[keyPath];
    if (!targetForKeyPath) {
        //没有则创建
        targetForKeyPath = [_BlockTarget new];
        //保存
        allTargets[keyPath] = targetForKeyPath;
        //如果第一次，则注册对keyPath的KVO监听
        [self addObserver:targetForKeyPath forKeyPath:keyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    }
    [targetForKeyPath addBlock:block];
    //对第一次注册KVO的类进行dealloc方法调剂
    [self _swizzleDealloc];
}

- (void)unobserveForKeyPath:(NSString *)keyPath{
    if (!keyPath.length) return;
    NSMutableDictionary *allTargets = objc_getAssociatedObject(self, __KVOBlockKey);
    if (!allTargets) return;
    _BlockTarget *target = allTargets[keyPath];
    if (!target) return;
    [self removeObserver:target forKeyPath:keyPath];
    [allTargets removeObjectForKey:keyPath];
}

- (void)unobserveForAllKeyPath {
    NSMutableDictionary *allTargets = objc_getAssociatedObject(self, __KVOBlockKey);
    if (!allTargets) return;
    [allTargets enumerateKeysAndObjectsUsingBlock:^(id key, _BlockTarget *target, BOOL *stop) {
        [self removeObserver:target forKeyPath:key];
    }];
    [allTargets removeAllObjects];
}

static void * deallocHasSwizzledKey = "deallocHasSwizzledKey";

/**
 *  调剂dealloc方法，由于无法直接使用运行时的swizzle方法对dealloc方法进行调剂，所以稍微麻烦一些
 */
- (void)_swizzleDealloc {
    //我们给每个类绑定上一个值来判断dealloc方法是否被调剂过，如果调剂过了就无需再次调剂了
    BOOL swizzled = [objc_getAssociatedObject(self.class, deallocHasSwizzledKey) boolValue];
    //如果调剂过则直接返回
    if (swizzled) return;
    //开始调剂
    Class swizzleClass = self.class;
    //获取原有的dealloc方法
    SEL deallocSelector = sel_registerName("dealloc");
    //初始化一个函数指针用于保存原有的dealloc方法
    __block void (*originalDealloc)(__unsafe_unretained id, SEL) = NULL;
    //实现我们自己的dealloc方法，通过block的方式
    id newDealloc = ^(__unsafe_unretained id objSelf){
        [objSelf unobserveForAllKeyPath];
        
        //根据原有的dealloc方法是否存在进行判断
        if (originalDealloc == NULL) {//如果不存在，说明本类没有实现dealloc方法，则需要向父类发送dealloc消息(objc_msgSendSuper)
            //构造objc_msgSendSuper所需要的参数，.receiver为方法的实际调用者，即为类本身，.super_class指向其父类
            struct objc_super superInfo = {
                .receiver = objSelf,
                .super_class = class_getSuperclass(swizzleClass)
            };
            //构建objc_msgSendSuper函数
            void (*msgSend)(struct objc_super *, SEL) = (__typeof__(msgSend))objc_msgSendSuper;
            //向super发送dealloc消息
            msgSend(&superInfo, deallocSelector);
        }else{//如果存在，表明该类实现了dealloc方法，则直接调用即可
            //调用原有的dealloc方法
            originalDealloc(objSelf, deallocSelector);
        }
    };
    //根据block构建新的dealloc实现IMP
    IMP newDeallocIMP = imp_implementationWithBlock(newDealloc);
    //尝试添加新的dealloc方法，如果该类已经复写的dealloc方法则不能添加成功，反之则能够添加成功
    if (!class_addMethod(swizzleClass, deallocSelector, newDeallocIMP, "v@:")) {
        //如果没有添加成功则保存原有的dealloc方法，用于新的dealloc方法中
        Method deallocMethod = class_getInstanceMethod(swizzleClass, deallocSelector);
        originalDealloc = (void(*)(__unsafe_unretained id, SEL))method_getImplementation(deallocMethod);
        originalDealloc = (void(*)(__unsafe_unretained id, SEL))method_setImplementation(deallocMethod, newDeallocIMP);
    }
    //标记该类已经调剂过了
    objc_setAssociatedObject(self.class, deallocHasSwizzledKey, @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end
