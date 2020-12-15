

// @discussion Generally, access performance is lower than NSMutableArray/... etc, but higher than using @synchronized, NSLock, or pthread_mutex_t.

#define INIT(...) self = super.init; \
if (!self) return nil; \
__VA_ARGS__; \
if (!_container) return nil; \
_lock = dispatch_semaphore_create(1); \
return self;


#define LOCK(...) dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER); \
__VA_ARGS__; \
dispatch_semaphore_signal(_lock);
