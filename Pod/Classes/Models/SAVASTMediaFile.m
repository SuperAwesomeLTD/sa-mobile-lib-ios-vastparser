//
//  SAMediaFile.m
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

#import "SAVASTMediaFile.h"

@implementation SAVASTMediaFile

- (id) init{
    if (self = [super init]) {
        
    }
    return self;
}

- (id) initWithJsonDictionary:(NSDictionary *)jsonDictionary {
    if (self = [super initWithJsonDictionary:jsonDictionary]) {
        _width = [jsonDictionary objectForKey:@"width"];
        _height = [jsonDictionary objectForKey:@"height"];
        _type = [jsonDictionary objectForKey:@"type"];
        _URL = [jsonDictionary objectForKey:@"URL"];
        _diskURL = [jsonDictionary objectForKey:@"diskURL"];
    }
    return self;
}

- (NSDictionary*) dictionaryRepresentation {
    return @{
        @"width": nullSafe(_width),
        @"height": nullSafe(_height),
        @"type": nullSafe(_type),
        @"URL": nullSafe(_URL),
        @"diskURL": nullSafe(_diskURL)
    };
}

@end