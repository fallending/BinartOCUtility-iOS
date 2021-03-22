#import "BANotification.h"
#import "BARuntime.h"

#import "_pragma_push.h"

@implementation NSNotification ( BA )

- (BOOL)mt_is:(NSString *)name {
    return [self.name isEqualToString:name];
}

- (BOOL)mt_isKindOf:(NSString *)prefix {
    return [self.name hasPrefix:prefix];
}

+ (instancetype)mt_named:(NSString *)aName {
    return [NSNotification notificationWithName:aName object:nil];
}

@end

@implementation NSObject ( NotificationResponder )

- (void)mt_handleNotification:(NSNotification *)notification {
}

- (void)mt_observeNotification:(NSString *)notificationName {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:notificationName
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mt_handleNotification:)
                                                 name:notificationName
                                               object:nil];
}

- (void)mt_observeAllNotifications {
    NSArray * methods = [[self class] mt_methodsWithPrefix:@"mt_handleNotification:" untilClass:[NSObject class]];
    
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
        
        [self mt_observeNotification:notificationName];
    }
}

- (void)mt_unobserveNotification:(NSString *)name {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:name
                                                  object:nil];
}

- (void)mt_unobserveAllNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

@implementation NSObject (NotificationSender)

+ (BOOL)mt_postNotification:(NSString *)name {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:nil];
    return YES;
}

- (BOOL)mt_postNotification:(NSString *)name {
    return [[self class] mt_postNotification:name];
}

+ (BOOL)mt_postNotification:(NSString *)name withObject:(NSObject *)object {
    [[NSNotificationCenter defaultCenter] postNotificationName:name object:object];
    return YES;
}

- (BOOL)mt_postNotification:(NSString *)name withObject:(NSObject *)object {
    return [[self class] mt_postNotification:name withObject:object];
}

- (void)mt_postNotificationOnMainThread:(NSNotification *)notification {
    [self performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:YES];
}

- (void)mt_postNotificationOnMainThreadName:(NSString *)aName object:(id)anObject {
    NSNotification *notification = [NSNotification notificationWithName:aName object:anObject];
    [self mt_postNotificationOnMainThread:notification];
}

- (void)mt_postNotificationOnMainThreadName:(NSString *)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
    NSNotification *notification = [NSNotification notificationWithName:aName object:anObject userInfo:aUserInfo];
    [self mt_postNotificationOnMainThread:notification];
}

@end

#import "_pragma_pop.h"
