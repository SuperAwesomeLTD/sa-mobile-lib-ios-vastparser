//
//  SAVASTManager.m
//  Pods
//
//  Copyright (c) 2015 SuperAwesome Ltd. All rights reserved.
//
//  Created by Gabriel Coman on 12/15/2015.
//
//

// import headers
#import "SAVASTManager.h"

// import player
#import "SAVideoPlayer.h"

// import modelspace
#import "SAVASTAd.h"
#import "SAVASTCreative.h"
#import "SALinearCreative.h"
#import "SANonLinearCreative.h"
#import "SACompanionAdsCreative.h"
#import "SAImpression.h"
#import "SATracking.h"
#import "SAMediaFile.h"

// import aux headers
#import "SAUtils.h"
#import "SAExtensions.h"
#import "SAEvents.h"

//
// @brief: private interface
@interface SAVASTManager () <SAVASTParserProtocol, SAVideoPlayerProtocol>

// a strong reference to a parser
@property (nonatomic, strong) SAVASTParser *parser;

// a weak reference to a player declared somewhere - that just acts as renderer
@property (nonatomic, weak) SAVideoPlayer *playerRef;

// the queue of ads
@property (nonatomic, strong) NSArray *adQueue;
// temporary fix
@property (nonatomic, assign) NSInteger currentAdIndex;
@property (nonatomic, assign) NSInteger currentCreativeIndex;
// refs to ad and creative
@property (nonatomic, weak) SAVASTAd *_cAd;
@property (nonatomic, weak) SALinearCreative *_cCreative;

@end

//
// @brief: implementation
@implementation SAVASTManager

- (id) initWithPlayer:(SAVideoPlayer *)player {
    if (self = [super init]) {
        
        // init player ref
        _playerRef = player;
        _playerRef.delegate = self;
        
        // init parser
        _parser = [[SAVASTParser alloc] init];
        _parser.delegate = self;
    }
    
    return self;
}

- (void) parseVASTURL:(NSString *)urlString {
    [_parser parseVASTURL:urlString];
}

#pragma mark <SAVASTParserProtocol>

- (void) didParseVASTAndHasAdsResponse:(NSArray*)ads {
    // copy a ref to the ads
    _adQueue = ads;
    
    // set the playhead
    _currentAdIndex = 0;
    _currentCreativeIndex = -1;
    
    // setup current ad
    __cAd = _adQueue[_currentAdIndex];
    
    // call delegates for parse vast
    if (_delegate && [_delegate respondsToSelector:@selector(didParseVASTAndFindAds)]) {
        [_delegate didParseVASTAndFindAds];
    }
    // and start ad
    if (_delegate && [_delegate respondsToSelector:@selector(didStartAd)]) {
        [_delegate didStartAd];
    }
    
    // call the standard progress thriugh ads func
    [self progressThroughAds];
}

- (void) didNotFindAnyValidAds {
    NSLog(@"[AA :: ERROR] didNotFindAnyValidAds");
    
    // call delegate
    if (_delegate && [_delegate respondsToSelector:@selector(didParseVASTButDidNotFindAnyAds)]) {
        [_delegate didParseVASTButDidNotFindAnyAds];
    }
}

- (void) didFindInvalidVASTResponse {
    NSLog(@"[AA :: ERROR] didFindInvalidVASTResponse");
    
    // call delegate
    if (_delegate && [_delegate respondsToSelector:@selector(didNotParseVAST)]) {
        [_delegate didNotParseVAST];
    }
}

#pragma mark <SAVASTPlayerProtocol>

- (void) didFindPlayerReady {
    NSLog(@"[AA :: INFO] didFindPlayerReady");
    
    // in case this is the first creative in the Ad, and it <can play>,
    // send Ad impressions
    NSArray *impressionsToSend = [__cAd.Impressions filterBy:@"isSent" withBool:false];
    for (SAImpression *impression in impressionsToSend) {
        impression.isSent = true;
        [SAEvents sendEventToURL:impression.URL];
    }
}

- (void) didStartPlayer {
    NSLog(@"[AA :: INFO] didStartPlayer ");
    
    // send event tracker
    [self sendCurrentCreativeTrackersFor:@"start"];
    
    // also, for each creative send the creativeView event
    [self sendCurrentCreativeTrackersFor:@"creativeView"];
    
    // call delegate
    if (_delegate && [_delegate respondsToSelector:@selector(didStartCreative)]) {
        [_delegate didStartCreative];
    }
}

- (void) didReachFirstQuartile {
    NSLog(@"[AA :: INFO] didReachFirstQuartile ");
    
    // send event tracker
    [self sendCurrentCreativeTrackersFor:@"firstQuartile"];
    
    // call delegate
    if (_delegate && [_delegate respondsToSelector:@selector(didReachFirstQuartileOfCreative)]) {
        [_delegate didReachFirstQuartileOfCreative];
    }
}

