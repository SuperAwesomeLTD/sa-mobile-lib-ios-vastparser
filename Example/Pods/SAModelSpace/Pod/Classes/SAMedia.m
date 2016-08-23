//
//  SAMedia.m
//  Pods
//
//  Created by Gabriel Coman on 22/08/2016.
//
//

#import "SAMedia.h"

@implementation SAMedia

- (id) init {
    if (self = [super init]) {
        
    }
    return self;
}

- (id) initWithJsonDictionary:(NSDictionary *)jsonDictionary {
    if (self = [super initWithJsonDictionary:jsonDictionary]) {
        _html = [jsonDictionary safeObjectForKey:@"html"];
        _playableDiskUrl = [jsonDictionary safeObjectForKey:@"playableDiskUrl"];
        _playableMediaUrl = [jsonDictionary safeObjectForKey:@"playableMediaUrl"];
        _type = [jsonDictionary safeObjectForKey:@"type"];
        _isOnDisk = [[jsonDictionary safeObjectForKey:@"isOnDisk"] boolValue];
    }
    return self;
}

- (NSDictionary*) dictionaryRepresentation {
    return @{
             @"html": nullSafe(_html),
             @"playableDiskUrl": nullSafe(_playableDiskUrl),
             @"playableMediaUrl": nullSafe(_playableMediaUrl),
             @"type": nullSafe(_type),
             @"isOnDisk": @(_isOnDisk)
             };
}

@end
