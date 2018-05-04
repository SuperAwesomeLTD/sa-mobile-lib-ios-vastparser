//
//  SAResponseFactory.h
//  SAVASTParser_Tests
//
//  Created by Gabriel Coman on 04/05/2018.
//  Copyright © 2018 Gabriel Coman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OHHTTPStubs/OHHTTPStubs.h>

@interface SAResponseFactory : NSObject
- (OHHTTPStubsResponse*) sendResponse: (NSString*) xml;
- (OHHTTPStubsResponse*) sendError;
@end