- (void) didReachMidpoint {
    NSLog(@"[AA :: INFO] didReachMidpoint ");
    
    // send event tracker
    [self sendCurrentCreativeTrackersFor:@"midpoint"];
    
    // call delegate
    if(_delegate && [_delegate respondsToSelector:@selector(didReachMidpointOfCreative)]){
        [_delegate didReachMidpointOfCreative];
    }
}

- (void) didReachThirdQuartile {
    NSLog(@"[AA :: INFO] didReachThirdQuartile ");
    
    // send event tracker
    [self sendCurrentCreativeTrackersFor:@"thirdQuartile"];
    
    // call delegate
    if (_delegate && [_delegate respondsToSelector:@selector(didReachThirdQuartileOfCreative)]) {
        [_delegate didReachThirdQuartileOfCreative];
    }
}

- (void) didReachEnd {
    NSLog(@"[AA :: INFO] didReachEnd ");
    
    // send event tracker
    [self sendCurrentCreativeTrackersFor:@"complete"];
    
    // call delegate
    if (_delegate && [_delegate respondsToSelector:@selector(didEndOfCreative)]) {
        [_delegate didEndOfCreative];
    }
    
    // progress through ads
    [self progressThroughAds];
}

- (void) didPlayWithError {
    NSLog(@"[AA :: ERROR] didPlayWithError ");
    
    // if a creative is played with error, send events to the error tag
    // and advance to the next ad
    for (NSString *error in __cAd.Errors) {
        [SAEvents sendEventToURL:error];
    }
    
    // call delegate
    if (_delegate && [_delegate respondsToSelector:@selector(didHaveErrorForCreative)]) {
        [_delegate didHaveErrorForCreative];
    }
    
    // go forward
    [self progressThroughAds];
}

- (void) didGoToURL {
    // send event to URL
//    for (NSString *ctracking in __cCreative.ClickTracking) {
//        [SAEvents sendEventToURL:ctracking];
//    }
    
    // setup the current click URL
    NSString *url = @"";
    if (__cCreative.ClickThrough != NULL && [SAUtils isValidURL:__cCreative.ClickThrough]) {
        url = __cCreative.ClickThrough;
    }
    
    // call delegate
    if (_delegate && [_delegate respondsToSelector:@selector(didGoToURL:withTrackingArray:)]) {
        [_delegate didGoToURL:[NSURL URLWithString:url] withTrackingArray:__cCreative.ClickTracking];
    }
}

#pragma mark <Progress Through Ads>

- (void) progressThroughAds {
    
    // reset player
    [_playerRef reset];
    
    NSInteger creativeCount = [[_adQueue objectAtIndex:_currentAdIndex] Creatives].count;
    
    // case just get another creative from the current Ad
    if (_currentCreativeIndex < creativeCount - 1) {
        _currentCreativeIndex++;
        __cCreative = __cAd.Creatives[_currentCreativeIndex];
        
        // play the video
        [self playCurrentAdWithCurrentCreative];
    }
    else {
        // call delegate
        if (_delegate && [_delegate respondsToSelector:@selector(didEndAd)]) {
            [_delegate didEndAd];
        }
        
        // Case advance to new Ad
        if (_currentAdIndex < _adQueue.count - 1) {
            _currentCreativeIndex = 0;
            _currentAdIndex++;
            
            __cAd = _adQueue[_currentAdIndex];
            __cCreative = __cAd.Creatives[_currentCreativeIndex];
            
            // call start ad
            if (_delegate && [_delegate respondsToSelector:@selector(didStartAd)]) {
                [_delegate didStartAd];
            }
            
            // play the video
            [self playCurrentAdWithCurrentCreative];
            
        } else {
            [_playerRef destroy];
            
            // call delegate
            if (_delegate && [_delegate respondsToSelector:@selector(didEndAllAds)]) {
                [_delegate didEndAllAds];
            }
        }
    }
}

//
// @brief: basically code that I use a lot in this class and felt the need
// to be included in a function
- (void) playCurrentAdWithCurrentCreative {
    // play the current creative
    NSURL *url = [NSURL URLWithString:__cCreative.playableMediaURL];
    [_playerRef playWithMediaURL:url];
    _playerRef.delegate = self;
}

#pragma mark <Aux functions>

//
// @brief: again code that happened to be used a lot here, so I've packaged it
// as a function
- (void) sendCurrentCreativeTrackersFor:(NSString*)event {
    NSArray *trackers = [__cCreative.TrackingEvents filterBy:@"event" withValue:event];
    for (SATracking *tracker in trackers) {
        [SAEvents sendEventToURL:tracker.URL];
    }
}

- (void) dealloc {
    NSLog(@"SAVASTManager dealloc");
}

@end
