#import "BAMacros.h"
#import "BAProperty.h"

@interface NSBundle ( BAUtil )

@PROP_READONLY( NSString *,    mt_bundleName );
@PROP_READONLY( NSString *,    mt_extensionName );

+ (NSBundle *)mt_bundleWithName:(NSString *)bundleName;

+ (UIImage *)mt_imageWithName:(NSString *)imageName bundleName:(NSString *)bundleName;
+ (UIImage *)mt_imageWithName:(NSString *)imageName bundleName:(NSString *)bundleName subPath:(NSString *)subPath;

- (id)mt_dataForResource:(NSString *)resName;
- (id)mt_textForResource:(NSString *)resName;
- (id)mt_imageForResource:(NSString *)resName;

@end
