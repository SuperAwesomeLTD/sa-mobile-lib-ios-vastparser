/**
 * @Copyright:   SuperAwesome Trading Limited 2017
 * @Author:      Gabriel Coman (gabriel.coman@superawesome.tv)
 */

#import "SAMedia.h"

@implementation SAMedia

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
        _html = [jsonDictionary safeStringForKey:@"html" orDefault:_html];
        _playableDiskUrl = [jsonDictionary safeStringForKey:@"playableDiskUrl" orDefault:_playableDiskUrl];
        _playableMediaUrl = [jsonDictionary safeStringForKey:@"playableMediaUrl" orDefault:_playableMediaUrl];
        _type = [jsonDictionary safeStringForKey:@"type" orDefault:_type];
        _bitrate = [jsonDictionary safeIntForKey:@"bitrate" orDefault:_bitrate];
        _isOnDisk = [jsonDictionary safeBoolForKey:@"isOnDisk" orDefault:_isOnDisk];
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
             @"html": nullSafe(_html),
             @"playableDiskUrl": nullSafe(_playableDiskUrl),
             @"playableMediaUrl": nullSafe(_playableMediaUrl),
             @"type": nullSafe(_type),
             @"bitrate": @(_bitrate),
             @"isOnDisk": @(_isOnDisk)
             };
}

/**
 * Method that initializes all the values for the model
 */
- (void) initDefaults {
    _html = nil;
    _playableDiskUrl = nil;
    _playableMediaUrl = nil;
    _type = nil;
    _bitrate = 0;
    _isOnDisk = false;
}

@end
