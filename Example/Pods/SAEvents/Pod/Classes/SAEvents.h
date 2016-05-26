//
//  SAEvents.h
//  Pods
//
//  Created by Gabriel Coman on 26/02/2016.
//
//

#import <Foundation/Foundation.h>

//
// SAEvents is a class that contains a multitude of functions used to send
// messages to the server in case some event gets triggered regarding an Ad
// such as viewable impression, ad rating, etc
@interface SAEvents : NSObject

//
// This is just a "dumb" function that sends a GET request to the
// specified URL; it's a thing wrapper for SANetwork.sendGetToEndpoint() so that
// it's fire-and-forget
// @param: the URL to make the event request to
+ (void) sendEventToURL:(NSString*)url;

// functions to enable or disable tracking
+ (void) enableSATracking;
+ (void) disableSATracking;

@end
