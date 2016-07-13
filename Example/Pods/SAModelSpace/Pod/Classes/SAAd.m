//
//  SAAd.m
//  Pods
//
//  Copyright (c) 2015 SuperAwesome Ltd. All rights reserved.
//
//  Created by Gabriel Coman on 28/09/2015.
//
//

// import this model's header
#import "SAAd.h"

#import "SACreative.h"
#import "SADetails.h"
#import "SAData.h"

@implementation SAAd

- (id) init {
    if (self = [super init]){
    
    }
    return self;
}

- (id) initWithJsonDictionary:(NSDictionary *)jsonDictionary {
    if (self = [super initWithJsonDictionary:jsonDictionary]) {
        
        _placementId = [[jsonDictionary safeObjectForKey:@"placementId"] integerValue];
        _advertiserId = [[jsonDictionary safeObjectForKey:@"advertiserId"] integerValue];
        _publisherId = [[jsonDictionary safeObjectForKey:@"publisherId"] integerValue];
        _error = [[jsonDictionary safeObjectForKey:@"error"] integerValue];
        _app = [[jsonDictionary safeObjectForKey:@"app"] integerValue];
        _lineItemId = [[jsonDictionary safeObjectForKey:@"line_item_id"] integerValue];
        _campaignId = [[jsonDictionary safeObjectForKey:@"campaign_id"] integerValue];
        _test = [[jsonDictionary safeObjectForKey:@"test"] boolValue];
        _isFallback = [[jsonDictionary safeObjectForKey:@"is_fallback"] boolValue];
        _isFill = [[jsonDictionary safeObjectForKey:@"is_fill"] boolValue];
        _isHouse = [[jsonDictionary safeObjectForKey:@"is_house"] boolValue];
        _creative = [[SACreative alloc] initWithJsonDictionary:[jsonDictionary safeObjectForKey:@"creative"]];
    }
    
    return self;
}

- (NSDictionary*) dictionaryRepresentation {
    return @{
        @"placementId": @(_placementId),
        @"advertiserId": @(_advertiserId),
        @"publisherId": @(_publisherId),
        @"error": @(_error),
        @"app": @(_app),
        @"line_item_id": @(_lineItemId),
        @"campaign_id": @(_campaignId),
        @"test": @(_test),
        @"is_fallback": @(_isFallback),
        @"is_fill": @(_isFill),
        @"is_house": @(_isHouse),
        @"creative": nullSafe([_creative dictionaryRepresentation])
    };
}

- (BOOL) isValid {
    
    if (_creative == NULL) return false;
    if (_creative.creativeFormat == invalid) return false;
    if (_creative.details == NULL) return false;
    
    switch (_creative.creativeFormat) {
        case image: {
            if (_creative.details.image == NULL) return false;
            break;
        }
        case video:{
            if (_creative.details.vast == NULL) return false;
            break;
        }
        case invalid:{
            return false;
            break;
        }
        case tag:{
            if (_creative.details.tag == NULL) return false;
            break;
        }
        case rich:{
            if (_creative.details.url == NULL) return false;
            break;
        }
    }
    
    return true;
}

@end
