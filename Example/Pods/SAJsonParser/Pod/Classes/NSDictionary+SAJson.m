//
//  NSDictionary+SAJsonExtension.m
//  Pods
//
//  Created by Gabriel Coman on 27/05/2016.
//
//

#import "NSDictionary+SAJson.h"

@implementation NSDictionary (SAJson)

// private common functions

- (NSData*) jsonData:(NSJSONWritingOptions) options {
    if ([NSJSONSerialization isValidJSONObject:self]) {
        return [NSJSONSerialization dataWithJSONObject:self options:kNilOptions error:nil];
    }
    return nil;
}

- (NSDictionary*) dictionaryFromData:(NSData*) json {
    
    if (json != nil) {
        NSError *error = nil;
        NSDictionary *temp = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableContainers error:&error];
        if (error == nil) {
            return temp;
        }
    }
    
    return nil;
}

// deserialization

- (NSDictionary*) dictionaryRepresentation {
    return self;
}

- (NSString*) jsonPreetyStringRepresentation {
    NSData *json = [self jsonData:NSJSONWritingPrettyPrinted];
    return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
}

- (NSString*) jsonCompactStringRepresentation {
    NSData *json = [self jsonData:kNilOptions];
    return [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
}

- (NSData*) jsonDataRepresentation {
    return [self jsonData:kNilOptions];
}

// serialization

- (id) initWithJsonDictionary:(NSDictionary *)jsonDictionary {
    if (self = [self initWithDictionary:jsonDictionary]) {
    
    }
    return self;
}

- (id) initWithJsonData:(NSData *)jsonData {
    NSDictionary *temp = [self dictionaryFromData:jsonData];
    if (!temp) return NULL;
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

@end

