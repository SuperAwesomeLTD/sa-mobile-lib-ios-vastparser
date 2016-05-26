//
//  SAEvents.m
//  Pods
//
//  Created by Gabriel Coman on 26/02/2016.
//
//

#import "SAEvents.h"
#import "SAUtils.h"

@implementation SAEvents

static bool isSATrackingEnabled = true;

+ (void) sendEventToURL:(NSString *)url {
    if (!isSATrackingEnabled) return;
    [SAUtils sendGETtoEndpoint:url withQueryDict:NULL andSuccess:NULL orFailure:NULL];
}

// functions to enable or disable tracking
+ (void) enableSATracking {
    isSATrackingEnabled = true;
}

+ (void) disableSATracking {
    isSATrackingEnabled = false;
}

@end
