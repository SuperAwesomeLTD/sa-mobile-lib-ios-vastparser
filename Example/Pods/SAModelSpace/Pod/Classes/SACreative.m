/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

// import this model's header
#import "SACreative.h"
#import "SADetails.h"

@implementation SACreative

/**
 * Base init method
 *
 * @return a new instance of the object
 */
- (id) init {
    if (self = [super init]) {
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
        
        // take from json
        __id = [jsonDictionary safeIntForKey:@"id" orDefault:__id];
        _name = [jsonDictionary safeStringForKey:@"name" orDefault:_name];
        _cpm = [jsonDictionary safeIntForKey:@"cpm" orDefault:_cpm];
        
        NSString *format = [jsonDictionary safeStringForKey:@"format" orDefault:nil];
        _format = getSACreativeFormatFromString(format);
        
        _payload = [jsonDictionary safeStringForKey:@"customPayload" orDefault:_payload];
        _live = [jsonDictionary safeBoolForKey:@"live" orDefault:_live];
        _approved = [jsonDictionary safeBoolForKey:@"approved" orDefault:_approved];
        
        _clickUrl = [jsonDictionary safeStringForKey:@"click_url" orDefault:_clickUrl];
        _clickCounterUrl = [jsonDictionary safeStringForKey:@"clickCounterUrl" orDefault:_clickCounterUrl];
        _impressionUrl = [jsonDictionary safeStringForKey:@"impression_url" orDefault:_impressionUrl];
        _installUrl = [jsonDictionary safeStringForKey:@"installUrl" orDefault:_installUrl];
        
        _bundle = [jsonDictionary safeStringForKey:@"bundleId" orDefault:_bundle];
        
        NSDictionary *detailsDict = [jsonDictionary safeDictionaryForKey:@"details" orDefault:nil];
        if (detailsDict) {
            _details = [[SADetails alloc] initWithJsonDictionary:detailsDict];
        }
        
        switch (_format) {
            case SA_Image:{
                if (_details.image != nil) {
                    NSURL *url = [NSURL URLWithString:_details.image];
                    _details.base = [NSString stringWithFormat:@"%@://%@", [url scheme], [url host]];
                }
                break;
            }
            case SA_Video: {
                if (_details.video != nil) {
                    NSURL *url = [NSURL URLWithString:_details.video];
                    _details.base = [NSString stringWithFormat:@"%@://%@", [url scheme], [url host]];
                }
                break;
            }
            case SA_Tag:{
                _details.base = @"https://ads.superawesome.tv";
                break;
            }
            case SA_Rich:{
                if (_details.url != nil) {
                    NSURL *url = [NSURL URLWithString:_details.url];
                    _details.base = [NSString stringWithFormat:@"%@://%@", [url scheme], [url host]];
                }
                break;
            }
            case SA_Appwall:
            case SA_Invalid: {
                // do nothing
                break;
            }
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
             @"id": @(__id),
             @"name": nullSafe(_name),
             @"cpm": @(_cpm),
             @"format": getStringFromSACreativeFormat(_format),
             @"customPayload": nullSafe(_payload),
             @"live": @(_live),
             @"approved": @(_approved),
             @"click_url": nullSafe(_clickUrl),
             @"clickCounterUrl": nullSafe(_clickCounterUrl),
             @"impression_url": nullSafe(_impressionUrl),
             @"installUrl": nullSafe(_installUrl),
             @"bundleId": nullSafe(_bundle),
             @"details": nullSafe([_details dictionaryRepresentation])
             };
}

/**
 * Method that initializes all the values for the model
 */
- (void) initDefaults {
    
    // setup defaults
    __id = 0;
    _name = nil;
    _cpm = 0;
    _format = SA_Invalid;
    _live = true;
    _approved = true;
    _payload = nil;
    _clickUrl = nil;
    _clickCounterUrl = nil;
    _installUrl = nil;
    _impressionUrl = nil;
    _bundle = nil;
    
    // details & events
    _details = [[SADetails alloc] init];
}

@end
