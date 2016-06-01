//
//  NSDictionary+SafeHandling.m
//  Pods
//
//  Created by Gabriel Coman on 31/05/2016.
//
//

#import "NSDictionary+SafeHandling.h"

@implementation NSDictionary (SafeHandling)

// safe get

- (id) safeObjectForKey:(id)aKey {
    NSObject *object = self[aKey];
    
    if (object == [NSNull null]) {
        return nil;
    }
    if (object == nil) {
        return nil;
    }
    
    return object;
}

@end
