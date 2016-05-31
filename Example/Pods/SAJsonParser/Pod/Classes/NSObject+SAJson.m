//
//  NSObject+SASerialization.m
//  Pods
//
//  Created by Gabriel Coman on 27/05/2016.
//
//

#import "NSObject+SAJson.h"
#import "NSDictionary+SAJson.h"

@implementation NSObject (SAJson)

// default implementation (that should be overridden)
- (id) initWithJsonDictionary:(NSDictionary*)jsonDictionary{
    if (self = [self init]){
        
    }
    return self;
}

// default implementation - should be left as it is
- (id) initWithJsonString:(NSString*)jsonString {
    NSDictionary *jsonDictionary = [[NSDictionary alloc] initWithJsonString:jsonString];
    if (self = [self initWithJsonDictionary:jsonDictionary]) {
        
    }
    return self;
}

// default implementation - should be left as it is
- (id) initWithJsonData:(NSData*)jsonData {
    NSDictionary *jsonDictionary = [[NSDictionary alloc] initWithJsonData:jsonData];
    if (self = [self initWithJsonDictionary:jsonDictionary]) {
        
    }
    return self;
}

// default implementation - should be left as it is
- (BOOL) isValid {
    return true;
}

// serialization

// default implementation that should be overriden
- (NSDictionary*) dictionaryRepresentation {
    return NULL;
}

// default implementation - should be left as it is
- (NSString*) jsonPreetyStringRepresentation {
    NSDictionary *dictionary = [self dictionaryRepresentation];
    if ([NSJSONSerialization isValidJSONObject:dictionary]) {
        NSData *json = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:nil];
        return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    }
    return nil;
}

// default implementation - should be left as it is
- (NSString*) jsonCompactStringRepresentation {
    NSDictionary *dictionary = [self dictionaryRepresentation];
    if ([NSJSONSerialization isValidJSONObject:dictionary]) {
        NSData *json = [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:nil];
        return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    }
    return nil;
}

// default implementation - should be left as it is
- (NSData*) jsonDataRepresentation {
    NSDictionary *dictionary = [self dictionaryRepresentation];
    if ([NSJSONSerialization isValidJSONObject:dictionary]) {
        return [NSJSONSerialization dataWithJSONObject:dictionary options:kNilOptions error:nil];
    }
    return nil;
}

@end
