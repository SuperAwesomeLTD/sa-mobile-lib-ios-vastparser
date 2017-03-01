//
//  SAVAST_Parser_Local_Tests2.m
//  SAVASTParser
//
//  Created by Gabriel Coman on 01/03/2017.
//  Copyright © 2017 Gabriel Coman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SAVASTParser.h"
#import "SAXMLParser.h"
#import "SAVASTMedia.h"
#import "SAVASTAd.h"
#import "SAVASTEvent.h"

@interface SAVAST_Parser_Local_Tests2 : XCTestCase

@end

@implementation SAVAST_Parser_Local_Tests2

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testParseMediaXML1 {
    
    // given
    NSString *fp1 = [[NSBundle mainBundle] pathForResource:@"xml6" ofType:@"xml"];
    NSString *given = [NSString stringWithContentsOfFile:fp1 encoding:NSUTF8StringEncoding error:nil];
    
    SAXMLParser *xmlParser = [[SAXMLParser alloc] init];
    SAXMLElement *document = [xmlParser parseXMLString:given];
    
    XCTAssertNotNil(document);
    
    SAVASTParser *vastParser = [[SAVASTParser alloc] init];
    XCTAssertNotNil(vastParser);
    
    NSString *tag = @"Ad";
    
    SAXMLElement *Ad = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:document forName:tag];
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
                                           @"vast_error", @"vast_impression", @"vast_click_through", @"vast_creativeView", @"vast_start", @"vast_firstQuartile"
                                           ];
    NSArray<NSString*> *expected_urls = @[
                                          @"https://ads.staging.superawesome.tv/v2/video/error?placement=544&creative=5728&line_item=1022&sdkVersion=unknown&rnd=7062039&prog=a35a7dab-86f1-437f-b3d9-3b58ef069390&device=web&country=GB&code=[ERRORCODE]",
                                          @"https://ads.staging.superawesome.tv/v2/video/impression?placement=544&creative=5728&line_item=1022&sdkVersion=unknown&rnd=9788452&prog=a35a7dab-86f1-437f-b3d9-3b58ef069390&device=web&country=GB",
                                          @"https://ads.staging.superawesome.tv/v2/video/click?placement=544&creative=5728&line_item=1022&sdkVersion=unknown&rnd=9970101&prog=a35a7dab-86f1-437f-b3d9-3b58ef069390&device=web&country=GB",
                                          @"https://ads.staging.superawesome.tv/v2/video/tracking?event=creativeView&placement=544&creative=5728&line_item=1022&sdkVersion=unknown&rnd=3266878&prog=a35a7dab-86f1-437f-b3d9-3b58ef069390&device=web&country=GB",
                                          @"https://ads.staging.superawesome.tv/v2/video/tracking?event=start&placement=544&creative=5728&line_item=1022&sdkVersion=unknown&rnd=9640628&prog=a35a7dab-86f1-437f-b3d9-3b58ef069390&device=web&country=GB",
                                          @"https://ads.staging.superawesome.tv/v2/video/tracking?event=firstQuartile&placement=544&creative=5728&line_item=1022&sdkVersion=unknown&rnd=2560539&prog=a35a7dab-86f1-437f-b3d9-3b58ef069390&device=web&country=GB"
                                          ];
    
    XCTAssertEqual(expected_vastType, ad.type);
    XCTAssertNil(ad.redirect);
    XCTAssertNotNil(ad.events);
    XCTAssertNotNil(ad.media);
    XCTAssertEqual(expected_vastEventsSize, [ad.events count]);
    XCTAssertEqual(expected_mediaListSize, [ad.media count]);
    
    for (int i = 0; i < [ad.events count]; i++) {
        XCTAssertEqualObjects(expected_types[i], ad.events[i].event);
        XCTAssertEqualObjects(expected_urls[i], ad.events[i].URL);
    }
    
    SAVASTMedia *savastMedia = ad.media[0];
    XCTAssertNotNil(savastMedia);
    XCTAssertTrue([savastMedia isValid]);
    XCTAssertEqualObjects(expected_mediaUrl, savastMedia.url);
    XCTAssertEqual(expected_bitrate, savastMedia.bitrate);
    XCTAssertEqual(expected_width, savastMedia.width);
    XCTAssertEqual(expected_height, savastMedia.height);
}

- (void) testParseMediaXML2 {
    
    // given
    SAXMLElement *document = nil;
    
    SAVASTParser *vastParser = [[SAVASTParser alloc] init];
    XCTAssertNotNil(vastParser);
    
    NSString *tag = @"Ad";
    
    SAXMLElement *Ad = [SAXMLParser findFirstIntanceInSiblingsAndChildrenOf:document forName:tag];
    XCTAssertNil(Ad);
    
    SAVASTAd *ad = [vastParser parseAdXML:Ad];
    XCTAssertNotNil(ad);
    
    SAVASTAdType expected_vastType = SA_Invalid_VAST;
    int expected_vastEventsSize = 0;
    int expected_mediaListSize = 0;
    
    XCTAssertEqual(expected_vastType, ad.type);
    XCTAssertNil(ad.redirect);
    XCTAssertNotNil(ad.events);
    XCTAssertNotNil(ad.media);
    XCTAssertEqual(expected_vastEventsSize, [ad.events count]);
    XCTAssertEqual(expected_mediaListSize, [ad.media count]);
}

@end
