//
//  SACreative.m
//  Pods
//
//  Copyright (c) 2015 SuperAwesome Ltd. All rights reserved.
//
//  Created by Gabriel Coman on 28/09/2015.
//
//

// import this model's header
#import "SACreative.h"
#import "SADetails.h"

@implementation SACreative

- (id) init {
    if (self = [super init]) {
        _details = [[SADetails alloc] init];
        _events = [@[] mutableCopy];
        _clicks = [@[] mutableCopy];
    }
    return self;
}

- (id) initWithJsonDictionary:(NSDictionary *)jsonDictionary {
    if (self = [super initWithJsonDictionary:jsonDictionary]) {
        
        __id = [[jsonDictionary safeObjectForKey:@"id"] integerValue];
        _name = [jsonDictionary safeObjectForKey:@"name"];
        _cpm = [[jsonDictionary safeObjectForKey:@"cpm"] integerValue];
        _format = [jsonDictionary safeObjectForKey:@"format"];
        _creativeFormat = (SACreativeFormat)[[jsonDictionary safeObjectForKey:@"creativeFormat"] integerValue];
        _customPayload = [jsonDictionary safeObjectForKey:@"customPayload"];
        _live = [[jsonDictionary safeObjectForKey:@"live"] boolValue];
        _approved = [[jsonDictionary safeObjectForKey:@"approved"] boolValue];
        _clickUrl = [jsonDictionary safeObjectForKey:@"click_url"];
        _events = [[[NSArray alloc] initWithJsonArray:[jsonDictionary safeObjectForKey:@"events"] andIterator:^id(id item) {
            return [[SATracking alloc] initWithJsonDictionary:(NSDictionary*)item];
        }] mutableCopy];
        _clicks = [[[NSArray alloc] initWithJsonArray:[jsonDictionary safeObjectForKey:@"clicks"] andIterator:^id(id item) {
            return [[SATracking alloc] initWithJsonDictionary:(NSDictionary*)item];
        }] mutableCopy];
        _details = [[SADetails alloc] initWithJsonDictionary:[jsonDictionary safeObjectForKey:@"details"]];
        
    }
    return self;
}

- (NSDictionary*) dictionaryRepresentation {
    return @{
             @"id": @(__id),
             @"name": nullSafe(_name),
             @"cpm": @(_cpm),
             @"format": nullSafe(_format),
             @"creativeFormat": @(_creativeFormat),
             @"customPayload": nullSafe(_customPayload),
             @"live": @(_live),
             @"approved": @(_approved),
             @"click_url": nullSafe(_clickUrl),
             @"events": nullSafe([_events dictionaryRepresentation]),
             @"clicks": nullSafe([_clicks dictionaryRepresentation]),
             @"details": nullSafe([_details dictionaryRepresentation])
             };
}

@end
