#import "BAMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary ( BAUtil )

// MARK: = 存放

- (BOOL)mt_set:(NSObject *)obj atPath:(NSString *)path;
- (BOOL)mt_set:(NSObject *)obj atPath:(NSString *)path separator:(NSString * _Nullable)separator;

+ (NSMutableDictionary *)mt_keyValues:(id)first, ...;
- (BOOL)mt_setKeyValues:(id)first, ...;

- (void)mt_setPoint:(CGPoint)o forKey:(NSString *)key;
- (void)mt_setSize:(CGSize)o forKey:(NSString *)key;
- (void)mt_setRect:(CGRect)o forKey:(NSString *)key;

@end

@interface NSDictionary ( BAUtil )

// MARK: = 访问

- (BOOL)mt_hasKey:(id)key;

- (id)mt_atPath:(NSString *)path;
- (id)mt_atPath:(NSString *)path separator:(NSString * _Nullable)separator;
- (id)mt_atPath:(NSString *)path otherwise:(NSObject *)other separator:(NSString * _Nullable)separator;

- (CGPoint)mt_pointAtPath:(NSString *)path;
- (CGSize)mt_sizeAtPath:(NSString *)path;
- (CGRect)mt_rectAtPath:(NSString *)path;

// MARK: = 流处理

/// 同步遍历
- (void)mt_each:(void (^)(id key, id obj))block;

/// 并发遍历
- (void)mt_apply:(void (^)(id key, id obj))block;

/// 匹配，返回第一个匹配上的 kv pair
- (nullable id)mt_match:(BOOL (^)(id key, id obj))block;

/// 选取，返回所有匹配上的 kv pairs
- (NSDictionary *)mt_select:(BOOL (^)(id key, id obj))block;

/// 反选，返回所有匹配失败的 kv pairs
- (NSDictionary *)mt_reject:(BOOL (^)(id key, id obj))block;

/// 映射
- (NSDictionary *)mt_map:(id (^)(id key, id obj))block;

/// 是否有匹配上的
- (BOOL)mt_any:(BOOL (^)(id key, id obj))block;

/// 是否没有匹配上的
- (BOOL)mt_none:(BOOL (^)(id key, id obj))block;

/// 是否全部匹配上
- (BOOL)mt_all:(BOOL (^)(id key, id obj))block;

@end

NS_ASSUME_NONNULL_END

