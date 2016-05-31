//
//  NSDictionary+SAJsonExtension.m
//  Pods
//
//  Created by Gabriel Coman on 27/05/2016.
//
//

#import "NSDictionary+SAJson.h"

@implementation NSDictionary (SAJson)

+ (NSDictionary*) dictionaryWithJsonData:(NSData*)jsonData {
    
    if (jsonData == NULL) return NULL;
    NSError *error = NULL;
    NSDictionary *jsonDict = NULL;
    return [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
}

+ (NSDictionary*) dictionaryWithJsonString:(NSString*)jsonString {
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    return [NSDictionary dictionaryWithJsonData:jsonData];
}

@end
