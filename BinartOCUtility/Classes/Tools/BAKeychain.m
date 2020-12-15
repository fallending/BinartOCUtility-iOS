#import "BAKeychain.h"

#import <Foundation/Foundation.h>
#import <Security/Security.h>

NSString *const KeychainErrorDomain = @"com.samsoffes.sskeychain";
NSString *const KeychainAccountKey = @"acct";
NSString *const KeychainCreatedAtKey = @"cdat";
NSString *const KeychainClassKey = @"labl";
NSString *const KeychainDescriptionKey = @"desc";
NSString *const KeychainLabelKey = @"labl";
NSString *const KeychainLastModifiedKey = @"mdat";
NSString *const KeychainWhereKey = @"svce";

static CFTypeRef SSKeychainAccessibilityType = NULL;

#define KEYCHAIN_SYNCHRONIZATION_AVAILABLE 1
#define KEYCHAIN_ACCESS_GROUP_AVAILABLE 1

#ifdef KEYCHAIN_SYNCHRONIZATION_AVAILABLE
typedef enum : NSUInteger {
    KeychainQuerySynchronizationModeAny,
    KeychainQuerySynchronizationModeNo,
    KeychainQuerySynchronizationModeYes
} KeychainQuerySynchronizationMode;
#endif

/**
 Simple interface for querying or modifying keychain items.
 */

@interface BAKeychainQuery : NSObject

@property (nonatomic, copy) NSString *account;
@property (nonatomic, copy) NSString *service;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *accessGroup;

@property (nonatomic) KeychainQuerySynchronizationMode synchronizationMode;

/** Root storage for password information */
@property (nonatomic, copy) NSData *passwordData;

/**
 This property automatically transitions between an object and the value of
 `passwordData` using NSKeyedArchiver and NSKeyedUnarchiver.
 */
@property (nonatomic, copy) id<NSCoding> passwordObject;

/**
 Convenience accessor for setting and getting a password string. Passes through
 to `passwordData` using UTF-8 string encoding.
 */
@property (nonatomic, copy) NSString *password;

- (BOOL)save:(NSError **)error;
- (BOOL)deleteItem:(NSError **)error;


///---------------
/// @name Fetching
///---------------

/**
 Fetch all keychain items that match the given account, service, and access
 group. The values of `password` and `passwordData` are ignored when fetching.
 
 @param error Populated should an error occur.
 
 @return An array of dictionaries that represent all matching keychain items or
 `nil` should an error occur.
 The order of the items is not determined.
 */
- (NSArray<NSDictionary<NSString *, id> *> *)fetchAll:(NSError **)error;

/**
 Fetch the keychain item that matches the given account, service, and access
 group. The `password` and `passwordData` properties will be populated unless
 an error occurs. The values of `password` and `passwordData` are ignored when
 fetching.
 
 @param error Populated should an error occur.
 
 @return `YES` if fetching was successful, `NO` otherwise.
 */
- (BOOL)fetch:(NSError **)error;


///-----------------------------
/// @name Synchronization Status
///-----------------------------

+ (BOOL)isSynchronizationAvailable;

@end

@implementation BAKeychainQuery

