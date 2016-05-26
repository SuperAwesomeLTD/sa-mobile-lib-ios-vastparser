//
//  NSString+Aux.m
//  Pods
//
//  Created by Gabriel Coman on 26/04/2016.
//
//

#import "NSString+JsonAux.h"

@implementation NSString (JsonAux)

- (NSString*) cleanFirstUnderscore {
    NSString *cleaned = self;
    if ([cleaned length] > 1){
        NSString *first = [cleaned substringToIndex:1];
        if ([first isEqualToString:@"_"]) {
            cleaned = [cleaned substringFromIndex:1];
        } else {
            cleaned = self;
        }
    }
    return cleaned;
}

- (NSString*) joinStringWithUnderscores {
    NSArray *components = [self componentsSeparatedByString:@"_"];
    NSMutableString *joined = nil;
    if ([components count] > 1) {
        joined = [[NSMutableString alloc] initWithString:[components firstObject]];
        for (int i = 1; i < [components count]; i++){
            [joined appendString:[components[i] capitalizedString]];
        }
    } else {
        joined = [self mutableCopy];
    }
    return joined;
}

@end
