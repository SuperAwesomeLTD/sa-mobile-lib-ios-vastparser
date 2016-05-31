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
    if (self = [super init]) {
        _width = [jsonDictionary safeStringForKey:@"width"];
        _height = [jsonDictionary safeStringForKey:@"height"];
        _type = [jsonDictionary safeStringForKey:@"type"];
        _URL = [jsonDictionary safeStringForKey:@"URL"];
        _diskURL = [jsonDictionary safeStringForKey:@"diskURL"];
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