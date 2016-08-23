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
#import "SAMedia.h"
#import "SATracking.h"

@implementation SAAd

- (id) init {
    if (self = [super init]){
        _creative = [[SACreative alloc] init];
    }
    return self;
}

- (id) initWithJsonDictionary:(NSDictionary *)jsonDictionary {
    if (self = [super initWithJsonDictionary:jsonDictionary]) {
        
        _error = [[jsonDictionary safeObjectForKey:@"error"] integerValue];
        _advertiserId = [[jsonDictionary safeObjectForKey:@"advertiserId"] integerValue];
        _publisherId = [[jsonDictionary safeObjectForKey:@"publisherId"] integerValue];
        _app = [[jsonDictionary safeObjectForKey:@"app"] integerValue];
        _lineItemId = [[jsonDictionary safeObjectForKey:@"line_item_id"] integerValue];
        _campaignId = [[jsonDictionary safeObjectForKey:@"campaign_id"] integerValue];
        _placementId = [[jsonDictionary safeObjectForKey:@"placementId"] integerValue];
        _test = [[jsonDictionary safeObjectForKey:@"test"] boolValue];
        _isFallback = [[jsonDictionary safeObjectForKey:@"is_fallback"] boolValue];
        _isFill = [[jsonDictionary safeObjectForKey:@"is_fill"] boolValue];
        _isHouse = [[jsonDictionary safeObjectForKey:@"is_house"] boolValue];
        _safeAdApproved = [[jsonDictionary safeObjectForKey:@"safe_ad_approved"] boolValue];
        _showPadlock = [[jsonDictionary safeObjectForKey:@"show_padlock"] boolValue];
        
        _isVAST = [[jsonDictionary safeObjectForKey:@"isVAST"] boolValue];
        _vastType = [[jsonDictionary safeObjectForKey:@"vastType"] integerValue];
        _vastRedirect = [jsonDictionary safeObjectForKey:@"vastRedirect"];
        
        _creative = [[SACreative alloc] initWithJsonDictionary:[jsonDictionary safeObjectForKey:@"creative"]];
    }
    
    return self;
}

- (NSDictionary*) dictionaryRepresentation {
    return @{
             @"error": @(_error),
             @"advertiserId": @(_advertiserId),
             @"publisherId": @(_publisherId),
             @"app": @(_app),
             @"line_item_id": @(_lineItemId),
             @"campaign_id": @(_campaignId),
             @"placementId": @(_placementId),
             @"test": @(_test),
             @"is_fallback": @(_isFallback),
             @"is_fill": @(_isFill),
             @"is_house": @(_isHouse),
             @"safe_ad_approved": @(_safeAdApproved),
             @"show_padlock": @(_showPadlock),
             @"isVAST": @(_isVAST),
             @"vastType": @(_vastType),
             @"vastRedirect": nullSafe(_vastRedirect),
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
