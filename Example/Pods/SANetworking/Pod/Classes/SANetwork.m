//
//  SANetwork.m
//  Pods
//
//  Created by Gabriel Coman on 05/07/2016.
//
//

#import "SANetwork.h"

@implementation SANetwork

- (void) sendRequestTo:(NSString*)endpoint
            withMethod:(NSString*)method
              andQuery:(NSDictionary*)query
             andHeader:(NSDictionary*)header
               andBody:(NSDictionary*)body
            andSuccess:(success)success
            andfailure:(failure)failure {
    
    // form main URL
    __block NSMutableString *_mendpoint = [endpoint mutableCopy];
    if (query != NULL && query.allKeys.count > 0) {
        [_mendpoint appendString:@"?"];
        [_mendpoint appendString:[self formGetQueryFromDict:query]];
    }
    
    // get the actual URL
    NSURL *url = [NSURL URLWithString:_mendpoint];
    
    // create the requrest
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setHTTPMethod:method];
    
    // set headers
    if (header != NULL && header.allKeys.count > 0) {
        for (NSString *key in header.allKeys) {
            [request setValue:[header objectForKey:key] forHTTPHeaderField:key];
        }
    }
    
    // set body, if post
    if ([method isEqualToString:@"POST"] && body != NULL && body.allKeys.count > 0) {
        request.HTTPBody = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:nil];
    }
    
    // get the response handler
    netresponse resp = ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        // handle two failure cases
        if (error != NULL || data == NULL) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"[NOK] %@ to %@", method, _mendpoint);
                if (failure != NULL) {
                    failure();
                }
            });
            return;
        }
        
        // get actual result
        NSInteger status = ((NSHTTPURLResponse*)response).statusCode;
        NSString *payload = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        // send response on main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"[OK] %ld | %@ to %@", status, method, _mendpoint);
            if (success != NULL) {
                success(status, payload);
            }
        });
    };
    
    // start the session
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:resp];
    [task resume];
}

- (void) sendGET:(NSString*)endpoint
       withQuery:(NSDictionary*)query
       andHeader:(NSDictionary*)header
      andSuccess:(success)success
      andFailure:(failure)failure {
    [self sendRequestTo:endpoint withMethod:@"GET" andQuery:query andHeader:header andBody:nil andSuccess:success andfailure:failure];
}

- (void) sendPOST:(NSString*)endpoint
        withQuery:(NSDictionary*)query
        andHeader:(NSDictionary*)header
          andBody:(NSDictionary*)body
       andSuccess:(success)success
       andFailure:(failure)failure {
    [self sendRequestTo:endpoint withMethod:@"POST" andQuery:query andHeader:header andBody:body andSuccess:success andfailure:failure];
}

// MARK: Private

- (NSString*) formGetQueryFromDict:(NSDictionary *)dict {
    NSMutableString *query = [[NSMutableString alloc] init];
    NSMutableArray *getParams = [[NSMutableArray alloc] init];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [getParams addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    }];
    [query appendString:[getParams componentsJoinedByString:@"&"]];
    
    return query;
}

@end
