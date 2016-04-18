//
//  SAMediaFile.m
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

#import "SAMediaFile.h"

@implementation SAMediaFile

- (void) print {
    NSLog(@"\t\tMediaFile [%@x%@] %@ => %@", _width, _height, _URL, _diskURL);
}

@end