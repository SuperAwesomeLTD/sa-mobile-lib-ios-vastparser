//
//  SAUtils.m
//  Pods
//
//  Created by Gabriel Coman on 09/03/2016.
//
//

#import "SAUtils.h"
#import "SAExtensions.h"
#import "NSString+HTML.h"

// constants with user agents
#define iOS_Mobile_UserAgent @"Mozilla/5.0 (iPhone; CPU iPhone OS 6_1_4 like Mac OS X) AppleWebKit/536.26 (KHTML, like Gecko) Version/6.0 Mobile/10B350 Safari/8536.25";
#define iOS_Tablet_UserAgent @"Mozilla/5.0 (iPad; CPU OS 7_0 like Mac OS X) AppleWebKit/537.51.1 (KHTML, like Gecko) Version/7.0 Mobile/11A465 Safari/9537.53";

@implementation SAUtils

////////////////////////////////////////////////////////////////////////////////
// Trully aux functions
////////////////////////////////////////////////////////////////////////////////

+ (CGRect) mapOldFrame:(CGRect)frame toNewFrame:(CGRect)oldframe {
    
    CGFloat newW = frame.size.width;
    CGFloat newH = frame.size.height;
    CGFloat oldW = oldframe.size.width;
    CGFloat oldH = oldframe.size.height;
    if (oldW == 1 || oldW == 0) { oldW = newW; }
    if (oldH == 1 || oldH == 0) { oldH = newH; }
    
    CGFloat oldR = oldW / oldH;
    CGFloat newR = newW / newH;
    
    CGFloat X = 0, Y = 0, W = 0, H = 0;
    
    if (oldR > newR) {
        W = newW;
        H = W / oldR;
        X = 0;
        Y = (newH - H) / 2.0f;
    }
    else {
        H = newH;
        W = H * oldR;
        Y = 0;
        X = (newW - W) / 2.0f;
    }
    
    return CGRectMake(X, Y, W, H);
}

+ (NSInteger) randomNumberBetween:(NSInteger)min maxNumber:(NSInteger)max {
    return min + arc4random_uniform((uint32_t)(max - min + 1));
}

+ (NSString*) findSubstringFrom:(NSString*)source betweenStart:(NSString*)start andEnd:(NSString*)end {
    NSRange startRange = [source rangeOfString:start];
    if (startRange.location != NSNotFound) {
        NSRange targetRange;
        targetRange.location = startRange.location + startRange.length;
        targetRange.length = [source length] - targetRange.location;
        NSRange endRange = [source rangeOfString:end options:0 range:targetRange];
        if (endRange.location != NSNotFound) {
            targetRange.length = endRange.location - targetRange.location;
            return [source substringWithRange:targetRange];
        }
    }
    
    return nil;
}

+ (NSString*) generateUniqueKey {
    // constants
    const NSString *alphabet  = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXZY0123456789";
    const NSInteger length = [alphabet length];
    const NSInteger dauLength = 32;
    
    // create the string
    NSMutableString *s = [NSMutableString stringWithCapacity:20];
    for (NSUInteger i = 0U; i < dauLength; i++) {
        u_int32_t r = arc4random() % length;
        unichar c = [alphabet characterAtIndex:r];
        [s appendFormat:@"%C", c];
    }
    
    return s;
}

////////////////////////////////////////////////////////////////////////////////
// System type functions
////////////////////////////////////////////////////////////////////////////////

+ (SASystemSize) getSystemSize {
    BOOL isIpad = [(NSString*)[UIDevice currentDevice].model hasPrefix:@"iPad"];
    return (isIpad ? size_tablet : size_mobile);
}

+ (NSString*) getVerboseSystemDetails {
    switch ([self getSystemSize]) {
        case size_tablet: return @"ios_tablet";
        case size_mobile: return @"ios_mobile";
    }
}

+ (NSString*) filePathForName:(NSString*)name type:(NSString*)type andBundle:(NSString*)bundleName andClass:(Class)className {
//    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
//    NSString *receivedImgName = [[NSBundle bundleWithPath:bundlePath] pathForResource:name ofType:type];
//    return receivedImgName;
    
    NSBundle *podBundle = [NSBundle bundleForClass:className];
    NSURL *bundleUrl = [podBundle URLForResource:bundleName withExtension:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:bundleUrl];
    return [bundle pathForResource:name ofType:type];
}

