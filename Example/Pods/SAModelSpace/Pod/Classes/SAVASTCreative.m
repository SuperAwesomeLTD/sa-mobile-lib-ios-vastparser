//
//  SAVASTCreative.m
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

// import header
#import "SAVASTCreative.h"

@implementation SAVASTCreative

- (id) init {
    if (self = [super init]) {
        
    }
    return self;
}

- (id) initWithJsonDictionary:(NSDictionary *)jsonDictionary {
    if (self = [super initWithJsonDictionary:jsonDictionary]) {
        
        _type = (SAVASTCreativeType)[[jsonDictionary safeObjectForKey:@"type"] integerValue];
        __id = [jsonDictionary safeObjectForKey:@"id"];
        _sequence = [jsonDictionary safeObjectForKey:@"sequence"];
        _Duration = [jsonDictionary safeObjectForKey:@"Duration"];
        _ClickThrough = [jsonDictionary safeObjectForKey:@"ClickThrough"];
        _playableMediaURL = [jsonDictionary safeObjectForKey:@"playableMediaURL"];
        _playableDiskURL = [jsonDictionary safeObjectForKey:@"playableDiskURL"];
        _isOnDisk = [[jsonDictionary safeObjectForKey:@"isOnDisk"] boolValue];
        _MediaFiles = [[[NSArray alloc] initWithJsonArray:[jsonDictionary safeObjectForKey:@"MediaFiles"] andIterator:^id(id item) {
            return [[SAVASTMediaFile alloc] initWithJsonDictionary:(NSDictionary*)item];
        }] mutableCopy];
        _TrackingEvents = [[[NSArray alloc] initWithJsonArray:[jsonDictionary safeObjectForKey:@"TrackingEvents"] andIterator:^id(id item) {
            return [[SAVASTTracking alloc] initWithJsonDictionary:(NSDictionary*)item];
        }] mutableCopy];
        _ClickTracking = [[[NSArray alloc] initWithJsonArray:[jsonDictionary safeObjectForKey:@"ClickTracking"] andIterator:^id(id item) {
            return (NSString*)item;
        }] mutableCopy];
        _CustomClicks = [[[NSArray alloc] initWithJsonArray:[jsonDictionary safeObjectForKey:@"CustomClicks"] andIterator:^id(id item) {
            return (NSString*)item;
        }] mutableCopy];
    }
    return self;
}

- (NSDictionary*) dictionaryRepresentation {
    return @{
        @"type": @(_type),
        @"id": nullSafe(__id),
        @"sequence": nullSafe(_sequence),
        @"Duration": nullSafe(_Duration),
        @"ClickThrough": nullSafe(_ClickThrough),
        @"playableMediaURL": nullSafe(_playableMediaURL),
        @"playableDiskURL": nullSafe(_playableDiskURL),
        @"isOnDisk": @(_isOnDisk),
        @"MediaFiles": [_MediaFiles dictionaryRepresentation],
        @"TrackingEvents": [_TrackingEvents dictionaryRepresentation],
        @"ClickTracking": [_ClickTracking dictionaryRepresentation],
        @"CustomClicks" : [_CustomClicks dictionaryRepresentation]
    };
}

- (void) sumCreative:(SAVASTCreative *)creative {
    // perform a "Sum" operation
    // first override some unimportant variables
    __id = creative._id;
    _sequence = creative.sequence;
    _Duration = creative.Duration;
    
    if (creative.ClickThrough) {
        _ClickThrough = creative.ClickThrough;
    }
    if (creative.playableMediaURL) {
        _playableMediaURL = creative.playableMediaURL;
    }
    if (creative.playableDiskURL) {
        _playableDiskURL = creative.playableDiskURL;
    }
    
    // then concatenate arrays (this is what's important)
    [_MediaFiles addObjectsFromArray:creative.MediaFiles];
    [_TrackingEvents addObjectsFromArray:creative.TrackingEvents];
    [_ClickTracking addObjectsFromArray:creative.ClickTracking];
    [_CustomClicks addObjectsFromArray:creative.CustomClicks];
}

@end