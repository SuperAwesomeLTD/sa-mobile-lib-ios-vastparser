//
//  NSDictionary+SAJsonExtension.h
//  Pods
//
//  Created by Gabriel Coman on 27/05/2016.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SAJson)

/**
 *  Factory constructor for a dictionary with a json string
 *
 *  @param jsonString valid json string
 *
 *  @return a new dictionary instance
 */
+ (NSDictionary*) dictionaryWithJsonString:(NSString*)jsonString;

/**
 *  Factory constructor for a dictionary with a json data object
 *
 *  @param jsonData a valid json data object
 *
 *  @return a new dictionary instance
 */
+ (NSDictionary*) dictionaryWithJsonData:(NSData*)jsonData;

@end
