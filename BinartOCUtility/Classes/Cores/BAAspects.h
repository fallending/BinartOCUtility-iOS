
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AspectErrorCode) {
    AspectErrorSelectorBlacklisted,                   // Selectors like release, retain, autorelease are blacklist.
    AspectErrorDoesNotRespondToSelector,              // Selector could not be found.
    AspectErrorSelectorDeallocPosition,               // When hooking dealloc, only AspectPositionBefore is allowed.
    AspectErrorSelectorAlreadyHookedInClassHierarchy, // Statically hooking the same method in subclasses is not allowed.
    AspectErrorFailedToAllocateClassPair,             // The runtime failed creating a class pair.
    AspectErrorMissingBlockSignature,                 // The block misses compile time signature info and can't be called.
    AspectErrorIncompatibleBlockSignature,            // The block signature does not match the method or is too large.
    
    AspectErrorRemoveObjectAlreadyDeallocated = 100   // (for removing) The object hooked is already deallocated.
};

typedef NS_OPTIONS(NSUInteger, AspectOptions) {
    AspectPositionAfter   = 0,            // Called after the original implementation (default)
    AspectPositionInstead = 1,            // Will replace the original implementation.
    AspectPositionBefore  = 2,            // Called before the original implementation.
    
    AspectOptionAutomaticRemoval = 1 << 3 // Will remove the hook after the first execution.
};

extern NSString *const AspectErrorDomain;

/**
 *  Opaque Aspect Token that allows to deregister the hook.
 */
@protocol AspectToken <NSObject>

- (BOOL)remove;

@end

/**
 *  The AspectInfo protocol is the first parameter of our block syntax.
 */
@protocol AspectInfo <NSObject>

// The instance that is currently hooked.
- (id)instance;

// The original invocation of the hooked method.
- (NSInvocation *)originalInvocation;

// All method arguments, boxed. This is lazily evaluated.
- (NSArray *)arguments;

@end

/**
 *  Aspects uses Objective-C message forwarding to hook into messages. This will create some overhead. Don't add aspects to methods that are called a lot. Aspects is meant for view/controller code that is not called a 1000 times per second.
 *
 *  Adding aspects returns an opaque token which can be used to deregister again. All calls are thread safe.
 */
@interface NSObject (Aspects)

/**
 *  Adds a block of code before/instead/after the current `selector` for a specific class.
 *
 *  @param block Aspects replicates the type signature of the method being hooked.
 *  The first parameter will be `id<AspectInfo>`, followed by all parameters of the method.
 *  These parameters are optional and will be filled to match the block signature.
 *  You can even use an empty block, or one that simple gets `id<AspectInfo>`.
 *
 *  @note Hooking static methods is not supported.
 *  @return A token which allows to later deregister the aspect.
 */
+ (id<AspectToken>)hookSelector:(SEL)selector withOptions:(AspectOptions)options usingBlock:(id)block error:(NSError * __strong *)error;

/**
 *  Adds a block of code before/instead/after the current `selector` for a specific instance.
 */
- (id<AspectToken>)hookSelector:(SEL)selector withOptions:(AspectOptions)options usingBlock:(id)block error:(NSError * __strong *)error;

@end

#pragma mark -

@interface NSObject ( AspectLifeCycle )

- (void)onWillDealloc:(void (^)(void))handler;

@end

NS_ASSUME_NONNULL_END
