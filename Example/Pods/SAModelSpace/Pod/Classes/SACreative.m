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
        
    }
    return self;
}

- (id) initWithJsonDictionary:(NSDictionary *)jsonDictionary {
    if (self = [super initWithJsonDictionary:jsonDictionary]) {
        
        __id = [[jsonDictionary safeObjectForKey:@"id"] integerValue];
        _name = [jsonDictionary safeObjectForKey:@"name"];
        _cpm = [[jsonDictionary safeObjectForKey:@"cpm"] integerValue];
        _format = [jsonDictionary safeObjectForKey:@"format"];
        _impressionUrl = [jsonDictionary safeObjectForKey:@"impression_url"];
        _customPayload = [jsonDictionary safeObjectForKey:@"customPayload"];
        _clickUrl = [jsonDictionary safeObjectForKey:@"click_url"];
        _live = [[jsonDictionary safeObjectForKey:@"live"] boolValue];
        _approved = [[jsonDictionary safeObjectForKey:@"approved"] boolValue];
        _details = [[SADetails alloc] initWithJsonDictionary:[jsonDictionary safeObjectForKey:@"details"]];
        _creativeFormat = (SACreativeFormat)[[jsonDictionary safeObjectForKey:@"creativeFormat"] integerValue];
        _viewableImpressionUrl = [jsonDictionary safeObjectForKey:@"viewableImpressionUrl"];
        _trackingUrl = [jsonDictionary safeObjectForKey:@"trackingUrl"];
        _parentalGateFailUrl = [jsonDictionary safeObjectForKey:@"parentalGateFailUrl"];
        _parentalGateOpenUrl = [jsonDictionary safeObjectForKey:@"parentalGateOpenUrl"];
        _parentalGateCloseUrl = [jsonDictionary safeObjectForKey:@"parentalGateCloseUrl"];
        _parentalGateSuccessUrl = [jsonDictionary safeObjectForKey:@"parentalGateSuccessUrl"];
    }
    return self;
}

- (NSDictionary*) dictionaryRepresentation {
    return @{
        @"id": @(__id),
        @"name": nullSafe(_name),
        @"cpm": @(_cpm),
        @"format": nullSafe(_format),
        @"impression_url": nullSafe(_impressionUrl),
        @"customPayload": nullSafe(_customPayload),
        @"click_url": nullSafe(_clickUrl),
        @"live": @(_live),
        @"approved": @(_approved),
        @"details": nullSafe([_details dictionaryRepresentation]),
        @"creativeFormat": @(_creativeFormat),
        @"viewableImpressionUrl": nullSafe(_viewableImpressionUrl),
        @"trackingUrl": nullSafe(_trackingUrl),
        @"parentalGateFailUrl": nullSafe(_parentalGateFailUrl),
        @"parentalGateOpenUrl": nullSafe(_parentalGateOpenUrl),
        @"parentalGateCloseUrl": nullSafe(_parentalGateCloseUrl),
        @"parentalGateSuccessUrl": nullSafe(_parentalGateSuccessUrl)
    };
}

@end
