//
//  NSObject+StringToModel.h
//  Pods
//
//  Created by Gabriel Coman on 22/04/2016.
//
//

#import <Foundation/Foundation.h>

/**
 Two options in parsing
 */
typedef enum SAJsonParsingOptions {
    Strict,
    CapitalizeKeysThatHaveUnderscores
}SAJsonParsingOptions;

@interface NSObject (StringToModel)

/**
 *  Special init function that initializes a model object starting from json data / string / dictionary
 *
 *  @param a valid json data / string / dictionary object
 *
 *  @return a new instance of the object
 */
- (id) initModelFromJsonDictionary:(NSDictionary*)jsonDictionary andOptions:(SAJsonParsingOptions)options;
- (id) initModelFromJsonData:(NSData*)jsonData andOptions:(SAJsonParsingOptions)options;
- (id) initModelFromJsonString:(NSString*)jsonString andOptions:(SAJsonParsingOptions)options;

@end
