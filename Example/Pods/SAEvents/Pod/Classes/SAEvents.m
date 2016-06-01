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
 
+ (void) sendDisplayMoatEvent:(UIView*)adView andAdDictionary:(NSDictionary*)adDict {
    // do nothing
}

+ (void) sendVideoMoatEvent:(AVPlayer *)player andLayer:(AVPlayerLayer *)layer andView:(UIView *)adView andAdDictionary:(NSDictionary *)adDict {
    // do nothing
}

// functions to enable or disable tracking
+ (void) enableSATracking {
    isSATrackingEnabled = true;
}

+ (void) disableSATracking {
    isSATrackingEnabled = false;
}

@end
