#import "BADeviceUtil.h"

#import <sys/types.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <sys/utsname.h>
#import <sys/socket.h>
#import <sys/param.h>
#import <sys/mount.h>
#import <sys/stat.h>
#import <sys/utsname.h>
#import <net/if.h>
#import <net/if_dl.h>
#import <mach/mach.h>
#import <mach/mach_host.h>
#import <mach/processor_info.h>
#import <Security/Security.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#import "BAKeychain.h"

#pragma mark -

NSString * const UUIDForInstallationKey = @"uuidForInstallation";
NSString * const UUIDForDeviceKey = @"uuidForDevice";

#pragma mark -

/**
 *  @author fallenink
 
 *  About error: @""
 
 *  Initialize in Class Method: @"+ (void)initialize"
 *  or change file suffix from "*.m" to "*.mm"
 */

BOOL IOS8 = NO;
BOOL IOS9 = NO;
BOOL IOS10 = NO;
BOOL IOS11 = NO;

BOOL IOS11_OR_LATER = NO;
BOOL IOS10_OR_LATER = NO;
BOOL IOS9_OR_LATER = NO;
BOOL IOS8_OR_LATER = NO;
BOOL IOS7_OR_LATER = NO;
BOOL IOS6_OR_LATER = NO;
BOOL IOS5_OR_LATER = NO;
BOOL IOS4_OR_LATER = NO;
BOOL IOS3_OR_LATER = NO;

BOOL IOS11_OR_EARLIER = NO;
BOOL IOS9_OR_EARLIER = NO;
BOOL IOS8_OR_EARLIER = NO;
BOOL IOS7_OR_EARLIER = NO;
BOOL IOS6_OR_EARLIER = NO;
BOOL IOS5_OR_EARLIER = NO;
BOOL IOS4_OR_EARLIER = NO;
BOOL IOS3_OR_EARLIER = NO;

BOOL IS_SCREEN_35_INCH = NO;
BOOL IS_SCREEN_4_INCH = NO;
BOOL IS_SCREEN_47_INCH = NO;
BOOL IS_SCREEN_55_INCH = NO;
BOOL IS_SCREEN_58_INCH = NO;

#pragma mark -

BOOL IS_IPHONE_4        = NO;
BOOL IS_IPHONE_4S       = NO;
BOOL IS_IPHONE_5        = NO;
BOOL IS_IPHONE_5C       = NO;
BOOL IS_IPHONE_5S       = NO;
BOOL IS_IPHONE_6        = NO;
BOOL IS_IPHONE_6S       = NO;
BOOL IS_IPHONE_6P       = NO;
BOOL IS_IPHONE_6SP      = NO;
BOOL IS_IPHONE_6SE      = NO;
BOOL IS_IPHONE_7        = NO;
BOOL IS_IPHONE_7P       = NO;
BOOL IS_IPHONE_8        = NO;
BOOL IS_IPHONE_8P       = NO;
BOOL IS_IPHONE_X        = NO;
BOOL IS_SIMULATOR       = NO;

BOOL IS_IPHONE_DESIGN_X = NO;

#pragma mark -

NSString * const UIDevicePasscodeKeychainService = @"UIDevice-PasscodeStatus_KeychainService";
NSString * const UIDevicePasscodeKeychainAccount = @"UIDevice-PasscodeStatus_KeychainAccount";


@implementation BADevice {
    // uuids
    NSString *_uuidForSession;
    NSString *_uuidForInstallation;
}

@DEF_SINGLETON( BADevice )

@DEF_PROP_READONLY( NSString *,			osVersion )
//@def_prop_readonly( OperationSystem,    osType )
@DEF_PROP_READONLY( NSString *,			bundleVersion )
@DEF_PROP_READONLY( NSString *,			bundleShortVersion )
@DEF_PROP_READONLY( NSInteger,          bundleBuild )
@DEF_PROP_READONLY( NSString *,			bundleIdentifier )
@DEF_PROP_READONLY( NSString *,			urlSchema )
@DEF_PROP_READONLY( NSString *,			deviceModel )

@DEF_PROP_READONLY( CGSize,				screenSize )

@DEF_PROP_READONLY( double,             totalMemory )
@DEF_PROP_READONLY( double,				availableMemory )
@DEF_PROP_READONLY( double,				usedMemory )

@DEF_PROP_READONLY( double,				availableDisk )

@DEF_PROP_READONLY( NSString *,         appSize )

@DEF_PROP_READONLY( NSString *,         buildCode )
@DEF_PROP_READONLY( int32_t,            intAppVersion )
@DEF_PROP_READONLY( NSString *,         appVersion )

@DEF_PROP_READONLY( BOOL,               photoCaptureAccessable )
@DEF_PROP_READONLY( BOOL,               photoLibraryAccessable )

@DEF_PROP_READONLY( NSArray *,          languages )

@DEF_PROP_READONLY( NSString *,         uuid )
@DEF_PROP_READONLY( NSString *,         uuidForSession )
@DEF_PROP_READONLY( NSString *,         uuidForInstallation )
@DEF_PROP_READONLY( NSString *,         uuidForVendor )
@DEF_PROP_READONLY( NSString *,         uuidForDevice )

@DEF_PROP_READONLY( NSString *,         deviceInfo )
@DEF_PROP_READONLY( NSString *,         deviceVersion )

