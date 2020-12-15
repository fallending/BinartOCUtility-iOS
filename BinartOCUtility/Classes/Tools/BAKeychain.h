
//  inspired by [soffes/SSKeychain](https://github.com/soffes/SSKeychain)

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(OSStatus, SSKeychainErrorCode) {
    /** Some of the arguments were invalid. */
    KeychainErrorBadArguments = -1001,
};

/** SSKeychain error domain */
extern NSString *const KeychainErrorDomain;

/** Account name. */
extern NSString *const KeychainAccountKey;

/**
 Time the item was created.
 
 The value will be a string.
 */
extern NSString *const KeychainCreatedAtKey;

/** Item class. */
extern NSString *const KeychainClassKey;

/** Item description. */
extern NSString *const KeychainDescriptionKey;

/** Item label. */
extern NSString *const KeychainLabelKey;

/** Time the item was last modified.
 
 The value will be a string.
 */
extern NSString *const KeychainLastModifiedKey;

/** Where the item was created. */
extern NSString *const KeychainWhereKey;

/**
 Simple wrapper for accessing accounts, getting passwords, setting passwords, and deleting passwords using the system
 Keychain on Mac OS X and iOS.
 
 This was originally inspired by EMKeychain and SDKeychain (both of which are now gone). Thanks to the authors.
 Keychain has since switched to a simpler implementation that was abstracted from [SSToolkit](http://sstoolk.it).
 */

@interface BAKeychain : NSObject

+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account;
+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error __attribute__((swift_error(none)));

+ (NSData *)passwordDataForService:(NSString *)serviceName account:(NSString *)account;
+ (NSData *)passwordDataForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error __attribute__((swift_error(none)));

+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error __attribute__((swift_error(none)));

+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error __attribute__((swift_error(none)));

+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)serviceName account:(NSString *)account;
+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error __attribute__((swift_error(none)));

+ (NSArray<NSDictionary<NSString *, id> *> *)allAccounts;
+ (NSArray<NSDictionary<NSString *, id> *> *)allAccounts:(NSError *__autoreleasing *)error __attribute__((swift_error(none)));

+ (NSArray<NSDictionary<NSString *, id> *> *)accountsForService:(NSString *)serviceName;
+ (NSArray<NSDictionary<NSString *, id> *> *)accountsForService:(NSString * _Nullable)serviceName error:(NSError *__autoreleasing *)error __attribute__((swift_error(none)));

+ (CFTypeRef)accessibilityType;
+ (void)setAccessibilityType:(CFTypeRef)accessibilityType;

@end

/**
 *  Usage
 --------------------------------
 NSError *error = nil;
 NSString *password = [_Keychain passwordForService:@"MyService" account:@"samsoffes"error:&error];
 
 if ([error code] == KeychainErrorNotFound) {
    NSLog(@"Passwordnot found");
 }
 --------------------------------
 *  Desc
 --------------------------------
 KeyChain的方法中涉及到的变量主要有三个，分别如这一小节的标题所示，是password、service、account。password、account分别保存的是密码和用户名信息。service保存的是服务的类型，就是用户名和密码是为什么应用保存的一个标志。比如一个用户可以再不同的论坛中使用相同的用户名和密码，那么service保存的信息分别标识不同的论坛。由于包名通常具有一定的唯一性，通常在程序中可以用包的名称来作为service的标识
 --------------------------------
 */

NS_ASSUME_NONNULL_END
