
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BAPair <__covariant ObjectType1, __covariant ObjectType2> : NSObject <NSCopying, NSMutableCopying>

@property (nonatomic, strong, nullable) ObjectType1 first;
@property (nonatomic, strong, nullable) ObjectType2 second;

+ (instancetype)with:(ObjectType1)first and:(ObjectType2)second;
- (instancetype)with:(ObjectType1)first and:(ObjectType2)second;

@end

NS_ASSUME_NONNULL_END
