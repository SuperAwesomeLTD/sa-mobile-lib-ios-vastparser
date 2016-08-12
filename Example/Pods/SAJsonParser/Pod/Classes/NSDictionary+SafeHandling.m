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

- (_Nullable id) safeObjectForKey:(_Nullable id)aKey {
    if (aKey == nil || aKey == [NSNull null]) {
        return nil;
    } else {
        NSObject *object = self[aKey];
        
        if (object == [NSNull null]) {
            return nil;
        }
        if (object == nil) {
            return nil;
        }
        
        return object;
    }
}

@end
