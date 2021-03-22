#import "BABundleUtil.h"

@implementation NSBundle ( BAUtil )

- (NSString *)mt_bundleName {
    return [[self.resourcePath lastPathComponent] stringByDeletingPathExtension];
}

- (NSString *)mt_extensionName {
    return [self.resourcePath pathExtension];
}

+ (NSBundle *)mt_bundleWithName:(NSString *)bundleName {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    return [NSBundle bundleWithPath:bundlePath];
}

+ (UIImage *)mt_imageWithName:(NSString *)imageName bundleName:(NSString *)bundleName {
    NSBundle *bundle = [self mt_bundleWithName:bundleName];
    UIImage *(^ getBundleImage)(NSString *) = ^(NSString *res) {
        return  [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil]; // iOS 8.0
//        NSString *imagePath = [bundle pathForResource:res ofType:@"png"];
//        return  [UIImage imageWithContentsOfFile:imagePath];
    };
    UIImage *image = getBundleImage(imageName);
    
    return image;
}

+ (UIImage *)mt_imageWithName:(NSString *)imageName bundleName:(NSString *)bundleName subPath:(NSString *)subPath {
    NSBundle *bundle = [self mt_bundleWithName:bundleName];
    UIImage *(^ getBundleImage)(NSString *) = ^(NSString *res) {
        NSString *imagePath = [bundle pathForResource:res ofType:@"png" inDirectory:subPath];
        return  [UIImage imageWithContentsOfFile:imagePath];
    };
    UIImage *image = getBundleImage(imageName);
    
    return image;
}

- (id)mt_dataForResource:(NSString *)resName {
    NSString *    path = [NSString stringWithFormat:@"%@/%@", self.resourcePath, resName];
    NSData *    data = [NSData dataWithContentsOfFile:path];
    
    return data;
}

- (id)mt_textForResource:(NSString *)resName {
    NSString *    path = [NSString stringWithFormat:@"%@/%@", self.resourcePath, resName];
    NSString *    data = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:NULL];
    
    return data;
}

- (id)mt_imageForResource:(NSString *)resName {
    NSString *    extensionName = [resName pathExtension];
    NSString *    resourceName = [resName substringToIndex:(resName.length - extensionName.length - 1)];
    
    UIImage *    image = nil;
    
    if ( !image ) { // 3x 优先，2x其次
        NSString *    path = [NSString stringWithFormat:@"%@/%@@3x.%@", self.resourcePath, resourceName, extensionName];
        NSString *    path2 = [NSString stringWithFormat:@"%@/%@@2x.%@", self.resourcePath, resourceName, extensionName];
        NSString *    path3 = [NSString stringWithFormat:@"%@/%@.%@", self.resourcePath, resourceName, extensionName];
        
        image = [[UIImage alloc] initWithContentsOfFile:path];
        if ( !image ) {
            image = [[UIImage alloc] initWithContentsOfFile:path2];
        }
        
        if ( !image ) {
            image = [[UIImage alloc] initWithContentsOfFile:path3];
        }
    }
    
    return image;
}

@end
