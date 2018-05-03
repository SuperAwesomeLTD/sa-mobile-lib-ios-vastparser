//
//  SAXML_Parser_Tests7.m
//  SAVASTParser
//
//  Created by Gabriel Coman on 01/03/2017.
//  Copyright © 2017 Gabriel Coman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SAXMLParser.h"
#import "SATestUtils.h"

@interface SAXML_Parser_Tests7 : XCTestCase
@property (nonatomic, strong) SATestUtils *utils;
@end

@implementation SAXML_Parser_Tests7

- (void)setUp {
    [super setUp];
    _utils = [[SATestUtils alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testInvalidXML1 {
    
    // given
    NSString *given = [_utils fixtureWithName:@"mock_xml_response_3" ofType:@"xml"];
    
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:given];
    
    XCTAssertNil(document);
    
}

- (void) testInvalidXML2 {
    
    // given
    NSString *given = nil;
    
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:given];
    
    XCTAssertNil(document);
    
}

@end
