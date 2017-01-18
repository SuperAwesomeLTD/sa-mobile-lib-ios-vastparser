/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAVASTAd.h"
#import "SATracking.h"
#import "SAVASTMedia.h"

@implementation SAVASTAd

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
        
        // get simple strings
        _vastRedirect = [jsonDictionary safeStringForKey:@"vastRedirect" orDefault:_vastRedirect];
        _mediaUrl = [jsonDictionary safeStringForKey:@"mediaUrl" orDefault:_mediaUrl];
        
        // read the vast type
        NSInteger type = [jsonDictionary safeIntForKey:@"vastType" orDefault:0];
        _vastType = getSAVASTAdTypeFromInt(type);
        
        // get array of media
        NSArray *media = [jsonDictionary safeArrayForKey:@"mediaList" orDefault:@[]];
        _mediaList = [[[NSArray alloc] initWithJsonArray:media andIterator:^id(id item) {
            return [[SAVASTMedia alloc] initWithJsonDictionary:(NSDictionary*)item];
        }] mutableCopy];
        
        // get array of events
        NSArray *events = [jsonDictionary safeArrayForKey:@"vastEvents" orDefault:@[]];
        _vastEvents = [[[NSArray alloc] initWithJsonArray:events andIterator:^id(id item) {
            return [[SATracking alloc] initWithJsonDictionary:(NSDictionary*)item];
        }] mutableCopy];
    }
    
    return self;
}

/**
 * Overridden "isValid" method from the SADeserializationProtocol protocol
 *
 * @return true or false
 */
- (BOOL) isValid {
    return _mediaUrl != nil && _vastType != SA_Invalid_VAST && [_mediaList count] >= 1;
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
             @"vastRedirect": nullSafe(_vastRedirect),
             @"mediaUrl": nullSafe(_mediaUrl),
             @"vastType": @(_vastType),
             @"mediaList": nullSafe([_mediaList dictionaryRepresentation]),
             @"vastEvents": nullSafe([_vastEvents dictionaryRepresentation])
             };
}

/**
 * Method that initializes all the values for the model
 */
- (void) initDefaults {
    _vastRedirect = nil;
    _vastType = SA_Invalid_VAST;
    _mediaUrl = nil;
    _mediaList = [@[] mutableCopy];
    _vastEvents = [@[] mutableCopy];
}

- (void) sumAd:(SAVASTAd *)toBeAdded {
    _mediaUrl = toBeAdded.mediaUrl ? toBeAdded.mediaUrl : _mediaUrl;
    [_vastEvents addObjectsFromArray:toBeAdded.vastEvents];
    [_mediaList addObjectsFromArray:toBeAdded.mediaList];
}

@end
