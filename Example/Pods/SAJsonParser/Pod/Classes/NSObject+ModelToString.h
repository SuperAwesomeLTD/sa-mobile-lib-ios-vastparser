//
//  NSObject+DictionaryRepresentation.h
//  Pods
//
//  Created by Gabriel Coman on 21/04/2016.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (ModelToString)

/**
 *  This function parses an object model and transforms it into a NSDictionary
 *
 *  @return return a dictionary of key-value elements based on the NSObjects
 *          properties
 */
- (id) dictionaryRepresentation;

/**
 *  This function returns a Json string formed from the properties of an object
 *
 *  @return a preety formatted json string
 */
- (NSString*) jsonStringPreetyRepresentation;

/**
 *  This function returns a Json string formed from the properties of an object
 *
 *  @return a compact formatted json string
 */
- (NSString*) jsonStringCompactRepresentation;

/**
 *  This function returns a Json data object formed from the properties of an object
 *
 *  @return a Json nsdata object
 */
- (NSData*) jsonDataRepresentation;

@end