@DEF_PROP_READONLY( HardwareType,       hardware )
@DEF_PROP_READONLY( NSString *,         hardwareAsString )
@DEF_PROP_READONLY( NSString *,         hardwareDescription )

@DEF_PROP_READONLY( NSString *,         systemName )
@DEF_PROP_READONLY( CGFloat,            batteryLevel )
@DEF_PROP_READONLY( NSString *,         macAddress )
@DEF_PROP_READONLY( NSUInteger,         cpuFrequency )
@DEF_PROP_READONLY( NSUInteger,         busFrequency )
@DEF_PROP_READONLY( NSUInteger,         ramSize )
@DEF_PROP_READONLY( NSUInteger,         cpuNumber )
@DEF_PROP_READONLY( NSString *,         systemVersion )
@DEF_PROP_READONLY( BOOL,               hasCamera )
@DEF_PROP_READONLY( NSUInteger,         totalMemoryBytes )
@DEF_PROP_READONLY( NSUInteger,         freeMemoryBytes )
@DEF_PROP_READONLY( long long,          freeDiskSpaceBytes )
@DEF_PROP_READONLY( long long,          totalDiskSpaceBytes )

@DEF_PROP_READONLY( BOOL,               passcodeStatusSupported )
@DEF_PROP_READONLY( PasscodeStatus,     passcodeStatus )

+ (void)load {
    [self shared];
    
    [self loadDeviceModel];
    
    [self loadDeviceDesignModel];
    
    /**
     *  ios 10.0 新方案：
     *
     *  自从前段时间我们放弃了 iOS 7，我们可以轻易的切换到新的 isOperatingSystemAtLeastVersion: 方法上。其内部实现是通过调用 operatingSystemVersion ，是相当高效的
     */
    // 判断当前系统版本
    IOS8 = [[UIDevice currentDevice].systemVersion floatValue] >= 8.0 && [[UIDevice currentDevice].systemVersion floatValue] < 9.0;
    IOS9 = [[UIDevice currentDevice].systemVersion floatValue] >= 9.0 && [[UIDevice currentDevice].systemVersion floatValue] < 10.0;
    IOS10 = [[UIDevice currentDevice].systemVersion floatValue] >= 10.0 && [[UIDevice currentDevice].systemVersion floatValue] < 11.0;
    IOS11 = [[UIDevice currentDevice].systemVersion floatValue] >= 11.0 && [[UIDevice currentDevice].systemVersion floatValue] < 12.0;

    IOS11_OR_LATER = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0);
    IOS10_OR_LATER = ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0);
    IOS9_OR_LATER =  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0);
    IOS8_OR_LATER =  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0);
    IOS7_OR_LATER =  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0);
    IOS6_OR_LATER =  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0);
    IOS5_OR_LATER =  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 5.0);
    IOS4_OR_LATER =  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 4.0);
    IOS3_OR_LATER =  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 3.0);
    
    IOS11_OR_EARLIER  = !IOS11_OR_LATER;
    IOS9_OR_EARLIER = !IOS10_OR_LATER;
    IOS8_OR_EARLIER = !IOS9_OR_LATER;
    IOS7_OR_EARLIER = !IOS8_OR_LATER;
    IOS6_OR_EARLIER = !IOS7_OR_LATER;
    IOS5_OR_EARLIER = !IOS6_OR_LATER;
    IOS4_OR_EARLIER = !IOS5_OR_LATER;
    IOS3_OR_EARLIER = !IOS4_OR_LATER;
    
    /**
     以下数据，来源于 模拟器调试打印
     机型                分辨率          ???             PPI         尺寸          启动图大小
     X              1125x2001       375x812 @3x                     5.8         1125x2436
         - Safe Area
             > 竖屏：UIEdgeInsets(44.0, 0.0, 34.0, 0.0) 上左下右
             > 横屏：UIEdgeInsets(0.0, 44.0, 21.0, 44.0) 上左下右
     SE             640x1136                                        4
     5S             640x1136                                        4
     8P             1242x2208
     7P             1242x2208                                       5.5
     6P             1242x2208
     6SP            1242x2208
     8              750x1334                                        4.7
     7              750x1334
     6S             750x1334
     6              750x1334        375x667 @2x
     4              640x960
     4S             640x960
     */
    IS_SCREEN_4_INCH = ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO);
    IS_SCREEN_35_INCH = ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO);
    IS_SCREEN_47_INCH = ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO);
    IS_SCREEN_55_INCH = ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO);
    IS_SCREEN_58_INCH = ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436)/** 如果不适配启动图，那么有效显示区域在中间，上下有黑边，同时这里获取到的height为2001.所以先适配启动图 */, [[UIScreen mainScreen] currentMode].size) : NO);
}

- (NSString *)now {
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:SS"];
    return [formatter stringFromDate:[NSDate date]];
}

- (NSString *)osVersion {
    return [NSString stringWithFormat:@"%@ %@", [UIDevice currentDevice].systemName, [UIDevice currentDevice].systemVersion];
}

- (NSString *)bundleVersion {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
}

