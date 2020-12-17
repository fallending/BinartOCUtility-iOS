#import "BAMacros.h"

// model序列化推荐 YYModel

@interface BAJsonUtil: NSObject

+ (NSString *)toJsonString:(NSDictionary *)dict;
+ (NSDictionary *)toJsonDictionary:(NSString *)jsonString;

@end
