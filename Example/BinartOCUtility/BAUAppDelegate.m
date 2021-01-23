//
//  BAUAppDelegate.m
//  BinartOCUtility
//
//  Created by fallending on 07/27/2020.
//  Copyright (c) 2020 fallending. All rights reserved.
//

#import "BAUAppDelegate.h"
#import <BinartOCUtility/BAUtility.h>
#import "BAUAppDelegate+TestPath.h"

///usr/include/cdefs.h
//#define __dead2         __attribute__((__noreturn__))
//#define __pure2         __attribute__((__const__))
//
///* __unused denotes variables and functions that may not be used, preventing
// * the compiler from warning about it if not used.
// */
//#define __unused        __attribute__((__unused__))
//
///* __used forces variables and functions to be included even if it appears
// * to the compiler that they are not used (and would thust be discarded).
// */
//#define __used          __attribute__((__used__))
//
///* __cold marks code used for debugging or that is rarely taken
// * and tells the compiler to optimize for size and outline code.
// */
//#if __has_attribute(cold)
//#define __cold          __attribute__((__cold__))
//#else
//#define __cold
//#endif
//
///* __exported denotes symbols that should be exported even when symbols
// * are hidden by default.
// * __exported_push/_exported_pop are pragmas used to delimit a range of
// *  symbols that should be exported even when symbols are hidden by default.
// */
//#define __exported                      __attribute__((__visibility__("default")))
//#define __exported_push         _Pragma("GCC visibility push(default)")
//#define __exported_pop          _Pragma("GCC visibility pop")

@implementation BAUAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [self testPath];
    
#if DEBUG
    NSLog(@"run in debug env");
#else
    NSLog(@"run in release env");
#endif
    
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