- (NSString *)bundleShortVersion {
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

- (NSInteger)bundleBuild {
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *build = [infoDictionary objectForKey:@"CFBundleVersion"];
    return [build integerValue];
}

- (NSString *)bundleIdentifier {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
}

- (NSString *)urlSchema {
    return [self urlSchemaWithName:nil];
}

- (NSString *)urlSchemaWithName:(NSString *)name {
    NSArray * array = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleURLTypes"];
    for ( NSDictionary * dict in array ) {
        if ( name ) {
            NSString * URLName = [dict objectForKey:@"CFBundleURLName"];
            if ( nil == URLName ) {
                continue;
            }
            
            if ( NO == [URLName isEqualToString:name] ) {
                continue;
            }
        }
        
        NSArray * URLSchemes = [dict objectForKey:@"CFBundleURLSchemes"];
        if ( nil == URLSchemes || 0 == URLSchemes.count ) {
            continue;
        }
        
        NSString * schema = [URLSchemes objectAtIndex:0];
        if ( schema && schema.length ) {
            return schema;
        }
    }
    
    return nil;
}

- (NSString *)deviceModel {
    return [UIDevice currentDevice].model;
}

- (CGSize)screenSize {
    return [UIScreen mainScreen].currentMode.size;
}

//- (BOOL)isScreenSizeEqualTo:(CGSize)size {
//    CGSize size2 = CGSizeMake( size.height, size.width );
//    CGSize screenSize = [UIScreen mainScreen].currentMode.size;
//
//    if ( CGSizeEqualToSize(size, screenSize) || CGSizeEqualToSize(size2, screenSize) ) {
//        return YES;
//    }
//
//    return NO;
//}

//- (BOOL)isScreenSizeSmallerThan:(CGSize)size {
//    CGSize size2 = CGSizeMake( size.height, size.width );
//    CGSize screenSize = [UIScreen mainScreen].currentMode.size;
//
//    if ( (size.width > screenSize.width && size.height > screenSize.height) ||
//        (size2.width > screenSize.width && size2.height > screenSize.height) ) {
//        return YES;
//    }
//
//    return NO;
//}

//- (BOOL)isScreenSizeBiggerThan:(CGSize)size {
//    CGSize size2 = CGSizeMake( size.height, size.width );
//    CGSize screenSize = [UIScreen mainScreen].currentMode.size;
//
//    if ( (size.width < screenSize.width && size.height < screenSize.height) ||
//        (size2.width < screenSize.width && size2.height < screenSize.height) ) {
//        return YES;
//    }
//
//    return NO;
//}

//- (BOOL)isOsVersionOrEarlier:(NSString *)ver {
//    if ( [[self osVersion] compare:ver] != NSOrderedDescending ) {
//        return YES;
//    } else {
//        return NO;
//    }
//}
//
//- (BOOL)isOsVersionOrLater:(NSString *)ver {
//    if ( [[self osVersion] compare:ver] != NSOrderedAscending ) {
//        return YES;
//    } else {
//        return NO;
//    }
//}
//
//- (BOOL)isOsVersionEqualTo:(NSString *)ver {
//    if ( NSOrderedSame == [[self osVersion] compare:ver] ) {
//        return YES;
//    } else {
//        return NO;
//    }
//}

#pragma mark - memory

- (double)totalMemory {
    return [[NSProcessInfo processInfo] physicalMemory]/1024.0/1024.0;
}

- (double)availableMemory {
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);
    
    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    
    return ((vm_page_size *vmStats.free_count) / 1024.0) / 1024.0;
}

- (double)usedMemory {
    task_basic_info_data_t taskInfo;
    mach_msg_type_number_t infoCount = TASK_BASIC_INFO_COUNT;
    kern_return_t kernReturn = task_info(mach_task_self(),
                                         TASK_BASIC_INFO,
                                         (task_info_t)&taskInfo,
                                         &infoCount);
    
    if (kernReturn != KERN_SUCCESS
        ) {
        return NSNotFound;
    }
    
    return taskInfo.resident_size / 1024.0 / 1024.0;
}

#pragma mark - Disk

- (double)availableDisk {
    NSDictionary *attributes = [NSFileManager.defaultManager attributesOfFileSystemForPath:PATH_OF_DOCUMENT error:nil];
    
    return [attributes[NSFileSystemFreeSize] unsignedLongLongValue] / (double)0x100000;
}

- (NSString *)appSize {
    unsigned long long docSize   =  [self sizeOfFolder:PATH_OF_DOCUMENT];
    unsigned long long libSize   =  [self sizeOfFolder:PATH_OF_LIBRARY];
    unsigned long long cacheSize =  [self sizeOfFolder:PATH_OF_CACHE];
    
    unsigned long long total = docSize + libSize + cacheSize;
    
    NSString *folderSizeStr = [NSByteCountFormatter stringFromByteCount:total countStyle:NSByteCountFormatterCountStyleFile];
    return folderSizeStr;
}

- (unsigned long long)sizeOfFolder:(NSString *)folderPath {
    NSArray *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:folderPath error:nil];
    NSEnumerator *contentsEnumurator = [contents objectEnumerator];
    
    NSString *file;
    unsigned long long folderSize = 0;
    
    while (file = [contentsEnumurator nextObject]) {
        NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:file] error:nil];
        folderSize += [[fileAttributes objectForKey:NSFileSize] intValue];
    }
    return folderSize;
}

#pragma mark -

- (NSString *)buildCode {
    return APP_BUILD; // ^_^
}

- (int32_t)intAppVersion {
    NSString *versionStr = APP_VERSION;
    NSArray *strVerArr = [versionStr componentsSeparatedByString:@"."];
    NSMutableString *version = [[NSMutableString alloc]init];
    for (int i =0 ; i<strVerArr.count; i++) {
        NSString *str = strVerArr[i];
        if (i == strVerArr.count-1 &&
            str.length == 1) {
            
            str = [NSString stringWithFormat:@"0%@",str];
            [version appendString:str];
        } else {
            [version appendString:str];
        }
    }
    
    return [version intValue];
}

