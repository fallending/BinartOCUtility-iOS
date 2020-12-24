
#import <Foundation/Foundation.h>

#undef  NOTIFICATION
#define NOTIFICATION( name ) \
        STATIC_PROPERTY( name )

#undef  DEF_NOTIFICATION
#define DEF_NOTIFICATION( name ) \
        DEF_STATIC_PROPERTY2( name, @"notification", NSStringFromClass([self class]) )

NS_ASSUME_NONNULL_BEGIN

@interface NSNotification ( BA )

/// 将通知的对等，等同于其name
- (BOOL)ba_is:(NSString *)name;

/// 将通知的比较，利用前缀匹配
- (BOOL)ba_isKindOf:(NSString *)prefix; // 前缀匹配

/// 用通知的name实例化一个通知对象
+ (instancetype)ba_named:(NSString *)name;

@end

@interface NSObject ( NotificationResponder )

- (void)ba_handleNotification:(NSNotification *)notification; // 通知响应函数模板 ^_^

- (void)ba_observeNotification:(NSString *)name;
- (void)ba_observeAllNotifications;

- (void)ba_unobserveNotification:(NSString *)name;
- (void)ba_unobserveAllNotifications;

@end

@interface NSObject ( NotificationSender )

+ (BOOL)ba_postNotification:(NSString *)name;
- (BOOL)ba_postNotification:(NSString *)name;

+ (BOOL)ba_postNotification:(NSString *)name withObject:(NSObject *)object;
- (BOOL)ba_postNotification:(NSString *)name withObject:(NSObject *)object;

- (void)ba_postNotificationOnMainThread:(NSNotification *)notification;
- (void)ba_postNotificationOnMainThreadName:(NSString *)name object:(id)object;
- (void)ba_postNotificationOnMainThreadName:(NSString *)name object:(id)object userInfo:(NSDictionary *)userInfo;

@end

NS_ASSUME_NONNULL_END
