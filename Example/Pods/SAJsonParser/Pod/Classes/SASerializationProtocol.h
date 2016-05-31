//
//  NSObject+SASerialization.h
//  Pods
//
//  Created by Gabriel Coman on 27/05/2016.
//
//

#import <Foundation/Foundation.h>

/**
 *  This function makes sure the data you enter in a dictionary object is not
 *  ever going to be NULL or nil; If it's not initialized, a NSNull instance
 *  will be delivered
 *
 *  @param object the object in question
 *
 *  @return either the object or NSNull
 */
static id _Nullable nullSafe(id object) {
    return object ?: [NSNull null];
}

/**
 This protocol describes the functions that must be implemented by a class in
 order to serialize correctly using the SA method
 */
@protocol SASerializationProtocol <NSObject>

@required

/**
 *  This function provides the dictionary representation of a model object;
 *  Does not have a default implementation and is the only function that **must**
 *  be implemented by a user
 *
 *  @return a dictionary
 */
- (NSDictionary* _Nullable) dictionaryRepresentation;

@optional

/**
 *  This function provides the json preety string representation of a model 
 *  object; It has a default implementation
 *
 *  @return a JSON string
 */
- (NSString* _Nullable) jsonPreetyStringRepresentation;

/**
 *  This function provides the json compact string representation of a model
 *  object; It has a default implementation
 *
 *  @return a JSON string
 */
- (NSString* _Nullable) jsonCompactStringRepresentation;

/**
 *  This funciton provides the json NSData representation of a model object;
 *  It has a default implementation
 *
 *  @return a NSData object
 */
- (NSData* _Nullable) jsonDataRepresentation;

@end
