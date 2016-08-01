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
#import "SAVASTTracking.h"
#import "SAVASTMediaFile.h"

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

// refs to ad and creative
@property (nonatomic, weak) SAVASTAd *_cAd;
@property (nonatomic, weak) SAVASTCreative *_cCreative;

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

- (void) manageWithAd:(SAVASTAd *)ad {
    
    // failure
    if (ad == nil || ad.creative == nil){
        if (_delegate && [_delegate respondsToSelector:@selector(didNotFindAds)]){
            [_delegate didNotFindAds];
        }
        return;
    }
    
    // setup current ad
    __cAd = ad;
    __cCreative = ad.creative;
    
    // and start ad
    if (_delegate && [_delegate respondsToSelector:@selector(didStartAd)]) {
        [_delegate didStartAd];
    }
    
    // play & manage
    [_playerRef reset];
    [self playCurrentAdWithCurrentCreative];
}

- (void) parseVASTURL:(NSString *)urlString {
    [_parser parseVASTURL:urlString];
}

#pragma mark <SAVASTParserProtocol>

- (void) didParseVAST:(SAVASTAd *)ad {
    [self manageWithAd:ad];
}

#pragma mark <SAVASTPlayerProtocol>

- (void) didFindPlayerReady {
    NSLog(@"[AA :: INFO] didFindPlayerReady");
    
    for (NSString *impression in __cAd.Impressions) {
        [SAEvents sendEventToURL:impression];
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
        [_delegate didEndAd];
        [_delegate didEndAllAds];
    }
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
}

- (void) didGoToURL {
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

//
// @brief: basically code that I use a lot in this class and felt the need
// to be included in a function
- (void) playCurrentAdWithCurrentCreative {
    // play the current creative
    _playerRef.delegate = self;
    if (__cCreative.isOnDisk) {
        NSString *finalDiskURL = [SAUtils filePathInDocuments:__cCreative.playableDiskURL];
        NSLog(@"Playing video from Disk %@", finalDiskURL);
        [_playerRef playWithMediaFile:finalDiskURL];
    }
    else {
        NSLog(@"Playing video from URL %@", __cCreative.playableMediaURL);
        NSURL *url = [NSURL URLWithString:__cCreative.playableMediaURL];
        [_playerRef playWithMediaURL:url];
    }
}

#pragma mark <Aux functions>

//
// @brief: again code that happened to be used a lot here, so I've packaged it
// as a function
- (void) sendCurrentCreativeTrackersFor:(NSString*)event {
    NSArray *trackers = [__cCreative.TrackingEvents filterBy:@"event" withValue:event];
    for (SAVASTTracking *tracker in trackers) {
        [SAEvents sendEventToURL:tracker.URL];
    }
}

- (void) dealloc {
    NSLog(@"SAVASTManager dealloc");
}

@end
