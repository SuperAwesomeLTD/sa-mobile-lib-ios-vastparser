//
//  NSObject+SASerialization.h
//  Pods
//
//  Created by Gabriel Coman on 27/05/2016.
//
//

#import <Foundation/Foundation.h>
#import "SADeserializationProtocol.h"
#import "SASerializationProtocol.h"

/**
 *  This class is used to provide an extension to NSObject in order to implement
 *  the SADeserialization and SASerialization protocols
 */
@interface NSObject (SAJson) <SADeserializationProtocol, SASerializationProtocol>
@end
