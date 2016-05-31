//
//  NSDictionary+SAJsonExtension.m
//  Pods
//
//  Created by Gabriel Coman on 27/05/2016.
//
//

#import "NSDictionary+SAJson.h"

@implementation NSDictionary (SAJson)

// deserialization

- (NSDictionary*) dictionaryRepresentation {
    return self;
}

- (NSString*) jsonPreetyStringRepresentation {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSData *json = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
        return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSString*) jsonCompactStringRepresentation {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        NSData *json = [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:nil];
        return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    }
    return nil;
}

- (NSData*) jsonDataRepresentation {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        return [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:nil];
    }
    return nil;
}

// serialization

- (id) initWithJsonDictionary:(NSDictionary *)jsonDictionary {
    if (self = [self init]) {
        NSMutableDictionary *dictionary = [@{} mutableCopy];
        for (NSString *key in [jsonDictionary allKeys]) {
            [dictionary setValue:[jsonDictionary objectForKey:key] forKey:key];
        }
        self = dictionary;
    }
    return self;
}

- (id) initWithJsonData:(NSData *)jsonData {
    if (jsonData == NULL) return NULL;
    NSError *error = NULL;
    NSDictionary *temp = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    if (error) return NULL;
    if (self = [self initWithJsonDictionary:temp]){
        
    }
    return self;
}

- (id) initWithJsonString:(NSString *)jsonString {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    if (self = [self initWithJsonData:jsonData]){
        
    }
    return self;
}

- (BOOL) isValid {
    return true;
}

- (id) objectForKey:(id)aKey {
    id response = [self objectForKey:aKey];
    if (response != NULL || ![response isKindOfClass:[NSNull class]]) { return response; }
    return NULL;
}

@end

