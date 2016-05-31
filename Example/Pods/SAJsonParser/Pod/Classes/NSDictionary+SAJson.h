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

/**
 *  Function to safely get data from a dictionary
 *
 *  @param aKey key
 *
 *  @return result
 */
- (id) safeObjectForKey:(id)aKey;
- (BOOL) safeBoolForKey:(id)aKey;
- (NSInteger) safeIntForKey:(id)aKey;
- (CGFloat) safeFloatForKey:(id)aKey;
- (double) safeDoubleForKey:(id)aKey;
- (NSString*) safeStringForKey:(NSString*)aKey;

@end
