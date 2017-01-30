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
#import "SATracking.h"

@interface SAVAST_Parser_Local_Tests : XCTestCase
@end

@implementation SAVAST_Parser_Local_Tests

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
    XCTAssertEqualObjects(expected_url, savastMedia.mediaUrl);
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
    XCTAssertEqualObjects(expected_url, savastMedia.mediaUrl);
    
}

- (void) testParseMediaXML3 {
    
    // given
    NSString *fp1 = [[NSBundle mainBundle] pathForResource:@"xml6" ofType:@"xml"];
    NSString *given = [NSString stringWithContentsOfFile:fp1 encoding:NSUTF8StringEncoding error:nil];
    
    SAXMLParser *xmlParser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [xmlParser parseXMLString:given];
    
    XCTAssertNotNil(document);
    
    SAVASTParser *vastParser = [[SAVASTParser alloc] init];
    XCTAssertNotNil(vastParser);
    
    SAXMLElement *Ad = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:document forName:@"Ad"];
    XCTAssertNotNil(Ad);
    
    SAVASTAd *ad = [vastParser parseAdXML:Ad];
    XCTAssertNotNil(ad);
    
    SAVASTAdType expected_vastType = SA_InLine_VAST;
    int expected_vastEventsSize = 6;
    int expected_mediaListSize = 1;
    NSString *expected_mediaUrl = @"https://s3-eu-west-1.amazonaws.com/sb-ads-video-transcoded/c0sKSRTuPu8dDkok2HQTnLS1k3A6vL6c.mp4";
    int expected_bitrate = 720;
    int expected_width = 600;
    int expected_height = 480;
    
    NSArray<NSString*> *expected_types = @[
                                @"error", @"impression", @"click_through", @"creativeView", @"start", @"firstQuartile"
                                ];
    NSArray<NSString*> *expected_urls = @[
                                         @"https://ads.staging.superawesome.tv/v2/video/error?placement=544&creative=5728&line_item=1022&sdkVersion=unknown&rnd=7062039&prog=a35a7dab-86f1-437f-b3d9-3b58ef069390&device=web&country=GB&code=[ERRORCODE]",
                                         @"https://ads.staging.superawesome.tv/v2/video/impression?placement=544&creative=5728&line_item=1022&sdkVersion=unknown&rnd=9788452&prog=a35a7dab-86f1-437f-b3d9-3b58ef069390&device=web&country=GB",
                                         @"https://ads.staging.superawesome.tv/v2/video/click?placement=544&creative=5728&line_item=1022&sdkVersion=unknown&rnd=9970101&prog=a35a7dab-86f1-437f-b3d9-3b58ef069390&device=web&country=GB",
                                         @"https://ads.staging.superawesome.tv/v2/video/tracking?event=creativeView&placement=544&creative=5728&line_item=1022&sdkVersion=unknown&rnd=3266878&prog=a35a7dab-86f1-437f-b3d9-3b58ef069390&device=web&country=GB",
                                         @"https://ads.staging.superawesome.tv/v2/video/tracking?event=start&placement=544&creative=5728&line_item=1022&sdkVersion=unknown&rnd=9640628&prog=a35a7dab-86f1-437f-b3d9-3b58ef069390&device=web&country=GB",
                                         @"https://ads.staging.superawesome.tv/v2/video/tracking?event=firstQuartile&placement=544&creative=5728&line_item=1022&sdkVersion=unknown&rnd=2560539&prog=a35a7dab-86f1-437f-b3d9-3b58ef069390&device=web&country=GB"
                                         ];
    
    XCTAssertEqual(expected_vastType, ad.vastType);
    XCTAssertNil(ad.vastRedirect);
    XCTAssertNotNil(ad.vastEvents);
    XCTAssertNotNil(ad.mediaList);
    XCTAssertEqual(expected_vastEventsSize, [ad.vastEvents count]);
    XCTAssertEqual(expected_mediaListSize, [ad.mediaList count]);
    
    for (int i = 0; i < [ad.vastEvents count]; i++) {
        XCTAssertEqualObjects(expected_types[i], ad.vastEvents[i].event);
        XCTAssertEqualObjects(expected_urls[i], ad.vastEvents[i].URL);
    }
    
    SAVASTMedia *savastMedia = ad.mediaList[0];
    XCTAssertNotNil(savastMedia);
    XCTAssertTrue([savastMedia isValid]);
    XCTAssertEqualObjects(expected_mediaUrl, savastMedia.mediaUrl);
    XCTAssertEqual(expected_bitrate, savastMedia.bitrate);
    XCTAssertEqual(expected_width, savastMedia.width);
    XCTAssertEqual(expected_height, savastMedia.height);
}

@end
