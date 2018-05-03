//
//  SAMockVASTServer.m
//  SAVASTParser_Example
//
//  Created by Gabriel Coman on 03/05/2018.
//  Copyright © 2018 Gabriel Coman. All rights reserved.
//

#import "SAMockVASTServer.h"
#import <OHHTTPStubs/OHHTTPStubs.h>
#import "SATestUtils.h"

@interface SAMockVASTServer ()
@property (nonatomic, strong) SATestUtils *utils;
@end

@implementation SAMockVASTServer

- (id) init {
    if (self = [super init]) {
        _utils = [[SATestUtils alloc] init];
    }
    return self;
}

- (void) start {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest * _Nonnull request) {
        return true;
    } withStubResponse:^OHHTTPStubsResponse * _Nonnull(NSURLRequest * _Nonnull request) {
        NSString *url = [request URL].absoluteString;
        if ([url containsString:@"/vast/vast1.xml"])        return [self sendResponse:@"mock_vast_response_1.0"];
        else if ([url containsString:@"/vast/vast2.0.xml"]) return [self sendResponse:@"mock_vast_response_2.0"];
        else if ([url containsString:@"/vast/vast2.1.xml"]) return [self sendResponse:@"mock_vast_response_2.1"];
        else if ([url containsString:@"/vast/vast3.0.xml"]) return [self sendResponse:@"mock_vast_response_3.0"];
        else if ([url containsString:@"/vast/vast3.1.xml"]) return [self sendResponse:@"mock_vast_response_3.1"];
        else if ([url containsString:@"/vast/vast4.0.xml"]) return [self sendResponse:@"mock_vast_response_4.0"];
        else if ([url containsString:@"/vast/vast5.0.xml"]) return [self sendResponse:@"mock_vast_response_5.0"];
        else if ([url containsString:@"/vast/vast5.1.xml"]) return [self sendResponse:@"mock_vast_response_5.1"];
        else if ([url containsString:@"/vast/vast5.2.xml"]) return [self sendResponse:@"mock_vast_response_5.2"];
        else if ([url containsString:@"/vast/vast5.3.xml"]) return [self sendResponse:@"mock_vast_response_5.3"];
        else return [self sendError];
    }];
}

- (NSString*) sendVASTTag: (NSString*) xml {
    return [_utils fixtureWithName:xml ofType:@"xml"];
}

- (OHHTTPStubsResponse*) sendResponse: (NSString*) xml {
    NSString *xmlString = [self sendVASTTag:xml];
    NSData *data = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *headers = @{@"Content-Type": @"application/xml"};
    return [OHHTTPStubsResponse responseWithData:data statusCode:200 headers:headers];
}

- (OHHTTPStubsResponse*) sendError {
    NSError* notConnectedError = [NSError errorWithDomain:NSURLErrorDomain code:kCFURLErrorNotConnectedToInternet userInfo:nil];
    return [OHHTTPStubsResponse responseWithError:notConnectedError];
}

- (void) shutdown {
    [OHHTTPStubs removeAllStubs];
}

@end
