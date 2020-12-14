

#import <UIKit/UIKit.h>
#import <libkern/OSAtomic.h>

#import "BAQueues.h"

// MARK: - BADispatchQueuePool

#define MAX_QUEUE_COUNT 8

static inline qos_class_t NSQualityOfServiceToQOSClass(NSQualityOfService qos) {
    switch (qos) {
        case NSQualityOfServiceUserInteractive: return QOS_CLASS_USER_INTERACTIVE;
        case NSQualityOfServiceUserInitiated: return QOS_CLASS_USER_INITIATED;
        case NSQualityOfServiceUtility: return QOS_CLASS_UTILITY;
        case NSQualityOfServiceBackground: return QOS_CLASS_BACKGROUND;
        case NSQualityOfServiceDefault: return QOS_CLASS_DEFAULT;
        default: return QOS_CLASS_UNSPECIFIED;
    }
}

typedef struct {
    const char *name;
    void **queues;
    uint32_t queueCount;
    int32_t counter;
} BADispatchContext;

static BADispatchContext *BADispatchContextCreate(const char *name, uint32_t queueCount, NSQualityOfService qos) {
    BADispatchContext *context = calloc(1, sizeof(BADispatchContext));
    if (!context) return NULL;
    context->queues = calloc(queueCount, sizeof(void *));
    if (!context->queues) {
        free(context);
        return NULL;
    }
    
    dispatch_qos_class_t qosClass = NSQualityOfServiceToQOSClass(qos);
    for (NSUInteger i = 0; i < queueCount; i++) {
        dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, qosClass, 0);
        dispatch_queue_t queue = dispatch_queue_create(name, attr);
        context->queues[i] = (__bridge_retained void *)(queue);
    }

    context->queueCount = queueCount;
    if (name) {
         context->name = strdup(name);
    }
    return context;
}

static void BADispatchContextRelease(BADispatchContext *context) {
    if (!context) return;
    if (context->queues) {
        for (NSUInteger i = 0; i < context->queueCount; i++) {
            void *queuePointer = context->queues[i];
            dispatch_queue_t queue = (__bridge_transfer dispatch_queue_t)(queuePointer);
            const char *name = dispatch_queue_get_label(queue);
            if (name) strlen(name);
            queue = nil;
        }
        free(context->queues);
        context->queues = NULL;
    }
    if (context->name) free((void *)context->name);
    free(context);
}

static dispatch_queue_t BADispatchContextGetQueue(BADispatchContext *context) {
    uint32_t counter = (uint32_t)OSAtomicIncrement32(&context->counter);
    void *queue = context->queues[counter % context->queueCount];
    return (__bridge dispatch_queue_t)(queue);
}


static BADispatchContext *BADispatchContextGetForQOS(NSQualityOfService qos) {
    static BADispatchContext *context[5] = {0};
    switch (qos) {
        case NSQualityOfServiceUserInteractive: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[0] = BADispatchContextCreate("com.binart.queuepool.user-interactive", count, qos);
            });
            return context[0];
        } break;
        case NSQualityOfServiceUserInitiated: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[1] = BADispatchContextCreate("com.binart.queuepool.user-initiated", count, qos);
            });
            return context[1];
        } break;
        case NSQualityOfServiceUtility: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[2] = BADispatchContextCreate("com.binart.queuepool.utility", count, qos);
            });
            return context[2];
        } break;
        case NSQualityOfServiceBackground: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[3] = BADispatchContextCreate("com.binart.queuepool.background", count, qos);
            });
            return context[3];
        } break;
        case NSQualityOfServiceDefault:
        default: {
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                int count = (int)[NSProcessInfo processInfo].activeProcessorCount;
                count = count < 1 ? 1 : count > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : count;
                context[4] = BADispatchContextCreate("com.binart.queuepool.default", count, qos);
            });
            return context[4];
        } break;
    }
}

@implementation BADispatchQueuePool {
    @public
    BADispatchContext *_context;
}

- (void)dealloc {
    if (_context) {
        BADispatchContextRelease(_context);
        _context = NULL;
    }
}

- (instancetype)initWithContext:(BADispatchContext *)context {
    self = [super init];
    if (!context) return nil;
    self->_context = context;
    _name = context->name ? [NSString stringWithUTF8String:context->name] : nil;
    return self;
}

- (instancetype)initWithName:(NSString *)name queueCount:(NSUInteger)queueCount qos:(NSQualityOfService)qos {
    if (queueCount == 0 || queueCount > MAX_QUEUE_COUNT) return nil;
    self = [super init];
    _context = BADispatchContextCreate(name.UTF8String, (uint32_t)queueCount, qos);
    if (!_context) return nil;
    _name = name;
    return self;
}

- (dispatch_queue_t)queue {
    return BADispatchContextGetQueue(_context);
}

+ (instancetype)defaultPoolForQOS:(NSQualityOfService)qos {
    switch (qos) {
        case NSQualityOfServiceUserInteractive: {
            static BADispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[BADispatchQueuePool alloc] initWithContext:BADispatchContextGetForQOS(qos)];
            });
            return pool;
        } break;
        case NSQualityOfServiceUserInitiated: {
            static BADispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[BADispatchQueuePool alloc] initWithContext:BADispatchContextGetForQOS(qos)];
            });
            return pool;
        } break;
        case NSQualityOfServiceUtility: {
            static BADispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[BADispatchQueuePool alloc] initWithContext:BADispatchContextGetForQOS(qos)];
            });
            return pool;
        } break;
        case NSQualityOfServiceBackground: {
            static BADispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[BADispatchQueuePool alloc] initWithContext:BADispatchContextGetForQOS(qos)];
            });
            return pool;
        } break;
        case NSQualityOfServiceDefault:
        default: {
            static BADispatchQueuePool *pool;
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                pool = [[BADispatchQueuePool alloc] initWithContext:BADispatchContextGetForQOS(NSQualityOfServiceDefault)];
            });
            return pool;
        } break;
    }
}

@end

// MARK: - BAAsync

@interface BAAsync ()

@end

@implementation BAAsync

+ (void)inMain:(dispatch_block_t)block {
    NSParameterAssert(block);
    dispatch_async(dispatch_get_main_queue(), block);
}

+ (void)inGlobal:(dispatch_block_t)block {
    NSParameterAssert(block);
    dispatch_async([BADispatchQueuePool defaultPoolForQOS:NSQualityOfServiceBackground].queue, block);
}

+ (void)inMain:(dispatch_block_t)block after:(NSTimeInterval)seconds {
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * seconds), dispatch_get_main_queue(), block);
}

+ (void)inGlobal:(dispatch_block_t)block after:(NSTimeInterval)seconds {
    NSParameterAssert(block);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * seconds), [BADispatchQueuePool defaultPoolForQOS:NSQualityOfServiceBackground].queue, block);
}

@end
