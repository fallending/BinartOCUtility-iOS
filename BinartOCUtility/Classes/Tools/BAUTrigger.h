//
//  BAUTrigger.h
//  BinartOCUtility
//
//  Created by Seven on 2020/8/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BAUTrigger : NSObject

// MARK: - Selector

+ (void)performSelectorWithPrefix:(NSString *)prefix;

+ (id)performCallChainWithSelector:(SEL)sel;
+ (id)performCallChainWithSelector:(SEL)sel reversed:(BOOL)flag;

+ (id)performCallChainWithPrefix:(NSString *)prefix;
+ (id)performCallChainWithPrefix:(NSString *)prefix reversed:(BOOL)flag;

+ (id)performCallChainWithName:(NSString *)name;
+ (id)performCallChainWithName:(NSString *)name reversed:(BOOL)flag;

+ (id)performSelector:(SEL)selector withObjects:(NSArray *)objects;
+ (void)performSelectorOnMainThread:(SEL)selector withObject:(id)arg1 withObject:(id)arg2 waitUntilDone:(BOOL)wait;
+ (void)performSelector:(SEL)aSelector withObjects:(NSArray *)arguments afterDelay:(NSTimeInterval)delay;

// MARK: - Asynchronize block

+ (void)onMain:(void(^)(void))block;
+ (void)onMain:(void(^)(void))block after:(BOOL)seconds;

+ (void)onGlobal:(void(^)(void))block;
+ (void)onGlobal:(void(^)(void))block after:(BOOL)seconds;

@end

NS_ASSUME_NONNULL_END
