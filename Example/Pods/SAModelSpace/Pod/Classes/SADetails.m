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

#import "SAData.h"

@implementation SADetails

- (id) init {
    if (self = [super init]) {
        
    }
    return self;
}

- (id) initWithJsonDictionary:(NSDictionary *)jsonDictionary {
    if (self = [super initWithJsonDictionary:jsonDictionary]) {
        
        _width = [[jsonDictionary safeObjectForKey:@"width"] integerValue];
        _height = [[jsonDictionary safeObjectForKey:@"height"] integerValue];
        _image = [jsonDictionary safeObjectForKey:@"image"];
        _value = [[jsonDictionary safeObjectForKey:@"value"] integerValue];
        _name = [jsonDictionary safeObjectForKey:@"name"];
        _video = [jsonDictionary safeObjectForKey:@"video"];
        _bitrate = [[jsonDictionary safeObjectForKey:@"bitrate"] integerValue];
        _duration = [[jsonDictionary safeObjectForKey:@"duration"] integerValue];
        _vast = [jsonDictionary safeObjectForKey:@"vast"];
        _tag = [jsonDictionary safeObjectForKey:@"tag"];
        _zipFile = [jsonDictionary safeObjectForKey:@"zipFile"];
        _url = [jsonDictionary safeObjectForKey:@"url"];
        _placementFormat = [jsonDictionary safeObjectForKey:@"placement_format"];
        _cdnUrl = [jsonDictionary safeObjectForKey:@"cdnUrl"];
        _data = [[SAData alloc] initWithJsonDictionary:[jsonDictionary safeObjectForKey:@"data"]];
    }
    return self;
}

- (NSDictionary*) dictionaryRepresentation {
    return @{
        @"width": @(_width),
        @"height": @(_height),
        @"image": nullSafe(_image),
        @"value": @(_value),
        @"name": nullSafe(_name),
        @"video": nullSafe(_video),
        @"bitrate": @(_bitrate),
        @"duration": @(_duration),
        @"vast": nullSafe(_vast),
        @"tag": nullSafe(_tag),
        @"zipFile": nullSafe(_zipFile),
        @"url": nullSafe(_url),
        @"placement_format": nullSafe(_placementFormat),
        @"cdnUrl": nullSafe(_cdnUrl),
        @"data": nullSafe([_data dictionaryRepresentation])
    };
}

@end
