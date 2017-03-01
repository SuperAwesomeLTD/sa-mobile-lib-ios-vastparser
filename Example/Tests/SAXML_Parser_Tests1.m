//
//  SAVASTParserTests.m
//  SAVASTParserTests
//
//  Created by Gabriel Coman on 03/08/2016.
//  Copyright (c) 2016 Gabriel Coman. All rights reserved.
//

@import XCTest;
#import "SAXMLParser.h"

@interface SAXML_Parser_Tests1 : XCTestCase
@end

@implementation SAXML_Parser_Tests1

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testXMLParsing1 {
    
    // given
    NSString *fp1 = [[NSBundle mainBundle] pathForResource:@"xml1" ofType:@"xml"];
    NSString *given = [NSString stringWithContentsOfFile:fp1 encoding:NSUTF8StringEncoding error:nil];
    
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

