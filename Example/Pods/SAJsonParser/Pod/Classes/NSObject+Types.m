//
//  NSObject+BaseType.m
//  Pods
//
//  Created by Gabriel Coman on 21/04/2016.
//
//

#import "NSObject+Types.h"

@implementation NSObject (Types)

- (BOOL) isBaseType {
    return ([self isKindOfClass:[NSNumber class]] ||
            [self isKindOfClass:[NSDecimalNumber class]]  ||
            [self isKindOfClass:[NSString class]] ||
            [self isKindOfClass:[NSMutableString class]] ||
            [self isKindOfClass:[NSSet class]] ||
            [self isKindOfClass:[NSMutableSet class]] ||
            [self isKindOfClass:[NSArray class]] ||
            [self isKindOfClass:[NSMutableArray class]] ||
            [self isKindOfClass:[NSDictionary class]] ||
            [self isKindOfClass:[NSMutableDictionary class]] ||
            [self isKindOfClass:[NSNull class]]);
}

- (BOOL) isObjectType {
    return [self isKindOfClass:[NSObject class]];
}

- (BOOL) isValueType {
    return (![self isKindOfClass:[NSNull class]] &&
            [self isKindOfClass:[NSValue class]]);
}

- (BOOL) isNumberType {
    return (![self isKindOfClass:[NSNull class]] &&
            ([self isKindOfClass:[NSNumber class]] ||
             [self isKindOfClass:[NSDecimalNumber class]]));
}

- (BOOL) isStringType {
    return (![self isKindOfClass:[NSNull class]] &&
            ([self isKindOfClass:[NSString class]] ||
             [self isKindOfClass:[NSMutableString class]]));
}

- (BOOL) isArrayType {
    return (![self isKindOfClass:[NSNull class]] &&
            ([self isKindOfClass:[NSArray class]] ||
            [self isKindOfClass:[NSMutableArray class]]));
}

- (BOOL) isDictionaryType {
    return (![self isKindOfClass:[NSNull class]] &&
            ([self isKindOfClass:[NSDictionary class]] ||
             [self isKindOfClass:[NSMutableDictionary class]]));
}

- (BOOL) isSetType {
    return (![self isKindOfClass:[NSNull class]] &&
            ([self isKindOfClass:[NSSet class]] ||
             [self isKindOfClass:[NSMutableSet class]] ||
             [self isKindOfClass:[NSMutableIndexSet class]] ||
             [self isKindOfClass:[NSMutableOrderedSet class]]));
}

- (BOOL) isNullType {
    return [self isKindOfClass:[NSNull class]];
}

@end
