//
//  SAVAST_Parser_Async_Tests.m
//  SAVASTParser
//
//  Created by Gabriel Coman on 18/01/2017.
//  Copyright © 2017 Gabriel Coman. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SAVASTParser.h"
#import "SAVASTAd.h"
#import "SAVASTMedia.h"
#import "SATracking.h"

@interface SAVAST_Parser_Async_Tests : XCTestCase
@end

@implementation SAVAST_Parser_Async_Tests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void) testVASTTag1 {
    
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    
    SAVASTParser *parser = [[SAVASTParser alloc] init];
    XCTAssertNotNil(parser);
    
    NSString *vast = @"https://raw.githubusercontent.com/SuperAwesomeLTD/sa-mobile-lib-ios-vastparser/master/Example/Tests/Datasource/VAST1.xml";
    
    [parser parseVAST:vast withResponse:^(SAVASTAd *ad) {
        
        SAVASTAdType adType = SA_InLine_VAST;
        NSString *expected_mediaUrl = @"https://ads.superawesome.tv/v2/demo_images/video.mp4";
        int expected_vastEventsL = 15;
        NSString *expected_error = @"https://ads.superawesome.tv/v2/video/error?placement=30479&creative=-1&line_item=-1&sdkVersion=unknown&rnd=3232269&device=web&country=GB&code=[ERRORCODE]";
        NSString *expected_impression = @"https://ads.superawesome.tv/v2/video/impression?placement=30479&creative=-1&line_item=-1&sdkVersion=unknown&rnd=4538730&device=web&country=GB";
        NSString *expected_click = @"https://ads.superawesome.tv/v2/video/click?placement=30479&creative=-1&line_item=-1&sdkVersion=unknown&rnd=1809240&device=web&country=GB";

        XCTAssertNotNil(ad);
        XCTAssertEqual(ad.type, adType);
        XCTAssertNotNil(ad.url);
        XCTAssertEqualObjects(expected_mediaUrl, ad.url);
        XCTAssertNotNil(ad.events);
        XCTAssertEqual(expected_vastEventsL, [ad.events count]);
        
        SATracking *error = nil;
        SATracking *impression = nil;
        SATracking *click = nil;
        for (SATracking *tracking in ad.events) {
            if ([tracking.event containsString:@"vast_error"]) error = tracking;
            if ([tracking.event containsString:@"vast_impression"]) impression = tracking;
            if ([tracking.event containsString:@"vast_click_through"]) click = tracking;
        }
        
        XCTAssertNotNil(error);
        XCTAssertEqualObjects(expected_error, error.URL);
        XCTAssertNotNil(impression);
        XCTAssertEqualObjects(expected_impression, impression.URL);
        XCTAssertNotNil(click);
        XCTAssertEqualObjects(expected_click, click.URL);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void) testVASTTag2 {
    
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    
    SAVASTParser *parser = [[SAVASTParser alloc] init];
    XCTAssertNotNil(parser);
    
    NSString *vast = @"https://raw.githubusercontent.com/SuperAwesomeLTD/sa-mobile-lib-ios-vastparser/master/Example/Tests/Datasource/VAST2.0.xml";
    
    [parser parseVAST:vast withResponse:^(SAVASTAd *ad) {
        
        XCTAssertNotNil(ad);
        
        NSString *expected_mediaURL = @"https://ads.superawesome.tv/v2/demo_images/video.mp4";
        int expected_vastEventsL = 40;
        int expected_errorL = 2;
        int expected_impressionL = 2;
        int expected_click_throughL = 1;
        int expected_click_trackingL = 3;
        
        XCTAssertNotNil(ad.url);
        XCTAssertEqualObjects(expected_mediaURL, ad.url);
        XCTAssertNotNil(ad.events);
        XCTAssertEqual(expected_vastEventsL, [ad.events count]);
        
        NSMutableArray *errors = [@[] mutableCopy];
        NSMutableArray *impressions = [@[] mutableCopy];
        NSMutableArray *clicks_tracking = [@[] mutableCopy];
        NSMutableArray *click_through = [@[] mutableCopy];
        
        for (SATracking *tracking in ad.events) {
            if ([tracking.event containsString:@"vast_error"]) [errors addObject:tracking];
            if ([tracking.event containsString:@"vast_impression"]) [impressions addObject:tracking];
            if ([tracking.event containsString:@"vast_click_tracking"]) [clicks_tracking addObject:tracking];
            if ([tracking.event containsString:@"vast_click_through"]) [click_through addObject:tracking];
        }
        
        XCTAssertEqual(expected_errorL, [errors count]);
        XCTAssertEqual(expected_impressionL, [impressions count]);
        XCTAssertEqual(expected_click_trackingL, [clicks_tracking count]);
        XCTAssertEqual(expected_click_throughL, [click_through count]);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    
}

- (void) testVASTTag3 {
    
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    
    SAVASTParser *parser = [[SAVASTParser alloc] init];
    XCTAssertNotNil(parser);
    
    NSString *vast = @"https://raw.githubusercontent.com/SuperAwesomeLTD/sa-mobile-lib-ios-vastparser/master/Example/Tests/Datasource/VAST3.0.xml";
    
    [parser parseVAST:vast withResponse:^(SAVASTAd *ad) {
        
        int expected_vastEventsL = 21;
        
        XCTAssertNotNil(ad);
        XCTAssertNil(ad.url);
        XCTAssertNotNil(ad.events);
        XCTAssertEqual(expected_vastEventsL, [ad.events count]);
        XCTAssertNotNil(ad.redirect);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    
}

- (void) testVASTTag4 {
    
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    
    SAVASTParser *parser = [[SAVASTParser alloc] init];
    XCTAssertNotNil(parser);
    
    NSString *vast = @"https://raw.githubusercontent.com/SuperAwesomeLTD/sa-mobile-lib-ios-vastparser/master/Example/Tests/Datasource/VAST4.0.xml";
    
    [parser parseVAST:vast withResponse:^(SAVASTAd *ad) {
        
        int expected_vastEventsL = 0;
        
        XCTAssertNotNil(ad);
        XCTAssertNil(ad.url);
        XCTAssertNotNil(ad.events);
        XCTAssertEqual(expected_vastEventsL, [ad.events count]);
        XCTAssertNil(ad.redirect);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    
}

- (void) testVASTTag5 {
    
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    
    SAVASTParser *parser = [[SAVASTParser alloc] init];
    XCTAssertNotNil(parser);
    
    NSString *vast = @"jsaksa//sakask...sa";
    
    [parser parseVAST:vast withResponse:^(SAVASTAd *ad) {
        
        int expected_vastEventsL = 0;
        
        XCTAssertNotNil(ad);
        XCTAssertNil(ad.url);
        XCTAssertNotNil(ad.events);
        XCTAssertEqual(expected_vastEventsL, [ad.events count]);
        XCTAssertNil(ad.redirect);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    
}

- (void) testVASTTag6 {
    
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    
    SAVASTParser *parser = [[SAVASTParser alloc] init];
    XCTAssertNotNil(parser);
    
    NSString *vast = nil;
    
    [parser parseVAST:vast withResponse:^(SAVASTAd *ad) {
        
        int expected_vastEventsL = 0;
        
        XCTAssertNotNil(ad);
        XCTAssertNil(ad.url);
        XCTAssertNotNil(ad.events);
        XCTAssertEqual(expected_vastEventsL, [ad.events count]);
        XCTAssertNil(ad.redirect);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    
}

- (void) testVASTTag7 {
    
    __block XCTestExpectation *expectation = [self expectationWithDescription:@"High Expectations"];
    
    SAVASTParser *parser = [[SAVASTParser alloc] init];
    XCTAssertNotNil(parser);
    
    NSString *vast = @"https://raw.githubusercontent.com/SuperAwesomeLTD/sa-mobile-lib-ios-vastparser/master/Example/Tests/Datasource/VAST5.0.xml";
    
    [parser parseVAST:vast withResponse:^(SAVASTAd *ad) {
        
        XCTAssertNotNil(ad);
        
        NSString *expected_mediaURL = @"https://ads.superawesome.tv/v2/demo_images/video.mp4";
        int expected_vastEventsL = 30;
        int expected_errorL = 2;
        int expected_impressionL = 2;
        int expected_click_throughL = 0;
        int expected_click_trackingL = 4;
        
        XCTAssertNotNil(ad.url);
        XCTAssertEqualObjects(expected_mediaURL, ad.url);
        XCTAssertNotNil(ad.events);
        XCTAssertEqual(expected_vastEventsL, [ad.events count]);
        
        NSMutableArray *errors = [@[] mutableCopy];
        NSMutableArray *impressions = [@[] mutableCopy];
        NSMutableArray *clicks_tracking = [@[] mutableCopy];
        NSMutableArray *click_through = [@[] mutableCopy];
        
        for (SATracking *tracking in ad.events) {
            if ([tracking.event containsString:@"vast_error"]) [errors addObject:tracking];
            if ([tracking.event containsString:@"vast_impression"]) [impressions addObject:tracking];
            if ([tracking.event containsString:@"vast_click_tracking"]) [clicks_tracking addObject:tracking];
            if ([tracking.event containsString:@"vast_click_through"]) [click_through addObject:tracking];
        }
        
        XCTAssertEqual(expected_errorL, [errors count]);
        XCTAssertEqual(expected_impressionL, [impressions count]);
        XCTAssertEqual(expected_click_trackingL, [clicks_tracking count]);
        XCTAssertEqual(expected_click_throughL, [click_through count]);
        
        [expectation fulfill];
    }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    
}


@end
