//
//  NSObject+BaseType.h
//  Pods
//
//  Created by Gabriel Coman on 21/04/2016.
//
//

#import <Foundation/Foundation.h>

@interface NSObject (Types)

/**
 *  Function that returns whether a value is of any of the "base objc types"
 *
 *  @return either true or false
 */
- (BOOL) isBaseType;

/**
 *  Returns true if type is descendant from nsobject
 *
 *  @return true or false
 */
- (BOOL) isObjectType;

/**
 *  Returns true if type is number type
 *
 *  @return either true or false
 */
- (BOOL) isNumberType;

/**
 *  Returns true if type is value type
 *
 *  @return either true or false
 */
- (BOOL) isValueType;

/**
 *  Returns true if type is string type
 *
 *  @return either true or false
 */
- (BOOL) isStringType;

/**
 *  Returns true if type is array
 *
 *  @return either true or false
 */
- (BOOL) isArrayType;

/**
 *  Returns true if type is dictionary
 *
 *  @return either true or false
 */
- (BOOL) isDictionaryType;

/**
 *  Returns true if type is set
 *
 *  @return either true or false
 */
- (BOOL) isSetType;

/**
 *  Returns true if type is null class
 *
 *  @return either true or false
 */
- (BOOL) isNullType;

@end
