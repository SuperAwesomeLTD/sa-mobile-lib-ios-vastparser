//
//  SAVAST_Parser_Local_Tests.m
//  SAVASTParser
//
//  Created by Gabriel Coman on 18/01/2017.
//  Copyright © 2017 Gabriel Coman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SAVASTParser.h"
#import "SAXMLParser.h"
#import "SAVASTMedia.h"
#import "SAVASTAd.h"
#import "SAVASTEvent.h"

@interface SAVAST_Parser_Local_Tests1 : XCTestCase
@end

@implementation SAVAST_Parser_Local_Tests1

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void) testParseMediaXML1 {
    
    // given
    NSString *fp1 = [[NSBundle mainBundle] pathForResource:@"xml4" ofType:@"xml"];
    NSString *given = [NSString stringWithContentsOfFile:fp1 encoding:NSUTF8StringEncoding error:nil];
    
    SAXMLParser *xmlParser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [xmlParser parseXMLString:given];
    
    XCTAssertNotNil(document);
    
    SAVASTParser *vastParser = [[SAVASTParser alloc] init];
    XCTAssertNotNil(vastParser);
    
    SAXMLElement *firstMediaElement = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:document forName:@"MediaFile"];
    XCTAssertNotNil(firstMediaElement);
    
    SAVASTMedia *savastMedia = [vastParser parseMediaXML:firstMediaElement];
    XCTAssertNotNil(savastMedia);
    
    NSString *expected_type = @"video/mp4";
    int expected_width = 600;
    int expected_height = 480;
    int expected_bitrate = 720;
    NSString *expected_url = @"https://s3-eu-west-1.amazonaws.com/sb-ads-video-transcoded/c0sKSRTuPu8dDkok2HQTnLS1k3A6vL6c.mp4";
    
    XCTAssertEqualObjects(expected_type, savastMedia.type);
    XCTAssertEqual(expected_width, savastMedia.width);
    XCTAssertEqual(expected_height, savastMedia.height);
    XCTAssertEqual(expected_bitrate, savastMedia.bitrate);
    XCTAssertEqualObjects(expected_url, savastMedia.url);
}

- (void) testParseMediaXML2 {
    
    // given
    NSString *fp1 = [[NSBundle mainBundle] pathForResource:@"xml5" ofType:@"xml"];
    NSString *given = [NSString stringWithContentsOfFile:fp1 encoding:NSUTF8StringEncoding error:nil];
    
    SAXMLParser *xmlParser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [xmlParser parseXMLString:given];
    
    XCTAssertNil(document);
    
    SAVASTParser *vastParser = [[SAVASTParser alloc] init];
    XCTAssertNotNil(vastParser);
    
    SAXMLElement *firstMediaElement = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:document forName:@"MediaFile"];
    XCTAssertNil(firstMediaElement);
    
    SAVASTMedia *savastMedia = [vastParser parseMediaXML:firstMediaElement];
    XCTAssertNotNil(savastMedia);
    
    NSString *expected_type = nil;
    int expected_width = 0;
    int expected_height = 0;
    int expected_bitrate = 0;
    NSString *expected_url = nil;
    
    XCTAssertEqualObjects(expected_type, savastMedia.type);
    XCTAssertEqual(expected_width, savastMedia.width);
    XCTAssertEqual(expected_height, savastMedia.height);
    XCTAssertEqual(expected_bitrate, savastMedia.bitrate);
    XCTAssertEqualObjects(expected_url, savastMedia.url);
    
}

- (void) testParseMediaXML3 {
    
    // given
    SAXMLElement *document = nil;
    
    SAVASTParser *vastParser = [[SAVASTParser alloc] init];
    XCTAssertNotNil(vastParser);
    
    SAXMLElement *firstMediaElement = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:document forName:@"MediaFile"];
    XCTAssertNil(firstMediaElement);
    
    SAVASTMedia *savastMedia = [vastParser parseMediaXML:firstMediaElement];
    XCTAssertNotNil(savastMedia);
    
    NSString *expected_type = nil;
    int expected_width = 0;
    int expected_height = 0;
    int expected_bitrate = 0;
    NSString *expected_url = nil;
    
    XCTAssertEqualObjects(expected_type, savastMedia.type);
    XCTAssertEqual(expected_width, savastMedia.width);
    XCTAssertEqual(expected_height, savastMedia.height);
    XCTAssertEqual(expected_bitrate, savastMedia.bitrate);
    XCTAssertEqualObjects(expected_url, savastMedia.url);
    
}

@end
