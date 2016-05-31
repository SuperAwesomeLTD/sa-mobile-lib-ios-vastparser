//
//  NSDictionary+SAJsonExtension.h
//  Pods
//
//  Created by Gabriel Coman on 27/05/2016.
//
//

#import <Foundation/Foundation.h>
#import <Foundation/NSEnumerator.h>

#import "SADeserializationProtocol.h"
#import "SASerializationProtocol.h"

@interface NSDictionary (SAJson) <SASerializationProtocol, SADeserializationProtocol>

- (id) safeObjectForKey:(id)aKey;

@end
