//
//  BAUAppDelegate+TestCategoryOverrideWarning.m
//  BinartOCUtility_Example
//
//  Created by Seven on 2020/12/26.
//  Copyright © 2020 fallending. All rights reserved.
//

#import "BAUAppDelegate+TestCategoryOverrideWarning.h"

// origin class

@interface TestCategoryOverrideWarningObject : NSObject

- (void)test;

@end

@implementation TestCategoryOverrideWarningObject

- (void)test {
    
}

@end

// category override



@interface TestCategoryOverrideWarningObject ( Test )

- (void)test;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation TestCategoryOverrideWarningObject ( Test )

- (void)test {
    
}

@end

#pragma clang diagnostic pop

// gtest


@implementation BAUAppDelegate (TestCategoryOverrideWarning)

@end
