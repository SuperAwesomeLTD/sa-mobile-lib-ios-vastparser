//
//  SAEvents.m
//  Pods
//
//  Created by Gabriel Coman on 26/02/2016.
//
//

#import "SAEvents.h"
#import "SAUtils.h"
#import "SANetwork.h"

@implementation SAEvents

static bool isSATrackingEnabled = true;

+ (void) sendEventToURL:(NSString *)url {
    if (!isSATrackingEnabled) return;
    
    SANetwork *network = [[SANetwork alloc] init];
    [network sendGET:url
           withQuery:@{}
           andHeader:@{@"Content-Type":@"application/json",
                       @"User-Agent":[SAUtils getUserAgent]
                       }
          andSuccess:^(NSInteger status, NSString *payload) {
        // success
    } andFailure:^{
        // failure
    }];
}

+ (void) sendCustomEvent:(NSString*) baseUrl
           withPlacement:(NSInteger) placementId
            withLineItem:(NSInteger) lineItem
             andCreative:(NSInteger) creative
                andEvent:(NSString*) event
{
    
    if (!isSATrackingEnabled) return;
    
    NSDictionary *data = @{
        @"placement": @(placementId),
        @"creative": @(creative),
        @"line_item": @(lineItem),
        @"event": event
    };
    NSDictionary *cjson = @{
        @"rnd": @([SAUtils getCachebuster]),
        @"ct": @([SAUtils getNetworkConnectivity]),
        @"data": [SAUtils encodeJSONDictionaryFromNSDictionary:data]
    };
    
    NSString *url = [NSString stringWithFormat:@"%@/event?%@", baseUrl, [SAUtils formGetQueryFromDict:cjson]];
    [self sendEventToURL:url];
}
 
+ (NSString*) sendDisplayMoatEvent:(UIWebView*)webView andAdDictionary:(NSDictionary*)adDict {
    return @"";
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
