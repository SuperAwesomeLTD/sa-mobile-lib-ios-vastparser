/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAAd.h"
#import "SACreative.h"
#import "SADetails.h"
#import "SAMedia.h"
#import "SATracking.h"

@implementation SAAd

/**
 * Base init method
 *
 * @return a new instance of the object
 */
- (id) init {
    if (self = [super init]){
        [self initDefaults];
    }
    return self;
}

/**
 * Overridden "initWithJsonDictionary" init method from the
 * SADeserializationProtocol protocol that describes how this model gets
 * initialised from the fields of a NSDictionary object (create from a
 * JSON string)
 *
 * @return a new instance of the object
 */
- (id) initWithJsonDictionary:(NSDictionary *)jsonDictionary {
    if (self = [super initWithJsonDictionary:jsonDictionary]) {
        
        // init defaults
        [self initDefaults];
        
        // start taking from JSON
        _error = [jsonDictionary safeIntForKey:@"error" orDefault:_error];
        _advertiserId = [jsonDictionary safeIntForKey:@"advertiserId" orDefault:_advertiserId];
        _publisherId = [jsonDictionary safeIntForKey:@"publisherId" orDefault:_publisherId];
        _app = [jsonDictionary safeIntForKey:@"app" orDefault:_app];
        _lineItemId = [jsonDictionary safeIntForKey:@"line_item_id" orDefault:_lineItemId];
        _campaignId = [jsonDictionary safeIntForKey:@"campaign_id" orDefault:_campaignId];
        _placementId = [jsonDictionary safeIntForKey:@"placementId" orDefault:_placementId];
        
        NSInteger campaignType = [jsonDictionary safeIntForKey:@"campaign_type" orDefault:0];
        _campaignType = getSACampaignTypeFromInt(campaignType);
        
        _test = [jsonDictionary safeBoolForKey:@"test" orDefault:_test];
        _isFallback = [jsonDictionary safeBoolForKey:@"is_fallback" orDefault:_isFallback];
        _isFill = [jsonDictionary safeBoolForKey:@"is_fill" orDefault:_isFill];
        _isHouse = [jsonDictionary safeBoolForKey:@"is_house" orDefault:_isHouse];
        _safeAdApproved = [jsonDictionary safeBoolForKey:@"safe_ad_approved" orDefault:_safeAdApproved];
        _showPadlock = [jsonDictionary safeBoolForKey:@"show_padlock" orDefault:_showPadlock];
        _moat = [jsonDictionary safeFloatForKey:@"moat" orDefault:_moat];
        
        _device = [jsonDictionary safeStringForKey:@"device" orDefault:_device];
        
        NSDictionary *creativeDict = [jsonDictionary safeDictionaryForKey:@"creative" orDefault:nil];
        if (creativeDict) {
            _creative = [[SACreative alloc] initWithJsonDictionary:creativeDict];
        }
    }
    
    return self;
}

/**
 * Overridden "isValid" method from the SADeserializationProtocol protocol
 *
 * @return true or false
 */
- (BOOL) isValid {
    
    switch (_creative.format) {
        case SA_Invalid:
            return false;
        case SA_Image:
            return _creative.details.image != nil && _creative.details.media.html != nil;
        case SA_Rich:
            return _creative.details.url != nil && _creative.details.media.html != nil;
        case SA_Video:
            return _creative.details.vast != nil &&
                    _creative.details.media.playableMediaUrl != nil &&
                    _creative.details.media.playableDiskUrl != nil &&
                    _creative.details.media.isOnDisk;
        case SA_Tag:
            return _creative.details.tag != nil && _creative.details.media.html != nil;
        case SA_Appwall:
            return _creative.details.image != nil &&
                    _creative.details.media.playableMediaUrl != nil &&
                    _creative.details.media.playableDiskUrl != nil &&
                    _creative.details.media.isOnDisk;
    }
    
    return true;
}

/**
 * Overridden "dictionaryRepresentation" method from the
 * SADeserializationProtocol protocol that describes how this model is
 * going to get translated to a dictionary
 *
 * @return a NSDictionary object representing all the members of this object
 */
- (NSDictionary*) dictionaryRepresentation {
    return @{
             @"error": @(_error),
             @"advertiserId": @(_advertiserId),
             @"publisherId": @(_publisherId),
             @"app": @(_app),
             @"line_item_id": @(_lineItemId),
             @"campaign_id": @(_campaignId),
             @"placementId": @(_placementId),
             @"campaign_type": @(_campaignType),
             @"moat": @(_moat),
             @"test": @(_test),
             @"is_fallback": @(_isFallback),
             @"is_fill": @(_isFill),
             @"is_house": @(_isHouse),
             @"safe_ad_approved": @(_safeAdApproved),
             @"show_padlock": @(_showPadlock),
             @"creative": nullSafe([_creative dictionaryRepresentation]),
             @"device": nullSafe(_device)
             };
}

/**
 * Method that initializes all the values for the model
 */
- (void) initDefaults {
    
    _error = 0;
    _advertiserId = 0;
    _publisherId = 0;
    _app = 0;
    _lineItemId = 0;
    _campaignId = 0;
    _placementId = 0;
    _campaignType = SA_CPM;
    _moat = 0.2;
    _test = false;
    _isFallback = false;
    _isFill = false;
    _isHouse = false;
    _safeAdApproved = false;
    _showPadlock = false;
    _device = nil;
    
    // create creative
    _creative = [[SACreative alloc] init];
}

@end
