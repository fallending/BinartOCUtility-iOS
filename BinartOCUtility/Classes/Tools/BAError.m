#import "BAError.h"
#import <objc/runtime.h>

@implementation NSError (Handler)

@DEF_NSSTRING( messagedKey )
@DEF_NSSTRING( errorDomain )

+ (instancetype)errorWithDomain:(NSString *)domain
                           code:(NSInteger)code
                           desc:(NSString *)desc { // desc 可以为空
    NSAssert(domain, @"Domain nil");
    
    desc = !desc ? @"" : desc;
    
    NSDictionary *userInfo      = @{[self messagedKey]:desc};
    NSError *error              = [self errorWithDomain:domain code:code userInfo:userInfo];;

    return error;
}

- (BOOL)is:(NSInteger)code {
    return [self code] == code;
}

- (NSString *)message {
    
    if (self.userInfo &&
        [self.userInfo.allKeys containsObject:[self messagedKey]]) {
        
        return self.userInfo[[self messagedKey]];
    }
    
    // 没有消息
    return @"";
}

@end
