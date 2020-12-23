#import "BAMacros.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSMutableDictionary ( BAUtil )

// MARK: = 存放

+ (NSMutableDictionary *)ba_keyValues:(id)first, ...;

- (BOOL)ba_setObject:(NSObject *)obj atPath:(NSString *)path;
- (BOOL)ba_setObject:(NSObject *)obj atPath:(NSString *)path separator:(NSString * _Nullable)separator;
- (BOOL)ba_setKeyValues:(id)first, ...;

- (void)ba_setPoint:(CGPoint)o forKey:(NSString *)key;
- (void)ba_setSize:(CGSize)o forKey:(NSString *)key;
- (void)ba_setRect:(CGRect)o forKey:(NSString *)key;

@end

@interface NSDictionary ( BAUtil )

// MARK: = 访问

- (BOOL)ba_hasKey:(id)key;

- (id)ba_atPath:(NSString *)path;
- (id)ba_atPath:(NSString *)path separator:(NSString * _Nullable)separator;
- (id)ba_atPath:(NSString *)path otherwise:(NSObject *)other separator:(NSString * _Nullable)separator;

- (CGPoint)ba_pointAtPath:(NSString *)path;
- (CGSize)ba_sizeAtPath:(NSString *)path;
- (CGRect)ba_rectAtPath:(NSString *)path;

// MARK: = 流处理

/// 同步遍历
- (void)ba_each:(void (^)(id key, id obj))block;

/// 并发遍历
- (void)ba_apply:(void (^)(id key, id obj))block;

/// 匹配，返回第一个匹配上的 kv pair
- (nullable id)ba_match:(BOOL (^)(id key, id obj))block;

/// 选取，返回所有匹配上的 kv pairs
- (NSDictionary *)ba_select:(BOOL (^)(id key, id obj))block;

/// 反选，返回所有匹配失败的 kv pairs
- (NSDictionary *)ba_reject:(BOOL (^)(id key, id obj))block;

/// 映射
- (NSDictionary *)ba_map:(id (^)(id key, id obj))block;

/// 是否有匹配上的
- (BOOL)ba_any:(BOOL (^)(id key, id obj))block;

/// 是否没有匹配上的
- (BOOL)ba_none:(BOOL (^)(id key, id obj))block;

/// 是否全部匹配上
- (BOOL)ba_all:(BOOL (^)(id key, id obj))block;

@end

NS_ASSUME_NONNULL_END

