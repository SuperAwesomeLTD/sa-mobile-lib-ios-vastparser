//
//  SADetails.m
//  Pods
//
//  Copyright (c) 2015 SuperAwesome Ltd. All rights reserved.
//
//  Created by Gabriel Coman on 28/09/2015.
//
//

#import "SADetails.h"

@implementation SADetails

- (id) init {
    if (self = [super init]) {
        _media = [[SAMedia alloc] init];
    }
    return self;
}

- (id) initWithJsonDictionary:(NSDictionary *)jsonDictionary {
    if (self = [super initWithJsonDictionary:jsonDictionary]) {
        
        _width = [[jsonDictionary safeObjectForKey:@"width"] integerValue];
        _height = [[jsonDictionary safeObjectForKey:@"height"] integerValue];
        _name = [jsonDictionary safeObjectForKey:@"name"];
        _placementFormat = [jsonDictionary safeObjectForKey:@"placement_format"];
        _bitrate = [[jsonDictionary safeObjectForKey:@"bitrate"] integerValue];
        _duration = [[jsonDictionary safeObjectForKey:@"duration"] integerValue];
        _value = [[jsonDictionary safeObjectForKey:@"value"] integerValue];
        _image = [jsonDictionary safeObjectForKey:@"image"];
        _video = [jsonDictionary safeObjectForKey:@"video"];
        _vast = [jsonDictionary safeObjectForKey:@"vast"];
        _tag = [jsonDictionary safeObjectForKey:@"tag"];
        _zipFile = [jsonDictionary safeObjectForKey:@"zipFile"];
        _url = [jsonDictionary safeObjectForKey:@"url"];
        _cdnUrl = [jsonDictionary safeObjectForKey:@"cdnUrl"];
        _media = [[SAMedia alloc] initWithJsonDictionary:[jsonDictionary safeObjectForKey:@"media"]];
    }
    return self;
}

- (NSDictionary*) dictionaryRepresentation {
    return @{
             @"width": @(_width),
             @"height": @(_height),
             @"name": nullSafe(_name),
             @"placement_format": nullSafe(_placementFormat),
             @"bitrate": @(_bitrate),
             @"duration": @(_duration),
             @"value": @(_value),
             @"image": nullSafe(_image),
             @"video": nullSafe(_video),
             @"vast": nullSafe(_vast),
             @"tag": nullSafe(_tag),
             @"zipFile": nullSafe(_zipFile),
             @"url": nullSafe(_url),
             @"cdnUrl": nullSafe(_cdnUrl),
             @"media": nullSafe([_media dictionaryRepresentation])
             };
}

@end
