
#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, BAUReachabilityStatus) {
    BAUReachabilityStatusNone  = 0, //Not Reachable
    BAUReachabilityStatusWWAN  = 1, // Reachable via WWAN (2G/3G/4G)
    BAUReachabilityStatusWiFi  = 2, // Reachable via WiFi
};

typedef NS_ENUM(NSUInteger, BAUReachabilityWWANStatus) {
    BAUReachabilityWWANStatusNone  = 0, // Not Reachable vis WWAN
    BAUReachabilityWWANStatus2G = 2,    // Reachable via 2G (GPRS/EDGE)       10~100Kbps
    BAUReachabilityWWANStatus3G = 3,    // Reachable via 3G (WCDMA/HSDPA/...) 1~10Mbps
    BAUReachabilityWWANStatus4G = 4,    // Reachable via 4G (eHRPD/LTE)       100Mbps
};

@interface BAUReachability : NSObject

@property (nonatomic, readonly) SCNetworkReachabilityFlags flags;
@property (nonatomic, readonly) BAUReachabilityStatus status;
@property (nonatomic, readonly) BAUReachabilityWWANStatus wwanStatus NS_AVAILABLE_IOS(7_0);
@property (nonatomic, readonly, getter=isReachable) BOOL reachable;
@property (nullable, nonatomic, copy) void (^notifyBlock)(BAUReachability *reachability); // Call on Global, not Main

+ (instancetype)reachability;
+ (nullable instancetype)reachabilityWithHostname:(NSString *)hostname;

/**
 Create an object to check the reachability of a given IP address
 
 @param hostAddress You may pass `struct sockaddr_in` for IPv4 address or `struct sockaddr_in6` for IPv6 address.
 */
+ (nullable instancetype)reachabilityWithAddress:(const struct sockaddr *)hostAddress;

@end

NS_ASSUME_NONNULL_END
