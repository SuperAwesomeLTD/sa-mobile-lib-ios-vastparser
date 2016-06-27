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
        _width = [jsonDictionary safeObjectForKey:@"width"];
        _height = [jsonDictionary safeObjectForKey:@"height"];
        _type = [jsonDictionary safeObjectForKey:@"type"];
        _URL = [jsonDictionary safeObjectForKey:@"URL"];
        _diskURL = [jsonDictionary safeObjectForKey:@"diskURL"];
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