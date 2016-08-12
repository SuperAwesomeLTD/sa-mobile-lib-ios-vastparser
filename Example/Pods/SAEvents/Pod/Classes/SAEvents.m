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

+ (void) sendEventToURL:(NSString *)url {
    SANetwork *network = [[SANetwork alloc] init];
    [network sendGET:url
           withQuery:@{}
           andHeader:@{@"Content-Type":@"application/json",
                       @"User-Agent":[SAUtils getUserAgent]}
        withResponse:^(NSInteger status, NSString *payload, BOOL success) {
            if (success) {
                NSLog(@"Event sent OK!");
            } else {
                NSLog(@"Event sent NOK!");
            }
        }];
}

+ (void) sendCustomEvent:(NSString*) baseUrl
           withPlacement:(NSInteger) placementId
            withLineItem:(NSInteger) lineItem
             andCreative:(NSInteger) creative
                andEvent:(NSString*) event
{
    
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

@end
