//
//  SAXML_Parser_Tests4.m
//  SAVASTParser
//
//  Created by Gabriel Coman on 01/03/2017.
//  Copyright © 2017 Gabriel Coman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SAXMLParser.h"
#import "SATestUtils.h"

@interface SAXML_Parser_Tests4 : XCTestCase
@property (nonatomic, strong) SATestUtils *utils;
@property (nonatomic, strong) NSString *given;
@end

@implementation SAXML_Parser_Tests4

- (void)setUp {
    [super setUp];
    _utils = [[SATestUtils alloc] init];
    _given = [_utils fixtureWithName:@"mock_xml_response_2" ofType:@"xml"];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    
}

- (void) testSearchSiblingsAndChildrenOf1 {
    
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:_given];
    __block NSString *tag = @"Error";
    
    XCTAssertNotNil(document);
    
    __block NSMutableArray *errors = [@[] mutableCopy];
    
    [SAXMLParser searchSiblingsAndChildrenOf:document forName:tag andInterate:^(SAXMLElement *element) {
        XCTAssertNotNil(element);
        XCTAssertEqualObjects([element getName], tag);
        [errors addObject:element];
    }];
    
    XCTAssertNotNil(errors);
    XCTAssertEqual(errors.count, 1);
}

- (void) testSearchSiblingsAndChildrenOf2 {
    
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:_given];
    __block NSString *tag = @"Impression";
    
    XCTAssertNotNil(document);
    
    __block NSMutableArray *impressions = [@[] mutableCopy];
    
    [SAXMLParser searchSiblingsAndChildrenOf:document forName:tag andInterate:^(SAXMLElement *element) {
        XCTAssertNotNil(element);
        XCTAssertEqualObjects([element getName], tag);
        [impressions addObject:element];
    }];
    
    XCTAssertNotNil(impressions);
    XCTAssertEqual(impressions.count, 3);
}

- (void) testSearchSiblingsAndChildrenOf3 {
    
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:_given];
    __block NSString *tag = @"Click";
    
    XCTAssertNotNil(document);
    
    __block NSMutableArray *clicks = [@[] mutableCopy];
    
    [SAXMLParser searchSiblingsAndChildrenOf:document forName:tag andInterate:^(SAXMLElement *element) {
        XCTAssertNotNil(element);
        XCTAssertEqualObjects([element getName], tag);
        [clicks addObject:element];
    }];
    
    XCTAssertNotNil(clicks);
    XCTAssertEqual(clicks.count, 0);
}

- (void) testSearchSiblingsAndChildrenOf4 {
    
    SAXMLParser *parser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [parser parseXMLString:_given];
    __block NSString *tag = nil;
    
    XCTAssertNotNil(document);
    
    __block NSMutableArray *clicks = [@[] mutableCopy];
    
    [SAXMLParser searchSiblingsAndChildrenOf:document forName:tag andInterate:^(SAXMLElement *element) {
        XCTAssertNotNil(element);
        XCTAssertEqualObjects([element getName], tag);
        [clicks addObject:element];
    }];
    
    XCTAssertNotNil(clicks);
    XCTAssertEqual(clicks.count, 0);
}

- (void) testSearchSiblingsAndChildrenOf5 {
    
    SAXMLElement *document = nil;
    __block NSString *tag = nil;
    
    __block NSMutableArray *clicks = [@[] mutableCopy];
    
    [SAXMLParser searchSiblingsAndChildrenOf:document forName:tag andInterate:^(SAXMLElement *element) {
        XCTAssertNotNil(element);
        XCTAssertEqualObjects([element getName], tag);
        [clicks addObject:element];
    }];
    
    XCTAssertNotNil(clicks);
    XCTAssertEqual(clicks.count, 0);
}

@end
