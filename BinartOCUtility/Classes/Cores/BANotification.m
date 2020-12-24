#import "BANotification.h"
#import "BARuntime.h"

#import "_pragma_push.h"

@implementation NSNotification ( BA )

- (BOOL)ba_is:(NSString *)name {
    return [self.name isEqualToString:name];
}

- (BOOL)ba_isKindOf:(NSString *)prefix {
    return [self.name hasPrefix:prefix];
}

+ (instancetype)ba_named:(NSString *)aName {
    return [NSNotification notificationWithName:aName object:nil];
}

@end

@implementation NSObject ( NotificationResponder )

- (void)ba_handleNotification:(NSNotification *)notification {
}

- (void)ba_observeNotification:(NSString *)notificationName {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:notificationName
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(ba_handleNotification:)
                                                 name:notificationName
                                               object:nil];
}

- (void)ba_observeAllNotifications {
    NSArray * methods = [[self class] ba_methodsWithPrefix:@"ba_handleNotification:" untilClass:[NSObject class]];
    
    if ( nil == methods || 0 == methods.count ) {
        return;
    }
    
    for ( NSString * selectorName in methods ) {
        SEL sel = NSSelectorFromString( selectorName );
        if ( NULL == sel )
            continue;
        
        NSMutableString * notificationName = [self performSelector:sel];
        if ( nil == notificationName  )
            continue;
        
        [self ba_observeNotification:notificationName];
    }
}

- (void)ba_unobserveNotification:(NSString *)name {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:name
                                                  object:nil];
}

- (void)ba_unobserveAllNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation NSObject (NotificationSender)

+ (BOOL)ba_postNotification:(NSString *)name {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
    return YES;
}

- (BOOL)ba_postNotification:(NSString *)name {
    return [[self class] ba_postNotification:name];
}

+ (BOOL)ba_postNotification:(NSString *)name withObject:(NSObject *)object {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:object];
    return YES;
}

- (BOOL)ba_postNotification:(NSString *)name withObject:(NSObject *)object {
    return [[self class] ba_postNotification:name withObject:object];
}

- (void)ba_postNotificationOnMainThread:(NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
}

- (void)ba_postNotificationOnMainThreadName:(NSString *)aName object:(id)anObject {
    NSNotification *notification = [NSNotification notificationWithName:aName object:anObject];
    [self ba_postNotificationOnMainThread:notification];
}

- (void)ba_postNotificationOnMainThreadName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
    NSNotification *notification = [NSNotification notificationWithName:aName object:anObject userInfo:aUserInfo];
    [self ba_postNotificationOnMainThread:notification];
}

@end

#import "_pragma_pop.h"
