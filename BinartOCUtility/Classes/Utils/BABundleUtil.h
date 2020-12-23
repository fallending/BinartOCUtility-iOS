#import "BAMacros.h"
#import "BAProperty.h"

@interface NSBundle ( BAUtil )

@PROP_READONLY( NSString *,    ba_bundleName );
@PROP_READONLY( NSString *,    ba_extensionName );

+ (NSBundle *)ba_bundleWithName:(NSString *)bundleName;

+ (UIImage *)ba_imageWithName:(NSString *)imageName bundleName:(NSString *)bundleName;
+ (UIImage *)ba_imageWithName:(NSString *)imageName bundleName:(NSString *)bundleName subPath:(NSString *)subPath;

- (id)ba_dataForResource:(NSString *)resName;
- (id)ba_textForResource:(NSString *)resName;
- (id)ba_imageForResource:(NSString *)resName;

@end
