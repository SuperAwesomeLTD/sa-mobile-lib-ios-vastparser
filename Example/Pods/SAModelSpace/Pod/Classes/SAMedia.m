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
        _width = [[jsonDictionary safeObjectForKey:@"width"] integerValue];
        _height = [[jsonDictionary safeObjectForKey:@"height"] integerValue];
        _type = [jsonDictionary safeObjectForKey:@"type"];
        _isOnDisk = [jsonDictionary safeObjectForKey:@"isOnDisk"];
    }
    return self;
}

- (NSDictionary*) dictionaryRepresentation {
    return @{
             @"html": nullSafe(_html),
             @"playableDiskUrl": nullSafe(_playableDiskUrl),
             @"playableMediaUrl": nullSafe(_playableMediaUrl),
             @"width": @(_width),
             @"height": @(_height),
             @"type": nullSafe(_type),
             @"isOnDisk": @(_isOnDisk)
             };
}

@end
