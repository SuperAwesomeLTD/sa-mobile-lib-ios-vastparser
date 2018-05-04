//
//  SAResponseFactory.m
//  SAVASTParser_Tests
//
//  Created by Gabriel Coman on 04/05/2018.
//  Copyright © 2018 Gabriel Coman. All rights reserved.
//

#import "SAResponseFactory.h"
#import "SATestUtils.h"

@interface SAResponseFactory ()
@property (nonatomic, strong) SATestUtils *utils;
@end

@implementation SAResponseFactory

- (id) init {
    if (self = [super init]) {
        _utils = [[SATestUtils alloc] init];
    }
    
    return self;
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

@end