- (BOOL)save:(NSError *__autoreleasing *)error {
    OSStatus status = KeychainErrorBadArguments;
    if (!self.service || !self.account || !self.passwordData) {
        if (error) {
            *error = [[self class] errorWithCode:status];
        }
        return NO;
    }
    NSMutableDictionary *query = nil;
    NSMutableDictionary * searchQuery = [self query];
    status = SecItemCopyMatching((__bridge CFDictionaryRef)searchQuery, nil);
    if (status == errSecSuccess) {//item already exists, update it!
        query = [[NSMutableDictionary alloc]init];
        [query setObject:self.passwordData forKey:(__bridge id)kSecValueData];
#if __IPHONE_4_0 && TARGET_OS_IPHONE
        CFTypeRef accessibilityType = [BAKeychain accessibilityType];
        if (accessibilityType) {
            [query setObject:(__bridge id)accessibilityType forKey:(__bridge id)kSecAttrAccessible];
        }
#endif
        status = SecItemUpdate((__bridge CFDictionaryRef)(searchQuery), (__bridge CFDictionaryRef)(query));
    }else if(status == errSecItemNotFound){//item not found, create it!
        query = [self query];
        if (self.label) {
            [query setObject:self.label forKey:(__bridge id)kSecAttrLabel];
        }
        [query setObject:self.passwordData forKey:(__bridge id)kSecValueData];
#if __IPHONE_4_0 && TARGET_OS_IPHONE
        CFTypeRef accessibilityType = [BAKeychain accessibilityType];
        if (accessibilityType) {
            [query setObject:(__bridge id)accessibilityType forKey:(__bridge id)kSecAttrAccessible];
        }
#endif
        status = SecItemAdd((__bridge CFDictionaryRef)query, NULL);
    }
    if (status != errSecSuccess && error != NULL) {
        *error = [[self class] errorWithCode:status];
    }
    return (status == errSecSuccess);}


- (BOOL)deleteItem:(NSError *__autoreleasing *)error {
    OSStatus status = KeychainErrorBadArguments;
    if (!self.service || !self.account) {
        if (error) {
            *error = [[self class] errorWithCode:status];
        }
        return NO;
    }
    
    NSMutableDictionary *query = [self query];
#if TARGET_OS_IPHONE
    status = SecItemDelete((__bridge CFDictionaryRef)query);
#else
    // On Mac OS, SecItemDelete will not delete a key created in a different
    // app, nor in a different version of the same app.
    //
    // To replicate the issue, save a password, change to the code and
    // rebuild the app, and then attempt to delete that password.
    //
    // This was true in OS X 10.6 and probably later versions as well.
    //
    // Work around it by using SecItemCopyMatching and SecKeychainItemDelete.
    CFTypeRef result = NULL;
    [query setObject:@YES forKey:(__bridge id)kSecReturnRef];
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status == errSecSuccess) {
        status = SecKeychainItemDelete((SecKeychainItemRef)result);
        CFRelease(result);
    }
#endif
    
    if (status != errSecSuccess && error != NULL) {
        *error = [[self class] errorWithCode:status];
    }
    
    return (status == errSecSuccess);
}


- (NSArray *)fetchAll:(NSError *__autoreleasing *)error {
    NSMutableDictionary *query = [self query];
    [query setObject:@YES forKey:(__bridge id)kSecReturnAttributes];
    [query setObject:(__bridge id)kSecMatchLimitAll forKey:(__bridge id)kSecMatchLimit];
#if __IPHONE_4_0 && TARGET_OS_IPHONE
    CFTypeRef accessibilityType = [BAKeychain accessibilityType];
    if (accessibilityType) {
        [query setObject:(__bridge id)accessibilityType forKey:(__bridge id)kSecAttrAccessible];
    }
#endif
    
    CFTypeRef result = NULL;
    OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    if (status != errSecSuccess && error != NULL) {
        *error = [[self class] errorWithCode:status];
        return nil;
    }
    
    return (__bridge_transfer NSArray *)result;
}


