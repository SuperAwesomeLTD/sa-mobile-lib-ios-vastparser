//
//  SAXML_Parser_Tests7.m
//  SAVASTParser
//
//  Created by Gabriel Coman on 01/03/2017.
//  Copyright © 2017 Gabriel Coman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SAXMLParser.h"

@interface SAXML_Parser_Tests7 : XCTestCase

@end

@implementation SAXML_Parser_Tests7

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testInvalidXML1 {
    
    // given
    NSString *fp1 = [[NSBundle mainBundle] pathForResource:@"xml3" ofType:@"xml"];
    NSString *given = [NSString stringWithContentsOfFile:fp1 encoding:NSUTF8StringEncoding error:nil];
    
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
