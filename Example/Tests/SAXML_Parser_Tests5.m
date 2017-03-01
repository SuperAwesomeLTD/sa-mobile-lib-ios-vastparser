//
//  SAXML_Parser_Tests5.m
//  SAVASTParser
//
//  Created by Gabriel Coman on 01/03/2017.
//  Copyright © 2017 Gabriel Coman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SAXMLParser.h"

@interface SAXML_Parser_Tests5 : XCTestCase
@property (nonatomic, strong) NSString *given;
@end

@implementation SAXML_Parser_Tests5

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

- (void) testFindFirstInstanceInSiblingsAndChildrenOf1 {
    
    // given
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:_given];
    NSString *tag = @"Impression";
    
    XCTAssertNotNil(document);
    
    SAXMLElement *firstImpression = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:document forName:tag];
    
    XCTAssertNotNil(firstImpression);
    
    NSString *expected_firstImpressionUrl = @"https://ads.staging.superawesome.tv/v2/impr1/";
    NSString *firstImpressionUrl = [[firstImpression getValue] stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    XCTAssertNotNil(firstImpressionUrl);
    XCTAssertEqualObjects(expected_firstImpressionUrl, firstImpressionUrl);
}

- (void) testFindFirstInstanceInSiblingsAndChildrenOf2 {
    
    // given
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:_given];
    NSString *tag = @"Click";
    
    XCTAssertNotNil(document);
    
    SAXMLElement *firstClick = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:document forName:tag];
    XCTAssertNil(firstClick);
}

- (void) testFindFirstInstanceInSiblingsAndChildrenOf3 {
    
    // given
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:_given];
    NSString *tag = nil;

    XCTAssertNotNil(document);
    
    SAXMLElement *firstClick = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:document forName:tag];
    XCTAssertNil(firstClick);
}

- (void) testFindFirstInstanceInSiblingsAndChildrenOf4 {
    
    // given
    SAXMLElement *document = nil;
    NSString *tag = nil;
    
    SAXMLElement *firstClick = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:document forName:tag];
    XCTAssertNil(firstClick);
}

@end
