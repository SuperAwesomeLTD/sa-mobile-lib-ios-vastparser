//
//  NSObject+StringToModel.m
//  Pods
//
//  Created by Gabriel Coman on 22/04/2016.
//
//

#import "NSObject+StringToModel.h"
#import "NSObject+Types.h"
#import "NSString+JsonAux.h"
#include <objc/message.h>

/**
 *  Internal class that holds an object property (name, type, etc)
 */
@interface SAObjectProperty : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@end

@implementation SAObjectProperty
@end

/**
 * Category implementation
 */
@implementation NSObject (StringToModel)

/**
 *******************************************************************************
 *  Constructors
 *******************************************************************************
 */

- (id) initModelFromJsonDictionary:(NSDictionary*)jsonDictionary andOptions:(SAJsonParsingOptions)options {
    if (self = [self init]){
        [self setModelPropertiesFromDict:jsonDictionary andOptions:[NSNumber numberWithInteger:options]];
    }
    return self;
}

- (id) initModelFromJsonData:(NSData*)jsonData andOptions:(SAJsonParsingOptions)options {
    if (jsonData == NULL) return self;
    
    NSError *error = NULL;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    if (jsonDict == NULL || error) return self;
    
    if (self = [self initModelFromJsonDictionary:jsonDict andOptions:options]){
        // all good
    }
    
    return self;
}

- (id) initModelFromJsonString:(NSString*)jsonString andOptions:(SAJsonParsingOptions)options {
    if (jsonString == NULL) return self;
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = NULL;
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&error];
    
    if (jsonDict == NULL || error) return self;
    
    if (self = [self initModelFromJsonDictionary:jsonDict andOptions:options]){
        // all good
    }
    
    return self;
}


/**
 *******************************************************************************
 *  Internal functions
 *******************************************************************************
 */

/**
 *  Main library function that takes a dictionary and assign it values from
 *  a dictionary based on the model property names and dictionary key names
 *
 *  @param dict a dictionary
 */
- (void) setModelPropertiesFromDict:(NSDictionary *)dictionary andOptions:(NSNumber*)options {
    @autoreleasepool {
        
        // get all attributes
        unsigned int count = 0;
        objc_property_t *cproperties = class_copyPropertyList([self class], &count);
        
        NSMutableArray *properties = [@[] mutableCopy];
        
        NSLog(@"Class %@", [self class]);
        
        // get properties
        for (int i = 0; i < count; i++) {
            // get property & associated attributes
            objc_property_t property = cproperties[i];
            NSString *attributes = [NSString stringWithUTF8String:property_getAttributes(property)];
            
            // represent the property in SA internal style
            // by getting the name and actual type of a property that's going to
            // be represented
            SAObjectProperty *objProperty = [[SAObjectProperty alloc] init];
            objProperty.name = [NSString stringWithUTF8String:property_getName(property)];
            objProperty.type = [[attributes componentsSeparatedByString:@","] firstObject];
            objProperty.type = [objProperty.type stringByReplacingOccurrencesOfString:@"@" withString:@""];
            objProperty.type = [objProperty.type stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            objProperty.type = [objProperty.type substringFromIndex:1];
            
            // add property
            [properties addObject:objProperty];
        }
        
        // get the dictionary of corresponding properties
        NSDictionary *corresponding = [self getCorrespondingProperties:properties fromDictionary:dictionary withOptions:(SAJsonParsingOptions)[options integerValue]];
        
        // do the magick!
        for (SAObjectProperty *prop in properties) {
            NSString *propName = prop.name;
            NSString *propType = prop.type;
            NSString *dictKey = ([corresponding objectForKey:prop.name] ? [corresponding objectForKey:propName] : propName);
            id valueFromDict = [dictionary objectForKey:dictKey];
            
            // check that the value was encountered in the dictionary!
            // if not, warn the user so that he knows
            if (valueFromDict == NULL || [valueFromDict isNullType]) {
                NSLog(@"\t[WARNING] Did not encounter member \"%@\" in source dictionary", propName);
            }
            else {
                
                // get class name
                Class className = NSClassFromString(propType);
                
                // case value is not an object, but a value (bool, int, NSInteger, etc)
                if (className == NULL){
                    [self setValue:valueFromDict forKey:propName];
                    NSLog(@"\t[OK-Val] Got dictonary key \"%@\" for model property \"%@\"", dictKey, propName);
                }
                // case value is actually an object
                else {
                    NSLog(@"\t[OK-Obj] Got dictonary key \"%@\" for model property \"%@\"", dictKey, propName);
    
                    // init the corresponding value
                    id correspondingValue = [[NSClassFromString(propType) alloc] init];
                    
                    // in case the object isn't an array
                    if (![correspondingValue isArrayType]) {
                        
                        if ([correspondingValue respondsToSelector:@selector(setModelPropertiesFromDict:andOptions:)] && ![correspondingValue isBaseType]){
                            [correspondingValue performSelector:@selector(setModelPropertiesFromDict:andOptions:) withObject:valueFromDict withObject:options];
                            [self setValue:correspondingValue forKey:propName];
                        } else {
                            [self setValue:valueFromDict forKey:propName];
                        }
                    }
                    // in case object is an array
                    else {
                        [self setValue:[valueFromDict mutableCopy] forKey:propName];
                    }
                }
            }
        }
        
        // free all data
        free(cproperties);
        cproperties = nil;
    }
}

/**
 *  Function that takes a buch of model properties and finds the fields that
 *  most likely match in a dictionary
 *
 *  @param properties an array of SAObjectProperty objects
 *  @param dictionary the corresponding dictionary with data
 *
 *  @return A dictionary containing [model_property : dict_key] pairs
 */
- (NSDictionary*) getCorrespondingProperties:(NSMutableArray*)properties fromDictionary:(NSDictionary*)dictionary withOptions:(SAJsonParsingOptions)options {
    
    // the result
    NSMutableDictionary *result = [@{} mutableCopy];
    
    // do the matching
    for (SAObjectProperty *prop in properties) {
        NSString *normalProperty = prop.name;
        NSString *cleanProperty = [prop.name cleanFirstUnderscore];
        
        // init found as false, always
        BOOL found = false;
        
        for (NSString *dictKey in [dictionary allKeys]) {
            NSString *normalKey = dictKey;
            NSString *joinedKey = [dictKey joinStringWithUnderscores];
            
            // do some comparisons
            if ([normalProperty isEqualToString:normalKey] || [cleanProperty isEqualToString:normalKey]) {
                found = true;
            }
            
            if (options == CapitalizeKeysThatHaveUnderscores &&
                ([normalProperty isEqualToString:joinedKey] || [cleanProperty isEqualToString:joinedKey])){
                found = true;
            }
            
            // assign
            if (found) {
                [result setValue:normalKey forKey:normalProperty];
                break;
            }
        }
    }
    
    // return result
    return result;
}

@end
