//
//  NSObject+DictionaryRepresentation.m
//  Pods
//
//  Created by Gabriel Coman on 21/04/2016.
//
//

#import "NSObject+ModelToString.h"
#import "NSObject+Types.h"
#include <objc/message.h>

@implementation NSObject (ModelToString)

- (id) dictionaryRepresentation {
    @autoreleasepool {
        
        //
        // this is the case where the NSObject value is either null or
        // a number or string - in this case, just return the number
        if ([self isNullType]) return self;
        if ([self isValueType]) return self;
        if ([self isNumberType]) return self;
        if ([self isStringType]) return self;
        
        // if the object is an array
        // basically form a new array with dictionarised values
        if ([self isArrayType]) {
            
            NSArray *arraySelf = (NSArray*)self;
            NSMutableArray *array = [@[] mutableCopy];
            
            for (id object in arraySelf) {
                if ([object isObjectType]) {
                    [array addObject:[object dictionaryRepresentation]];
                } else {
                    [array addObject:object];
                }
            }
            
            return array;
        }
        // if the object is a dictionary
        // form a new dictionary with dictionarised values
        else if ([self isDictionaryType]) {
            
            NSDictionary *dictionarySelf = (NSDictionary*)self;
            NSMutableArray *dictionary = [@{} mutableCopy];
            
            for (id key in [dictionarySelf allKeys]) {
                id object = [dictionarySelf objectForKey:key];
                if ([object isObjectType]){
                    [dictionary setValue:[object dictionaryRepresentation] forKey:key];
                } else {
                    [dictionary setValue:object forKey:key];
                }
            }
            
            return dictionary;
        }
        // if the object is a set type, form an array with dictionarised values
        else if ([self isSetType]){
            
            NSSet *setSelf = (NSSet*)self;
            NSMutableArray *array = [@[] mutableCopy];
            
            for (id object in setSelf) {
                if ([object isObjectType]){
                    [array addObject:[object dictionaryRepresentation]];
                } else {
                    [array addObject:object];
                }
            }
            
            return array;
        }
        // for custom model objects, etc, do a more complex algorithm
        else {
            
            // form the return dictionary
            NSMutableDictionary *returnDictionary = [@{} mutableCopy];
            
            // get the properties of the current object
            unsigned int count = 0;
            objc_property_t *properties = class_copyPropertyList([self class], &count);
            NSString *key;
            NSObject *value;
            
            // cycle through properties and determine if the current dictionary should
            // be populated by either normal base values (int, float, NSString)
            // or sub-dictionaries
            for (int i = 0; i < count; i++) {
                
                // get current key & value
                key = [NSString stringWithUTF8String:property_getName(properties[i])];
                if ([self valueForKeyPath:key]) {
                    value = [self valueForKey:key];
                } else {
                    value = [NSNull null];
                }
                
                if ([value isObjectType]) {
                    [returnDictionary setObject:[value dictionaryRepresentation] forKey:key];
                } else {
                    [returnDictionary setObject:value forKey:key];
                }
            }
            
            // fre-up memory, C-style
            free(properties);
            properties = nil;
            
            // return final dictionary
            return returnDictionary;
        }
    }
}

- (NSString*) jsonStringRepresentation:(NSJSONWritingOptions)options {
    // data needed for the representation
    NSString *stringJson = NULL;
    NSData *dataJson = NULL;
    NSError *error = NULL;
    
    // get the dictionary
    NSDictionary *dictionaryRepresentation = [self dictionaryRepresentation];
    
    // serialize it
    if ([NSJSONSerialization isValidJSONObject:dictionaryRepresentation]) {
        
        dataJson = [NSJSONSerialization dataWithJSONObject:dictionaryRepresentation
                                                       options:options
                                                         error:&error];
        
        // and form the string
        if (dataJson != nil && error == nil) {
            stringJson = [[NSString alloc] initWithData:dataJson
                                               encoding:NSUTF8StringEncoding];
        }
    }
    
    return stringJson;
}

- (NSString*) jsonStringPreetyRepresentation {
    return [self jsonStringRepresentation:NSJSONWritingPrettyPrinted];
}

- (NSString*) jsonStringCompactRepresentation {
    return [self jsonStringRepresentation:kNilOptions];
}

- (NSData*) jsonDataRepresentation {
    return [[self jsonStringCompactRepresentation] dataUsingEncoding:NSUTF8StringEncoding];
}

@end