+ (NSString *) getDocumentsDirectory {
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = paths.firstObject;
    return basePath;
}

+ (NSString*) filePathInDocuments:(NSString*)fpath {
    return [[self getDocumentsDirectory] stringByAppendingPathComponent:fpath];
}

////////////////////////////////////////////////////////////////////////////////
// URL and Network request helper classes
////////////////////////////////////////////////////////////////////////////////

+ (NSString*) getUserAgent {
    switch ([self getSystemSize]) {
        case size_tablet: return iOS_Tablet_UserAgent;
        case size_mobile: return iOS_Mobile_UserAgent;
        
    }
}

+ (NSInteger) getCachebuster {
    NSInteger min = 1000000, max = 1500000;
    return [self randomNumberBetween:min maxNumber:max];
}

+ (NSString*) encodeURI:(NSString*)stringToEncode {
    return CFBridgingRelease(
        CFURLCreateStringByAddingPercentEscapes(
            NULL,
            (__bridge CFStringRef)stringToEncode,
            NULL,
            (__bridge CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
            CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)
        )
    );
}

+ (NSString*) formGetQueryFromDict:(NSDictionary *)dict {
    NSMutableString *query = [[NSMutableString alloc] init];
    NSMutableArray *getParams = [[NSMutableArray alloc] init];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull end) {
        [getParams addObject:[NSString stringWithFormat:@"%@=%@", key, obj]];
    } atEnd:^{
        [query appendString:[getParams componentsJoinedByString:@"&"]];
    }];
    
    return query;
}

+ (NSString*) encodeJSONDictionaryFromNSDictionary:(NSDictionary *)dict {
    NSMutableString *stringJSON = [[NSMutableString alloc] init];
    NSMutableArray *jsonFields = [[NSMutableArray alloc] init];
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull end) {
        if ([obj isKindOfClass:[NSString class]]){
            [jsonFields addObject:[NSString stringWithFormat:@"\"%@\":\"%@\"", key, obj ]];
        } else {
            [jsonFields addObject:[NSString stringWithFormat:@"\"%@\":%@", key, obj ]];
        }
    } atEnd:^{
        [stringJSON appendFormat:@"{%@}", [jsonFields componentsJoinedByString:@","]];
    }];
    
    return [self encodeURI:stringJSON];
}

+ (NSString*) decodeHTMLEntitiesFrom:(NSString*)string {
    return [string stringByDecodingHTMLEntities];
}

+ (BOOL) isValidURL:(NSObject *)urlObject {
    if (![urlObject isKindOfClass:[NSString class]] || urlObject == nil) return false;
    NSURL *candidateURL = [NSURL URLWithString:(NSString*)urlObject];
    if (candidateURL && candidateURL.scheme && candidateURL.host) return true;
    return false;
}

////////////////////////////////////////////////////////////////////////////////
// Aux network functions
////////////////////////////////////////////////////////////////////////////////

+ (void) sendGETtoEndpoint:(NSString*)endpoint
             withQueryDict:(NSDictionary*)GETDict
                andSuccess:(success)success
                 orFailure:(failure)failure {
    
    // prepare the URL
    __block NSMutableString *_surl = [endpoint mutableCopy];
    
    [_surl appendString:(GETDict.allKeys.count > 0 ? @"?" : @"")];
    [_surl appendString:[self formGetQueryFromDict:GETDict]];
    
    NSURL *url = [NSURL URLWithString:_surl];
    
    // create the request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:url];
    [request setValue:[self getUserAgent] forHTTPHeaderField:@"User-Agent"];
    [request setHTTPMethod:@"GET"];
    
    // form the response block to the POST
    netresponse resp = ^(NSData * data, NSURLResponse * response, NSError * error) {
        
        NSInteger status = ((NSHTTPURLResponse*)response).statusCode;
        
        if (error || status != 200) {
            // logging
            NSLog(@"Network error for %@ - %@", _surl, error);
            
            // send message
            dispatch_async(dispatch_get_main_queue(), ^{
                if (failure) {
                    failure();
                }
            });
        }
        else {
            
            // logging
            NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (str.length >= 10){  str = [[str substringToIndex:9] stringByAppendingString:@" ... /truncated"]; }
            NSLog(@"Success: %@ ==> %@", _surl, str);
            
            // send message
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success){
                    success(data);
                }
            });
        }
    };
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:resp];
    [task resume];
}


@end