- (BOOL)fetch:(NSError *__autoreleasing *)error {
    OSStatus status = KeychainErrorBadArguments;
    if (!self.service || !self.account) {
        if (error) {
            *error = [[self class] errorWithCode:status];
        }
        return NO;
    }
    
    CFTypeRef result = NULL;
    NSMutableDictionary *query = [self query];
    [query setObject:@YES forKey:(__bridge id)kSecReturnData];
    [query setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
    status = SecItemCopyMatching((__bridge CFDictionaryRef)query, &result);
    
    if (status != errSecSuccess) {
        if (error) {
            *error = [[self class] errorWithCode:status];
        }
        return NO;
    }
    
    self.passwordData = (__bridge_transfer NSData *)result;
    return YES;
}


#pragma mark - Accessors

- (void)setPasswordObject:(id<NSCoding>)object {
    self.passwordData = [NSKeyedArchiver archivedDataWithRootObject:object];
}


- (id<NSCoding>)passwordObject {
    if ([self.passwordData length]) {
        return [NSKeyedUnarchiver unarchiveObjectWithData:self.passwordData];
    }
    return nil;
}


- (void)setPassword:(NSString *)password {
    self.passwordData = [password dataUsingEncoding:NSUTF8StringEncoding];
}


- (NSString *)password {
    if ([self.passwordData length]) {
        return [[NSString alloc] initWithData:self.passwordData encoding:NSUTF8StringEncoding];
    }
    return nil;
}


#pragma mark - Synchronization Status

#ifdef KEYCHAIN_SYNCHRONIZATION_AVAILABLE
+ (BOOL)isSynchronizationAvailable {
#if TARGET_OS_IPHONE
    // Apple suggested way to check for 7.0 at runtime
    // https://developer.apple.com/library/ios/documentation/userexperience/conceptual/transitionguide/SupportingEarlieriOS.html
    return floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1;
#else
    return floor(NSFoundationVersionNumber) > NSFoundationVersionNumber10_8_4;
#endif
}
#endif


#pragma mark - Private

- (NSMutableDictionary *)query {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    [dictionary setObject:(__bridge id)kSecClassGenericPassword forKey:(__bridge id)kSecClass];
    
    if (self.service) {
        [dictionary setObject:self.service forKey:(__bridge id)kSecAttrService];
    }
    
    if (self.account) {
        [dictionary setObject:self.account forKey:(__bridge id)kSecAttrAccount];
    }
    
#ifdef KEYCHAIN_ACCESS_GROUP_AVAILABLE
#if !TARGET_IPHONE_SIMULATOR
    if (self.accessGroup) {
        [dictionary setObject:self.accessGroup forKey:(__bridge id)kSecAttrAccessGroup];
    }
#endif
#endif
    
#ifdef KEYCHAIN_SYNCHRONIZATION_AVAILABLE
    if ([[self class] isSynchronizationAvailable]) {
        id value;
        
        switch (self.synchronizationMode) {
            case KeychainQuerySynchronizationModeNo: {
                value = @NO;
                break;
            }
            case KeychainQuerySynchronizationModeYes: {
                value = @YES;
                break;
            }
            case KeychainQuerySynchronizationModeAny: {
                value = (__bridge id)(kSecAttrSynchronizableAny);
                break;
            }
        }
        
        [dictionary setObject:value forKey:(__bridge id)(kSecAttrSynchronizable)];
    }
#endif
    
    return dictionary;
}


+ (NSError *)errorWithCode:(OSStatus) code {
    static dispatch_once_t onceToken;
    static NSBundle *resourcesBundle = nil;
    dispatch_once(&onceToken, ^{
        NSURL *url = [[NSBundle bundleForClass:[self class]] URLForResource:@"SSKeychain" withExtension:@"bundle"];
        resourcesBundle = [NSBundle bundleWithURL:url];
    });
    
    NSString *message = nil;
    switch (code) {
        case errSecSuccess: return nil;
        case KeychainErrorBadArguments: message = NSLocalizedStringFromTableInBundle(@"SSKeychainErrorBadArguments", @"SSKeychain", resourcesBundle, nil); break;
            
#if TARGET_OS_IPHONE
        case errSecUnimplemented: {
            message = NSLocalizedStringFromTableInBundle(@"errSecUnimplemented", @"SSKeychain", resourcesBundle, nil);
            break;
        }
        case errSecParam: {
            message = NSLocalizedStringFromTableInBundle(@"errSecParam", @"SSKeychain", resourcesBundle, nil);
            break;
        }
        case errSecAllocate: {
            message = NSLocalizedStringFromTableInBundle(@"errSecAllocate", @"SSKeychain", resourcesBundle, nil);
            break;
        }
        case errSecNotAvailable: {
            message = NSLocalizedStringFromTableInBundle(@"errSecNotAvailable", @"SSKeychain", resourcesBundle, nil);
            break;
        }
        case errSecDuplicateItem: {
            message = NSLocalizedStringFromTableInBundle(@"errSecDuplicateItem", @"SSKeychain", resourcesBundle, nil);
            break;
        }
        case errSecItemNotFound: {
            message = NSLocalizedStringFromTableInBundle(@"errSecItemNotFound", @"SSKeychain", resourcesBundle, nil);
            break;
        }
        case errSecInteractionNotAllowed: {
            message = NSLocalizedStringFromTableInBundle(@"errSecInteractionNotAllowed", @"SSKeychain", resourcesBundle, nil);
            break;
        }
        case errSecDecode: {
            message = NSLocalizedStringFromTableInBundle(@"errSecDecode", @"SSKeychain", resourcesBundle, nil);
            break;
        }
        case errSecAuthFailed: {
            message = NSLocalizedStringFromTableInBundle(@"errSecAuthFailed", @"SSKeychain", resourcesBundle, nil);
            break;
        }
        default: {
            message = NSLocalizedStringFromTableInBundle(@"errSecDefault", @"SSKeychain", resourcesBundle, nil);
        }
#else
        default:
            message = (__bridge_transfer NSString *)SecCopyErrorMessageString(code, NULL);
#endif
    }
    
    NSDictionary *userInfo = nil;
    if (message) {
        userInfo = @{ NSLocalizedDescriptionKey : message };
    }
    return [NSError errorWithDomain:KeychainErrorDomain code:code userInfo:userInfo];
}

@end

// MARK: - BAKeychain

@implementation BAKeychain

+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account {
    return [self passwordForService:serviceName account:account error:nil];
}


+ (NSString *)passwordForService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
    BAKeychainQuery *query = [[BAKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    [query fetch:error];
    return query.password;
}

+ (NSData *)passwordDataForService:(NSString *)serviceName account:(NSString *)account {
    return [self passwordDataForService:serviceName account:account error:nil];
}

+ (NSData *)passwordDataForService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error {
    BAKeychainQuery *query = [[BAKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    [query fetch:error];
    
    return query.passwordData;
}


+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account {
    return [self deletePasswordForService:serviceName account:account error:nil];
}


+ (BOOL)deletePasswordForService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
    BAKeychainQuery *query = [[BAKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    return [query deleteItem:error];
}


+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account {
    return [self setPassword:password forService:serviceName account:account error:nil];
}


+ (BOOL)setPassword:(NSString *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError *__autoreleasing *)error {
    BAKeychainQuery *query = [[BAKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    query.password = password;
    return [query save:error];
}

+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)serviceName account:(NSString *)account {
    return [self setPasswordData:password forService:serviceName account:account error:nil];
}


+ (BOOL)setPasswordData:(NSData *)password forService:(NSString *)serviceName account:(NSString *)account error:(NSError **)error {
    BAKeychainQuery *query = [[BAKeychainQuery alloc] init];
    query.service = serviceName;
    query.account = account;
    query.passwordData = password;
    return [query save:error];
}

+ (NSArray *)allAccounts {
    return [self allAccounts:nil];
}


+ (NSArray *)allAccounts:(NSError *__autoreleasing *)error {
    return [self accountsForService:nil error:error];
}


+ (NSArray *)accountsForService:(NSString *)serviceName {
    return [self accountsForService:serviceName error:nil];
}


+ (NSArray *)accountsForService:(NSString *)serviceName error:(NSError *__autoreleasing *)error {
    BAKeychainQuery *query = [[BAKeychainQuery alloc] init];
    query.service = serviceName;
    return [query fetchAll:error];
}


#if __IPHONE_4_0 && TARGET_OS_IPHONE
+ (CFTypeRef)accessibilityType {
    return SSKeychainAccessibilityType;
}


+ (void)setAccessibilityType:(CFTypeRef)accessibilityType {
    CFRetain(accessibilityType);
    if (SSKeychainAccessibilityType) {
        CFRelease(SSKeychainAccessibilityType);
    }
    SSKeychainAccessibilityType = accessibilityType;
}
#endif


@end
