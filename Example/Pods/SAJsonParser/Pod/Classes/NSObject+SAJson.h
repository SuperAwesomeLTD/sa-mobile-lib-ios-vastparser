//
//  NSObject+SASerialization.h
//  Pods
//
//  Created by Gabriel Coman on 27/05/2016.
//
//

// import foundation
#import <Foundation/Foundation.h>

// import main protocols
#import "SADeserializationProtocol.h"
#import "SASerializationProtocol.h"

/**
 *  This is an extension to NSObject in order to implement
 *  the SADeserialization and SASerialization protocols
 */
@interface NSObject (SAJson) <SADeserializationProtocol, SASerializationProtocol>
@end
