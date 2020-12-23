#import "BAMacros.h"
#import "BAProperty.h"

typedef enum : NSUInteger {
    LocaleType_EN,
    LocaleType_ZH,
} LocaleType;

@interface NSDateFormatter ( BAUtil )

+ (id)dateFormatter;
+ (id)dateFormatterWithFormat:(NSString *)dateFormat;

+ (id)defaultDateFormatter;/*yyyy-MM-dd HH:mm:ss*/

- (NSDateFormatter *)withLocaleType:(LocaleType)type;
- (NSDateFormatter *)withFormat:(NSString *)dateFormat;

@end

#pragma mark -

#define SECOND        (1)
#define MINUTE        (60 * SECOND)
#define HOUR        (60 * MINUTE)
#define DAY            (24 * HOUR)
#define WEEK        (7 * DAY)
#define MONTH        (30 * DAY)
#define YEAR        (12 * MONTH)
#define NOW            [NSDate date]

#define ymdhms      @"yyyy-MM-dd HH:mm:ss"

#define DATE_COMPONENTS (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

typedef enum {
    WeekdayType_Sunday = 1,
    WeekdayType_Monday,
    WeekdayType_Tuesday,
    WeekdayType_Wednesday,
    WeekdayType_Thursday,
    WeekdayType_Friday,
    WeekdayType_Saturday
} WeekdayType;

@interface NSDate ( BAUtil )

// Decomposing dates
@PROP_READONLY( NSInteger,        year );
@PROP_READONLY( NSInteger,        month );
@PROP_READONLY( NSInteger,        day );
@PROP_READONLY( NSInteger,        hour );
@PROP_READONLY( NSInteger,        minute );
@PROP_READONLY( NSInteger,        second );
@PROP_READONLY( WeekdayType,    weekday );
@PROP_READONLY( NSInteger,        week );
@PROP_READONLY( NSDate *,       beginningOfDay ); // NSDate convenience methods which shortens some of frequently used formatting and date altering methods.

+ (NSTimeInterval)unixTime;
+ (NSString *)unixDate;
+ (NSDate *)gmtDate; // 格林威治时间 (GMT)
+ (NSTimeInterval)gmtTime;

+ (NSDateFormatter *)format;
+ (NSDateFormatter *)format:(NSString *)format;
+ (NSDateFormatter *)format:(NSString *)format timeZoneGMT:(NSInteger)hours;
+ (NSDateFormatter *)format:(NSString *)format timeZoneName:(NSString *)name;

- (NSString *)toString:(NSString *)format;
- (NSString *)toString:(NSString *)format timeZoneGMT:(NSInteger)hours;
- (NSString *)toString:(NSString *)format timeZoneName:(NSString *)name;

+ (NSDate *)fromString:(NSString *)string;

+ (NSDate *)dateFromString:(NSString *)dateString;
+ (NSDate *)dateFromString:(NSString *)dateString withFormat:(NSString *)fmt;

@end
