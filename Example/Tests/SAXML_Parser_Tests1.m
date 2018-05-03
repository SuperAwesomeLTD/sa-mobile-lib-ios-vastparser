//
//  SAVASTParserTests.m
//  SAVASTParserTests
//
//  Created by Gabriel Coman on 03/08/2016.
//  Copyright (c) 2016 Gabriel Coman. All rights reserved.
//

@import XCTest;
#import "SAXMLParser.h"
#import "SATestUtils.h"

@interface SAXML_Parser_Tests1 : XCTestCase
@property (nonatomic, strong) SATestUtils *utils;
@end

@implementation SAXML_Parser_Tests1

- (void)setUp {
    [super setUp];
    _utils = [[SATestUtils alloc] init];
}

- (void)tearDown {
    [super tearDown];
}

- (void) testXMLParsing1 {
    
    // given
    NSString *given = [_utils fixtureWithName:@"mock_xml_response_1" ofType:@"xml"];
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:given];
    
    XCTAssertNotNil(document);
    
}

- (void) testXMLParsing2 {
    
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:nil];
    
    XCTAssertNil(document);
    
}

@end

