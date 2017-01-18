//
//  SAVASTParserTests.m
//  SAVASTParserTests
//
//  Created by Gabriel Coman on 03/08/2016.
//  Copyright (c) 2016 Gabriel Coman. All rights reserved.
//

@import XCTest;
#import "SAXMLParser.h"

@interface SAXML_Parser_Tests : XCTestCase

@end

@implementation SAXML_Parser_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
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

- (void) testSearchSiblingsAndChildrenOf1 {
    
    // given
    NSString *fp1 = [[NSBundle mainBundle] pathForResource:@"xml2" ofType:@"xml"];
    NSString *given = [NSString stringWithContentsOfFile:fp1 encoding:NSUTF8StringEncoding error:nil];
    
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:given];
    
    XCTAssertNotNil(document);
    
    NSMutableArray *errors = [@[] mutableCopy];
    [SAXMLParser searchSiblingsAndChildrenOf:document forName:@"Error" into:errors];
    
    XCTAssertNotNil(errors);
    XCTAssertEqual(errors.count, 1);
    
    NSMutableArray *impressions = [@[] mutableCopy];
    [SAXMLParser searchSiblingsAndChildrenOf:document forName:@"Impression" into:impressions];
    
    XCTAssertNotNil(impressions);
    XCTAssertEqual(impressions.count, 3);
    
    NSMutableArray *clicks = [@[] mutableCopy];
    [SAXMLParser searchSiblingsAndChildrenOf:document forName:@"Clicks" into:clicks];
    
    XCTAssertNotNil(clicks);
    XCTAssertEqual(clicks.count, 0);
}

- (void) testSearchSiblingsAndChildrenOf2 {
    
    // given
    NSString *fp1 = [[NSBundle mainBundle] pathForResource:@"xml2" ofType:@"xml"];
    NSString *given = [NSString stringWithContentsOfFile:fp1 encoding:NSUTF8StringEncoding error:nil];
    
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:given];
    
    XCTAssertNotNil(document);
    
    NSMutableArray *errors = [SAXMLParser searchSiblingsAndChildrenOf:document forName:@"Error"];
    
    XCTAssertNotNil(errors);
    XCTAssertEqual(errors.count, 1);
    
    NSMutableArray *impressions = [SAXMLParser searchSiblingsAndChildrenOf:document forName:@"Impression"];
    
    XCTAssertNotNil(impressions);
    XCTAssertEqual(impressions.count, 3);
    
    NSMutableArray *clicks = [SAXMLParser searchSiblingsAndChildrenOf:document forName:@"Clicks"];
    
    XCTAssertNotNil(clicks);
    XCTAssertEqual(clicks.count, 0);
}

- (void) testSearchSiblingsAndChildrenOf3 {
    
    // given
    NSString *fp1 = [[NSBundle mainBundle] pathForResource:@"xml2" ofType:@"xml"];
    NSString *given = [NSString stringWithContentsOfFile:fp1 encoding:NSUTF8StringEncoding error:nil];
    
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:given];
    
    XCTAssertNotNil(document);
    
    __block NSMutableArray *errors = [@[] mutableCopy];
    
    [SAXMLParser searchSiblingsAndChildrenOf:document forName:@"Error" andInterate:^(SAXMLElement *element) {
        XCTAssertNotNil(element);
        XCTAssertEqualObjects([element getName], @"Error");
        [errors addObject:element];
    }];
    
    XCTAssertNotNil(errors);
    XCTAssertEqual(errors.count, 1);
    
    
    __block NSMutableArray *impressions = [@[] mutableCopy];
    
    [SAXMLParser searchSiblingsAndChildrenOf:document forName:@"Impression" andInterate:^(SAXMLElement *element) {
        XCTAssertNotNil(element);
        XCTAssertEqualObjects([element getName], @"Impression");
        [impressions addObject:element];
    }];
    
    XCTAssertNotNil(impressions);
    XCTAssertEqual(impressions.count, 3);
    
    
    __block NSMutableArray *clicks = [@[] mutableCopy];
    
    [SAXMLParser searchSiblingsAndChildrenOf:document forName:@"Click" andInterate:^(SAXMLElement *element) {
        XCTAssertNotNil(element);
        XCTAssertEqualObjects([element getName], @"Click");
        [clicks addObject:element];
    }];
    
    XCTAssertNotNil(clicks);
    XCTAssertEqual(clicks.count, 0);
}

- (void) testFindFirstInstanceInSiblingsAndChildrenOf {
    
    // given
    NSString *fp1 = [[NSBundle mainBundle] pathForResource:@"xml2" ofType:@"xml"];
    NSString *given = [NSString stringWithContentsOfFile:fp1 encoding:NSUTF8StringEncoding error:nil];
    
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:given];
    
    XCTAssertNotNil(document);
    
    SAXMLElement *firstImpression = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:document forName:@"Impression"];
    
    XCTAssertNotNil(firstImpression);
    
    NSString *expected_firstImpressionUrl = @"https://ads.staging.superawesome.tv/v2/impr1/";
    NSString *firstImpressionUrl = [[firstImpression getValue] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    XCTAssertNotNil(firstImpressionUrl);
    XCTAssertEqualObjects(expected_firstImpressionUrl, firstImpressionUrl);
    
    SAXMLElement *firstClick = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:document forName:@"Click"];
    XCTAssertNil(firstClick);
}

- (void) testCheckSiblingsAndChildrenOf {
    
    // given
    NSString *fp1 = [[NSBundle mainBundle] pathForResource:@"xml2" ofType:@"xml"];
    NSString *given = [NSString stringWithContentsOfFile:fp1 encoding:NSUTF8StringEncoding error:nil];
    
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:given];
    
    XCTAssertNotNil(document);
    
    BOOL errorExists = [SAXMLParser checkSiblingsAndChildrenOf:document forName:@"Error"];
    XCTAssertTrue(errorExists);
    
    BOOL impressionExists = [SAXMLParser checkSiblingsAndChildrenOf:document forName:@"Impression"];
    XCTAssertTrue(impressionExists);
    
    BOOL clickExists = [SAXMLParser checkSiblingsAndChildrenOf:document forName:@"Click"];
    XCTAssertFalse(clickExists);
}

- (void) testInvalidXML {
    
    // given
    NSString *fp1 = [[NSBundle mainBundle] pathForResource:@"xml3" ofType:@"xml"];
    NSString *given = [NSString stringWithContentsOfFile:fp1 encoding:NSUTF8StringEncoding error:nil];
    
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:given];
    
    XCTAssertNil(document);
    
}

@end