- (NSString *)appVersion {
    return APP_VERSION; // ^_^
}

#pragma mark - Accessory

- (BOOL)photoCaptureAccessable {
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if (authStatus == ALAuthorizationStatusRestricted || authStatus == ALAuthorizationStatusDenied){// || authStatus == ALAuthorizationStatusNotDetermined) {
        return NO;
    }
    return YES;
}

- (BOOL)photoLibraryAccessable {
    if (floor(NSFoundationVersionNumber) > floor(1047.25)) { // iOS 8+
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if ((status == PHAuthorizationStatusDenied) || (status == PHAuthorizationStatusRestricted)) {
            return NO;
        } else {
            return YES;
        }
    } else {
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if ((author == ALAuthorizationStatusDenied) || (author == ALAuthorizationStatusRestricted)) {
            return NO;
        } else {
            return YES;
        }
    }
}

#pragma mark - language

- (NSArray *)languages {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults objectForKey:@"AppleLanguages"];
}

- (NSString *)currentLanguage {
    NSArray *languages = [NSLocale preferredLanguages];
    NSString *currentLanguage = [languages firstObject];
    return [NSString stringWithString:currentLanguage];
}

#pragma mark -

- (NSString *)uuid {
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    
    NSString *uuidValue = (__bridge_transfer NSString *)uuidStringRef;
    uuidValue = [uuidValue lowercaseString];
    uuidValue = [uuidValue stringByReplacingOccurrencesOfString:@"-" withString:@""];
    return uuidValue;
}

- (NSString *)uuidForSession {
    if( _uuidForSession == nil ){
        _uuidForSession = [self uuid];
    }
    
    return _uuidForSession;
}

