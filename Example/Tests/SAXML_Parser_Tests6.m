//
//  SAXML_Parser_Tests6.m
//  SAVASTParser
//
//  Created by Gabriel Coman on 01/03/2017.
//  Copyright © 2017 Gabriel Coman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SAXMLParser.h"

@interface SAXML_Parser_Tests6 : XCTestCase
@property (nonatomic, strong) NSString *given;
@end

@implementation SAXML_Parser_Tests6

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    NSString *fp1 = [[NSBundle mainBundle] pathForResource:@"xml2" ofType:@"xml"];
    _given = [NSString stringWithContentsOfFile:fp1 encoding:NSUTF8StringEncoding error:nil];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testCheckSiblingsAndChildrenOf1 {
    
    // given
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:_given];
    NSString *tag = @"Error";
    
    XCTAssertNotNil(document);
    
    BOOL errorExists = [SAXMLParser checkSiblingsAndChildrenOf:document forName:tag];
    XCTAssertTrue(errorExists);
    
}

- (void) testCheckSiblingsAndChildrenOf2 {
    
    // given
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:_given];
    NSString *tag = @"Impression";
    
    XCTAssertNotNil(document);
    
    BOOL impressionExists = [SAXMLParser checkSiblingsAndChildrenOf:document forName:tag];
    XCTAssertTrue(impressionExists);
}

- (void) testCheckSiblingsAndChildrenOf3 {
    
    // given
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:_given];
    NSString *tag = @"Click";
    
    XCTAssertNotNil(document);
    
    BOOL clickExists = [SAXMLParser checkSiblingsAndChildrenOf:document forName:tag];
    XCTAssertFalse(clickExists);
}

- (void) testCheckSiblingsAndChildrenOf4 {
    
    // given
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:_given];
    NSString *tag = nil;
    
    XCTAssertNotNil(document);
    
    BOOL clickExists = [SAXMLParser checkSiblingsAndChildrenOf:document forName:tag];
    XCTAssertFalse(clickExists);
}

- (void) testCheckSiblingsAndChildrenOf5 {
    
    // given
    SAXMLElement *document = nil;
    NSString *tag = nil;
    
    BOOL clickExists = [SAXMLParser checkSiblingsAndChildrenOf:document forName:tag];
    XCTAssertFalse(clickExists);
}


@end
