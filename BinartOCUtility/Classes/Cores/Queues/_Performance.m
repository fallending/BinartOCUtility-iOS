#import "_Performance.h"
#import "BAProperty.h"
#import "BAThreadSafeDictionary.h"

#pragma mark - 

@implementation NSObject ( Performance )

- (void)runBlockWithPerformance:(void (^)(void)) block withTag:(NSString *) tag {
    
    double a = CFAbsoluteTimeGetCurrent();
    block();
    double b = CFAbsoluteTimeGetCurrent();
    
    unsigned int m = ((b-a) * 1000.0f); // convert from seconds to milliseconds
    
    ba_log(@"%@: %d ms", tag ? @"" : @"Time taken", m);
}

@end

@interface BAPerformance ()

@SINGLETON( BAPerformance )

@PROP_STRONG( BAThreadSafeDictionary *, tags )

@end

@implementation BAPerformance

@DEF_SINGLETON( BAPerformance )

- (id)init {
    self = [super init];
    if ( self ) {
        _tags = [BAThreadSafeDictionary new];
    }
    
    return self;
}

+ (void)enter:(NSString *)tag {
    NSNumber * time = [NSNumber numberWithDouble:CACurrentMediaTime()];
    NSString * name = [NSString stringWithFormat:@"%@ enter", tag];
    
    [BAPerformance.shared.tags setObject:time forKey:name];
}

+ (void)leave:(NSString *)tag {
    @autoreleasepool {
        NSString * name1 = [NSString stringWithFormat:@"%@ enter", tag];
        NSString * name2 = [NSString stringWithFormat:@"%@ leave", tag];
        
        CFTimeInterval time1 = [[BAPerformance.shared.tags objectForKey:name1] doubleValue];
        CFTimeInterval time2 = CACurrentMediaTime(); // this method returns, units to seconds
        
        NSLog( @"Time '%@' = %.0f(ms)", tag, fabs((time2 - time1)*1000) );
        
        [BAPerformance.shared.tags removeObjectForKey:name1];
        [BAPerformance.shared.tags removeObjectForKey:name2];
    }
}

@end