- (NSString *)uuidForInstallation {
    if( _uuidForInstallation == nil ){
        _uuidForInstallation = [[NSUserDefaults standardUserDefaults] stringForKey:UUIDForInstallationKey];
        
        if( _uuidForInstallation == nil ){
            _uuidForInstallation = [self uuid];
            
            [[NSUserDefaults standardUserDefaults] setObject:_uuidForInstallation forKey:UUIDForInstallationKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
    
    return _uuidForInstallation;
}

- (NSString *)uuidForVendor {
    return [[[[[UIDevice currentDevice] identifierForVendor] UUIDString] lowercaseString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
}

- (NSString *)uuidForDevice {
    //also known as udid/uniqueDeviceIdentifier but this doesn't persists to system reset
    
    return [self uuidForDeviceUsingValue:nil];
}

- (NSString *)uuidForDeviceUsingValue:(NSString *)uuidValue {
    NSString *serviceName = STRINGIFY(_System);
    //also known as udid/uniqueDeviceIdentifier but this doesn't persists to system reset
    
    NSString *uuidForDeviceInMemory = _uuidForDevice;
    /*
     //this would overwrite an existing uuid, it could be dangerous
     if( [self uuidValueIsValid:uuidValue] )
     {
     _uuidForDevice = uuidValue;
     }
     */
    if( _uuidForDevice == nil ) {
        _uuidForDevice = [BAKeychain passwordForService:serviceName account:UUIDForDeviceKey];
        if( _uuidForDevice == nil ) {
            _uuidForDevice = [[NSUserDefaults standardUserDefaults] stringForKey:UUIDForDeviceKey];
            
            if( _uuidForDevice == nil ) {
                if([self uuidValueIsValid:uuidValue] ) {
                    _uuidForDevice = uuidValue;
                } else {
                    _uuidForDevice = [self uuid];
                }
            }
        }
    }
    
    if([self uuidValueIsValid:uuidValue] && ![_uuidForDevice isEqualToString:uuidValue]) {
//        exceptioning(@"Cannot overwrite uuidForDevice, uuidForDevice has already been created and cannot be overwritten.")
        ba_log(@"出大事儿啦！出错啦！")
    }
    
    if(![uuidForDeviceInMemory isEqualToString:_uuidForDevice]) {
        [[NSUserDefaults standardUserDefaults] setObject:_uuidForDevice forKey:UUIDForDeviceKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [BAKeychain setPassword:_uuidForDevice forService:serviceName account:UUIDForDeviceKey];
    }
    
    return _uuidForDevice;
}

- (BOOL)uuidValueIsValid:(NSString *)uuidValue {
    return (uuidValue != nil && (uuidValue.length == 32 || uuidValue.length == 36));
}

- (NSString *)deviceUDID {
    return [self uuidForDevice];
}

///// MARK: -

- (NSString *)deviceInfo {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    
    return [NSString stringWithFormat: @"%@ %@ %@ %@ %@", [[UIDevice currentDevice] systemName], [[UIDevice currentDevice] systemVersion], [self deviceVersion], [[UIDevice currentDevice] localizedModel], [[info subscriberCellularProvider] carrierName]];
}

- (NSString *)deviceVersion {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

///// MARK: -

- (void)openSettings {
    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (BOOL)call:(NSString *)phone {
    NSString *phoneNumberString = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (phoneNumberString != nil) {
        NSString *urlStr = [[NSString alloc] initWithFormat:@"telprompt://%@", phoneNumberString];
        BOOL isSuccess = [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
        if (!isSuccess) {
            ba_log(@"拨打电话失败:%@", urlStr);
            
            return NO;
        }
    }
    
    return YES;
}

#pragma mark -

- (NSString*)hardwareAsString {
    int name[] = {CTL_HW,HW_MACHINE};
    size_t size = 100;
    sysctl(name, 2, NULL, &size, NULL, 0); // getting size of answer
    char *hw_machine = malloc(size);
    
    sysctl(name, 2, hw_machine, &size, NULL, 0);
    NSString *hardware = [NSString stringWithUTF8String:hw_machine];
    free(hw_machine);
    return hardware;
}

/* This is another way of gtting the system info
 * For this you have to #import <sys/utsname.h>
 */

/*
 NSString* machineName
 {
 struct utsname systemInfo;
 uname(&systemInfo);
 return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
 }
 */

- (HardwareType)hardware {
    NSString *hardware = [self hardwareAsString];
    if ([hardware isEqualToString:@"iPhone1,1"])    return IPHONE_2G;
    if ([hardware isEqualToString:@"iPhone1,2"])    return IPHONE_3G;
    if ([hardware isEqualToString:@"iPhone2,1"])    return IPHONE_3GS;
    
    if ([hardware isEqualToString:@"iPhone3,1"])    return IPHONE_4;
    if ([hardware isEqualToString:@"iPhone3,2"])    return IPHONE_4;
    if ([hardware isEqualToString:@"iPhone3,3"])    return IPHONE_4;
    if ([hardware isEqualToString:@"iPhone4,1"])    return IPHONE_4S;
    
    if ([hardware isEqualToString:@"iPhone5,1"])    return IPHONE_5;
    if ([hardware isEqualToString:@"iPhone5,2"])    return IPHONE_5;
    if ([hardware isEqualToString:@"iPhone5,3"])    return IPHONE_5C;
    if ([hardware isEqualToString:@"iPhone5,4"])    return IPHONE_5C;
    if ([hardware isEqualToString:@"iPhone6,1"])    return IPHONE_5S;
    if ([hardware isEqualToString:@"iPhone6,2"])    return IPHONE_5S;
    
    if ([hardware isEqualToString:@"iPhone7,1"])    return IPHONE_6_PLUS;
    if ([hardware isEqualToString:@"iPhone7,2"])    return IPHONE_6;
    if ([hardware isEqualToString:@"iPhone8,1"])    return IPHONE_6S;
    if ([hardware isEqualToString:@"iPhone8,2"])    return IPHONE_6S_PLUS;
    
    if ([hardware isEqualToString:@"iPhone9,1"])   return IPHONE_7;
    if ([hardware isEqualToString:@"iPhone9,2"])   return IPHONE_7_PLUS;
    
    if ([hardware isEqualToString:@"iPhone10,1"])   return IPHONE_8;
    if ([hardware isEqualToString:@"iPhone10,4"])   return IPHONE_8;
    if ([hardware isEqualToString:@"iPhone10,2"])   return IPHONE_8_PLUS;
    if ([hardware isEqualToString:@"iPhone10,5"])   return IPHONE_8_PLUS;
    
    if ([hardware isEqualToString:@"iPhone10,3"])   return IPHONE_X;
    if ([hardware isEqualToString:@"iPhone10,6"])   return IPHONE_X;
    
    // Add at 2019/04/29 start
    if ([hardware isEqualToString:@"iPhone11,2"])   return IPHONE_XS;
    if ([hardware isEqualToString:@"iPhone11,3"])   return IPHONE_XS;
    if ([hardware isEqualToString:@"iPhone11,6"])   return IPHONE_XS;
    if ([hardware isEqualToString:@"iPhone11,8"])   return IPHONE_XR;
    // Add at 2019/04/29 ended
    
    if ([hardware isEqualToString:@"iPod1,1"])      return IPOD_TOUCH_1G;
    if ([hardware isEqualToString:@"iPod2,1"])      return IPOD_TOUCH_2G;
    if ([hardware isEqualToString:@"iPod3,1"])      return IPOD_TOUCH_3G;
    if ([hardware isEqualToString:@"iPod4,1"])      return IPOD_TOUCH_4G;
    if ([hardware isEqualToString:@"iPod5,1"])      return IPOD_TOUCH_5G;
    
    if ([hardware isEqualToString:@"iPad1,1"])      return IPAD;
    if ([hardware isEqualToString:@"iPad1,2"])      return IPAD;
    if ([hardware isEqualToString:@"iPad2,1"])      return IPAD_2;
    if ([hardware isEqualToString:@"iPad2,2"])      return IPAD_2;
    if ([hardware isEqualToString:@"iPad2,3"])      return IPAD_2;
    if ([hardware isEqualToString:@"iPad2,4"])      return IPAD_2;
    if ([hardware isEqualToString:@"iPad2,5"])      return IPAD_MINI;
    if ([hardware isEqualToString:@"iPad2,6"])      return IPAD_MINI;
    if ([hardware isEqualToString:@"iPad2,7"])      return IPAD_MINI;
    if ([hardware isEqualToString:@"iPad3,1"])      return IPAD_3;
    if ([hardware isEqualToString:@"iPad3,2"])      return IPAD_3;
    if ([hardware isEqualToString:@"iPad3,3"])      return IPAD_3;
    if ([hardware isEqualToString:@"iPad3,4"])      return IPAD_4;
    if ([hardware isEqualToString:@"iPad3,5"])      return IPAD_4;
    if ([hardware isEqualToString:@"iPad3,6"])      return IPAD_4;
    if ([hardware isEqualToString:@"iPad4,1"])      return IPAD_AIR;
    if ([hardware isEqualToString:@"iPad4,2"])      return IPAD_AIR;
    if ([hardware isEqualToString:@"iPad4,3"])      return IPAD_AIR;
    if ([hardware isEqualToString:@"iPad4,4"])      return IPAD_MINI_RETINA;
    if ([hardware isEqualToString:@"iPad4,5"])      return IPAD_MINI_RETINA;
    if ([hardware isEqualToString:@"iPad4,6"])      return IPAD_MINI_RETINA;
    if ([hardware isEqualToString:@"iPad4,7"])      return IPAD_MINI_3;
    if ([hardware isEqualToString:@"iPad4,8"])      return IPAD_MINI_3;
    if ([hardware isEqualToString:@"iPad5,3"])      return IPAD_AIR_2;
    if ([hardware isEqualToString:@"iPad5,4"])      return IPAD_AIR_2;
    
    // Add at 2019/04/29 start
    if ([hardware isEqualToString:@"iPad6,3"])      return IPAD_PRO_9;
    if ([hardware isEqualToString:@"iPad6,4"])      return IPAD_PRO_9;
    if ([hardware isEqualToString:@"iPad6,7"])      return IPAD_PRO_12;
    if ([hardware isEqualToString:@"iPad6,8"])      return IPAD_PRO_12;
    // Add at 2019/04/29 ended
    
    if ([hardware isEqualToString:@"i386"])         return SIMULATOR;
    if ([hardware isEqualToString:@"x86_64"])       return SIMULATOR;
    
    if ([hardware hasPrefix:@"iPhone"])             return SIMULATOR;
    if ([hardware hasPrefix:@"iPod"])               return SIMULATOR;
    if ([hardware hasPrefix:@"iPad"])               return SIMULATOR;
    
    return NOT_AVAILABLE;
}

- (NSString *)hardwareDescription {
    NSString *hardware = [self hardwareAsString];
    if ([hardware isEqualToString:@"iPhone1,1"])    return @"iPhone 2G";
    if ([hardware isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([hardware isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([hardware isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([hardware isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([hardware isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([hardware isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([hardware isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([hardware isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([hardware isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    if ([hardware isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    if ([hardware isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
    if ([hardware isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
    if ([hardware isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([hardware isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([hardware isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([hardware isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([hardware isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([hardware isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    
    if ([hardware isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([hardware isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([hardware isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([hardware isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
    
    if ([hardware isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([hardware isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    
    // Add at 2019/04/29 start
    if ([hardware isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([hardware isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max (China)";
    if ([hardware isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([hardware isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    // Add at 2019/04/29 end
    
    if ([hardware isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([hardware isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([hardware isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([hardware isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([hardware isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    
    if ([hardware isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([hardware isEqualToString:@"iPad1,2"])      return @"iPad";
    if ([hardware isEqualToString:@"iPad2,1"])      return @"iPad 2";
    if ([hardware isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([hardware isEqualToString:@"iPad2,3"])      return @"iPad 2";
    if ([hardware isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([hardware isEqualToString:@"iPad2,5"])      return @"iPad Mini";
    if ([hardware isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([hardware isEqualToString:@"iPad2,7"])      return @"iPad Mini";
    if ([hardware isEqualToString:@"iPad3,1"])      return @"iPad 3";
    if ([hardware isEqualToString:@"iPad3,2"])      return @"iPad 3";
    if ([hardware isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([hardware isEqualToString:@"iPad3,4"])      return @"iPad 4";
    if ([hardware isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([hardware isEqualToString:@"iPad3,6"])      return @"iPad 4";
    if ([hardware isEqualToString:@"iPad4,1"])      return @"iPad Air";
    if ([hardware isEqualToString:@"iPad4,2"])      return @"iPad Air";
    if ([hardware isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([hardware isEqualToString:@"iPad4,4"])      return @"iPad Mini Retina";
    if ([hardware isEqualToString:@"iPad4,5"])      return @"iPad Mini Retina";
    if ([hardware isEqualToString:@"iPad4,6"])      return @"iPad Mini Retina CN";
    if ([hardware isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([hardware isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([hardware isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([hardware isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    
    // Add at 2019/04/29 start
    if ([hardware isEqualToString:@"iPad6,3"])       return @"iPad Pro 9.7";
    if ([hardware isEqualToString:@"iPad6,4"])       return @"iPad Pro 9.7";
    if ([hardware isEqualToString:@"iPad6,7"])       return @"iPad Pro 12.9";
    if ([hardware isEqualToString:@"iPad6,8"])       return @"iPad Pro 12.9";
    // Add at 2019/04/29 ended
    
    if ([hardware isEqualToString:@"i386"])         return @"iPhone Simulator 32";
    if ([hardware isEqualToString:@"x86_64"])       return @"iPhone Simulator 64";
    
    // By default
    if ([hardware hasPrefix:@"iPhone"])             return @"iPhone";
    if ([hardware hasPrefix:@"iPod"])               return @"iPod";
    if ([hardware hasPrefix:@"iPad"])               return @"iPad";
    
    return nil;
}

- (NSString *)systemName {
    return [[UIDevice currentDevice] systemName];
}

- (CGFloat)batteryLevel {
    return [[UIDevice currentDevice] batteryLevel];
}

- (NSString *)macAddress {
    int                 mib[6];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if((mib[5] = if_nametoindex("en0")) == 0) {
        printf("Error: if_nametoindex error\n");
        return NULL;
    }
    
    if(sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 1\n");
        return NULL;
    }
    
    if((buf = malloc(len)) == NULL) {
        printf("Could not allocate memory. Rrror!\n");
        return NULL;
    }
    
    if(sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        printf("Error: sysctl, take 2");
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02X:%02X:%02X:%02X:%02X:%02X",
                           *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    
    return outstring;
}

- (NSString *)systemVersion {
    return [[UIDevice currentDevice] systemVersion];
}

- (BOOL)hasCamera {
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (NSUInteger)getSysInfo:(uint)typeSpecifier {
    size_t size = sizeof(int);
    int result;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib, 2, &result, &size, NULL, 0);
    return (NSUInteger)result;
}

- (NSUInteger)cpuFrequency {
    return [self getSysInfo:HW_CPU_FREQ];
}

- (NSUInteger)busFrequency {
    return [self getSysInfo:HW_BUS_FREQ];
}

- (NSUInteger)ramSize {
    return [self getSysInfo:HW_MEMSIZE];
}

- (NSUInteger)cpuNumber {
    return [self getSysInfo:HW_NCPU];
}

- (NSUInteger)totalMemoryBytes {
    return [self getSysInfo:HW_PHYSMEM];
}

- (NSUInteger)freeMemoryBytes {
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    vm_size_t pagesize;
    vm_statistics_data_t vm_stat;
    
    host_page_size(host_port, &pagesize);
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS) {
        return 0;
    }
    unsigned long mem_free = vm_stat.free_count * pagesize;
    return mem_free;
}

- (long long)freeDiskSpaceBytes {
    struct statfs buf;
    long long freespace;
    freespace = 0;
    if ( statfs("/private/var", &buf) >= 0 ) {
        freespace = (long long)buf.f_bsize * buf.f_bfree;
    }
    return freespace;
}

- (long long)totalDiskSpaceBytes {
    struct statfs buf;
    long long totalspace;
    totalspace = 0;
    if ( statfs("/private/var", &buf) >= 0 ) {
        totalspace = (long long)buf.f_bsize * buf.f_blocks;
    }
    return totalspace;
}

- (BOOL)passcodeStatusSupported {
#if TARGET_IPHONE_SIMULATOR
    return NO;
#endif
    
#ifdef __IPHONE_8_0
    return YES;
#else
    return NO;
#endif
}

- (PasscodeStatus)passcodeStatus {
#if TARGET_IPHONE_SIMULATOR
    NSLog(@"-[%@ %@] - not supported in simulator", NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return PasscodeStatusUnknown;
#endif
    
#ifdef __IPHONE_8_0
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunreachable-code"
    {
#pragma clang diagnostic pop
        static NSData *password = nil;
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            password = [NSKeyedArchiver archivedDataWithRootObject:NSStringFromSelector(_cmd)];
        });
        
        NSDictionary *query = @{
                                (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                (__bridge id)kSecAttrService: UIDevicePasscodeKeychainService,
                                (__bridge id)kSecAttrAccount: UIDevicePasscodeKeychainAccount,
                                (__bridge id)kSecReturnData: @YES,
                                };
        
        CFErrorRef sacError = NULL;
        SecAccessControlRef sacObject;
        sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly, kNilOptions, &sacError);
        
        // unable to create the access control item.
        if (sacObject == NULL || sacError != NULL) {
            return PasscodeStatusUnknown;
        }
        
        
        NSMutableDictionary *setQuery = [query mutableCopy];
        [setQuery setObject:password forKey:(__bridge id)kSecValueData];
        [setQuery setObject:(__bridge id)sacObject forKey:(__bridge id)kSecAttrAccessControl];
        
        OSStatus status;
        status = SecItemAdd((__bridge CFDictionaryRef)setQuery, NULL);
        
        // if it failed to add the item.
        if (status == errSecDecode) {
            return PasscodeStatusDisabled;
        }
        
        status = SecItemCopyMatching((__bridge CFDictionaryRef)query, NULL);
        
        // it managed to retrieve data successfully
        if (status == errSecSuccess) {
            return PasscodeStatusEnabled;
        }
        
        // not sure what happened, returning unknown
        return PasscodeStatusUnknown;
        
    }
#else
    return PasscodeStatusUnknown;
#endif
}


#pragma mark -

+ (void)loadDeviceModel {
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    
    // iPhone
    if ([platform isEqualToString:@"iPhone1,1"]) {}
    if ([platform isEqualToString:@"iPhone1,2"]) {}
    if ([platform isEqualToString:@"iPhone2,1"]) {}
    if ([platform isEqualToString:@"iPhone3,1"]) IS_IPHONE_4=YES;
    if ([platform isEqualToString:@"iPhone3,2"]) IS_IPHONE_4=YES;
    if ([platform isEqualToString:@"iPhone3,3"]) IS_IPHONE_4=YES;
    if ([platform isEqualToString:@"iPhone4,1"]) IS_IPHONE_4S=YES;
    if ([platform isEqualToString:@"iPhone5,1"]) IS_IPHONE_5=YES;
    if ([platform isEqualToString:@"iPhone5,2"]) IS_IPHONE_5=YES;
    if ([platform isEqualToString:@"iPhone5,3"]) IS_IPHONE_5C=YES;
    if ([platform isEqualToString:@"iPhone5,4"]) IS_IPHONE_5C=YES;
    if ([platform isEqualToString:@"iPhone6,1"]) IS_IPHONE_5S=YES;
    if ([platform isEqualToString:@"iPhone6,2"]) IS_IPHONE_5S=YES;
    if ([platform isEqualToString:@"iPhone7,2"]) IS_IPHONE_6=YES;
    if ([platform isEqualToString:@"iPhone7,1"]) IS_IPHONE_6P=YES;
    if ([platform isEqualToString:@"iPhone8,1"]) IS_IPHONE_6SP=YES;
    if ([platform isEqualToString:@"iPhone8,2"]) IS_IPHONE_6SP=YES;
    if ([platform isEqualToString:@"iPhone8,3"]) IS_IPHONE_6SE=YES;
    if ([platform isEqualToString:@"iPhone8,4"]) IS_IPHONE_6SE=YES;
    if ([platform isEqualToString:@"iPhone9,1"]) IS_IPHONE_7=YES;
    if ([platform isEqualToString:@"iPhone9,2"]) IS_IPHONE_7P=YES;
    if ([platform isEqualToString:@"iPhone10,1"])   IS_IPHONE_8=YES;
    if ([platform isEqualToString:@"iPhone10,4"])   IS_IPHONE_8=YES;
    if ([platform isEqualToString:@"iPhone10,2"])   IS_IPHONE_8P=YES;
    if ([platform isEqualToString:@"iPhone10,5"])   IS_IPHONE_8P=YES;
    if ([platform isEqualToString:@"iPhone10,3"])   IS_IPHONE_X=YES;
    if ([platform isEqualToString:@"iPhone10,6"])   IS_IPHONE_X=YES;
    
    //iPod Touch
    if ([platform isEqualToString:@"iPod1,1"])   {}
    if ([platform isEqualToString:@"iPod2,1"])   {}
    if ([platform isEqualToString:@"iPod3,1"])   {}
    if ([platform isEqualToString:@"iPod4,1"])   {}
    if ([platform isEqualToString:@"iPod5,1"])   {}
    if ([platform isEqualToString:@"iPod7,1"])   {}
    
    //iPad
    if ([platform isEqualToString:@"iPad1,1"])   {}
    if ([platform isEqualToString:@"iPad2,1"])   {}
    if ([platform isEqualToString:@"iPad2,2"])   {}
    if ([platform isEqualToString:@"iPad2,3"])   {}
    if ([platform isEqualToString:@"iPad2,4"])   {}
    if ([platform isEqualToString:@"iPad3,1"])   {}
    if ([platform isEqualToString:@"iPad3,2"])   {}
    if ([platform isEqualToString:@"iPad3,3"])   {}
    if ([platform isEqualToString:@"iPad3,4"])   {}
    if ([platform isEqualToString:@"iPad3,5"])   {}
    if ([platform isEqualToString:@"iPad3,6"])   {}
    
    //iPad Air
    if ([platform isEqualToString:@"iPad4,1"])   {}
    if ([platform isEqualToString:@"iPad4,2"])   {}
    if ([platform isEqualToString:@"iPad4,3"])   {}
    if ([platform isEqualToString:@"iPad5,3"])   {}
    if ([platform isEqualToString:@"iPad5,4"])   {}
    
    //iPad mini
    if ([platform isEqualToString:@"iPad2,5"])   {}
    if ([platform isEqualToString:@"iPad2,6"])   {}
    if ([platform isEqualToString:@"iPad2,7"])   {}
    if ([platform isEqualToString:@"iPad4,4"])   {}
    if ([platform isEqualToString:@"iPad4,5"])   {}
    if ([platform isEqualToString:@"iPad4,6"])   {}
    if ([platform isEqualToString:@"iPad4,7"])   {}
    if ([platform isEqualToString:@"iPad4,8"])   {}
    if ([platform isEqualToString:@"iPad4,9"])   {}
    if ([platform isEqualToString:@"iPad5,1"])   {}
    if ([platform isEqualToString:@"iPad5,2"])   {}
    
    if ([platform isEqualToString:@"i386"])      IS_SIMULATOR=YES;
    if ([platform isEqualToString:@"x86_64"])    IS_SIMULATOR=YES;
}

+ (void)loadDeviceDesignModel {
    if (CGSizeEqualToSize([UIScreen mainScreen].currentMode.size, CGSizeMake(1125, 2436))) {
        IS_IPHONE_DESIGN_X = YES;
    }
}

#pragma mark - Public method

//+ (void)iPhoneXWith:(Block)handler {
//    if (IS_IPHONE_DESIGN_X) {
//        if (handler) handler();
//    }
//}

//+ (void)iPhoneXWith:(Block)handlerX otherwise:(Block)handlerOther {
//    if (IS_IPHONE_DESIGN_X) {
//        if (handlerX) handlerX();
//    } else {
//        if (handlerOther) handlerOther();
//    }
//}
//
//+ (void)iOS11_NotiPhoneXWith:(Block)handler {
//    if (@available(iOS 11.0, *)) {
//        if (IS_NOT_IPHONE_DESIGN_X) {
//            if (handler) handler();
//        }
//    }
//}

@end
