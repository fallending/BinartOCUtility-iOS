//
//  BAUAppDelegate+TestPath.m
//  BinartOCUtility_Example
//
//  Created by Seven on 2020/12/25.
//  Copyright © 2020 fallending. All rights reserved.
//

#import "BAUAppDelegate+TestPath.h"

#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonRandom.h>

@interface NSString (Extension)
- (NSString *)MD5String;
@end

@implementation NSString (Extension)

- (NSString *)MD5String {
    const char * pointer = [self UTF8String];
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(pointer, (CC_LONG)strlen(pointer), md5Buffer);
    
    NSMutableString *string = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [string appendFormat:@"%02x",md5Buffer[i]];
    
    return string;
}


@end

@implementation BAUAppDelegate (TestPath)

- (void)testPath {
    mt_log(@"qiniu image path = %@", [self makeImageQiniuPath:10091 imageSize:CGSizeMake(1024, 648)])
    mt_log(@"qiniu gif image path = %@", [self makeGifImageQiniuPath:10091 imageSize:CGSizeMake(1024, 648)])
    mt_log(@"qiniu voice path = %@", [self makeVoiceQiniuPath:10091])
    mt_log(@"qiniu avatar image path = %@", [self makeAvatarImageQiniuPath:10091 imageSize:CGSizeMake(1024, 648)])
    mt_log(@"qiniu custom image path = %@", [self makeCustomImageQiniuPath:10091 customPath:@"custom" imageSize:CGSizeMake(1024, 648)])
}

-(NSString *)makeImageQiniuPath:(int64_t)uid imageSize:(CGSize)size {
    NSDateFormatter *pathDateFormatter = [[NSDateFormatter alloc] init];
    pathDateFormatter.dateFormat = @"yy/MM/dd";
    pathDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSString *str = [pathDateFormatter stringFromDate: [NSDate date]];
    
    NSString *randomMD5 = [[[[NSUUID UUID] UUIDString] MD5String] substringFromIndex:16];
    NSString *strSize = size.width > 0 && size.height > 0 ? [NSString stringWithFormat:@"_%dx%d", (int)size.width, (int)size.height] : @"";
    NSString *path = [NSString stringWithFormat:@"%@/%llu/%@%@.jpg", str, uid, randomMD5, strSize];
    return path;
}

-(NSString *)makeGifImageQiniuPath:(int64_t)uid imageSize:(CGSize)size {
    NSDateFormatter *pathDateFormatter = [[NSDateFormatter alloc] init];
    pathDateFormatter.dateFormat = @"yy/MM/dd";
    pathDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSString *str = [pathDateFormatter stringFromDate: [NSDate date]];
    
    NSString *randomMD5 = [[[[NSUUID UUID] UUIDString] MD5String] substringFromIndex:16];
    NSString *strSize = size.width > 0 && size.height > 0 ? [NSString stringWithFormat:@"_%dx%d", (int)size.width, (int)size.height] : @"";
    NSString *path = [NSString stringWithFormat:@"%@/%llu/%@%@.gif", str, uid, randomMD5, strSize];
    return path;
}

-(NSString *)makeVoiceQiniuPath:(int64_t)uid {
    NSDateFormatter *pathDateFormatter = [[NSDateFormatter alloc] init];
    pathDateFormatter.dateFormat = @"yy/MM/dd";
    pathDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSString *str = [pathDateFormatter stringFromDate: [NSDate date]];
    
    NSString *randomMD5 = [[[[NSUUID UUID] UUIDString] MD5String] substringFromIndex:16];
    return [NSString stringWithFormat:@"%@/%llu/%@.aud", str, uid, randomMD5];
}

- (NSString *)makeAvatarImageQiniuPath:(int64_t)uid imageSize:(CGSize)size {
    NSDateFormatter *pathDateFormatter = [[NSDateFormatter alloc] init];
    pathDateFormatter.dateFormat = @"yy/MM/dd";
    pathDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSString *str = [pathDateFormatter stringFromDate: [NSDate date]];
    
    NSString *randomMD5 = [[[[NSUUID UUID] UUIDString] MD5String] substringFromIndex:16];
    NSString *strSize = size.width > 0 && size.height > 0 ? [NSString stringWithFormat:@"_%dx%d", (int)size.width, (int)size.height] : @"";
    NSString *path = [NSString stringWithFormat:@"avatar/%llu/%@/%@%@.jpg", uid, str, randomMD5, strSize];
    return path;
}

- (NSString *)makeCustomImageQiniuPath:(int64_t)uid customPath:(NSString *)customPath imageSize:(CGSize)size {
    
    NSDateFormatter *pathDateFormatter = [[NSDateFormatter alloc] init];
    pathDateFormatter.dateFormat = @"yy/MM/dd";
    pathDateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    
    NSString *str = [pathDateFormatter stringFromDate: [NSDate date]];
    
    NSString *randomMD5 = [[[[NSUUID UUID] UUIDString] MD5String] substringFromIndex:16];
    NSString *strSize = size.width > 0 && size.height > 0 ? [NSString stringWithFormat:@"_%dx%d", (int)size.width, (int)size.height] : @"";
    NSString *path = [NSString stringWithFormat:@"custom/%@/%llu/%@/%@%@.jpg", customPath, uid, str, randomMD5, strSize];
    return path;
}

@end
