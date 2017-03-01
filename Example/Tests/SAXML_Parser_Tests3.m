//
//  SAXML_Parser_Tests3.m
//  SAVASTParser
//
//  Created by Gabriel Coman on 01/03/2017.
//  Copyright © 2017 Gabriel Coman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SAXMLParser.h"

@interface SAXML_Parser_Tests3 : XCTestCase
@property (nonatomic, strong) NSString *given;
@end

@implementation SAXML_Parser_Tests3

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

- (void) testSearchSiblingsAndChildrenOf1 {
    
    // given
    
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:_given];
    NSString *tag = @"Error";
    
    XCTAssertNotNil(document);
    
    NSMutableArray *errors = [SAXMLParser searchSiblingsAndChildrenOf:document forName:tag];
    
    XCTAssertNotNil(errors);
    XCTAssertEqual(errors.count, 1);

}

- (void) testSearchSiblingsAndChildrenOf2 {
    
    // given
    
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:_given];
    NSString *tag = @"Impression";
    
    XCTAssertNotNil(document);
    
    NSMutableArray *impressions = [SAXMLParser searchSiblingsAndChildrenOf:document forName:tag];
    
    XCTAssertNotNil(impressions);
    XCTAssertEqual(impressions.count, 3);
    
}

- (void) testSearchSiblingsAndChildrenOf3 {
    
    // given
    
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:_given];
    NSString *tag = @"Clicks";
    
    XCTAssertNotNil(document);
    
    NSMutableArray *clicks = [SAXMLParser searchSiblingsAndChildrenOf:document forName:tag];
    
    XCTAssertNotNil(clicks);
    XCTAssertEqual(clicks.count, 0);
}

- (void) testSearchSiblingsAndChildrenOf4 {
    
    // given
    
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:_given];
    NSString *tag = nil;
    
    XCTAssertNotNil(document);
    
    NSMutableArray *clicks = [SAXMLParser searchSiblingsAndChildrenOf:document forName:tag];
    
    XCTAssertNotNil(clicks);
    XCTAssertEqual(clicks.count, 0);
}

- (void) testSearchSiblingsAndChildrenOf5 {
    
    SAXMLElement *document = nil;
    NSString *tag = nil;
    
    NSMutableArray *clicks = [SAXMLParser searchSiblingsAndChildrenOf:document forName:tag];
    
    XCTAssertNotNil(clicks);
    XCTAssertEqual(clicks.count, 0);
}

@end
