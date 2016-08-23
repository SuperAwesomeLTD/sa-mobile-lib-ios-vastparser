//
//  SATracking.m
//  Pods
//
//  Created by Gabriel Coman on 22/08/2016.
//
//

#import "SATracking.h"

@implementation SATracking

- (id) init{
    if (self = [super init]){
        
    }
    return self;
}

- (id) initWithJsonDictionary:(NSDictionary *)jsonDictionary {
    if (self = [super initWithJsonDictionary:jsonDictionary]) {
        _event = [jsonDictionary safeObjectForKey:@"event"];
        _URL = [jsonDictionary safeObjectForKey:@"URL"];
    }
    return self;
}

- (NSDictionary*) dictionaryRepresentation {
    return @{
             @"event": nullSafe(_event),
             @"URL": nullSafe(_URL)
             };
}

@end
