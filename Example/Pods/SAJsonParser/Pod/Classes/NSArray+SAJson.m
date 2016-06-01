//
//  NSArray+SAJson.m
//  Pods
//
//  Created by Gabriel Coman on 27/05/2016.
//
//

#import "NSArray+SAJson.h"

@implementation NSArray (SAJson)

// serialization part

- (NSArray*) dictionaryRepresentation {
    NSMutableArray *array = [@[] mutableCopy];
    
    for (id item in self){
        if ([item respondsToSelector:@selector(dictionaryRepresentation)]) {
            NSDictionary *result = [item dictionaryRepresentation];
            if (result != NULL && ![result isEqualToDictionary:@{}]) {
                [array addObject:result];
            }
        }
    }
    
    if ([array count] > 0) return array;
    return self;
}

- (NSString*) jsonPrettyStringRepresentation {
    NSArray *array = (NSArray*)[self dictionaryRepresentation];
    if ([NSJSONSerialization isValidJSONObject:array]) {
        NSData *json = [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
        return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSString*) jsonCompactStringRepresentation {
    NSArray *array = (NSArray*)[self dictionaryRepresentation];
    if ([NSJSONSerialization isValidJSONObject:array]) {
        NSData *json = [NSJSONSerialization dataWithJSONObject:array options:kNilOptions error:nil];
        return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSData*) jsonDataRepresentation {
    NSArray *array = (NSArray*)[self dictionaryRepresentation];
    if ([NSJSONSerialization isValidJSONObject:array]) {
        return [NSJSONSerialization dataWithJSONObject:array options:NSJSONWritingPrettyPrinted error:nil];
    }
    return nil;
}

// deserialization part

- (id) initWithJsonArray:(NSArray*)array andIterator:(SAArrayIterator)iterator {
    if (self = [self init]) {
        NSMutableArray *mutableSelf = [@[] mutableCopy];
        if (array != NULL) {
            for (id item in array) {
                [mutableSelf addObject:iterator(item)];
            }
        }
        self = mutableSelf;
    }
    
    return self;
}

+ (NSArray*) arrayWithJsonArray:(NSArray*)array andIterator:(SAArrayIterator)iterator {
    return [[NSArray alloc] initWithJsonArray:array andIterator:iterator];
}

- (id) initWithJsonString:(NSString*)json andIterator:(SAArrayIterator)iterator {
    NSData *data = [json dataUsingEncoding:NSUTF8StringEncoding];
    if (self = [self initWithJsonData:data andIterator:iterator]) {
        
    }
    return self;
}

+ (NSArray*) arrayWithJsonString:(NSString *)json andIterator:(SAArrayIterator)iterator {
    return [[NSArray alloc] initWithJsonString:json andIterator:iterator];
}

- (id) initWithJsonData:(NSData*)json andIterator:(SAArrayIterator)iterator {
    
    NSArray* array = [NSJSONSerialization JSONObjectWithData:json options:kNilOptions error:nil];
    if (self = [self initWithJsonArray:array andIterator:iterator]){
        
    }
    return self;
}

+ (NSArray*) arrayWithJsonData:(NSData *)json andIterator:(SAArrayIterator)iterator {
    return [[NSArray alloc] initWithJsonData:json andIterator:iterator];
}

@end
